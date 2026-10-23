/*
 * FLauncher
 * Copyright (C) 2021 Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/models/watch_next_item.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:http/http.dart' as http;

class WatchNextService extends ChangeNotifier {
  final FLauncherChannel _fLauncherChannel;
  final SettingsService? _settingsService;

  List<WatchNextItem> _allRawItems = [];
  List<WatchNextItem> _items = [];
  bool _isLoading = false;
  bool _hasPermission = false;
  int _activeHeroIndex = 0;
  final Map<String, Uint8List> _posterCache = {};
  final Set<String> _loadingPosters = {};
  final Set<String> _failedPosters = {};
  Timer? _refreshTimer;
  Timer? _posterNotifyDebounce;
  static const int _maxParallelPosterLoads = 2;

  List<WatchNextItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  bool get hasItems => _items.isNotEmpty;
  bool get hasVisibleSection => !_isLoading && (!_hasPermission || _items.isNotEmpty);
  int get activeHeroIndex => _activeHeroIndex;
  WatchNextItem? get activeHeroItem =>
      _items.isNotEmpty && _activeHeroIndex < _items.length ? _items[_activeHeroIndex] : null;

  Set<String> get availablePackageNames {
    return _allRawItems
        .map((item) => item.packageName)
        .whereType<String>()
        .where((pkg) => pkg.trim().isNotEmpty)
        .toSet();
  }

  String? getPosterUriForItem(WatchNextItem? item) {
    if (item == null) return null;
    final uri = item.backdropUri ?? item.posterUri;
    if (uri != null && uri.trim().isNotEmpty && !_failedPosters.contains(uri)) {
      return uri;
    }
    return 'placeholder://${item.id}';
  }

  bool itemHasImage(WatchNextItem item) {
    final uri = item.backdropUri ?? item.posterUri;
    if (uri == null || uri.trim().isEmpty) return false;
    if (_failedPosters.contains(uri)) return false;
    return true;
  }

  void setActiveHeroIndex(int index) {
    if (_items.isEmpty) return;
    final clamped = index.clamp(0, _items.length - 1);
    if (_activeHeroIndex != clamped) {
      _activeHeroIndex = clamped;
      _ensureActiveHeroImageLoaded();
      notifyListeners();
    }
  }

  void nextHeroItem() {
    if (_items.isEmpty) return;
    final next = (_activeHeroIndex + 1) % _items.length;
    setActiveHeroIndex(next);
  }

  void prevHeroItem() {
    if (_items.isEmpty) return;
    final prev = (_activeHeroIndex - 1 + _items.length) % _items.length;
    setActiveHeroIndex(prev);
  }

  void _ensureActiveHeroImageLoaded() {
    final item = activeHeroItem;
    if (item != null) {
      final uri = getPosterUriForItem(item);
      ensurePosterLoaded(uri);
    }
  }

  WatchNextService(this._fLauncherChannel, {SettingsService? settingsService})
      : _settingsService = settingsService {
    _settingsService?.addListener(_onSettingsChanged);
    _init();
  }

  void _onSettingsChanged() {
    _applyFilterAndNotify();
  }

  void _init() async {
    await refreshPermissionAndItems();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      refreshPermissionAndItems();
    });
  }

  @override
  void dispose() {
    _settingsService?.removeListener(_onSettingsChanged);
    _refreshTimer?.cancel();
    _posterNotifyDebounce?.cancel();
    super.dispose();
  }

  Future<void> checkPermission() async {
    try {
      _hasPermission = await _fLauncherChannel.checkWatchNextPermission();
    } catch (e) {
      debugPrint('WatchNext: Error checking permission: $e');
      _hasPermission = false;
    }
    notifyListeners();
  }

  Future<void> requestPermission() async {
    try {
      await _fLauncherChannel.requestWatchNextPermission();
    } catch (e) {
      debugPrint('WatchNext: Error requesting permission: $e');
    }
  }

  Future<void> forceRefresh() async {
    _posterCache.clear();
    _failedPosters.clear();
    await refreshPermissionAndItems();
  }

  Future<void> refreshPermissionAndItems() async {
    await checkPermission();
    if (_hasPermission) {
      await refreshItems();
    } else {
      _allRawItems = [];
      _items = [];
      notifyListeners();
    }
  }

  Future<void> refreshItems() async {
    if (_isLoading) return;

    if (!_hasPermission) {
      await checkPermission();
      if (!_hasPermission) {
        _allRawItems = [];
        _items = [];
        notifyListeners();
        return;
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final results = await _fLauncherChannel.getWatchNextItems();
      _allRawItems = results.map((map) => WatchNextItem.fromMap(map)).toList();
      _applyFilterAndNotify();
      unawaited(_preloadInitialPosters());
    } catch (e) {
      debugPrint('WatchNext: Error loading items: $e');
      _allRawItems = [];
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilterAndNotify() {
    final excluded = _settingsService?.watchNextExcludedPackages ?? const [];
    final hideWithoutImages = _settingsService?.watchNextHideProgramsWithoutImages ?? false;
    final maxItems = _settingsService?.watchNextMaxItems ?? 0;
    Iterable<WatchNextItem> filtered = _allRawItems.where((item) {
      final pkg = item.packageName;
      if (pkg != null && excluded.contains(pkg)) {
        return false;
      }
      if (hideWithoutImages && !itemHasImage(item)) {
        return false;
      }
      return true;
    });

    if (maxItems > 0) {
      filtered = filtered.take(maxItems);
    }
    _items = filtered.toList();

    if (_activeHeroIndex >= _items.length) {
      _activeHeroIndex = 0;
    }
    _ensureActiveHeroImageLoaded();
    notifyListeners();
  }

  Future<void> _preloadInitialPosters() async {
    final pendingUris = _items
        .map((item) => getPosterUriForItem(item))
        .whereType<String>()
        .where((uri) => !_posterCache.containsKey(uri))
        .toSet()
        .toList(growable: false);

    if (pendingUris.isEmpty) {
      return;
    }

    int nextIndex = 0;
    Future<void> worker() async {
      while (nextIndex < pendingUris.length) {
        final uri = pendingUris[nextIndex++];
        if (uri.startsWith('placeholder://')) {
          final id = int.tryParse(uri.replaceFirst('placeholder://', ''));
          WatchNextItem? found;
          for (final it in _items) {
            if (it.id == id) {
              found = it;
              break;
            }
          }
          if (found != null) {
            _loadPlaceholderForItem(found);
          }
        } else {
          await _loadPosterImage(uri);
        }
      }
    }

    final workers = List.generate(
      _maxParallelPosterLoads,
      (_) => worker(),
    );
    await Future.wait(workers);
  }

  void ensurePosterLoaded(String? uri) {
    if (uri == null || _posterCache.containsKey(uri) || _failedPosters.contains(uri) || _loadingPosters.contains(uri)) {
      return;
    }
    if (uri.startsWith('placeholder://')) {
      final id = int.tryParse(uri.replaceFirst('placeholder://', ''));
      WatchNextItem? found;
      for (final it in _items) {
        if (it.id == id) {
          found = it;
          break;
        }
      }
      if (found != null) {
        _loadPlaceholderForItem(found);
      }
      return;
    }
    unawaited(_loadPosterImage(uri));
  }

  Future<void> _loadPosterImage(String uri) async {
    if (_posterCache.containsKey(uri) || _loadingPosters.contains(uri)) {
      return;
    }
    _loadingPosters.add(uri);
    try {
      Uint8List? imageBytes;

      if (uri.startsWith('content://')) {
        imageBytes = await _fLauncherChannel.loadContentUriImage(uri);
      } else {
        final uriObj = Uri.parse(uri);
        final response = await http.get(uriObj).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
        }
      }

      if (imageBytes != null && imageBytes.isNotEmpty) {
        _posterCache[uri] = imageBytes;
        _failedPosters.remove(uri);
        _schedulePosterCacheNotification();
      } else {
        _failedPosters.add(uri);
        if (_settingsService?.watchNextHideProgramsWithoutImages ?? false) {
          _applyFilterAndNotify();
        } else {
          _triggerPlaceholderForUri(uri);
          _schedulePosterCacheNotification();
        }
      }
    } catch (_) {
      _failedPosters.add(uri);
      if (_settingsService?.watchNextHideProgramsWithoutImages ?? false) {
        _applyFilterAndNotify();
      } else {
        _triggerPlaceholderForUri(uri);
        _schedulePosterCacheNotification();
      }
    } finally {
      _loadingPosters.remove(uri);
    }
  }

  void _triggerPlaceholderForUri(String uri) {
    for (final item in _items) {
      if ((item.backdropUri ?? item.posterUri) == uri) {
        _loadPlaceholderForItem(item);
      }
    }
  }

  void _loadPlaceholderForItem(WatchNextItem item) {
    final key = 'placeholder://${item.id}';
    if (_posterCache.containsKey(key) || _loadingPosters.contains(key)) return;
    _loadingPosters.add(key);
    unawaited(() async {
      try {
        final bytes = await _generatePlaceholder(item);
        if (bytes != null && bytes.isNotEmpty) {
          _posterCache[key] = bytes;
          _schedulePosterCacheNotification();
        }
      } catch (e) {
        debugPrint('WatchNext: Error generating placeholder: $e');
      } finally {
        _loadingPosters.remove(key);
      }
    }());
  }

  Future<Uint8List?> _generatePlaceholder(WatchNextItem item) async {
    const width = 640.0;
    const height = 360.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));

    // Background gradient (rich cinematic dark palette)
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(width, height),
        const [
          Color(0xFF1E2433),
          Color(0xFF0F121A),
        ],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Subtle radial glow in upper center
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(width / 2, height * 0.38),
        width * 0.45,
        const [
          Color(0x24FFFFFF),
          Color(0x00000000),
        ],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), glowPaint);

    // Fetch and draw app icon if available
    bool drewIcon = false;
    if (item.packageName != null && item.packageName!.isNotEmpty) {
      try {
        final iconBytes = await _fLauncherChannel.getApplicationIcon(item.packageName!);
        if (iconBytes.isNotEmpty) {
          final codec = await ui.instantiateImageCodec(iconBytes);
          final frame = await codec.getNextFrame();
          final iconImage = frame.image;

          const iconSize = 76.0;
          const iconLeft = (width - iconSize) / 2;
          const iconTop = 72.0;
          final iconRect = Rect.fromLTWH(iconLeft, iconTop, iconSize, iconSize);

          final shadowPaint = Paint()
            ..color = const Color(0x66000000)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
          canvas.drawRRect(
            RRect.fromRectAndRadius(iconRect.shift(const Offset(0, 4)), const Radius.circular(18)),
            shadowPaint,
          );

          canvas.save();
          canvas.clipRRect(RRect.fromRectAndRadius(iconRect, const Radius.circular(16)));
          canvas.drawImageRect(
            iconImage,
            Rect.fromLTWH(0, 0, iconImage.width.toDouble(), iconImage.height.toDouble()),
            iconRect,
            Paint()..filterQuality = FilterQuality.medium,
          );
          canvas.restore();
          drewIcon = true;
        }
      } catch (_) {}
    }

    if (!drewIcon) {
      final iconPaint = Paint()
        ..color = const Color(0x55FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(const Offset(width / 2, 110), 34, iconPaint);

      final path = Path()
        ..moveTo(width / 2 - 9, 97)
        ..lineTo(width / 2 + 15, 110)
        ..lineTo(width / 2 - 9, 123)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0x55FFFFFF));
    }

    // Program title
    final titleSpan = TextSpan(
      text: item.title,
      style: const TextStyle(
        color: Color(0xEEFFFFFF),
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    );
    final titlePainter = TextPainter(
      text: titleSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: width - 80);

    final titleX = (width - titlePainter.width) / 2;
    const titleY = 175.0;
    titlePainter.paint(canvas, Offset(titleX, titleY));

    // Program description
    if (item.description != null && item.description!.trim().isNotEmpty) {
      final descSpan = TextSpan(
        text: item.description!.trim(),
        style: const TextStyle(
          color: Color(0x88FFFFFF),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      );
      final descPainter = TextPainter(
        text: descSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: width - 100);

      final descX = (width - descPainter.width) / 2;
      final descY = titleY + titlePainter.height + 8;
      descPainter.paint(canvas, Offset(descX, descY));
    }

    // Subtle edge border
    final borderPaint = Paint()
      ..color = const Color(0x18FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(const Rect.fromLTWH(0.5, 0.5, width - 1, height - 1), borderPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  void _schedulePosterCacheNotification() {
    if (_posterNotifyDebounce?.isActive ?? false) {
      return;
    }
    _posterNotifyDebounce = Timer(const Duration(milliseconds: 80), notifyListeners);
  }

  Uint8List? getCachedPoster(String? uri) {
    if (uri == null) return null;
    return _posterCache[uri];
  }

  bool hasPosterLoadFailed(String? uri) {
    if (uri == null) return false;
    return _failedPosters.contains(uri);
  }

  Future<void> launchItem(WatchNextItem item) async {
    debugPrint('WatchNext: Launching item: ${item.title}');
    debugPrint('WatchNext: packageName=${item.packageName}, contentId=${item.contentId}, intentUri=${item.intentUri}');

    if (item.packageName == null && item.intentUri == null) {
      debugPrint('WatchNext: Cannot launch - no package name or intent URI');
      return;
    }

    await _fLauncherChannel.launchWatchNextItem(
      item.packageName,
      item.contentId,
      item.intentUri,
    );
  }
}

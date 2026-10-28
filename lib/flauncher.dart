/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flauncher/actions.dart';
import 'package:flauncher/custom_traversal_policy.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/launcher_state.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/widgets/app_card.dart';
import 'package:flauncher/widgets/cached_blur_backdrop.dart';
import 'package:flauncher/widgets/category_clean_row.dart';
import 'package:flauncher/widgets/category_row.dart';
import 'package:flauncher/widgets/dock_contour_painter.dart';
import 'package:flauncher/widgets/launcher_alternative_view.dart';
import 'package:flauncher/widgets/focus_aware_app_bar.dart';
import 'package:flauncher/widgets/wallpaper_video_background.dart';
import 'package:flauncher/widgets/watch_next_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/l10n/app_localizations.dart';

import 'models/app.dart';
import 'models/category.dart';

const _kDockOuterPadding = EdgeInsets.only(
  left: kLauncherSectionHorizontalPadding,
  right: kLauncherSectionHorizontalPadding,
  top: 10,
  bottom: 16,
);

class FLauncher extends StatefulWidget {
  const FLauncher({super.key});

  @override
  State<FLauncher> createState() => _FLauncherState();
}

class _FLauncherState extends State<FLauncher> with WidgetsBindingObserver {
  final GlobalKey<FocusAwareAppBarState> _appBarKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _dockKey = GlobalKey();
  late final _HeroBackdropBaker _heroBackdropBaker = _HeroBackdropBaker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _heroBackdropBaker.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<WatchNextService>().refreshPermissionAndItems();
    }
  }

  @override
  Widget build(BuildContext context) => Actions(
    actions: <Type, Action<Intent>>{
      MoveFocusToSettingsIntent: CallbackAction<MoveFocusToSettingsIntent>(
        onInvoke: (_) => _appBarKey.currentState?.focusSettings(),
      ),
    },
    child: FocusTraversalGroup(
      policy: RowByRowTraversalPolicy(),
      child: Stack(
        children: [
          RepaintBoundary(
            child: Consumer3<WallpaperService, SettingsService, WatchNextService>(
              builder: (_, wallpaperService, settingsService, watchNextService, __) {
                final author = wallpaperService.slideshowAuthor;
                final redditCredit = wallpaperService.redditWallpaperCredit;
                final isBigPicture = settingsService.showWatchNextSection && settingsService.watchNextBigPictureMode;
                final activeItem = isBigPicture ? watchNextService.activeHeroItem : null;
                final heroUri = isBigPicture ? watchNextService.getPosterUriForItem(activeItem) : null;
                final heroBytes = isBigPicture ? watchNextService.getCachedPoster(heroUri) : null;
                final hasHeroBackdrop = isBigPicture && heroBytes != null;
                final screenSize = MediaQuery.sizeOf(context);
                final dpr = MediaQuery.devicePixelRatioOf(context);
                _heroBackdropBaker.update(
                  bytes: hasHeroBackdrop ? heroBytes : null,
                  size: screenSize,
                  dpr: dpr,
                );
                return Stack(
                  children: [
                    // Crossfade between wallpapers (each one has a revision-based key).
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 1500),
                      child: hasHeroBackdrop
                          ? const SizedBox.shrink(key: ValueKey('occluded_wallpaper'))
                          : _wallpaper(context, wallpaperService),
                    ),
                    // Hero items crossfade once baked simultaneously with dock blur.
                    AnimatedSwitcher(
                      duration: _kHeroFadeDuration,
                      child: hasHeroBackdrop
                          ? RepaintBoundary(
                              key: const ValueKey('hero_bg'),
                              child: ListenableBuilder(
                                listenable: _heroBackdropBaker,
                                builder: (context, _) {
                                  final heroImage = _heroBackdropBaker.textures?.hero;
                                  return AnimatedSwitcher(
                                    duration: _kHeroFadeDuration,
                                    switchInCurve: Curves.easeOutCubic,
                                    switchOutCurve: Curves.easeInCubic,
                                    child: heroImage == null
                                        ? const SizedBox.expand(key: ValueKey('empty_hero'))
                                        : RawImage(
                                            key: ObjectKey(heroImage),
                                            image: heroImage,
                                            width: screenSize.width,
                                            height: screenSize.height,
                                            fit: BoxFit.fill,
                                          ),
                                  );
                                },
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('no_hero_bg')),
                    ),
                    if (redditCredit != null && !hasHeroBackdrop)
                      Positioned(
                        right: 24,
                        top: 64,
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            redditCredit,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              shadows: const [Shadow(blurRadius: 4)],
                            ),
                          ),
                        ),
                      )
                    else if (author != null && !hasHeroBackdrop)
                      Positioned(
                        right: 24,
                        top: 64,
                        // Material gives the text the app font instead of the debug fallback style.
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            AppLocalizations.of(context)!.unsplashPhotoCredit(author),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              shadows: const [Shadow(blurRadius: 4)],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Selector3<LauncherState, SettingsService, WallpaperService, (bool, bool, bool)>(
            selector: (_, launcherState, settings, wallpaperService) => (
              launcherState.appGridFocused,
              settings.backgroundBlurDisabled,
              wallpaperService.wallpaperVideoFile != null,
            ),
            builder: (_, data, __) {
              final (appGridFocused, blurDisabled, hasVideoWallpaper) = data;
              return ListenableBuilder(
                listenable: _heroBackdropBaker,
                builder: (context, _) {
                  final gridBlur = _heroBackdropBaker.textures?.gridBlur;
                  if (blurDisabled || (hasVideoWallpaper && gridBlur == null)) {
                    return const SizedBox.shrink();
                  }
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: appGridFocused && !blurDisabled ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: CachedBlurLayer(
                          sigma: 10,
                          prebakedBlur: gridBlur,
                          hidden: !appGridFocused || blurDisabled,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Consumer<LauncherState>(
            builder:
                (_, state, child) => Visibility(
                  replacement: const Center(child: AlternativeLauncherView()),
                  visible: state.launcherVisible,
                  child: child!,
                ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: FocusAwareAppBar(key: _appBarKey),
              // (initialized (data.$1), layoutVersion (data.$2), showAppNamesBelowIcons (data.$3))
              body: Selector2<AppsService, SettingsService, (bool, int, bool)>(
                selector: (_, appsService, settingsService) =>
                    (appsService.initialized, appsService.layoutVersion, settingsService.showAppNamesBelowIcons),
                builder: (context, data, _) {
                  if (data.$1) {
                    return _tvOSLayout(context, context.read<AppsService>(), showAppNames: data.$3);
                  } else {
                    return _emptyState(context);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _setAppGridFocused(bool focused) {
    context.read<LauncherState>().setAppGridFocused(focused);
  }

  void _onAppGridFocused({VoidCallback? onFirstSectionFocused}) {
    _setAppGridFocused(true);
    onFirstSectionFocused?.call();
  }

  void _onHomeSectionFocused() {
    _setAppGridFocused(false);
  }

  Widget _tvOSLayout(BuildContext context, AppsService appsService, {required bool showAppNames}) {
    final favoritesCategory = appsService.categories.firstWhereOrNull((c) => c.name == 'Favorites');
    final favoriteApps = favoritesCategory?.applications ?? const [];

    final otherSections =
        appsService.launcherSections.where((section) {
          if (section is Category && section.name == 'Favorites') return false;
          return true;
        }).toList();

    final showWatchNextSection = context.select<SettingsService, bool>((s) => s.showWatchNextSection);
    final watchNextBigPicture = context.select<SettingsService, bool>((s) => s.watchNextBigPictureMode);
    final watchNextVisible = context.select<WatchNextService, bool>((s) => s.hasVisibleSection);
    final reserveWatchNextSpace = showWatchNextSection && watchNextVisible;

    if (favoriteApps.isEmpty && otherSections.isEmpty) return _emptyState(context);

    final watchNextSpace = watchNextBigPicture ? 385 : 410;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        if (favoriteApps.isNotEmpty || showWatchNextSection) ...[
          SliverToBoxAdapter(
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  (reserveWatchNextSpace ? watchNextSpace : 150),
            ),
          ),
          if (showWatchNextSection)
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: WatchNextRow(
                  isFirstSection: false,
                  isAboveDock: true,
                  onItemFocused: _onHomeSectionFocused,
                ),
              ),
            ),
          if (favoriteApps.isNotEmpty)
            SliverToBoxAdapter(
              child: KeyedSubtree(
                key: _dockKey,
                child: Padding(
                  padding: _kDockOuterPadding,
                  child: _dock(
                    context,
                    favoritesCategory!,
                    favoriteApps,
                    appsService,
                    handleUpNavigationToSettings: !reserveWatchNextSpace,
                  ),
                ),
              ),
            ),
        ],
        ..._buildSectionSlivers(
          otherSections,
          firstCategoryAlreadyFound: favoriteApps.isNotEmpty,
          showAppNames: showAppNames,
          onFirstSectionFocused: favoriteApps.isNotEmpty ? _scrollDockToTop : null,
        ),
        SliverToBoxAdapter(child: SizedBox(height: _bottomScrollPadding(context, hasDock: favoriteApps.isNotEmpty))),
      ],
    );
  }

  double _bottomScrollPadding(BuildContext context, {required bool hasDock}) {
    if (!hasDock) {
      return 64;
    }
    return MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - kToolbarHeight;
  }

  List<Widget> _buildSectionSlivers(
    List<LauncherSection> sections, {
    bool firstCategoryAlreadyFound = false,
    required bool showAppNames,
    VoidCallback? onFirstSectionFocused,
  }) {
    final List<Widget> slivers = [];
    bool firstCategoryFound = firstCategoryAlreadyFound;
    bool firstBuiltSectionFound = false;

    for (final section in sections) {
      final Key sectionKey = Key(section.id.toString());

      if (section is LauncherSpacer) {
        slivers.add(SliverToBoxAdapter(key: sectionKey, child: SizedBox(height: section.height.toDouble())));
        continue;
      }

      final category = section as Category;
      final filteredApps = category.applications;
      if (filteredApps.isEmpty) continue;

      final bool isFirstSection = !firstCategoryFound;
      if (isFirstSection) firstCategoryFound = true;
      final onAppFocused = !firstBuiltSectionFound
          ? () => _onAppGridFocused(onFirstSectionFocused: onFirstSectionFocused)
          : () => _onAppGridFocused();
      firstBuiltSectionFound = true;

      slivers.add(
        SliverToBoxAdapter(
          child: Selector<SettingsService, bool>(
            selector: (context, service) => service.showCategoryTitles,
            builder: (context, showTitle, _) {
              if (showTitle) {
                return Padding(
                  padding: const EdgeInsets.only(left: 40, bottom: 8, top: 8),
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      shadows: const [Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 8)],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      switch (category.type) {
        case CategoryType.row:
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: kLauncherSectionHorizontalPadding,
                  right: kLauncherSectionHorizontalPadding,
                  bottom: 8,
                ),
                child: CategoryRow(
                  key: sectionKey,
                  category: category,
                  applications: filteredApps,
                  isFirstSection: isFirstSection,
                  showTitle: false,
                  onAppFocused: onAppFocused,
                ),
              ),
            ),
          );
          break;
        case CategoryType.grid:
          final gridContentWidth = MediaQuery.sizeOf(context).width - 2 * kLauncherSectionHorizontalPadding;
          final gridAspectRatio = showAppNames
              ? appCardGridAspectRatio(gridContentWidth, category.columnsCount)
              : kAppCardAspectRatio;
          slivers.add(
            SliverPadding(
              padding: const EdgeInsets.only(
                left: kLauncherSectionHorizontalPadding,
                right: kLauncherSectionHorizontalPadding,
                bottom: 8,
              ),
              sliver: SliverGrid(
                key: sectionKey,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: category.columnsCount,
                  childAspectRatio: gridAspectRatio,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 0,
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: filteredApps.length,
                  findChildIndexCallback: (Key key) {
                    final valueKey = key as ValueKey<String>;
                    final index = filteredApps.indexWhere((app) => app.packageName == valueKey.value);
                    return index >= 0 ? index : null;
                  },
                  (context, index) => Padding(
                    key: Key(filteredApps[index].packageName),
                    padding: const EdgeInsets.symmetric(
                      horizontal: kAppCardHorizontalPadding,
                      vertical: kAppCardVerticalPadding,
                    ),
                    child: AppCard(
                      category: category,
                      application: filteredApps[index],
                      autofocus: index == 0,
                      handleUpNavigationToSettings: isFirstSection && index < category.columnsCount,
                      enforceAspectRatio: false,
                      onFocused: index < category.columnsCount ? onAppFocused : null,
                      ensureVisibleOnFocus: onAppFocused == null || index >= category.columnsCount,
                      onlyScrollWhenNearBottom: true,
                      onMove: (direction) => _onGridMove(context, category, index, direction, filteredApps),
                      onMoveEnd: () => context.read<AppsService>().saveApplicationOrderInCategory(category),
                    ),
                  ),
                ),
              ),
            ),
          );
          break;
      }
    }

    return slivers;
  }

  Future<void> _scrollDockToTop() async {
    final targetOffset = _dockTopScrollOffset();
    if (targetOffset == null) {
      return;
    }

    final position = _scrollController.position;
    if ((targetOffset - position.pixels).abs() < 16) {
      return;
    }

    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
    );
  }

  double? _dockTopScrollOffset() {
    final dockContext = _dockKey.currentContext;
    final renderObject = dockContext?.findRenderObject();
    if (!_scrollController.hasClients || renderObject == null) {
      return null;
    }

    final viewport = RenderAbstractViewport.of(renderObject);
    final position = _scrollController.position;
    return viewport.getOffsetToReveal(renderObject, 0).offset.clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  // TO DO : refractor duplicate _onMove code
  void _onGridMove(
    BuildContext context,
    Category category,
    int index,
    AxisDirection direction,
    List<App> filteredApps,
  ) {
    final currentRow = (index / category.columnsCount).floor();
    final totalRows = ((filteredApps.length - 1) / category.columnsCount).floor();

    int? newIndex;
    switch (direction) {
      case AxisDirection.up:
        if (currentRow > 0) newIndex = index - category.columnsCount;
        break;
      case AxisDirection.right:
        if (index < filteredApps.length - 1) newIndex = index + 1;
        break;
      case AxisDirection.down:
        if (currentRow < totalRows) newIndex = min(index + category.columnsCount, filteredApps.length - 1);
        break;
      case AxisDirection.left:
        if (index > 0) newIndex = index - 1;
        break;
    }

    if (newIndex != null) {
      final appsService = context.read<AppsService>();
      final movingApp = filteredApps[index];
      final realOldIndex = category.applications.indexOf(movingApp);
      final realNewIndex = category.applications.indexOf(filteredApps[newIndex]);
      if (realOldIndex >= 0 && realNewIndex >= 0) {
        appsService.reorderApplication(category, realOldIndex, realNewIndex);
        appsService.setPendingReorderFocus(movingApp.packageName, category.id);
      }
    }
  }

  Widget _dock(
    BuildContext context,
    Category category,
    List<App> apps,
    AppsService appsService, {
    required bool handleUpNavigationToSettings,
  }) {
    final backdropDisabled = context.select<SettingsService, bool>((s) => s.dockBackdropFilterDisabled);
    final darkBackground = context.select<SettingsService, bool>((s) => s.dockDarkBackground);
    final shadowEnabled = context.select<SettingsService, bool>((s) => s.dockShadowEnabled);
    final isBigPicture = context.select<SettingsService, bool>((s) => s.showWatchNextSection && s.watchNextBigPictureMode);

    const dockBorderRadius = 24.0;
    final borderRadius = BorderRadius.circular(dockBorderRadius);

    final content = CustomPaint(
      foregroundPainter: const DockContourPainter(radius: dockBorderRadius, strokeWidth: 1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: darkBackground
              ? Colors.black.withValues(alpha: 0.35)
              : (isBigPicture ? Colors.white.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.1)),
          borderRadius: borderRadius,
        ),
        child: CategoryCleanRow(
          category: category,
          applications: apps,
          isFirstSection: handleUpNavigationToSettings,
          scrollAlignment: 1.0,
          onAppFocused: _onHomeSectionFocused,
        ),
      ),
    );

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: shadowEnabled
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2)]
              : null,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: backdropDisabled
              ? content
              : ListenableBuilder(
                  listenable: _heroBackdropBaker,
                  child: content,
                  builder: (_, child) {
                    final dockBlur = _heroBackdropBaker.textures?.dockBlur;
                    return CachedBlurBackdrop(
                      sigma: 5,
                      prebakedBlur: dockBlur,
                      child: child!,
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _wallpaper(BuildContext context, WallpaperService wallpaperService) {
    final screenSize = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final videoFile = wallpaperService.wallpaperVideoFile;
    if (videoFile != null) {
      return SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: WallpaperVideoBackground(
          key: ValueKey("background_video_${wallpaperService.wallpaperRevision}"),
          file: videoFile,
        ),
      );
    }
    if (wallpaperService.wallpaper != null) {
      return Image(
        image: ResizeImage(wallpaperService.wallpaper!, height: (screenSize.height * dpr).round()),
        key: ValueKey("background_${wallpaperService.wallpaperRevision}"),
        fit: BoxFit.cover,
        height: screenSize.height,
        width: screenSize.width,
      );
    } else {
      return _CachedGradientBackground(key: const Key("background"), gradient: wallpaperService.gradient.gradient);
    }
  }

  Widget _emptyState(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(localizations.loading, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

/// Renders a [Gradient] once into a rasterized [ui.Image] and blits it as a
/// texture instead of evaluating the gradient shader every frame.
///
/// On low-end GPUs (e.g. Android TV sticks) a full-screen live gradient is
/// noticeably more expensive to raster than a cached texture, so this keeps the
/// background as cheap as a static image wallpaper.
class _CachedGradientBackground extends StatefulWidget {
  final Gradient gradient;

  const _CachedGradientBackground({super.key, required this.gradient});

  @override
  State<_CachedGradientBackground> createState() => _CachedGradientBackgroundState();
}

class _CachedGradientBackgroundState extends State<_CachedGradientBackground> {
  ui.Image? _image;
  Size _renderedSize = Size.zero;
  Gradient? _renderedGradient;
  bool _rendering = false;

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  Future<void> _render(Size size) async {
    if (_rendering) {
      return;
    }
    _rendering = true;
    final recorder = ui.PictureRecorder();
    final rect = Offset.zero & size;
    Canvas(recorder).drawRect(rect, Paint()..shader = widget.gradient.createShader(rect));
    final picture = recorder.endRecording();
    final image = picture.toImageSync(size.width.round(), size.height.round());
    picture.dispose();
    _rendering = false;
    if (!mounted) {
      image.dispose();
      return;
    }
    setState(() {
      _image?.dispose();
      _image = image;
      _renderedSize = size;
      _renderedGradient = widget.gradient;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final needsRender = size != _renderedSize || widget.gradient != _renderedGradient;
        if (needsRender && size.width > 0 && size.height > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && (size != _renderedSize || widget.gradient != _renderedGradient)) {
              _render(size);
            }
          });
        }
        final image = _image;
        if (image != null && !needsRender) {
          return RawImage(image: image, width: size.width, height: size.height, fit: BoxFit.fill);
        }
        // First frame (and while re-rendering): paint the gradient live once to avoid a flash.
        return DecoratedBox(decoration: BoxDecoration(gradient: widget.gradient));
      },
    );
  }
}

const _kHeroFadeDuration = Duration(milliseconds: 600);

class _HeroBackdropTextures {
  final ui.Image hero;
  final ui.Image dockBlur;
  final ui.Image gridBlur;
  final Uint8List bytes;
  bool _disposed = false;

  _HeroBackdropTextures({
    required this.hero,
    required this.dockBlur,
    required this.gridBlur,
    required this.bytes,
  });

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    hero.dispose();
    dockBlur.dispose();
    gridBlur.dispose();
  }
}

class _HeroBackdropBaker extends ChangeNotifier {
  _HeroBackdropTextures? _current;
  final List<_HeroBackdropTextures> _disposedTextures = [];
  Uint8List? _requestedBytes;
  Size _requestedSize = Size.zero;
  double _requestedDpr = 1.0;
  Size _currentSize = Size.zero;
  double _currentDpr = 1.0;
  bool _baking = false;

  _HeroBackdropTextures? get textures => _current;

  void update({required Uint8List? bytes, required Size size, required double dpr}) {
    if (identical(bytes, _requestedBytes) && size == _requestedSize && dpr == _requestedDpr) {
      return;
    }
    _requestedBytes = bytes;
    _requestedSize = size;
    _requestedDpr = dpr;

    if (bytes == null || size.width <= 0 || size.height <= 0) {
      if (_current != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_requestedBytes == null && _current != null) {
            _scheduleDispose(_current!);
            _current = null;
            notifyListeners();
          }
        });
      }
      return;
    }

    if (!_baking) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_baking && _requestedBytes != null) {
          _bake();
        }
      });
    }
  }

  void _scheduleDispose(_HeroBackdropTextures textures) {
    _disposedTextures.add(textures);
    Timer(const Duration(milliseconds: 1000), () {
      _disposedTextures.remove(textures);
      textures.dispose();
    });
  }

  Future<void> _bake() async {
    if (_baking) return;
    _baking = true;
    try {
      while (_requestedBytes != null &&
          (_current == null ||
              !identical(_requestedBytes, _current!.bytes) ||
              _requestedSize != _currentSize ||
              _requestedDpr != _currentDpr)) {
        final bytes = _requestedBytes!;
        final size = _requestedSize;
        final dpr = _requestedDpr;

        final pxSize = Size((size.width * dpr).roundToDouble(), (size.height * dpr).roundToDouble());
        final codec = await ui.instantiateImageCodecWithSize(
          await ui.ImmutableBuffer.fromUint8List(bytes),
          getTargetSize: (w, h) {
            final scale = min(1.0, max(pxSize.width / w, pxSize.height / h));
            return ui.TargetImageSize(width: (w * scale).round(), height: (h * scale).round());
          },
        );
        final source = (await codec.getNextFrame()).image;
        codec.dispose();

        if (!identical(bytes, _requestedBytes)) {
          source.dispose();
          continue;
        }

        // 1. Full-screen hero background with cinematic scrim
        final heroRecorder = ui.PictureRecorder();
        final heroCanvas = Canvas(heroRecorder);
        paintImage(canvas: heroCanvas, rect: Offset.zero & pxSize, image: source, fit: BoxFit.cover);
        const _CinematicScrimPainter().paint(heroCanvas, pxSize);
        final heroPicture = heroRecorder.endRecording();
        final heroImage = heroPicture.toImageSync(pxSize.width.toInt(), pxSize.height.toInt());
        heroPicture.dispose();

        // 2. Dock blur snapshot (960x540, sigma 5)
        final double targetWidth = min(size.width * dpr, 960.0);
        final double targetHeight = min(size.height * dpr, 540.0);
        final pxWidth = targetWidth.round();
        final pxHeight = targetHeight.round();
        final blurRect = Rect.fromLTWH(0, 0, pxWidth.toDouble(), pxHeight.toDouble());
        final double scaleFactor = pxWidth / size.width;

        final dockRecorder = ui.PictureRecorder();
        final dockCanvas = Canvas(dockRecorder);
        final dockPaint = Paint()
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: 5.0 * scaleFactor,
            sigmaY: 5.0 * scaleFactor,
            tileMode: TileMode.clamp,
          );
        dockCanvas.saveLayer(blurRect, dockPaint);
        paintImage(canvas: dockCanvas, rect: blurRect, image: source, fit: BoxFit.cover, filterQuality: FilterQuality.low);
        dockCanvas.restore();
        final dockPicture = dockRecorder.endRecording();
        final dockImage = dockPicture.toImageSync(pxWidth, pxHeight);
        dockPicture.dispose();

        // 3. App grid blur snapshot (960x540, sigma 10)
        final gridRecorder = ui.PictureRecorder();
        final gridCanvas = Canvas(gridRecorder);
        final gridPaint = Paint()
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: 10.0 * scaleFactor,
            sigmaY: 10.0 * scaleFactor,
            tileMode: TileMode.clamp,
          );
        gridCanvas.saveLayer(blurRect, gridPaint);
        paintImage(canvas: gridCanvas, rect: blurRect, image: source, fit: BoxFit.cover, filterQuality: FilterQuality.low);
        gridCanvas.restore();
        final gridPicture = gridRecorder.endRecording();
        final gridImage = gridPicture.toImageSync(pxWidth, pxHeight);
        gridPicture.dispose();

        source.dispose();

        if (!identical(bytes, _requestedBytes)) {
          heroImage.dispose();
          dockImage.dispose();
          gridImage.dispose();
          continue;
        }

        final old = _current;
        _current = _HeroBackdropTextures(
          hero: heroImage,
          dockBlur: dockImage,
          gridBlur: gridImage,
          bytes: bytes,
        );
        _currentSize = size;
        _currentDpr = dpr;

        if (old != null) {
          _scheduleDispose(old);
        }

        notifyListeners();
      }
    } finally {
      _baking = false;
    }
  }

  @override
  void dispose() {
    for (final t in _disposedTextures) {
      t.dispose();
    }
    _disposedTextures.clear();
    _current?.dispose();
    _current = null;
    super.dispose();
  }
}

class _CinematicScrimPainter extends CustomPainter {
  const _CinematicScrimPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Top-to-bottom cinematic scrim
    final vPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        const [
          Color(0x59000000), // 0.35
          Colors.transparent,
          Color(0x80000000), // 0.50
          Color(0xE0000000), // 0.88
        ],
        const [0.0, 0.25, 0.65, 1.0],
      );
    canvas.drawRect(rect, vPaint);

    // Left-to-right cinematic scrim
    final hPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        const [
          Color(0xA6000000), // 0.65
          Color(0x40000000), // 0.25
          Colors.transparent,
        ],
        const [0.0, 0.35, 0.7],
      );
    canvas.drawRect(rect, hPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


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

import 'package:flauncher/actions.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/models/watch_next_item.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void _playFocusSound(BuildContext context) {
  final settingsService = context.read<SettingsService>();
  if (settingsService.appKeyClickEnabled) {
    Feedback.forTap(context);
  } else {
    context.findRenderObject()?.sendSemanticsEvent(const TapSemanticEvent());
  }
}

const double _kWatchNextHeroHorizontalPadding = kLauncherSectionHorizontalPadding + kAppCardHorizontalPadding;

class WatchNextHero extends StatelessWidget {
  final List<WatchNextItem> items;
  final bool isFirstSection;
  final bool handleUpNavigationToSettings;
  final VoidCallback? onItemFocused;

  const WatchNextHero({
    super.key,
    required this.items,
    this.isFirstSection = false,
    this.handleUpNavigationToSettings = false,
    this.onItemFocused,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final watchNextService = context.watch<WatchNextService>();
    final activeItem = watchNextService.activeHeroItem ?? items.first;
    final activeIndex = watchNextService.activeHeroIndex.clamp(0, items.length - 1);

    final appsService = context.watch<AppsService>();
    final app = activeItem.packageName != null ? appsService.getApplication(activeItem.packageName) : null;
    final appName = app?.name;
    final localizations = AppLocalizations.of(context)!;
    final sourceBadge = appName != null
        ? '${localizations.watchNextSectionTitle.toUpperCase()} • ${appName.toUpperCase()}'
        : localizations.watchNextSectionTitle.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kWatchNextHeroHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _HeroInfo(
            sourceBadge: sourceBadge,
            title: activeItem.title,
            description: activeItem.description?.trim(),
            progressPercent: activeItem.progressPercent,
          ),
          const SizedBox(height: 14),

          // Action Button and Carousel indicators
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _HeroWatchButton(
                item: activeItem,
                autofocus: isFirstSection,
                handleUpNavigationToSettings: handleUpNavigationToSettings,
                onItemFocused: onItemFocused,
                onPrev: watchNextService.prevHeroItem,
                onNext: watchNextService.nextHeroItem,
                totalItems: items.length,
              ),
              if (items.length > 1) ...[
                const SizedBox(width: 20),
                _HeroPaginationIndicator(currentIndex: activeIndex, totalItems: items.length),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HeroInfo extends StatelessWidget {
  final String sourceBadge;
  final String title;
  final String? description;
  final int? progressPercent;

  const _HeroInfo({
    required this.sourceBadge,
    required this.title,
    required this.description,
    required this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    final hasDescription = description != null && description!.isNotEmpty;
    final hasProgress = progressPercent != null && progressPercent! > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Source badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1),
          ),
          child: Text(
            sourceBadge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1),
          ),
        ),
        const SizedBox(height: 10),

        // Title
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            shadows: [Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 10)],
          ),
        ),

        // Fixed-height synopsis slot (reserves exact height for 2 lines)
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: hasDescription
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      height: 1.35,
                      shadows: const [Shadow(color: Colors.black87, offset: Offset(0, 1), blurRadius: 6)],
                    ),
                  ),
                )
              : null,
        ),

        // Fixed-height progress slot (reserves exact height whether in progress or not)
        const SizedBox(height: 8),
        SizedBox(
          height: 4,
          child: hasProgress
              ? Container(
                  width: 140,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: (progressPercent! / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

class _HeroWatchButton extends StatefulWidget {
  final WatchNextItem item;
  final bool autofocus;
  final bool handleUpNavigationToSettings;
  final VoidCallback? onItemFocused;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final int totalItems;

  const _HeroWatchButton({
    required this.item,
    required this.autofocus,
    required this.handleUpNavigationToSettings,
    this.onItemFocused,
    required this.onPrev,
    required this.onNext,
    required this.totalItems,
  });

  @override
  State<_HeroWatchButton> createState() => _HeroWatchButtonState();
}

class _HeroWatchButtonState extends State<_HeroWatchButton> {
  final FocusNode _focusNode = FocusNode();
  bool _isHovered = false;
  bool _clicked = false;
  Timer? _launchTimer;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    _isHovered = widget.autofocus;
  }

  @override
  void dispose() {
    _launchTimer?.cancel();
    _resetTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _triggerLaunchWithFeedback() {
    if (_clicked) return;
    setState(() => _clicked = true);
    _playFocusSound(context);
    _launchTimer?.cancel();
    _launchTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      context.read<WatchNextService>().launchItem(widget.item);
      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _clicked = false);
        }
      });
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          if (widget.totalItems > 1) {
            widget.onPrev();
            _playFocusSound(context);
            return KeyEventResult.handled;
          }
          break;
        case LogicalKeyboardKey.arrowRight:
          if (widget.totalItems > 1) {
            widget.onNext();
            _playFocusSound(context);
            return KeyEventResult.handled;
          }
          break;
        case LogicalKeyboardKey.arrowUp:
          if (widget.handleUpNavigationToSettings) {
            Actions.invoke(context, const MoveFocusToSettingsIntent());
            return KeyEventResult.handled;
          }
          break;
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
          _triggerLaunchWithFeedback();
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isResume = widget.item.progressPercent != null && widget.item.progressPercent! > 0;
    final label = isResume ? localizations.watchNextResume : localizations.watchNextWatch;

    final double scale = _clicked ? 0.96 : 1.0;

    return RepaintBoundary(
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onKeyEvent: _handleKeyEvent,
        onFocusChange: (focused) {
          if (_isHovered == focused) return;
          setState(() => _isHovered = focused);
          if (focused) {
            _playFocusSound(context);
            widget.onItemFocused?.call();
          }
        },
        child: GestureDetector(
          onTap: _triggerLaunchWithFeedback,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: 48,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: ShapeDecoration(
                shape: StadiumBorder(
                  side: BorderSide(color: _isHovered ? Colors.white : Colors.white.withValues(alpha: 0.35), width: 1.0),
                ),
                color: _isHovered ? Colors.white : Colors.white.withValues(alpha: 0.22),
                shadows: _isHovered
                    ? const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3))]
                    : const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 24, color: _isHovered ? Colors.black87 : Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: _isHovered ? Colors.black87 : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPaginationIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalItems;

  const _HeroPaginationIndicator({required this.currentIndex, required this.totalItems});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(totalItems, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 6,
          height: 5,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(3),
            boxShadow: isActive ? [BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 6)] : null,
          ),
        );
      }),
    );
  }
}

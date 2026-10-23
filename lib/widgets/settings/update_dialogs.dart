import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flauncher/l10n/app_localizations.dart';

Future<void> showUpdateProgressDialog(
  BuildContext context, {
  required String label,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      content: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label)),
        ],
      ),
    ),
  );
}

Future<void> showNoUpdateDialog(
  BuildContext context,
  AppLocalizations localizations, {
  required String currentVersion,
  String? changelog,
}) {
  final hasChangelog = changelog != null && changelog.trim().isNotEmpty;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(localizations.updateNoUpdateTitle),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 540,
          minWidth: hasChangelog ? 420 : 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.updateNoUpdateBody(currentVersion)),
            if (hasChangelog) ...[
              const SizedBox(height: 14),
              Text(
                localizations.updateChangelog,
                style: Theme.of(dialogContext).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _ChangelogWidget(changelog: changelog),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(MaterialLocalizations.of(dialogContext).okButtonLabel),
        ),
      ],
    ),
  );
}

Future<bool> showUpdateAvailableDialog(
  BuildContext context,
  AppLocalizations localizations, {
  required String latestVersion,
  required String currentVersion,
  String? changelog,
}) async {
  final hasChangelog = changelog != null && changelog.trim().isNotEmpty;

  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(localizations.updateAvailableTitle),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 540,
              minWidth: hasChangelog ? 420 : 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.updateAvailableBody(
                      latestVersion, currentVersion),
                ),
                if (hasChangelog) ...[
                  const SizedBox(height: 14),
                  Text(
                    localizations.updateChangelog,
                    style:
                        Theme.of(dialogContext).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  const SizedBox(height: 8),
                  _ChangelogWidget(changelog: changelog),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child:
                  Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
            ),
            TextButton(
              autofocus: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(localizations.updateDownloadButton),
            ),
          ],
        ),
      ) ??
      false;
}

class _ChangelogWidget extends StatefulWidget {
  final String changelog;

  const _ChangelogWidget({required this.changelog});

  @override
  State<_ChangelogWidget> createState() => _ChangelogWidgetState();
}

class _ChangelogWidgetState extends State<_ChangelogWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _focused = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll(double delta) {
    if (!_scrollController.hasClients) return;
    final newOffset = (_scrollController.offset + delta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Focus(
      onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            if (_scrollController.hasClients &&
                _scrollController.offset <
                    _scrollController.position.maxScrollExtent - 4) {
              _scroll(60);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (_scrollController.hasClients && _scrollController.offset > 4) {
              _scroll(-60);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
            _scroll(180);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
            _scroll(-180);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 220,
          minWidth: double.infinity,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _focused
                ? theme.colorScheme.primary
                : theme.dividerColor.withValues(alpha: 0.25),
            width: _focused ? 2 : 1,
          ),
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: _buildChangelogContent(context, widget.changelog),
          ),
        ),
      ),
    );
  }

  Widget _buildChangelogContent(BuildContext context, String changelog) {
    final theme = Theme.of(context);
    final lines = changelog.split('\n');
    final widgets = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        if (widgets.isNotEmpty && widgets.last is! SizedBox) {
          widgets.add(const SizedBox(height: 6));
        }
        continue;
      }

      if (trimmed.startsWith('#')) {
        final headerText = trimmed.replaceFirst(RegExp(r"^#+\s*"), "");
        widgets.add(
          Padding(
            padding: EdgeInsets.only(
              top: widgets.isEmpty ? 0 : 8,
              bottom: 4,
            ),
            child: Text(
              headerText,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('* ') || trimmed.startsWith('- ')) {
        final bulletText = trimmed.substring(2).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "• ",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Text(
                    bulletText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              trimmed,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.35,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}

Future<bool> showReadyToInstallDialog(
  BuildContext context,
  AppLocalizations localizations, {
  required String latestVersion,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(localizations.updateReadyToInstallTitle),
          content: Text(localizations.updateReadyToInstallBody(latestVersion)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child:
                  Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(localizations.updateInstallButton),
            ),
          ],
        ),
      ) ??
      false;
}

Future<void> showInstallPermissionDialog(
  BuildContext context,
  AppLocalizations localizations, {
  required VoidCallback onOpenPermissionSettings,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(localizations.updateInstallPermissionTitle),
      content: Text(localizations.updateInstallPermissionBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onOpenPermissionSettings();
          },
          child: Text(localizations.updateOpenPermissionSettingsButton),
        ),
      ],
    ),
  );
}

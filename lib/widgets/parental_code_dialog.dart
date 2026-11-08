import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/parental_control_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

enum ParentalCodeDialogMode { verify, create }

String? _symbolFor(LogicalKeyboardKey key) {
  if (key == LogicalKeyboardKey.arrowUp) return "U";
  if (key == LogicalKeyboardKey.arrowDown) return "D";
  if (key == LogicalKeyboardKey.arrowLeft) return "L";
  if (key == LogicalKeyboardKey.arrowRight) return "R";
  const digits = [
    LogicalKeyboardKey.digit0, LogicalKeyboardKey.digit1, LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3, LogicalKeyboardKey.digit4, LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6, LogicalKeyboardKey.digit7, LogicalKeyboardKey.digit8,
    LogicalKeyboardKey.digit9,
  ];
  const numpad = [
    LogicalKeyboardKey.numpad0, LogicalKeyboardKey.numpad1, LogicalKeyboardKey.numpad2,
    LogicalKeyboardKey.numpad3, LogicalKeyboardKey.numpad4, LogicalKeyboardKey.numpad5,
    LogicalKeyboardKey.numpad6, LogicalKeyboardKey.numpad7, LogicalKeyboardKey.numpad8,
    LogicalKeyboardKey.numpad9,
  ];
  final d = digits.indexOf(key);
  if (d >= 0) return "$d";
  final n = numpad.indexOf(key);
  if (n >= 0) return "$n";
  return null;
}

bool _isValidate(LogicalKeyboardKey key) =>
    key == LogicalKeyboardKey.select ||
    key == LogicalKeyboardKey.enter ||
    key == LogicalKeyboardKey.numpadEnter ||
    key == LogicalKeyboardKey.gameButtonA;

/// Asks for the parental code with the remote (arrows / digits + OK).
/// The code is shown as dots only. Back cancels.
///
/// verify: resolves true once the code is accepted.
/// create: asks the code twice, stores it, resolves true.
Future<bool> showParentalCodeDialog(BuildContext context, {required ParentalCodeDialogMode mode}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _ParentalCodeDialog(mode: mode),
  );
  return result ?? false;
}

class _ParentalCodeDialog extends StatefulWidget {
  final ParentalCodeDialogMode mode;

  const _ParentalCodeDialog({required this.mode});

  @override
  State<_ParentalCodeDialog> createState() => _ParentalCodeDialogState();
}

class _ParentalCodeDialogState extends State<_ParentalCodeDialog> {
  final List<String> _entered = [];
  List<String>? _firstEntry; // create mode, awaiting confirmation
  String? _error;
  bool _busy = false;

  String get _title {
    if (widget.mode == ParentalCodeDialogMode.verify) return AppLocalizations.of(context)!.parentalRestrictedAccess;
    final l = AppLocalizations.of(context)!;
    return _firstEntry == null ? l.parentalNewCode : l.parentalConfirmCode;
  }

  String get _hint {
    final l = AppLocalizations.of(context)!;
    if (widget.mode == ParentalCodeDialogMode.verify) return l.parentalHintVerify;
    return _firstEntry == null
        ? l.parentalHintCreate(ParentalControlService.minCodeLength)
        : l.parentalHintConfirm;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || _busy) return KeyEventResult.ignored;
    final key = event.logicalKey;

    final symbol = _symbolFor(key);
    if (symbol != null) {
      setState(() {
        _error = null;
        if (_entered.length < 16) _entered.add(symbol);
      });
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      setState(() {
        if (_entered.isNotEmpty) _entered.removeLast();
      });
      return KeyEventResult.handled;
    }
    if (_isValidate(key)) {
      if (event is KeyDownEvent) _validate();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored; // Back etc. fall through to the dialog
  }

  Future<void> _validate() async {
    final service = context.read<ParentalControlService>();
    final code = List<String>.from(_entered);
    setState(() => _busy = true);

    if (widget.mode == ParentalCodeDialogMode.verify) {
      final result = await service.verify(code);
      if (!mounted) return;
      switch (result) {
        case ParentalCheckResult.ok:
          Navigator.of(context).pop(true);
          return;
        case ParentalCheckResult.wrong:
          _fail(AppLocalizations.of(context)!.parentalWrongCode);
        case ParentalCheckResult.lockedOut:
          _fail(AppLocalizations.of(context)!.parentalLocked(service.lockRemaining.inSeconds + 1));
      }
      return;
    }

    if (code.length < ParentalControlService.minCodeLength) {
      _fail(AppLocalizations.of(context)!.parentalTooShort(ParentalControlService.minCodeLength));
      return;
    }
    if (_firstEntry == null) {
      setState(() {
        _firstEntry = code;
        _entered.clear();
        _busy = false;
      });
      return;
    }
    if (_firstEntry!.join() != code.join()) {
      setState(() => _firstEntry = null);
      _fail(AppLocalizations.of(context)!.parentalMismatch);
      return;
    }
    await service.setCode(code);
    if (mounted) Navigator.of(context).pop(true);
  }

  void _fail(String message) {
    setState(() {
      _error = message;
      _entered.clear();
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: AlertDialog(
        title: Text(_title),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_hint, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                height: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _entered.length; i++)
                      Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

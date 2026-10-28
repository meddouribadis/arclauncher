const bool kEnableSelfUpdater = bool.fromEnvironment(
  'ENABLE_SELF_UPDATER',
  defaultValue: false,
);

const bool kUseNativeMediaPicker = bool.fromEnvironment(
  'USE_NATIVE_MEDIA_PICKER',
  defaultValue: false,
);

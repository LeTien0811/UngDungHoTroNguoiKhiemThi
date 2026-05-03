enum ViewState { idle, busy }

enum ServiceState { idle, busy }

enum CameraStatus { idle, uninitialized, ready, processing, success }

enum AIStatus { idle, initializing, ready, error, uninitialized, processing }

enum ScanStatus { ok, blur, notFoundObject, notFoundText, recapture, error }

enum SettingStatus {
  idle,
  processing,
  uninitialized,
  error,
}

enum ErrorFrame { blur, recapture }

enum AIType { ocrCorrection, voiceAssistantQA, error }

enum IntentType {
  USAGE,
  SAFETY,
  DETAILS,
  REPEAT,
  HISTORY,
  CANCEL,
  GENERAL,
  SETTINGS,
  SETTINGS_HARDWARE,
  SETTINGS_OPEN,
  SETTINGS_VOICE,
  SETTINGS_AI,
  UNKNOWN,
  ERROR
}

enum HapticState {
  light,
  heavy,
  selection,
  off,
}

enum UserProfileState {
  idle,
  checking,
  uninitialized,
  error,
}
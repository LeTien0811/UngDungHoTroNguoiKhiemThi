enum ViewState { idle, busy }

enum ServiceState { idle, busy }

enum CameraStatus { idle, uninitialized, ready, processing, success }

enum AIStatus { idle, initializing, ready, error, uninitialized, processing }

enum ScanStatus { ok, blur, notFoundObject, notFoundText, recapture, error }

enum SettingStatus { idle, processing, uninitialized, error }

enum ErrorFrame { blur, recapture }

enum AIType { VOICE_ASSISTANT, OCR_SCAN, GENERAL_CHAT, BUILD_EXTRACT_BASIC_PROFILE, DIRECT_VISION, error }

enum IntentType {
  USAGE,
  SAFETY,
  DETAILS,
  REPEAT,
  HISTORY,
  //Speed
  SETTING_SPEED_LOW,
  SETTING_SPEED_HIGH,
  SETTING_SPEED_NORMAL,
  // Lang
  SETTING_LANG_VI,
  SETTING_LANG_EN,
  // Pitch
  SETTING_PITCH_HIGH,
  SETTING_PITCH_LOW,
  //voice
  SETTING_VOICE_SOUTH,
  SETTING_VOICE_NORTH,
  SETTING_VOICE_MALE,
  SETTING_VOICE_FEMALE,
  SETTING_HARDWARE,
  SETTING_AI,
  CANCEL,
  GENERAL,
  UNKNOWN,
  ERROR,
}

enum HapticState { light, heavy, selection, off }

enum UserProfileState { idle, checking, uninitialized, error }

enum ViewState { idle, busy }

enum AIStatus { uninitialized, initializing, ready, error, missingAICore }

enum CameraStatus { idle, uninitialized, blur, recapture, processing, success }

enum ProcessStatus {
  ok,
  blur,
  recapture,
  error,
}

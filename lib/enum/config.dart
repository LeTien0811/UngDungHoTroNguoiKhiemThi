enum ViewState { idle, busy }

enum ServiceState { idle, busy }

enum CameraStatus { idle, uninitialized, ready, processing, success }

enum LocalAiStatus {
  idle,
  initializing,
  ready,
  error,
  uninitialized,
  processing,
}

enum ProcessStatus { ok, blur, recapture, error }

enum ErrorFrame { blur, recapture }

enum AiType { ocrCorrection, voiceAssistantQA, error}

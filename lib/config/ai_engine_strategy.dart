abstract class AiEngineStrategy {
  Future<void> initialize();
  Future<bool> isSupported();
  Future<String> processText(String rawText);
}
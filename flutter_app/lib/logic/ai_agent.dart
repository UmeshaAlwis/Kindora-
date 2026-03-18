class AIAgent {
  String detectIntent(String message) {
    final msg = message.toLowerCase();

    if (msg.contains("donate")) return "donate";
    if (msg.contains("charity") || msg.contains("search")) return "search";
    if (msg.contains("scam")) return "scam";

    return "general";
  }

  String processMessage(String message) {
    return "I'm here to help you with Kindora.";
  }
}
import 'package:kindora/core/navigation/kindora_app_role.dart';
import 'package:kindora/core/navigation/navigation_agent.dart';

/// High-level intent from a user message (theme / language / navigation / chat).
sealed class AssistantIntent {
  const AssistantIntent();
}

/// Handled locally; do not call chat API.
sealed class AssistantHandledIntent extends AssistantIntent {
  const AssistantHandledIntent();
}

/// Toggle or set dark mode.
class AssistantThemeIntent extends AssistantHandledIntent {
  const AssistantThemeIntent(this.useDarkMode);

  final bool useDarkMode;
}

/// Switch app language (BCP-47 code: en, si, ta).
class AssistantLanguageIntent extends AssistantHandledIntent {
  const AssistantLanguageIntent(this.languageCode);

  final String languageCode;
}

/// Navigation agent result (navigate, clarify, or forward to LLM).
class AssistantNavigationIntent extends AssistantIntent {
  const AssistantNavigationIntent(this.navigation);

  final NavigationResult navigation;
}

/// No local handling — use chat backend.
class AssistantChatOnlyIntent extends AssistantIntent {
  const AssistantChatOnlyIntent();
}

/// Parse theme, then language, then defer to [NavigationAgent].
AssistantIntent resolveAssistantIntent(
  String raw,
  KindoraAppRole role, {
  required bool currentlyDark,
}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return const AssistantChatOnlyIntent();

  if (isThemeToggleMessage(trimmed)) {
    return AssistantThemeIntent(!currentlyDark);
  }

  final theme = _parseThemeIntent(trimmed.toLowerCase());
  if (theme != null) {
    return AssistantThemeIntent(theme);
  }

  final lang = _parseLanguageIntent(trimmed.toLowerCase());
  if (lang != null) {
    return AssistantLanguageIntent(lang);
  }

  final nav = NavigationAgent.resolve(trimmed, role);
  return AssistantNavigationIntent(nav);
}

bool? _parseThemeIntent(String t) {
  const darkPhrases = [
    'dark mode',
    'dark theme',
    'night mode',
    'enable dark',
    'turn on dark',
    'use dark',
    'black theme',
  ];
  const lightPhrases = [
    'light mode',
    'light theme',
    'day mode',
    'disable dark',
    'turn off dark',
    'use light',
    'white theme',
  ];

  if (darkPhrases.any(t.contains)) return true;
  if (lightPhrases.any(t.contains)) return false;
  return null;
}

/// Returns true if message toggles theme (flip current).
bool isThemeToggleMessage(String raw) {
  final t = raw.toLowerCase().trim();
  if (t == 'toggle theme' ||
      t == 'toggle dark mode' ||
      t == 'toggle light mode' ||
      t == 'toggle mode') {
    return true;
  }
  return t.contains('toggle') &&
      t.contains('theme') &&
      t.split(RegExp(r'\s+')).length <= 5;
}

String? _parseLanguageIntent(String t) {
  final hasLanguageCue = t.contains('language') ||
      t.contains('locale') ||
      t.contains('translate ui') ||
      t.contains('switch to') ||
      t.contains('change to');

  String? code;
  if (t.contains('sinhala') ||
      t.contains('sinhalese') ||
      t.contains('සිංහල') ||
      RegExp(r'(^|\s)si(\s|$)').hasMatch(t)) {
    code = 'si';
  } else if (t.contains('tamil') ||
      t.contains('தமிழ்') ||
      RegExp(r'(^|\s)ta(\s|$)').hasMatch(t)) {
    code = 'ta';
  } else if (t.contains('english') ||
      RegExp(r'(^|\s)en(\s|$)').hasMatch(t)) {
    code = 'en';
  }

  if (code == null) return null;

  // Avoid accidental matches in long unrelated sentences.
  if (!hasLanguageCue && t.split(RegExp(r'\s+')).length > 4) {
    return null;
  }

  return code;
}

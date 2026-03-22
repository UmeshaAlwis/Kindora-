import 'kindora_app_role.dart';

/// One logical destination; path depends on the signed-in role.
class NavigationTarget {
  const NavigationTarget({
    required this.id,
    required this.reply,
    required this.pathsByRole,
    required this.keywords,
  });

  final String id;
  final String reply;

  /// Only include entries for roles that may open this screen.
  final Map<KindoraAppRole, String> pathsByRole;

  /// Lowercase tokens / phrases to match user text.
  final List<String> keywords;

  String? pathFor(KindoraAppRole role) => pathsByRole[role];
}

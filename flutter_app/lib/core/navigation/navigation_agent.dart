import 'kindora_app_role.dart';
import 'navigation_target.dart';

/// Result of interpreting a user message as a navigation request.
sealed class NavigationResult {
  const NavigationResult();

  /// Not a navigation command — forward to chat / LLM.
  bool get shouldForwardToChat => this is NavigationForwardToChat;

  bool get shouldNavigate => this is NavigationNavigate;

  bool get shouldClarify => this is NavigationClarify;
}

class NavigationForwardToChat extends NavigationResult {
  const NavigationForwardToChat();
}

class NavigationNavigate extends NavigationResult {
  const NavigationNavigate({
    required this.path,
    required this.assistantMessage,
    required this.targetId,
  });

  final String path;
  final String assistantMessage;
  final String targetId;
}

class NavigationClarify extends NavigationResult {
  const NavigationClarify(this.message);

  final String message;
}

/// Role-safe navigation: only routes present in the catalog for the current role.
class NavigationAgent {
  NavigationAgent._();

  /// Phrases that suggest the user wants to move in the app (not general Q&A).
  static final RegExp _navIntent = RegExp(
    r'\b(go to|open|take me|navigate|show me|bring me|switch to|jump to|visit)\b',
    caseSensitive: false,
  );

  /// All registered screens / tabs (whitelist).
  static final List<NavigationTarget> _targets = [
    NavigationTarget(
      id: 'home',
      reply: 'Opening your home dashboard.',
      pathsByRole: {
        KindoraAppRole.donor: '/dashboard',
        KindoraAppRole.beneficiary: '/beneficiary/dashboard',
        KindoraAppRole.volunteer: '/volunteer/dashboard',
      },
      keywords: [
        'home',
        'dashboard',
        'main',
        'start',
      ],
    ),
    NavigationTarget(
      id: 'feed',
      reply: 'Opening the feed.',
      pathsByRole: {
        KindoraAppRole.donor: '/feed',
        KindoraAppRole.beneficiary: '/beneficiary/feed',
        KindoraAppRole.volunteer: '/volunteer/feed',
      },
      keywords: [
        'feed',
        'posts',
        'updates',
        'activity',
        'timeline',
      ],
    ),
    NavigationTarget(
      id: 'messages',
      reply: 'Opening messages.',
      pathsByRole: {
        KindoraAppRole.donor: '/messages',
        KindoraAppRole.beneficiary: '/beneficiary/messages',
        KindoraAppRole.volunteer: '/volunteer/messages',
      },
      keywords: [
        'messages',
        'message',
        'chat',
        'inbox',
        'dm',
        'direct',
      ],
    ),
    NavigationTarget(
      id: 'notifications',
      reply: 'Opening notifications.',
      pathsByRole: {
        KindoraAppRole.donor: '/notifications',
        KindoraAppRole.beneficiary: '/notifications',
        KindoraAppRole.volunteer: '/notifications',
      },
      keywords: [
        'notifications',
        'notification',
        'alerts',
        'bell',
      ],
    ),
    NavigationTarget(
      id: 'merch',
      reply: 'Opening the shop.',
      pathsByRole: {
        KindoraAppRole.donor: '/merch',
      },
      keywords: [
        'merch',
        'merchandise',
        'shop',
        'store',
        'products',
      ],
    ),
    NavigationTarget(
      id: 'campaigns',
      reply: 'Opening campaigns.',
      pathsByRole: {
        KindoraAppRole.donor: '/campaigns',
        KindoraAppRole.volunteer: '/campaigns',
      },
      keywords: [
        'campaigns',
        'campaign',
        'browse campaigns',
        'discover campaigns',
      ],
    ),
    NavigationTarget(
      id: 'donor_beneficiary_campaigns',
      reply: 'Opening beneficiary campaigns you can support.',
      pathsByRole: {
        KindoraAppRole.donor: '/donor/beneficiary-campaigns',
      },
      keywords: [
        'beneficiary campaigns',
        'support people',
        'donate to beneficiary',
        'people in need',
      ],
    ),
    NavigationTarget(
      id: 'profile',
      reply: 'Opening your profile.',
      pathsByRole: {
        KindoraAppRole.donor: '/profile',
        KindoraAppRole.beneficiary: '/beneficiary/profile',
        KindoraAppRole.volunteer: '/volunteer/profile',
      },
      keywords: [
        'profile',
        'my profile',
        'account',
        'me',
      ],
    ),
    NavigationTarget(
      id: 'settings',
      reply: 'Opening settings.',
      pathsByRole: {
        KindoraAppRole.donor: '/profile/settings',
        KindoraAppRole.beneficiary: '/beneficiary/profile/settings',
        KindoraAppRole.volunteer: '/profile/settings',
      },
      keywords: [
        'settings',
        'preferences',
        'options',
        'configuration',
      ],
    ),
    NavigationTarget(
      id: 'beneficiary_wallet',
      reply: 'Opening your wallet.',
      pathsByRole: {
        KindoraAppRole.beneficiary: '/beneficiary/wallet',
      },
      keywords: [
        'wallet',
        'balance',
        'earnings',
        'payout',
      ],
    ),
    NavigationTarget(
      id: 'volunteer_joined',
      reply: 'Opening your joined campaigns.',
      pathsByRole: {
        KindoraAppRole.volunteer: '/volunteer/joined-campaigns',
      },
      keywords: [
        'joined',
        'joined campaigns',
        'my campaigns',
        'volunteer campaigns',
      ],
    ),
    NavigationTarget(
      id: 'beneficiary_create_campaign',
      reply: 'Opening create campaign.',
      pathsByRole: {
        KindoraAppRole.beneficiary: '/beneficiary/create-campaign',
      },
      keywords: [
        'create campaign',
        'new campaign',
        'start campaign',
        'launch campaign',
      ],
    ),
    NavigationTarget(
      id: 'beneficiary_campaigns_list',
      reply: 'Opening your campaigns.',
      pathsByRole: {
        KindoraAppRole.beneficiary: '/beneficiary/campaigns',
      },
      keywords: [
        'my campaigns',
        'campaign list',
        'manage campaigns',
      ],
    ),
    NavigationTarget(
      id: 'beneficiary_profile_completion',
      reply: 'Opening profile completion.',
      pathsByRole: {
        KindoraAppRole.beneficiary: '/beneficiary/profile-completion',
      },
      keywords: [
        'complete profile',
        'profile completion',
        'finish signup',
        'finish profile',
      ],
    ),
  ];

  static NavigationResult resolve(String raw, KindoraAppRole role) {
    final text = raw.toLowerCase().trim();
    if (text.isEmpty) return const NavigationForwardToChat();

    final hasNavIntent = _navIntent.hasMatch(text);
    final words = _tokenize(text);

    NavigationTarget? best;
    var bestScore = 0;

    for (final target in _targets) {
      final path = target.pathFor(role);
      if (path == null) continue;

      final score = _scoreTarget(text, words, target.keywords);
      if (score > bestScore) {
        bestScore = score;
        best = target;
      }
    }

    const minScore = 6;

    if (best != null && bestScore >= minScore) {
      final t = best;
      final path = t.pathFor(role);
      if (path != null) {
        return NavigationNavigate(
          path: path,
          assistantMessage: t.reply,
          targetId: t.id,
        );
      }
    }

    if (hasNavIntent && bestScore > 0 && best != null) {
      final t = best;
      final path = t.pathFor(role);
      if (path != null) {
        return NavigationNavigate(
          path: path,
          assistantMessage: t.reply,
          targetId: t.id,
        );
      }
    }

    if (hasNavIntent) {
      return NavigationClarify(
        'I’m not sure which screen you mean. As a ${role.displayLabel}, try: '
        '${_hintForRole(role)}',
      );
    }

    return const NavigationForwardToChat();
  }

  static String _hintForRole(KindoraAppRole role) {
    return switch (role) {
      KindoraAppRole.donor =>
        '“Open home”, “Open feed”, “Open shop”, or “Open campaigns”.',
      KindoraAppRole.beneficiary =>
        '“Open dashboard”, “Open wallet”, “Create campaign”, or “Open messages”.',
      KindoraAppRole.volunteer =>
        '“Open dashboard”, “Open joined campaigns”, “Open feed”, or “Open profile”.',
    };
  }

  static Set<String> _tokenize(String text) {
    return RegExp(r'[a-z0-9]+')
        .allMatches(text)
        .map((m) => m.group(0)!)
        .toSet();
  }

  static int _scoreTarget(
    String fullText,
    Set<String> words,
    List<String> keywords,
  ) {
    var score = 0;
    for (final kw in keywords) {
      final k = kw.trim().toLowerCase();
      if (k.isEmpty) continue;
      if (k.contains(' ')) {
        if (fullText.contains(k)) score += k.length + 4;
      } else {
        if (words.contains(k)) score += k.length + 8;
      }
    }
    return score;
  }
}

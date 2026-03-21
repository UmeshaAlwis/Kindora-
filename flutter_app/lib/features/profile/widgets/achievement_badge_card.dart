import 'package:flutter/material.dart';
import 'package:kindora/config/themes/app_colors.dart';

/// Maps API `icon` string to [IconData] for donor + volunteer badges.
IconData iconFromBadgeName(String icon) {
  switch (icon) {
    case 'redeem':
      return Icons.redeem;
    case 'military_tech':
      return Icons.military_tech;
    case 'emoji_events':
      return Icons.emoji_events;
    case 'campaign':
      return Icons.campaign;
    case 'event_repeat':
      return Icons.event_repeat;
    case 'bolt':
      return Icons.bolt;
    case 'volunteer_activism':
      return Icons.volunteer_activism;
    case 'groups':
      return Icons.groups;
    case 'handshake':
      return Icons.handshake_outlined;
    default:
      return Icons.verified;
  }
}

/// Brand palette for donor + volunteer achievement badges.
({Color accent, Color accent2, Color surface}) badgePaletteFor(String badgeId) {
  switch (badgeId) {
    // —— Donor ——
    case 'first_gift':
      return (
        accent: AppColors.primaryOrange,
        accent2: Color.lerp(AppColors.primaryOrange, Colors.white, 0.35)!,
        surface: AppColors.orangeSurface,
      );
    case 'starter_supporter':
      return (
        accent: AppColors.primaryBlue,
        accent2: AppColors.blueDeep,
        surface: AppColors.blueSurface,
      );
    case 'golden_donor':
      return (
        accent: Color.lerp(AppColors.primaryOrange, AppColors.primaryBlue, 0.25)!,
        accent2: AppColors.primaryOrange,
        surface: AppColors.orangeSurface,
      );
    case 'three_campaign_backer':
      return (
        accent: AppColors.blueDeep,
        accent2: AppColors.primaryBlue,
        surface: AppColors.blueSurface,
      );
    case 'monthly_giver':
      return (
        accent: AppColors.primaryBlue,
        accent2: Color.lerp(AppColors.primaryBlue, AppColors.primaryOrange, 0.4)!,
        surface: AppColors.blueSurface,
      );
    case 'rapid_responder':
      return (
        accent: AppColors.primaryOrange,
        accent2: AppColors.primaryBlue,
        surface: AppColors.orangeSurface,
      );
    // —— Volunteer ——
    case 'vol_first_step':
      return (
        accent: AppColors.primaryOrange,
        accent2: Color.lerp(AppColors.primaryOrange, Colors.white, 0.35)!,
        surface: AppColors.orangeSurface,
      );
    case 'vol_team_player':
      return (
        accent: AppColors.primaryBlue,
        accent2: AppColors.blueDeep,
        surface: AppColors.blueSurface,
      );
    case 'vol_impact_builder':
      return (
        accent: Color.lerp(AppColors.primaryBlue, AppColors.primaryOrange, 0.3)!,
        accent2: AppColors.primaryOrange,
        surface: AppColors.orangeSurface,
      );
    case 'vol_super_volunteer':
      return (
        accent: AppColors.blueDeep,
        accent2: AppColors.primaryBlue,
        surface: AppColors.blueSurface,
      );
    case 'vol_connector':
      return (
        accent: AppColors.primaryBlue,
        accent2: AppColors.primaryOrange,
        surface: AppColors.blueSurface,
      );
    case 'vol_quick_helper':
      return (
        accent: AppColors.primaryOrange,
        accent2: AppColors.primaryBlue,
        surface: AppColors.orangeSurface,
      );
    case 'vol_steady_heart':
      return (
        accent: AppColors.primaryOrange,
        accent2: Color.lerp(AppColors.primaryBlue, AppColors.primaryOrange, 0.5)!,
        surface: AppColors.scaffoldLight,
      );
    default:
      return (
        accent: AppColors.primaryBlue,
        accent2: AppColors.primaryOrange,
        surface: AppColors.scaffoldLight,
      );
  }
}

/// Shared achievement tile (donor profile + volunteer profile).
class AchievementBadgeCard extends StatelessWidget {
  final String badgeId;
  final IconData icon;
  final String title;
  final String subtitle;

  const AchievementBadgeCard({
    super.key,
    required this.badgeId,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = badgePaletteFor(badgeId);
    return Container(
      width: 168,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.surface,
            Colors.white,
          ],
        ),
        border: Border.all(color: c.accent.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: c.accent.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.accent, c.accent2],
              ),
              boxShadow: [
                BoxShadow(
                  color: c.accent.withOpacity(0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.2,
              color: Colors.grey.shade900,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              color: Colors.blueGrey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

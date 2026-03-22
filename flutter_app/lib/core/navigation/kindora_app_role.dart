/// Kindora mobile roles (matches Supabase `users.role` + AuthGate).
///
/// Backend uses `charity` for volunteers; we expose [volunteer] in app code.
enum KindoraAppRole {
  donor,
  beneficiary,
  volunteer,
}

extension KindoraAppRoleX on KindoraAppRole {
  /// Display name for assistant copy.
  String get displayLabel => switch (this) {
        KindoraAppRole.donor => 'Donor',
        KindoraAppRole.beneficiary => 'Beneficiary',
        KindoraAppRole.volunteer => 'Volunteer',
      };

  static KindoraAppRole fromBackendRole(String? raw) {
    switch (raw) {
      case 'beneficiary':
        return KindoraAppRole.beneficiary;
      case 'charity':
        return KindoraAppRole.volunteer;
      default:
        return KindoraAppRole.donor;
    }
  }
}

enum UserRole { admin, worker }

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.worker:
        return 'Worker';
    }
  }

  bool get isAdmin => this == UserRole.admin;

  static UserRole fromString(String? value) {
    if (value?.toLowerCase() == 'admin') return UserRole.admin;
    return UserRole.worker;
  }
}

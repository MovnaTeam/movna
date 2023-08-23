enum SystemPermissionStatus {
  always,
  denied,
  whileInUse,
  permanentlyDenied;

  bool get isGranted => switch (this) {
        SystemPermissionStatus.always => true,
        SystemPermissionStatus.whileInUse => true,
        _ => false,
      };
}

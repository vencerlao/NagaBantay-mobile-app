class LocalAuthStore {
  // In-memory store for the currently logged phone (normalized digits-only)
  // This avoids using platform plugins like SharedPreferences for quick runtime
  // lookups and prevents plugin lookup crashes in environments where plugins
  // aren't registered.
  static String? loggedPhone;
}

enum StorageKeys {
  /// Determine if the current environment should be [LOCAL_ENV] or [PRODUCTION_ENV]
  IS_LOCAL_ENVIRONMENT,

  /// Used to store logged user bearer token
  USER_TOKEN,

  /// Used to store logged user credentials used on login
  USER_CREDENTIALS,

  /// Used to store logged user profile information
  PROFILE_INFO,

  /// Telemetry events not yet accepted by the API, resent on the next flush
  PENDING_TELEMETRY,
}

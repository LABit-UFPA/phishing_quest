abstract interface class IRegisterRepository {
  Future<void> register({
    required String username,
    required String password,
    required String email,
  });
}

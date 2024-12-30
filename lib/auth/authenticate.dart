class AuthLogic {
  static const String correctPassword = "123abc";

  static bool authenticate(String enteredPassword) {
    return enteredPassword == correctPassword;
  }
}
class HttpExecption implements Exception {
  final String messenge;

  HttpExecption(this.messenge);

  @override
  String toString() {
    return messenge;
  }
}

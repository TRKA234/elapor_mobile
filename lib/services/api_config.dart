class ApiConfig {
  // Gunakan 10.67.233.115 untuk Emulator Android, localhost untuk iOS/Web
  static const String baseUrl = "http://10.67.233.115";

  static const String authUrl = "$baseUrl:8081"; // Go
  static const String reportUrl = "$baseUrl:8082"; // PHP
  static const String commentUrl = "$baseUrl:8083"; // Node.js
  static const String statsUrl = "$baseUrl:8084"; // Python
}

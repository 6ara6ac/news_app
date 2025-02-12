class ApiConstants {
  // Для Android эмулятора используем 10.0.2.2
  // Для iOS эмулятора используем localhost
  // Для реального устройства используем IP вашего компьютера
  static const String baseUrl = 'http://10.0.2.2:3000'; // Для Android эмулятора
  static const String apiUrl = '$baseUrl/api';
  static const String imagesUrl = '$baseUrl/images';
  static const String kBaseUrl =
      'http://your-api-base-url'; // Замените на ваш URL
}

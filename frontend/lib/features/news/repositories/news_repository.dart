import 'package:dio/dio.dart';
import '../models/news_article.dart';

class NewsRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:3000/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    validateStatus: (status) => true,
  ));

  Future<List<NewsArticle>> getNews({
    int page = 1,
    String? category,
  }) async {
    try {
      print('Fetching news: page=$page, category=$category');
      final response = await _dio.get(
        '/news',
        queryParameters: {
          'page': page,
          'pageSize': 20,
          'category': category?.toLowerCase(),
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['articles'];
        return data.map((json) => NewsArticle.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching news: $e');
      throw Exception('Failed to fetch news: $e');
    }
  }

  Future<List<NewsArticle>> searchNews(String query) async {
    try {
      final response = await _dio.get(
        '/news',
        queryParameters: {
          'search': query.trim(),
          'searchFields': ['title', 'shortSummary'],
          'page': 1,
          'pageSize': 20,
          'exact': true,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['articles'];
        return data.map((json) => NewsArticle.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching news: $e');
      return [];
    }
  }
}

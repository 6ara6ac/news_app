import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/news_article.dart';
import '../repositories/news_repository.dart';

final newsRepositoryProvider = Provider((ref) => NewsRepository());

final newsProvider =
    StateNotifierProvider<NewsNotifier, AsyncValue<List<NewsArticle>>>(
  (ref) => NewsNotifier(ref.read(newsRepositoryProvider)),
);

final selectedCategoryProvider = StateProvider<String>((ref) => '');
final searchQueryProvider = StateProvider<String>((ref) => '');

class NewsNotifier extends StateNotifier<AsyncValue<List<NewsArticle>>> {
  final NewsRepository _repository;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _currentCategory;

  NewsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNews();
  }

  Future<void> loadNews({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      state = const AsyncValue.loading();
    }

    if (!_hasMore) return;

    try {
      final news = await _repository.getNews(
        page: _currentPage,
        category: _currentCategory,
      );

      if (news.isEmpty) {
        _hasMore = false;
        return;
      }

      _currentPage++;
      if (refresh || !state.hasValue) {
        state = AsyncValue.data(news);
      } else {
        state = AsyncValue.data([...state.value!, ...news]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> searchNews(String query) async {
    if (query.isEmpty) {
      loadNews(refresh: true);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final results = await _repository.searchNews(query);
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleSave(String id) async {
    state = state.whenData((articles) {
      return articles.map((article) {
        if (article.id == id) {
          return NewsArticle(
            id: article.id,
            title: article.title,
            description: article.description,
            content: article.content,
            shortSummary: article.shortSummary,
            summary: article.summary,
            imageUrl: article.imageUrl,
            link: article.link,
            publishedAt: article.publishedAt,
            category: article.category,
            country: article.country,
            source: article.source,
            isNew: article.isNew,
            sourceUrl: article.sourceUrl,
            isSaved: !article.isSaved,
          );
        }
        return article;
      }).toList();
    });
  }
}

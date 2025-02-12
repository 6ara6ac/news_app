class NewsArticle {
  final String id;
  final String title;
  final String description;
  final String content;
  final String shortSummary;
  final String summary;
  final String imageUrl;
  final String link;
  final DateTime publishedAt;
  final String category;
  final String country;
  final Map<String, dynamic> source;
  final bool isNew;
  final String? sourceUrl;
  final bool isSaved;

  NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.shortSummary = '',
    this.summary = '',
    required this.imageUrl,
    required this.link,
    required this.publishedAt,
    required this.category,
    required this.country,
    required this.source,
    this.isNew = false,
    this.sourceUrl,
    this.isSaved = false,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      shortSummary: json['shortSummary'] ?? '',
      summary: json['summary'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      link: json['link'] ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : DateTime.now(),
      category: json['category'] ?? '',
      country: json['country'] ?? '',
      source: json['source'] ?? {},
      isNew: json['isNew'] ?? false,
      sourceUrl: json['sourceUrl'] as String?,
      isSaved: json['isSaved'] == true,
    );
  }
}

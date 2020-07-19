class News {
  final String author;
  final String title;
  final String description;
  final DateTime publishedAt;
  final String url;
  final String imageUrl;
  final String content;

  News._(this.author, this.title, this.description, this.publishedAt, this.url,
      this.imageUrl, this.content);

  factory News(Map<dynamic, dynamic> data) {
    return News._(
        data['author'],
        data['title'],
        data['description'],
        DateTime.parse(data['publishedAt']),
        data['url'],
        data['urlToImage'],
        data['content']);
  }
}

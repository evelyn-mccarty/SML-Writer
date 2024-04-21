class JsonArticle {
  final String title;
  final String author;
  final List<dynamic> tags;
  final List<dynamic> body;

  const JsonArticle({
    required this.title,
    required this.author,
    required this.tags,
    required this.body,
  });

  static JsonArticle fromJson(json) => JsonArticle(
        title: json["Title"],
        author: json["Author"],
        tags: json["Tags"],
        body: json["Body"],
      );

  static Map<String, dynamic> toJson(JsonArticle item) => {
        'Title': item.title,
        'Author': item.author,
        'Body': item.body,
        'Tags': item.tags
      };
}

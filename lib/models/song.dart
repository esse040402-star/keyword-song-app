/// 내 곡 한 개. 키워드는 곡마다 붙는다 (PRD 9장 Song).
class Song {
  const Song({
    required this.id,
    required this.title,
    required this.keywords,
    required this.createdAt,
    this.artist,
  });

  final int id;
  final String title;
  final String? artist;
  final List<String> keywords;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'keywords': keywords,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] as int,
        title: json['title'] as String,
        artist: json['artist'] as String?,
        keywords: (json['keywords'] as List).cast<String>(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

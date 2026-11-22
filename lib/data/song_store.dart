import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';
import 'preset_keywords.dart';

/// 곡 추가가 거절된 이유 (AC2, AC3).
enum AddSongError { emptyTitle, noKeyword }

class AddSongResult {
  const AddSongResult.success(this.song) : errors = const {};
  const AddSongResult.failure(this.errors) : song = null;

  final Song? song;
  final Set<AddSongError> errors;

  bool get ok => song != null;
}

/// 키워드 폴더 하나: 같은 키워드가 붙은 곡 묶음 (F4).
class KeywordFolder {
  const KeywordFolder(this.keyword, this.songs);

  final String keyword;
  final List<Song> songs;
}

/// 앱 전체가 공유하는 곡 데이터. 메인 폴더·곡 추가 화면이 같은 값을 본다.
/// 상태는 이 객체 한 곳에서만 바꾸고, 바뀌면 notifyListeners로 화면을 갱신한다.
class SongStore extends ChangeNotifier {
  SongStore(this._prefs, {List<Song> songs = const [], this.loadError})
      : _songs = List.of(songs);

  static const storageKey = 'songs_v1';

  final SharedPreferences _prefs;
  final List<Song> _songs;

  /// 저장 데이터를 읽지 못했을 때의 안내 문구. 없으면 null.
  final String? loadError;

  Future<void> _lastSave = Future.value();

  /// 마지막 저장이 끝날 때까지 기다린다 (테스트에서 재시작을 흉내 낼 때 사용).
  Future<void> get saved => _lastSave;

  /// 기기 저장소에서 곡을 읽는다. 읽기에 실패하면 안내만 남기고 빈 상태로 시작한다.
  static Future<SongStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null) return SongStore(prefs);
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList();
      return SongStore(prefs, songs: list);
    } catch (_) {
      return SongStore(
        prefs,
        loadError: '저장된 곡을 읽지 못해 빈 목록으로 시작했어요.',
      );
    }
  }

  List<Song> get songs => List.unmodifiable(_songs);

  /// 직접 만든 키워드: 곡에 붙어 있지만 미리 있는 키워드가 아닌 것 (AC5).
  List<String> get customKeywords {
    final presetKeys = presetKeywords.map(_key).toSet();
    final seen = <String, String>{};
    for (final song in _songs) {
      for (final k in song.keywords) {
        if (!presetKeys.contains(_key(k))) seen.putIfAbsent(_key(k), () => k);
      }
    }
    return seen.values.toList();
  }

  /// 키워드마다 곡을 묶은 폴더. 곡이 0개인 키워드는 만들지 않는다.
  /// 곡이 많은 폴더가 앞에 오고, 곡 수가 같으면 이름순이다.
  List<KeywordFolder> get folders {
    final byKey = <String, List<Song>>{};
    final label = <String, String>{};
    for (final song in _songs) {
      for (final k in song.keywords) {
        byKey.putIfAbsent(_key(k), () => []).add(song);
        label.putIfAbsent(_key(k), () => k);
      }
    }
    final result = [
      for (final e in byKey.entries) KeywordFolder(label[e.key]!, e.value),
    ];
    result.sort((a, b) {
      final byCount = b.songs.length.compareTo(a.songs.length);
      return byCount != 0 ? byCount : a.keyword.compareTo(b.keyword);
    });
    return result;
  }

  /// 선택한 키워드 + 직접 입력(쉼표 분리)을 합쳐 공백·중복을 정리한다 (AC4).
  /// 비교는 앞뒤 공백과 영문 대소문자를 무시하고, 먼저 나온 표기를 남긴다.
  static List<String> parseKeywords(
    Iterable<String> selected,
    String customInput,
  ) {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in [...selected, ...customInput.split(',')]) {
      final k = raw.trim();
      if (k.isEmpty) continue;
      if (seen.add(_key(k))) result.add(k);
    }
    return result;
  }

  /// 곡을 추가한다. 제목이 비었거나 키워드가 없으면 목록을 바꾸지 않는다.
  AddSongResult addSong({
    required String title,
    String? artist,
    Iterable<String> selectedKeywords = const [],
    String customKeywordInput = '',
  }) {
    final cleanTitle = title.trim();
    final keywords = parseKeywords(selectedKeywords, customKeywordInput);
    final errors = <AddSongError>{
      if (cleanTitle.isEmpty) AddSongError.emptyTitle,
      if (keywords.isEmpty) AddSongError.noKeyword,
    };
    if (errors.isNotEmpty) return AddSongResult.failure(errors);

    final cleanArtist = artist?.trim();
    final nextId =
        _songs.isEmpty ? 1 : _songs.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;
    final song = Song(
      id: nextId,
      title: cleanTitle,
      artist: (cleanArtist == null || cleanArtist.isEmpty) ? null : cleanArtist,
      keywords: keywords,
      createdAt: DateTime.now(),
    );
    _songs.add(song);
    notifyListeners();
    _lastSave = _persist();
    return AddSongResult.success(song);
  }

  Future<void> _persist() => _prefs.setString(
        storageKey,
        jsonEncode(_songs.map((s) => s.toJson()).toList()),
      );

  static String _key(String keyword) => keyword.trim().toLowerCase();
}

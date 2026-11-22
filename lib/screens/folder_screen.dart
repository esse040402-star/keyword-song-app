import 'package:flutter/material.dart';

import '../data/song_store.dart';
import '../models/song.dart';
import '../theme.dart';
import '../widgets/keyword_widgets.dart';

/// 키워드 폴더 하나를 열었을 때: 그 키워드가 붙은 곡 목록.
class FolderScreen extends StatelessWidget {
  const FolderScreen({super.key, required this.store, required this.keyword});

  final SongStore store;
  final String keyword;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final songs = store.folders
            .where((f) => f.keyword == keyword)
            .expand((f) => f.songs)
            .toList();
        return Scaffold(
          appBar: AppBar(title: Text('#$keyword · ${songs.length}곡')),
          body: songs.isEmpty
              ? const Center(
                  child: Text('이 키워드의 곡이 없어요',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: songs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => SongCard(song: songs[i], store: store),
                ),
        );
      },
    );
  }
}

class SongCard extends StatelessWidget {
  const SongCard({super.key, required this.song, required this.store});

  final Song song;
  final SongStore store;

  @override
  Widget build(BuildContext context) {
    final custom = store.customKeywords.map((e) => e.toLowerCase()).toSet();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, Color(0xFF5B4BD5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.music_note_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                if (song.artist != null)
                  Text(song.artist!,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final k in song.keywords)
                      KeywordTag(k, custom: custom.contains(k.toLowerCase())),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

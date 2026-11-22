import 'package:flutter/material.dart';

import '../data/song_store.dart';
import '../models/song.dart';
import '../theme.dart';
import 'add_song_screen.dart';
import 'folder_screen.dart';

/// 메인: 키워드마다 묶인 폴더와 곡 수 (F4). 곡이 없으면 안내만 보인다 (AC8).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});

  final SongStore store;

  Future<void> _openAdd(BuildContext context) async {
    final added = await Navigator.of(context).push<Song>(
      MaterialPageRoute(builder: (_) => AddSongScreen(store: store)),
    );
    if (added != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("'${added.title}'을(를) 추가했어요")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final folders = store.folders;
        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Header(store: store)),
                if (store.loadError != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        store.loadError!,
                        key: const Key('load-error'),
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                if (folders.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(onAdd: () => _openAdd(context)),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.35,
                      ),
                      itemCount: folders.length,
                      itemBuilder: (_, i) => _FolderCard(
                        folder: folders[i],
                        custom: store.customKeywords
                            .map((e) => e.toLowerCase())
                            .contains(folders[i].keyword.toLowerCase()),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FolderScreen(
                              store: store,
                              keyword: folders[i].keyword,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: folders.isEmpty
              ? null
              : FloatingActionButton.extended(
                  key: const Key('add-song-fab'),
                  onPressed: () => _openAdd(context),
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('곡 추가'),
                ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.store});

  final SongStore store;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내 곡 ${store.songs.length}곡 · 키워드 ${store.folders.length}개',
            key: const Key('summary'),
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            '키워드 플레이리스트',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({
    required this.folder,
    required this.custom,
    required this.onTap,
  });

  final KeywordFolder folder;
  final bool custom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = custom ? AppColors.custom : AppColors.accent;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: Key('folder-${folder.keyword}'),
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.folder_rounded, color: color, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(folder.keyword,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  Text('${folder.songs.length}곡',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.library_music_rounded,
              size: 56, color: AppColors.accent),
          const SizedBox(height: 16),
          const Text('곡을 추가해 보세요',
              key: Key('empty-message'),
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('곡마다 키워드를 붙이면 키워드별 폴더로 모여요',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('add-first-song'),
            onPressed: onAdd,
            child: const Text('첫 곡 추가하기'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'data/song_store.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await SongStore.load();
  runApp(KeywordPlaylistApp(store: store));
}

class KeywordPlaylistApp extends StatelessWidget {
  const KeywordPlaylistApp({super.key, required this.store});

  final SongStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '키워드 플레이리스트',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      // 웹(PC)에서도 모바일 앱 화면처럼 보이도록 폭을 제한한다.
      builder: (context, child) => ColoredBox(
        color: AppColors.background,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        ),
      ),
      home: HomeScreen(store: store),
    );
  }
}

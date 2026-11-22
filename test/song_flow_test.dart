// 11주차 확인 사례: PRD 수용 기준(AC) 중 이번 행동(곡 추가·키워드 폴더·기기 저장)에 해당하는 것.
// 각 테스트 이름 앞의 ACn은 PRD의 수용 기준 번호다.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyword_song_app/data/song_store.dart';
import 'package:keyword_song_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SongStore> newStore([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return SongStore.load();
}

void addSongs(SongStore store, List<(String, List<String>)> songs) {
  for (final (title, keywords) in songs) {
    final r = store.addSong(title: title, selectedKeywords: keywords);
    expect(r.ok, isTrue, reason: '준비용 곡 추가 실패: $title');
  }
}

Future<void> pumpApp(WidgetTester tester, SongStore store) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(KeywordPlaylistApp(store: store));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('AC1 곡 0개 → 제목+선택 키워드+직접 키워드로 추가하면 곡 1개·키워드 2개', (tester) async {
    final store = await newStore();
    await pumpApp(tester, store);

    await tester.tap(find.byKey(const Key('add-first-song')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('title-field')), '곡 A');
    await tester.tap(find.widgetWithText(FilterChip, '새벽'));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('custom-keyword-field')), '드라이브');
    await tester.tap(find.byKey(const Key('add-button')));
    await tester.pumpAndSettle();

    expect(store.songs.length, 1);
    expect(store.songs.single.keywords, ['새벽', '드라이브']);
    expect(find.text('내 곡 1곡 · 키워드 2개'), findsOneWidget);
    expect(find.byKey(const Key('folder-새벽')), findsOneWidget);
    expect(find.byKey(const Key('folder-드라이브')), findsOneWidget);
  });

  testWidgets('AC2 제목이 공백뿐이면 안내를 보이고 곡 수는 그대로', (tester) async {
    final store = await newStore();
    addSongs(store, [('곡 1', ['새벽']), ('곡 2', ['운동'])]);
    await pumpApp(tester, store);

    await tester.tap(find.byKey(const Key('add-song-fab')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('title-field')), '   ');
    await tester.tap(find.widgetWithText(FilterChip, '공부'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('add-button')));
    await tester.pumpAndSettle();

    expect(find.text('곡 제목을 입력하세요'), findsOneWidget);
    expect(store.songs.length, 2);
  });

  testWidgets('AC3 키워드가 없으면 안내를 보이고 곡 수는 그대로', (tester) async {
    final store = await newStore();
    addSongs(store, [('곡 1', ['새벽']), ('곡 2', ['운동'])]);
    await pumpApp(tester, store);

    await tester.tap(find.byKey(const Key('add-song-fab')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('title-field')), '곡 3');
    await tester.tap(find.byKey(const Key('add-button')));
    await tester.pumpAndSettle();

    expect(find.text('키워드를 1개 이상 선택하거나 입력하세요'), findsOneWidget);
    expect(store.songs.length, 2);
  });

  test("AC4 직접 입력 ' 새벽 , 새벽,카페' → 키워드 '새벽','카페' 2개", () {
    expect(SongStore.parseKeywords(const [], ' 새벽 , 새벽,카페'), ['새벽', '카페']);
  });

  test('AC4 보충: 선택한 키워드와 직접 입력이 겹치거나 영문 대소문자만 달라도 한 번만', () {
    expect(SongStore.parseKeywords(['새벽'], '새벽, Cafe, cafe,  '), ['새벽', 'Cafe']);
  });

  testWidgets("AC5 직접 만든 '카페'가 새 곡 추가 화면의 선택 목록에 보임", (tester) async {
    final store = await newStore();
    store.addSong(title: '곡 A', customKeywordInput: '카페');
    await pumpApp(tester, store);

    await tester.tap(find.byKey(const Key('add-song-fab')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilterChip, '카페'), findsOneWidget);
  });

  testWidgets("AC7 '새벽' 곡 3개·'운동' 곡 1개 → 폴더 새벽(3), 운동(1), 새벽을 열면 3곡", (tester) async {
    final store = await newStore();
    addSongs(store, [
      ('곡 1', ['새벽']),
      ('곡 2', ['새벽']),
      ('곡 3', ['새벽']),
      ('곡 4', ['운동']),
    ]);
    await pumpApp(tester, store);

    expect(find.descendant(of: find.byKey(const Key('folder-새벽')), matching: find.text('3곡')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('folder-운동')), matching: find.text('1곡')), findsOneWidget);

    await tester.tap(find.byKey(const Key('folder-새벽')));
    await tester.pumpAndSettle();

    expect(find.text('#새벽 · 3곡'), findsOneWidget);
    expect(find.text('곡 1'), findsOneWidget);
    expect(find.text('곡 3'), findsOneWidget);
    expect(find.text('곡 4'), findsNothing);
  });

  testWidgets('AC8 곡 0개로 시작하면 "곡을 추가해 보세요" 안내', (tester) async {
    final store = await newStore();
    await pumpApp(tester, store);

    expect(find.text('곡을 추가해 보세요'), findsOneWidget);
    expect(find.text('내 곡 0곡 · 키워드 0개'), findsOneWidget);
  });

  test('AC16 곡을 저장한 뒤 앱을 다시 시작해도(저장소에서 다시 읽어도) 곡과 키워드가 그대로', () async {
    final store = await newStore();
    store.addSong(
      title: '곡 A',
      artist: '가수 X',
      selectedKeywords: ['새벽'],
      customKeywordInput: '드라이브',
    );
    await store.saved;

    final reopened = await SongStore.load();
    expect(reopened.songs.length, 1);
    expect(reopened.songs.single.title, '곡 A');
    expect(reopened.songs.single.artist, '가수 X');
    expect(reopened.songs.single.keywords, ['새벽', '드라이브']);
  });

  testWidgets('저장 안정성: 저장 데이터가 망가져 있으면 안내를 보이고 빈 상태로 시작', (tester) async {
    final store = await newStore({SongStore.storageKey: '이건 JSON이 아님'});
    await pumpApp(tester, store);

    expect(find.byKey(const Key('load-error')), findsOneWidget);
    expect(find.text('곡을 추가해 보세요'), findsOneWidget);
  });
}

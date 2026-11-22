# 키워드 플레이리스트 (keyword-song-app)

곡마다 내가 정한 키워드를 붙이고, 그 키워드로 곡을 모아 보고 찾는 개인용 Flutter 앱 (개인 프로젝트).
앱 이름은 '키워드 곡함'에서 '키워드 플레이리스트'로 바꾸는 중이라 문서에 두 이름이 섞여 있습니다.

## 현재 상태 (2026-11-22, 11주차)

- 구현: 곡 추가(제목·키워드), 미리 있는 키워드 선택 + 직접 입력, 메인 키워드 폴더, 기기 저장
- 미구현: 곡 키워드 수정, 플레이리스트, 여러 키워드 검색, 추천, 붙여넣기, 삭제
- 자세한 확인 결과와 실패·미실행: [week11/dev-record.md](week11/dev-record.md)

## 실행

```powershell
flutter pub get
flutter run -d chrome
flutter test
```

주의: 폴더 경로에 한글이 있으면 `flutter analyze`가 오류로 끝날 수 있습니다. 이때는 `dart analyze`를 쓰거나 영문 경로에서 실행하세요.

## 문서

- `week09/` 주제 정리·분석 (PRD에 맞춰 수정 필요)
- `week11/dev-record.md` 11주차 개발 기록
- `week12/` 중간발표 장표(`midterm_slide.png`)와 대본(`script.md`)
- PRD: 별도 Claude 문서(키워드 곡함 PRD)에 있으며 이 저장소에는 아직 없음

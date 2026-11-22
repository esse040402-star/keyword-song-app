import 'package:flutter/material.dart';

import '../data/preset_keywords.dart';
import '../data/song_store.dart';
import '../theme.dart';
import '../widgets/keyword_widgets.dart';

/// 곡 추가 화면: 제목 + 키워드(선택/직접 입력) → 추가 (F1·F2).
class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key, required this.store});

  final SongStore store;

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _customController = TextEditingController();
  final Set<String> _selected = {};
  Set<AddSongError> _errors = {};

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _customController.dispose();
    super.dispose();
  }

  void _submit() {
    final result = widget.store.addSong(
      title: _titleController.text,
      artist: _artistController.text,
      selectedKeywords: _selected,
      customKeywordInput: _customController.text,
    );
    if (!result.ok) {
      setState(() => _errors = result.errors);
      return;
    }
    Navigator.of(context).pop(result.song);
  }

  @override
  Widget build(BuildContext context) {
    final customKeywords = widget.store.customKeywords;
    return Scaffold(
      appBar: AppBar(title: const Text('곡 추가')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _label('곡 제목'),
            TextField(
              key: const Key('title-field'),
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: '예: 곡 A',
                errorText: _errors.contains(AddSongError.emptyTitle)
                    ? '곡 제목을 입력하세요'
                    : null,
              ),
              onChanged: (_) {
                if (_errors.contains(AddSongError.emptyTitle)) {
                  setState(() => _errors = {..._errors}..remove(AddSongError.emptyTitle));
                }
              },
            ),
            const SizedBox(height: 20),
            _label('아티스트 (선택)'),
            TextField(
              key: const Key('artist-field'),
              controller: _artistController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: '비워 둬도 돼요'),
            ),
            const SizedBox(height: 24),
            _label('키워드 (눌러서 선택)'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final k in presetKeywords) _chip(k, custom: false),
                for (final k in customKeywords) _chip(k, custom: true),
              ],
            ),
            const SizedBox(height: 16),
            _label('직접 입력 (쉼표로 여러 개)'),
            TextField(
              key: const Key('custom-keyword-field'),
              controller: _customController,
              decoration: const InputDecoration(hintText: '예: 카페, 집중'),
              onChanged: (_) {
                if (_errors.contains(AddSongError.noKeyword)) {
                  setState(() => _errors = {..._errors}..remove(AddSongError.noKeyword));
                }
              },
            ),
            if (_errors.contains(AddSongError.noKeyword))
              const Padding(
                key: Key('keyword-error'),
                padding: EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  '키워드를 1개 이상 선택하거나 입력하세요',
                  style: TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            const SizedBox(height: 28),
            FilledButton(
              key: const Key('add-button'),
              onPressed: _submit,
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String keyword, {required bool custom}) {
    return KeywordChoiceChip(
      keyword: keyword,
      custom: custom,
      selected: _selected.contains(keyword),
      onSelected: (on) => setState(() {
        on ? _selected.add(keyword) : _selected.remove(keyword);
        _errors = {..._errors}..remove(AddSongError.noKeyword);
      }),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

import 'package:flutter/material.dart';

import '../theme.dart';

/// 곡에 붙은 키워드를 보여 주는 작은 라벨. 직접 만든 키워드는 피치색.
class KeywordTag extends StatelessWidget {
  const KeywordTag(this.keyword, {super.key, this.custom = false});

  final String keyword;
  final bool custom;

  @override
  Widget build(BuildContext context) {
    final color = custom ? AppColors.custom : AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$keyword',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// 눌러서 고르는 키워드 칩. 선택하면 색만이 아니라 체크 표시도 붙는다 (PRD 접근성).
class KeywordChoiceChip extends StatelessWidget {
  const KeywordChoiceChip({
    super.key,
    required this.keyword,
    required this.selected,
    required this.onSelected,
    this.custom = false,
  });

  final String keyword;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final bool custom;

  @override
  Widget build(BuildContext context) {
    final color = custom ? AppColors.custom : AppColors.accent;
    return FilterChip(
      label: Text(keyword),
      selected: selected,
      showCheckmark: true,
      onSelected: onSelected,
      backgroundColor: AppColors.surface,
      selectedColor: color.withValues(alpha: 0.28),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: selected ? color : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(color: selected ? color : Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/models/models.dart';

/// Frame 8 follow-up action tile (298 x 56).
class SuggestionTile extends StatelessWidget {
  const SuggestionTile({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  final Suggestion suggestion;
  final VoidCallback onTap;

  (RexSvg, Color) get _icon => switch (suggestion.action) {
    SuggestionAction.save => (RexSvg.piggyBank, RexColors.accentOrange),
    SuggestionAction.payBill => (RexSvg.banknotes, RexColors.accentCyan),
    SuggestionAction.rexyDecember => (
      RexSvg.sendAltFilled,
      RexColors.accentGreen,
    ),
    SuggestionAction.sendMoney => (RexSvg.sendAltFilled, RexColors.accentGreen),
    SuggestionAction.buyAirtime => (RexSvg.phoneCall, RexColors.accentGreen),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _icon;
    return Pressable(
      semanticLabel: '${suggestion.title}${suggestion.boldSuffix ?? ''}',
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: RexColors.softBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: RexSvgIcon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: suggestion.title),
                          if (suggestion.boldSuffix != null)
                            TextSpan(
                              text: suggestion.boldSuffix,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                      style: RexTypography.suggestionTitle,
                    ),
                  ),
                  Text(
                    suggestion.subtitle,
                    style: RexTypography.suggestionSub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: RexColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

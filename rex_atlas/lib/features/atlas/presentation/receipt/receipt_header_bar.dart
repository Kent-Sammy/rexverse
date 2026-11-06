import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/pressable.dart';

/// Back arrow plus centred title on the light-blue page, as in the receipt
/// frames ("Transaction Details", "Share Receipt").
class ReceiptHeaderBar extends StatelessWidget {
  const ReceiptHeaderBar({super.key, required this.title, this.backKey});

  final String title;
  final Key? backKey;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(8, top + 8, 8, 12),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Pressable(
                key: backKey,
                semanticLabel: 'Back',
                onTap: () => Navigator.of(context).maybePop(),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 24,
                    color: RexColors.textStrong,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RexTypography.host(
                    17,
                    weight: FontWeight.w600,
                    color: RexColors.textStrong,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/design_system/design_system.dart';
import '../widgets/atlas_brand.dart';

/// "rex" wordmark: "re" set in navy plus the Rex chevron mark as the "x".
class RexLogo extends StatelessWidget {
  const RexLogo({super.key, this.height = 24});

  /// Cap height of the wordmark.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rex',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            're',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: height * 1.25,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -height * 0.06,
              color: RexColors.logoNavy,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.04),
            child: SvgPicture.asset(AtlasAssets.mark, height: height * 0.86),
          ),
        ],
      ),
    );
  }
}

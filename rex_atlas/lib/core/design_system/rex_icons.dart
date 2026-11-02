import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icons whose Figma layer names identify a public icon set
/// (e.g. `carbon:send-alt-filled`). The SVGs in `assets/icons/` were fetched
/// from Iconify using those exact names, so they match the design source.
///
/// Iconly / vuesax icons (not publicly available) use Material icons
/// instead; those substitutions are listed in docs/ASSETS.md.
enum RexSvg {
  sendAltFilled('send_alt_filled'), // carbon:send-alt-filled
  piggyBank('piggy_bank'), // fa7-solid:piggy-bank
  banknotes('banknotes'), // wpf:banknotes
  phoneCall('phone_call'), // bxs:phone-call
  fingerprint('fingerprint'), // bi:fingerprint
  maximize('maximize'), // boxicons:maximize-filled
  close('close'), // coolicons:close
  audioFilled('audio_filled'), // ant-design:audio-filled
  arrowLeft('arrow_left'), // bi:arrow-left
  checkCircleOutlined(
    'check_circle_outlined',
  ), // ant-design:check-circle-outlined
  lightbulbAi('lightbulb_ai'); // ri:lightbulb-ai-fill

  const RexSvg(this.file);
  final String file;
  String get path => 'assets/icons/$file.svg';
}

class RexSvgIcon extends StatelessWidget {
  const RexSvgIcon(this.icon, {super.key, this.size = 24, required this.color});

  final RexSvg icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.path,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

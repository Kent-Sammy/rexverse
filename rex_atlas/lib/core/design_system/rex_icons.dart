import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icons whose Figma layer names identify a public icon set
/// (e.g. `carbon:send-alt-filled`). The SVGs in `assets/icons/` were fetched
/// from Iconify using those exact names, so they match the design source.
///
/// Iconly / vuesax icons were exported from Figma by the design owner and
/// keep their original colours unless a tint is passed.
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
  lightbulbAi('lightbulb_ai'), // ri:lightbulb-ai-fill (Figma export)
  // Exported from Figma by the design owner:
  iconlySend('iconly_send'), // Iconly/Bold/Send (composer)
  mic('mic_frame'), // ant-design:audio-filled frame (composer)
  copy('copy'), // vuesax copy (Transaction No.)
  notification('notification'), // home bell
  light('light'), // Electricity tile
  wifiSquare('wifi_square'), // Data tile (two-tone, keep colours)
  wallet('wallet'), // RexSave tile
  briefcase('briefcase'), // RexVault tile
  ticket('ticket'), // RexFlex tile
  navHome('nav_home'), // bottom menu (active, navy)
  navSave('nav_save'),
  navInvest('nav_invest'),
  navBorrow('nav_borrow'),
  navMore('nav_more'),
  eye('eye'); // balance visibility ("Show")

  const RexSvg(this.file);
  final String file;
  String get path => 'assets/icons/$file.svg';
}

class RexSvgIcon extends StatelessWidget {
  const RexSvgIcon(this.icon, {super.key, this.size = 24, this.color});

  final RexSvg icon;
  final double size;

  /// Tint colour. Null keeps the colours baked into the Figma export.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.path,
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

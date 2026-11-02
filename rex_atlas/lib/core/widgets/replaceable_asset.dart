import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shows a bundled image if it exists, otherwise a documented placeholder.
///
/// Several Figma raster/vector assets (assistant avatar, Rex Atlas mark,
/// bank logos, illustrations) could not be exported because the Figma MCP
/// plan limit was reached. Each slot has a fixed path under
/// `assets/images/` (see docs/ASSETS.md). Dropping the exported file at that
/// path replaces the placeholder with no code changes.
class ReplaceableAsset extends StatelessWidget {
  const ReplaceableAsset({
    super.key,
    required this.path,
    required this.placeholder,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String path;
  final Widget placeholder;
  final BoxFit fit;
  final double? width;
  final double? height;

  static final Map<String, Future<ByteData?>> _cache = {};
  static Future<Set<String>>? _manifest;

  /// Loads [path] only if it is listed in the asset manifest, so a missing
  /// slot never throws or triggers a network 404.
  static Future<ByteData?> _load(String path) =>
      _cache.putIfAbsent(path, () async {
        try {
          final assets = await (_manifest ??= AssetManifest.loadFromAssetBundle(
            rootBundle,
          ).then((m) => m.listAssets().toSet()));
          if (!assets.contains(path)) return null;
          return await rootBundle.load(path);
        } catch (_) {
          return null;
        }
      });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ByteData?>(
      future: _load(path),
      builder: (context, snap) {
        final data = snap.data;
        if (data == null) {
          return SizedBox(width: width, height: height, child: placeholder);
        }
        final bytes = data.buffer.asUint8List();
        if (path.endsWith('.svg')) {
          return SvgPicture.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
          );
        }
        return Image.memory(bytes, width: width, height: height, fit: fit);
      },
    );
  }
}

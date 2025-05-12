import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movna/presentation/widgets/none_widget.dart';

extension HexColorString on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true`.
  String toHexString({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${(a * 255.0).round().toRadixString(16).padLeft(2, '0')}'
      '${(r * 255.0).round().toRadixString(16).padLeft(2, '0')}'
      '${(g * 255.0).round().toRadixString(16).padLeft(2, '0')}'
      '${(b * 255.0).round().toRadixString(16).padLeft(2, '0')}';
}

const String svgThemedImagePrimary = 'fe0013';

/// This widget replace the default color by [primaryColor] from the theme of
/// the application.
///
/// [svgThemedImagePrimary] is the hexadecimal primary color to replace.
class SvgThemedWidget extends StatelessWidget {
  const SvgThemedWidget({
    required this.svgAsset,
    this.width,
    this.fit = BoxFit.contain,
    super.key,
  });

  final double? width;
  final String svgAsset;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: readSvgImage(svgAsset),
      builder: (BuildContext context, AsyncSnapshot<String> data) {
        if (data.hasData) {
          // Converts ARGB color into RGB color string
          final primaryColorHexString =
              Theme.of(context).colorScheme.primary.toHexString().substring(3);

          return SvgPicture.string(
            data.data!.replaceAll(
              RegExp(svgThemedImagePrimary, caseSensitive: false),
              primaryColorHexString,
            ),
            fit: fit,
            width: width,
          );
        }
        return const NoneWidget();
      },
    );
  }

  Future<String> readSvgImage(String path) async {
    return rootBundle.loadString(path);
  }
}

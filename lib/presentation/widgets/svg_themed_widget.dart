import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movna/presentation/widgets/none_widget.dart';

const int hexadecimalToSubtract = 0xFF000000;
const String svgThemedImagePrimary = 'fe0013';

/// This widget replace the default color by [primaryColor] from the theme of
/// the application.
///
/// [svgThemedImagePrimary] is the hexadecimal primary color to replace.
/// [hexadecimalToSubtract] is the hexadecimal value to subtract to convert an
/// ARGB color into RGB color.
class SvgThemedWidget extends StatelessWidget {
  const SvgThemedWidget({
    required this.svgAsset,
    this.width,
    this.fit = BoxFit.contain,
    Key? key,
  }) : super(key: key);

  final double? width;
  final String svgAsset;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: readSvgImage(svgAsset),
      builder: (BuildContext context, AsyncSnapshot<String> data) {
        if (data.hasData) {
          // Converts ARGB color into RGB color
          final primaryColor = Theme.of(context).colorScheme.primary.value -
              hexadecimalToSubtract;

          return SvgPicture.string(
            data.data!.replaceAll(
              RegExp(svgThemedImagePrimary, caseSensitive: false),
              primaryColor.toRadixString(16).padLeft(6, '0').toString(),
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

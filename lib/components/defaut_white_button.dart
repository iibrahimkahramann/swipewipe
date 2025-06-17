import 'package:flutter/widgets.dart';
import 'package:swipewipe/config/theme/custom_theme.dart';

class DefaultWhiteButton extends StatelessWidget {
  const DefaultWhiteButton({
    super.key,
    required this.height,
    required this.width,
    required this.onTap,
    required this.title,
  });

  final double height;
  final double width;
  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        height: height * 0.1,
        width: width,
        decoration: BoxDecoration(
          color: CustomTheme.accentColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.elliptical(40, 40),
            topRight: Radius.elliptical(40, 40),
            bottomLeft: Radius.elliptical(30, 30),
            bottomRight: Radius.elliptical(30, 30),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: CustomTheme.textTheme(context).bodyMedium?.copyWith(
                  color: CustomTheme.backgroundColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
      ),
    );
  }
}

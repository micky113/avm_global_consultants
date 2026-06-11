// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureCard extends StatelessWidget {
  final Color baseColor;
  final IconData icon;
  final String title;
  final String firstText;
  final String secondText;
  final String image;
  final double? width;
  final double? height;

  const FeatureCard({
    super.key,
    required this.baseColor,
    required this.icon,
    required this.title,
    required this.firstText,
    required this.secondText,
    required this.image,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Color endColor = baseColor;

    final Color startColor = baseColor.withValues(
      red: 255,
      green: 239,
      blue: 234,
    ); // Original color
    return Container(
      height: height ?? 530,
      width: width ?? 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        gradient: LinearGradient(
          begin: Alignment.topLeft, // Start from top-left
          end: Alignment.bottomRight, // End at bottom-right
          colors: [
            startColor, // Darker color at the start
            endColor, // Lighter color at the end
          ],
          // You can also add 'stops' for more control over where colors transition
          // stops: [0.0, 1.0], // Optional: 0.0 means first color at start, 1.0 means second color at end
        ),
        // TODO: Add a DecorationImage or CustomPainter here for the subtle geometric pattern
      ),
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Title
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 25,
              height: 1.3,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          Divider(
            color: Colors.white,
            thickness: 1.5,
            indent: 3,
            endIndent: 10,
          ),
          SizedBox(height: 15),
          Text(
            firstText,
            style: GoogleFonts.notoSans(
              fontSize: 22,
              height: 1.3,
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          Text(
            secondText,
            style: GoogleFonts.notoSans(
              fontSize: 22,
              height: 1.3,
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
          ),
          Spacer(), // Pushes content apart
          Image(image: AssetImage(image), height: 160, width: 160, fit: BoxFit.contain,),

          Spacer(), // Pushes content apart
          // "Find out more" Button
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Find out more',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

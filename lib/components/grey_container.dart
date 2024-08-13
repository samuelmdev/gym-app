import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final String text1;
  final String text2;

  const CustomContainer({
    super.key,
    required this.text1,
    required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900], // Background color
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8), // Rounded edges
      ),
      padding: const EdgeInsets.all(
          10.0), // Optional: Add padding inside the container
      child: Column(
        mainAxisSize: MainAxisSize.min, // Adjust the column size to its content
        children: [
          Text(
            text1,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10), // Optional: Add spacing between texts
          Text(text2),
        ],
      ),
    );
  }
}

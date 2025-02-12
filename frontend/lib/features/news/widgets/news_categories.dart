import 'package:flutter/material.dart';

class NewsCategories extends StatelessWidget {
  const NewsCategories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          horizontal: 16), // Только горизонтальные отступы
      child: Row(
          // ...
          ),
    );
  }
}

import 'package:flutter/material.dart';

class TimeAgo extends StatelessWidget {
  final DateTime dateTime;

  const TimeAgo({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final difference = DateTime.now().difference(dateTime);
    String timeAgo;

    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}д назад';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}ч назад';
    } else {
      timeAgo = '${difference.inMinutes}м назад';
    }

    return Text(
      timeAgo,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

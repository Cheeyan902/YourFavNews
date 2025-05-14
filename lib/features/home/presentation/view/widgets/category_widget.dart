import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:news_challenge/core/utils/extensions.dart';

import '../../../data/models/models.dart';
import '../../../data/models/news_category_extensions.dart';

class CategoryWidget extends StatelessWidget {
  final NewsModel newsModel; 

  const CategoryWidget({
    super.key,
    required this.newsModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width * 0.25,
      height: context.height * 0.03,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: CupertinoColors.activeBlue,
      ),
      child: Center(
        child: Text(
          newsModel.inferredCategory,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

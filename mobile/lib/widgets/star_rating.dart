import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final bool showRating;
  final Function(double)? onRatingChanged;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 24,
    this.color = Colors.amber,
    this.showRating = true,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return GestureDetector(
            onTap: onRatingChanged != null
                ? () => onRatingChanged!(index + 1.0)
                : null,
            child: Icon(
              index < rating
                  ? Icons.star
                  : index < rating + 0.5
                      ? Icons.star_half
                      : Icons.star_border,
              size: size,
              color: color,
            ),
          );
        }),
        if (showRating) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
} 
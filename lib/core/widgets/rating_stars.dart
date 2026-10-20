import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int? count;
  final double starSize;
  final bool showScoreText;
  final ValueChanged<int>? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.count,
    this.starSize = 16.0,
    this.showScoreText = true,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = onRatingChanged != null;

    final stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;

        if (isInteractive) {
          icon = starValue <= rating ? Icons.star_rounded : Icons.star_outline_rounded;
        } else {
          if (rating >= starValue) {
            icon = Icons.star_rounded;
          } else if (rating >= starValue - 0.5) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_outline_rounded;
          }
        }

        final starWidget = Icon(
          icon,
          size: starSize,
          color: AppColors.star,
        );

        if (isInteractive) {
          return InkWell(
            onTap: () => onRatingChanged!(starValue),
            borderRadius: BorderRadius.circular(starSize / 2),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: starWidget,
            ),
          );
        }

        return starWidget;
      }),
    );

    if (!showScoreText || isInteractive) {
      return stars;
    }

    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        stars,
        const SizedBox(width: AppSpacing.xs),
        Text(
          rating.toStringAsFixed(1),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '($count)',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

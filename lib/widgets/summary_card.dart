import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable summary card widget for dashboard metrics
class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.borderBlue,
            width: 1.5,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Center icon and text vertically
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              child: Icon(
                icon,
                color: AppTheme.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  // Removed MainAxisSize.min to allow Column to expand
                  children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textGrey,
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: AppTheme.textGrey,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    const SizedBox(height: AppTheme.spacing4),
                    // Placeholder to maintain equal height with cards that have subtitles
                    Text(
                      '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
    );
  }
}

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/avatar.dart';
import 'package:quest/theme/theme.dart';
import 'package:intl/intl.dart';
class EventDottedCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isAttending;
  final VoidCallback onTap;
  const EventDottedCard({super.key, required this.event, required this.isAttending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(30),
            dashPattern: const [6, 6], // dash length, gap
            strokeWidth: 0.5,
            color: AppTheme.textColor2,
            // color: AppTheme.redColor,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] ?? 'Tech Conference 2026',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event['description'] ??
                        'Exploring the latest in technology and innovation',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: AppTheme.textColor2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedLocation01,
                        size: 14,
                        color: Color(0xff8e8e93),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        event['location'] ?? 'No location specified',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppTheme.textColor2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 58,
                            height: 23,
                            child: Stack(
                              children: const [
                                Positioned(
                                  left: 0,
                                  child: CustomAvatar(imageUrl: 'assets/images/boy.png', radius: 11.5),
                                ),
                                Positioned(
                                  left: 15,
                                  child: CustomAvatar(imageUrl: 'assets/images/boy.png', radius: 11.5),
                                ),
                                Positioned(
                                  left: 30,
                                  child: CustomAvatar(imageUrl: 'assets/images/boy.png', radius: 11.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${(event['attendees'] as List?)?.length ?? 0} attending",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: AppTheme.textColor2,
                            ),
                          ),
                        ],
                      ),

                      // Removed hardcoded favorites
                    ],
                  ),

                  const SizedBox(height: 15),

                  if (isAttending)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.purpleColor.withValues(alpha: 0.1),

                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'You\'re attending',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.purpleColor,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 7),
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowDown01,
                                size: 18,
                                color: AppTheme.purpleColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.buttonColor2.withValues(alpha: 0.3),
                      border: Border.all(
                        width: 0.5,
                        color: AppTheme.buttonColor2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCalendar04,
                          size: 16,
                          color: Color(0xff8e8e93),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${DateTime.tryParse(event['date'] ?? '')?.day ?? 24}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 0),

                        SizedBox(
                          height: 10, // 👈 controls vertical line height
                          child: VerticalDivider(
                            thickness: 1.5, // 👈 line width
                            color: AppTheme.textColor2.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          event['date'] != null
                              ? DateFormat('MMM yyyy').format(DateTime.parse(event['date']))
                              : '',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 15),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedClock01,
                          size: 16,
                          color: Color(0xff8e8e93),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          event['time'] ?? '12pm - 3pm',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}

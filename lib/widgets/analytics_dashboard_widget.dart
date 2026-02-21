import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Map<String, List<String>> categoryGroups = {
  'Solid Waste Management': [
    'Uncollected Garbage',
    'Hauling of Cut Tree or Trimmings',
  ],
  'Environment & Natural Resources': [
    'Overgrown Trees and Plants',
    'Wildlife for Rescue',
    'Open Burning of Waste',
    'Clogged Natural Waterways',
    'Water Polluting Activities',
    'Disruptive Noisy Activities',
    'Odor from Agriculture & Industry',
    'Fly Problem from Piggery & Poultry',
  ],
};

final List<String> allIssueLabels = [
  'Uncollected Garbage',
  'Hauling of Cut Tree or Trimmings',
  'Overgrown Trees and Plants',
  'Wildlife for Rescue',
  'Open Burning of Waste',
  'Clogged Natural Waterways',
  'Water Polluting Activities',
  'Disruptive Noisy Activities',
  'Odor from Agriculture & Industry',
  'Fly Problem from Piggery & Poultry',
];

Color getColorForIssueLabel(String label, bool isMaxCount) {
  return isMaxCount ? const Color(0xFFDC143C) : const Color(0xFFFFC107);
}

class AnalyticsDashboardWidget extends StatelessWidget {
  final Map<String, int> categoryCounts;

  const AnalyticsDashboardWidget({
    super.key,
    required this.categoryCounts,
  });

  @override
  Widget build(BuildContext context) {
    final maxCount = categoryCounts.values.isEmpty
        ? 1
        : categoryCounts.values.reduce((a, b) => a > b ? a : b);

    final allCategories = allIssueLabels
        .map((issue) => MapEntry(issue, categoryCounts[issue] ?? 0))
        .toList();
    allCategories.sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF23552C), width: 1.5),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...allCategories.map((categoryEntry) {
            final label = categoryEntry.key;
            final count = categoryEntry.value;
            final barValue =
                maxCount > 0 ? count / maxCount : 0.0;
            final isMaxCount = count == maxCount;
            final color = getColorForIssueLabel(label, isMaxCount);

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 6,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontVariations: [
                          FontVariation('wght', 600)
                        ],
                        color: Color(0xFF23552C),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),

                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: barValue,
                        minHeight: 6,
                        backgroundColor:
                            const Color(0xFFE8E8E8),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                                color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  SizedBox(
                    width: 22,
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontVariations: [
                          FontVariation('wght', 700)
                        ],
                        color: Color(0xFF23552C),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
      ),
    );
  }
}

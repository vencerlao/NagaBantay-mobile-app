import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nagabantay_mobile_app/pages/continue-report_page.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // Options for each category
  final Map<String, List<String>> categoryOptions = {
    'Solid Waste Management': ['Uncollected Garbage', 'Hauling of Cut Tree or Trimmings'],
    'Environment & Natural Resources': ['Overgrown Trees and Plants', 'Wildlife for Rescue',
    'Open Burning of Waste', 'Clogged Natural Waterways', 'Water Polluting Activities',
    'Disruptive Noisy Activities', 'Odor from Agriculture & Industry', 'Fly Problem from Piggery & Poultry'],

  };

  // Track selected options per category
  final Map<String, Set<String>> selectedChipsPerCategory = {};

  void toggleChip(String category, String label) {
    setState(() {
      selectedChipsPerCategory.putIfAbsent(category, () => <String>{});
      if (selectedChipsPerCategory[category]!.contains(label)) {
        selectedChipsPerCategory[category]!.remove(label);
      } else {
        selectedChipsPerCategory[category]!.add(label);
      }
    });
  }

  Widget buildCategoryGroup(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF23552C),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selectedChipsPerCategory[title]?.contains(item) ?? false;
            return ChoiceChip(
              label: Text(
                item,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF23552C),
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontVariations: [FontVariation('wght', 400)],
                ),
              ),
              selected: isSelected,
              onSelected: (_) => toggleChip(title, item),

              // SELECTED (filled green)
              selectedColor: const Color(0xFF23552C),

              // UNSELECTED (hollow)
              backgroundColor: Colors.transparent,

              // Border for hollow look
              shape: StadiumBorder(
                side: BorderSide(
                  color: const Color(0xFF23552C),
                  width: 1.5,
                ),
              ),

              // Remove default checkmark padding look
              showCheckmark: false,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  bool hasSelection() {
    return selectedChipsPerCategory.values.any((set) => set.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            PhosphorIcons.caretLeft,
            size: 22.0,
            color: const Color(0xff06370b),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a category that best\ndescribes the issue',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                color: Color(0xFF23552C),
                fontVariations: [
                  FontVariation('wght', 700),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Build all category groups
            ...categoryOptions.entries.map((entry) {
              return buildCategoryGroup(entry.key, entry.value);
            }).toList(),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!hasSelection()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one option')),
                    );
                  } else {
                    // Navigate to your category report page and pass selections if needed
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => const ReportContinuePage(),
                    ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23552C),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

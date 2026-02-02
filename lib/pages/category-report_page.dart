import 'package:flutter/material.dart';
import 'package:nagabantay_mobile_app/pages/continue-report_page.dart';
import 'package:nagabantay_mobile_app/models/report_draft.dart';

class ReportPage extends StatefulWidget {
  final String phoneNumber;

  const ReportPage({super.key, required this.phoneNumber});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final Map<String, List<String>> categoryOptions = {
    'Solid Waste Management': ['Uncollected Garbage', 'Hauling of Cut Tree or Trimmings'],
    'Environment & Natural Resources': ['Overgrown Trees and Plants', 'Wildlife for Rescue',
    'Open Burning of Waste', 'Clogged Natural Waterways', 'Water Polluting Activities',
    'Disruptive Noisy Activities', 'Odor from Agriculture & Industry', 'Fly Problem from Piggery & Poultry'],

  };

  String? selectedIssue;

  final ReportDraft draft = ReportDraft();

  void goToNextPage(String selectedCategory, String phoneNumber) {
    draft.issue = selectedCategory;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportContinuePage(
          draft: draft,
          phoneNumber: widget.phoneNumber,
        ),
      ),
    );
  }

  void toggleChip(String label) {
    setState(() {
      if (selectedIssue == label) {
        selectedIssue = null;
      } else {
        selectedIssue = label;
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
            final isSelected = selectedIssue == item;

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
              onSelected: (_) {
                setState(() {
                  if (selectedIssue == item) {
                    selectedIssue = null;
                  } else {
                    selectedIssue = item;
                  }
                });
              },

              selectedColor: const Color(0xFF23552C),

              backgroundColor: Colors.transparent,

              shape: StadiumBorder(
                side: BorderSide(
                  color: const Color(0xFF23552C),
                  width: 1.5,
                ),
              ),

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
    return selectedIssue != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 48,
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

            ...categoryOptions.entries.map((entry) {
              return buildCategoryGroup(entry.key, entry.value);
            }).toList(),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedIssue == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an issue')),
                    );
                    return;
                  }

                  draft.issue = selectedIssue;

                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportContinuePage(
                          draft: draft,
                          phoneNumber: widget.phoneNumber,
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save report: $e')),
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

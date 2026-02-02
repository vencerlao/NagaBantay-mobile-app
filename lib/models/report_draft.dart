class ReportDraft {
  String? issue; // selected issue
  String? description;
  String? imagePath;
  double? latitude;
  double? longitude;

  String toModelInput() {
    final issueText = issue ?? '';
    final desc = description ?? '';
    return 'Issue: $issueText\nDescription: $desc';
  }
}

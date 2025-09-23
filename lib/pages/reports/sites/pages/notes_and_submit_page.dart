import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/reports/shared/widgets/notes_and_submit_widget.dart';

import '../models/breeding_site_report_data.dart';

class NotesAndSubmitPage extends StatefulWidget {
  final BreedingSiteReportData reportData;
  final VoidCallback onSubmit;
  final VoidCallback onPrevious;
  final bool isSubmitting;

  const NotesAndSubmitPage({
    Key? key,
    required this.reportData,
    required this.onSubmit,
    required this.onPrevious,
    required this.isSubmitting,
  }) : super(key: key);

  @override
  _NotesAndSubmitPageState createState() => _NotesAndSubmitPageState();
}

class _NotesAndSubmitPageState extends State<NotesAndSubmitPage> {
  void _updateNotes(String? notes) {
    widget.reportData.notes = notes;
  }

  @override
  Widget build(BuildContext context) {
    return NotesAndSubmitWidget(
      initialNotes: widget.reportData.notes,
      onNotesChanged: _updateNotes,
      onSubmit: widget.onSubmit,
      onPrevious: widget.onPrevious,
      isSubmitting: widget.isSubmitting,
      notesHint:
          '(HC) e.g., "Large container", "Near construction site", "Visible mosquito larvae"...',
      submitLoadingText: '(HC) Submitting your breeding site report...',
    );
  }
}

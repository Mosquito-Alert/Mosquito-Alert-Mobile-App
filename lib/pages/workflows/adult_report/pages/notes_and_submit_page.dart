import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';

import '../models/adult_report_data.dart';

class NotesAndSubmitPage extends StatefulWidget {
  final AdultReportData reportData;
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
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill notes if they exist
    if (widget.reportData.notes != null) {
      _notesController.text = widget.reportData.notes!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateNotes() {
    widget.reportData.notes =
        _notesController.text.isEmpty ? null : _notesController.text;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary card
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.summarize, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Report Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildSummaryRow(
                      'Photos', '${widget.reportData.photos.length} selected'),
                  _buildSummaryRow(
                      'Location', widget.reportData.locationDescription),
                  _buildSummaryRow(
                      'Environment', widget.reportData.environmentDisplayText),
                  _buildSummaryRow('Date',
                      widget.reportData.createdAt.toString().substring(0, 19)),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Notes section
          Text(
            'Additional Notes (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Add any additional observations or details about the mosquito or circumstances.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 12),

          TextField(
            controller: _notesController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText:
                  'e.g., "Found near standing water", "Very active", "Unusual markings"...',
              labelText: 'Notes',
            ),
            onChanged: (value) => _updateNotes(),
          ),

          SizedBox(height: 24),

          // Submit section
          if (widget.isSubmitting) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Submitting your report...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Please wait while we process your mosquito report.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Ready to submit
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Ready to Submit!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your mosquito report will help scientists track mosquito populations and prevent disease transmission.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 16),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.isSubmitting ? null : widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('(HC) Back'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: widget.isSubmitting ? null : widget.onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: widget.isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('(HC) Submitting...'),
                          ],
                        )
                      : Text(
                          MyLocalizations.of(context, 'send_data'),
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

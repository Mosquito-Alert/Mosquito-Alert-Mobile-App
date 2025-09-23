import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart' as api;
import 'package:mosquito_alert_app/pages/reports/bite/models/bite_report_data.dart';
import 'package:mosquito_alert_app/pages/reports/bite/widgets/body_part_selector.dart';
import 'package:mosquito_alert_app/pages/reports/bite/widgets/environment_selector.dart';
import 'package:mosquito_alert_app/pages/reports/bite/widgets/timing_selector.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';

/// Page for collecting bite information: counts, environment, and timing
class BiteQuestionsPage extends StatefulWidget {
  final BiteReportData reportData;
  final Function({
    int? head,
    int? leftArm,
    int? rightArm,
    int? chest,
    int? leftLeg,
    int? rightLeg,
  }) onBiteCountsChanged;
  final Function(api.BiteRequestEventEnvironmentEnum) onEnvironmentChanged;
  final Function(api.BiteRequestEventMomentEnum) onTimingChanged;
  final VoidCallback? onNext;
  final VoidCallback onPrevious;
  final bool canProceed;

  const BiteQuestionsPage({
    Key? key,
    required this.reportData,
    required this.onBiteCountsChanged,
    required this.onEnvironmentChanged,
    required this.onTimingChanged,
    this.onNext,
    required this.onPrevious,
    required this.canProceed,
  }) : super(key: key);

  @override
  _BiteQuestionsPageState createState() => _BiteQuestionsPageState();
}

class _BiteQuestionsPageState extends State<BiteQuestionsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '(HC) Bite Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          // Subtitle
          Text(
            '(HC) Please provide details about the mosquito bites',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 24),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Body part selector
                  Text(
                    '(HC) How many bites on each body part?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 16),

                  BodyPartSelector(
                    headCount: widget.reportData.headCount,
                    leftArmCount: widget.reportData.leftArmCount,
                    rightArmCount: widget.reportData.rightArmCount,
                    chestCount: widget.reportData.chestCount,
                    leftLegCount: widget.reportData.leftLegCount,
                    rightLegCount: widget.reportData.rightLegCount,
                    onCountChanged: widget.onBiteCountsChanged,
                  ),

                  SizedBox(height: 32),

                  // Total bites display
                  if (widget.reportData.totalBites > 0) ...[
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        border: Border.all(color: Colors.blue[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          SizedBox(width: 8),
                          Text(
                            '(HC) Total bites: ${widget.reportData.totalBites}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                  ],

                  // Environment question
                  Text(
                    '(HC) Where did the biting occur?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 16),

                  EnvironmentSelector(
                    selectedEnvironment: widget.reportData.eventEnvironment,
                    onEnvironmentChanged: widget.onEnvironmentChanged,
                  ),

                  SizedBox(height: 32),

                  // Timing question
                  Text(
                    '(HC) When did the biting occur?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 16),

                  TimingSelector(
                    selectedTiming: widget.reportData.eventMoment,
                    onTimingChanged: widget.onTimingChanged,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onPrevious,
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
                  onPressed: widget.canProceed ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    MyLocalizations.of(context, 'continue_txt'),
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
}

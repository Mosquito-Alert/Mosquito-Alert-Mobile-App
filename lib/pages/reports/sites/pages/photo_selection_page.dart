import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/reports/shared/widgets/photo_selector.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';

import '../models/breeding_site_report_data.dart';

class PhotoSelectionPage extends StatefulWidget {
  final BreedingSiteReportData reportData;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const PhotoSelectionPage({
    Key? key,
    required this.reportData,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  _PhotoSelectionPageState createState() => _PhotoSelectionPageState();
}

class _PhotoSelectionPageState extends State<PhotoSelectionPage> {
  void _onPhotosChanged() {
    setState(() {
      // Trigger rebuild to update the continue button state
    });
  }

  bool get _canProceed => widget.reportData.photos.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Photo selector component
        Expanded(
          child: PhotoSelector(
            selectedPhotos: widget.reportData.photos,
            onPhotosChanged: _onPhotosChanged,
            maxPhotos: 3,
            minPhotos: 1,
            titleKey: 'bs_info_adult_title',
            subtitleKey: 'camera_info_breeding_txt_01',
            infoBadgeTextKey: 'camera_info_breeding_txt_02',
          ),
        ),

        // Navigation buttons
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
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
                  onPressed: _canProceed ? widget.onNext : null,
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
        ),
      ],
    );
  }
}

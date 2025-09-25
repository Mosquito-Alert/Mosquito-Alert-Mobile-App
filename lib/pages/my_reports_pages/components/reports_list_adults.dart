import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:provider/provider.dart';

class ReportsListAdults extends StatefulWidget {
  const ReportsListAdults({super.key});

  @override
  State<ReportsListAdults> createState() => _ReportsListAdultsState();
}

class _ReportsListAdultsState extends State<ReportsListAdults> {
  List<Observation> adultReports = [];
  bool isLoading = true;
  late ObservationsApi observationsApi;

  @override
  void initState() {
    super.initState();
    MosquitoAlert apiClient =
        Provider.of<MosquitoAlert>(context, listen: false);
    observationsApi = apiClient.getObservationsApi();
    _loadAdultReports();
  }

  Future<void> _loadAdultReports() async {
    try {
      final response = await observationsApi.listMine();
      final reports = response.data?.results?.toList() ?? [];

      setState(() {
        adultReports = reports;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading adult reports: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (adultReports.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAdultReports,
      child: ListView.builder(
        itemCount: adultReports.length,
        itemBuilder: (context, index) {
          return _buildAdultReportTile(adultReports[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(MyLocalizations.of(context, 'no_reports_yet_txt')),
    );
  }

  Widget _buildAdultReportTile(Observation report) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1),
          child: const Icon(
            Icons.bug_report,
            color: Colors.orange,
          ),
        ),
        title: Text(
          MyLocalizations.of(context, 'adult_report'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMd().add_jm().format(report.createdAt),
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              '${MyLocalizations.of(context, 'location')}: ${report.location.point.latitude.toStringAsFixed(4)}, ${report.location.point.longitude.toStringAsFixed(4)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: () {
          // Simple tap handler for now
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(MyLocalizations.of(context, 'feature_coming_soon')),
            ),
          );
        },
      ),
    );
  }
}

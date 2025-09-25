import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:provider/provider.dart';

class ReportsListSites extends StatefulWidget {
  const ReportsListSites({super.key});

  @override
  State<ReportsListSites> createState() => _ReportsListSitesState();
}

class _ReportsListSitesState extends State<ReportsListSites> {
  List<BreedingSite> siteReports = [];
  bool isLoading = true;
  late BreedingSitesApi breedingSitesApi;

  @override
  void initState() {
    super.initState();
    MosquitoAlert apiClient =
        Provider.of<MosquitoAlert>(context, listen: false);
    breedingSitesApi = apiClient.getBreedingSitesApi();
    _loadSiteReports();
  }

  Future<void> _loadSiteReports() async {
    try {
      final response = await breedingSitesApi.listMine();
      final reports = response.data?.results?.toList() ?? [];

      setState(() {
        siteReports = reports;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading site reports: $e');
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

    if (siteReports.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadSiteReports,
      child: ListView.builder(
        itemCount: siteReports.length,
        itemBuilder: (context, index) {
          return _buildSiteReportTile(siteReports[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(MyLocalizations.of(context, 'no_reports_yet_txt')),
    );
  }

  Widget _buildSiteReportTile(BreedingSite report) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(
            Icons.water_drop,
            color: Colors.blue,
          ),
        ),
        title: Text(
          MyLocalizations.of(context, 'site_report'),
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

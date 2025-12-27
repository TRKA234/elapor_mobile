import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  List<Report> _reports = [];
  bool _isLoading = false;

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;

  Future<void> refreshReports() async {
    _isLoading = true;
    notifyListeners();
    _reports = await ReportService().fetchReports();
    _isLoading = false;
    notifyListeners();
  }
}

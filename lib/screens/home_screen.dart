import 'package:elapor_mobile/screens/add_report_screen.dart';
import 'package:elapor_mobile/screens/detail_report_screen.dart';
import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Report>> futureReports;
  String totalLaporan = "0";
  String sourceData = "-";

  @override
  void initState() {
    super.initState();
    futureReports = ReportService().fetchReports();
    fetchStats();
  }

  // Mengambil data dari Python Stats Service (Port 8084)
  Future<void> fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.statsUrl}/summary"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalLaporan = data['total_reports'].toString();
          sourceData = data['source'];
        });
      }
    } catch (e) {
      print("Error Stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("E-Lapor Microservices")),
      body: Column(
        children: [
          // Bagian Header Statistik (Data dari Python & Redis)
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Laporan (Redis Caching)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Sumber: $sourceData",
                      style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  ],
                ),
                Text(
                  totalLaporan,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // Bagian Daftar Laporan (Data dari PHP & MySQL)
          Expanded(
            child: FutureBuilder<List<Report>>(
              future: futureReports,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var report = snapshot.data![index];
                      return ListTile(
                        leading: Icon(Icons.location_on, color: Colors.red),
                        title: Text(report.title),
                        subtitle: Text(
                          "Koordinat: ${report.lat}, ${report.lng}",
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailReportScreen(report: report),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Gagal konek ke Backend. Pastikan Docker Jalan!",
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Pindah ke halaman tambah laporan
          bool? refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReportScreen()),
          );

          //jika berhasil tambah data, refreshlost di home
          if (refresh == true) {
            setState(() {
              futureReports = ReportService().fetchReports();
              fetchStats();
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

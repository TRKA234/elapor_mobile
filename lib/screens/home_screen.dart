import 'package:elapor_mobile/screens/add_report_screen.dart';
import 'package:elapor_mobile/screens/detail_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  List<Report> allReports = [];
  List<Report> filteredReports = [];
  String totalLaporan = "0";
  String sourceData = "-";
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _selectedStatus = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Umum',
    'Keamanan',
    'Jalan Rusak',
    'Sanitasi',
    'Sosial',
    'Infrastruktur',
    'Lingkungan',
    'Lainnya'
  ];

  final List<String> _statuses = [
    'Semua',
    'Pending',
    'Diproses',
    'Selesai'
  ];

  @override
  void initState() {
    super.initState();
    futureReports = ReportService().fetchReports();
    fetchStats();
  }

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

  Future<void> _refreshReports() async {
    setState(() {
      futureReports = ReportService().fetchReports();
    });
  }

  void _applyFilters(List<Report> reports) {
    filteredReports = reports.where((report) {
      final matchesSearch = _searchQuery.isEmpty ||
          report.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          report.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'Semua' || report.category == _selectedCategory;

      final matchesStatus = _selectedStatus == 'Semua' ||
          report.status.toLowerCase() == _selectedStatus.toLowerCase();

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber;
      case 'diproses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: Text("E-Lapor Microservices"),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshReports,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReports,
        child: FutureBuilder<List<Report>>(
          future: futureReports,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("Belum ada laporan"));
            }

            allReports = snapshot.data!;
            _applyFilters(allReports);

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Statistik Header
                  Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Laporan",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          totalLaporan,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Sumber: $sourceData (Redis Caching)",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari laporan...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        _applyFilters(allReports);
                      },
                    ),
                  ),
                  SizedBox(height: 12),

                  // Filter Category
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() => _selectedCategory = category);
                              _applyFilters(allReports);
                            },
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Filter Status
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: _statuses.map((status) {
                        final isSelected = _selectedStatus == status;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() => _selectedStatus = status);
                              _applyFilters(allReports);
                            },
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: Colors.green,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Laporan List
                  if (filteredReports.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada laporan ditemukan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredReports.length,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailReportScreen(report: report),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              report.title,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    report.category,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(
                                                        report.status),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    report.status.toUpperCase(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (report.photoUrls.isNotEmpty)
                                        Container(
                                          width: 50,
                                          height: 50,
                                          margin: EdgeInsets.only(left: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                report.photoUrls[0],
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (report.description.isNotEmpty) ...[
                                    SizedBox(height: 8),
                                    Text(
                                      report.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              size: 14,
                                              color: Colors.grey),
                                          SizedBox(width: 4),
                                          Text(
                                            report.address,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.comment,
                                              size: 14,
                                              color: Colors.grey),
                                          SizedBox(width: 4),
                                          Text(
                                            '${report.commentCount}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    dateFormatter.format(report.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReportScreen()),
          ).then((result) {
            if (result == true) {
              _refreshReports();
            }
          });
        },
        tooltip: 'Buat Laporan Baru',
        child: Icon(Icons.add),
      ),
    );
  }
}
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

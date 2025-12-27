import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class AddReportScreen extends StatefulWidget {
  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;

  // Simulasi Koordinat GPS (Bisa dikembangkan pakai package geolocator nanti)
  final String _lat = "-6.2000";
  final String _lng = "106.8166";

  Future<void> _submitReport() async {
    if (_titleController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Mengirim data ke PHP menggunakan parameter yang sudah kita buat sebelumnya
      final url = Uri.parse(
        "${ApiConfig.reportUrl}/index.php?title=${_titleController.text}&lat=$_lat&lng=$_lng",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Laporan Berhasil Terkirim!")));
        Navigator.pop(context, true); // Kembali ke Home dan beri tanda sukses
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Buat Laporan Baru")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Judul Masalah",
                hintText: "Contoh: Lampu Jalan Mati",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              tileColor: Colors.grey[200],
              leading: Icon(Icons.location_on, color: Colors.red),
              title: Text("Lokasi GPS (Otomatis)"),
              subtitle: Text("Lat: $_lat, Lng: $_lng"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("KIRIM LAPORAN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

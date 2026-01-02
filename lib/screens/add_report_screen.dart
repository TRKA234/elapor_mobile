import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../services/location_service.dart';
import '../services/image_service.dart';
import '../widgets/location_picker_dialog.dart';
import '../widgets/photo_gallery_widget.dart';

class AddReportScreen extends StatefulWidget {
  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final LocationService _locationService = LocationService();
  final ImageService _imageService = ImageService();

  String _category = 'Umum';
  double _lat = 0;
  double _lng = 0;
  String _address = 'Belum dipilih';
  List<File> _selectedImages = [];
  bool _isLoading = false;

  final List<String> _categories = [
    'Umum',
    'Keamanan',
    'Jalan Rusak',
    'Sanitasi',
    'Sosial',
    'Infrastruktur',
    'Lingkungan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
          _address = address;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showLocationPicker() {
    showDialog(
      context: context,
      builder: (context) => LocationPickerDialog(
        onLocationPicked: (position, address) {
          setState(() {
            _lat = position.latitude;
            _lng = position.longitude;
            _address = address;
          });
        },
        initialLat: _lat,
        initialLng: _lng,
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Judul laporan tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.reportUrl}/create.php'),
      );

      request.fields.addAll({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _category,
        'latitude': _lat.toString(),
        'longitude': _lng.toString(),
        'address': _address,
        'user_id': '1', // Bisa diganti dengan user ID dari auth
        'user_name': 'User',
      });

      for (var image in _selectedImages) {
        request.files.add(
          await http.MultipartFile.fromPath('photos[]', image.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan Berhasil Dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengirim laporan')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buat Laporan Baru'), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul
            Text(
              'Judul Laporan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Contoh: Jalan Rusak di Jl. Sudirman',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLength: 100,
            ),
            SizedBox(height: 16),

            // Kategori
            Text(
              'Kategori',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                underline: SizedBox(),
                padding: EdgeInsets.symmetric(horizontal: 12),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() => _category = value ?? 'Umum');
                },
              ),
            ),
            SizedBox(height: 16),

            // Deskripsi
            Text(
              'Deskripsi Detail',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Jelaskan detail permasalahan...',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            SizedBox(height: 16),

            // Lokasi
            Text(
              'Lokasi Laporan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: _showLocationPicker,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lat: ${_lat.toStringAsFixed(6)} | Lng: ${_lng.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _address,
                                style: TextStyle(fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Tap untuk ubah lokasi',
                        style: TextStyle(fontSize: 11, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Foto
            PhotoGalleryWidget(
              selectedImages: _selectedImages,
              onImagesChanged: (images) {
                setState(() => _selectedImages = images);
              },
              maxImages: 5,
            ),
            SizedBox(height: 24),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text('KIRIM LAPORAN'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

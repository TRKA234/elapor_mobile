import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationPickerDialog extends StatefulWidget {
  final Function(Position, String) onLocationPicked;
  final double? initialLat;
  final double? initialLng;

  const LocationPickerDialog({
    required this.onLocationPicked,
    this.initialLat,
    this.initialLng,
  });

  @override
  _LocationPickerDialogState createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final LocationService _locationService = LocationService();
  late TextEditingController _addressController;
  Position? _selectedPosition;
  String _selectedAddress = 'Mencari lokasi...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: widget.initialLat?.toString() ?? '',
    );
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        setState(() {
          _selectedPosition = position;
          _selectedAddress = address;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan lokasi. Izinkan akses GPS.'),
          ),
        );
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
    return Dialog(
      insetPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Lokasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi Terpilih',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (_selectedPosition != null) ...[
                        Text(
                          'Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}\nLng: ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _selectedAddress,
                          style: TextStyle(fontSize: 12),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else
                        Text(
                          'Belum ada lokasi terpilih',
                          style: TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: Icon(Icons.my_location),
                  label: Text('Gunakan Lokasi Sekarang'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 45),
                    backgroundColor: Colors.blue,
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: 'Cari alamat...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (value) async {
                    if (value.isNotEmpty) {
                      setState(() => _isLoading = true);
                      try {
                        final pos = await _locationService
                            .getLocationFromAddress(value);
                        if (pos != null) {
                          final address = await _locationService
                              .getAddressFromCoordinates(
                                pos.latitude,
                                pos.longitude,
                              );
                          setState(() {
                            _selectedPosition = pos;
                            _selectedAddress = address;
                          });
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Alamat tidak ditemukan')),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 45),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedPosition != null
                            ? () {
                                widget.onLocationPicked(
                                  _selectedPosition!,
                                  _selectedAddress,
                                );
                                Navigator.pop(context);
                              }
                            : null,
                        child: Text('Pilih'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 45),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}

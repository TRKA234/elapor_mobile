import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';

class PhotoGalleryWidget extends StatefulWidget {
  final List<File> selectedImages;
  final Function(List<File>) onImagesChanged;
  final int maxImages;

  const PhotoGalleryWidget({
    required this.selectedImages,
    required this.onImagesChanged,
    this.maxImages = 5,
  });

  @override
  _PhotoGalleryWidgetState createState() => _PhotoGalleryWidgetState();
}

class _PhotoGalleryWidgetState extends State<PhotoGalleryWidget> {
  final ImageService _imageService = ImageService();
  late List<File> _images;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.selectedImages);
  }

  Future<void> _addImageFromCamera() async {
    if (_images.length >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maksimal ${widget.maxImages} foto')),
      );
      return;
    }

    final image = await _imageService.pickImageFromCamera();
    if (image != null) {
      final compressed = await _imageService.compressImage(image);
      setState(() {
        _images.add(compressed ?? image);
        widget.onImagesChanged(_images);
      });
    }
  }

  Future<void> _addImageFromGallery() async {
    if (_images.length >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maksimal ${widget.maxImages} foto')),
      );
      return;
    }

    final images = await _imageService.pickMultipleImages();
    if (images.isNotEmpty) {
      final remaining = widget.maxImages - _images.length;
      final toAdd = images.take(remaining).toList();
      final compressed = await _imageService.compressMultipleImages(toAdd);

      setState(() {
        _images.addAll(compressed);
        widget.onImagesChanged(_images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      widget.onImagesChanged(_images);
    });
  }

  void _showImagePreview(File image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.file(image, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Laporan (${_images.length}/${widget.maxImages})',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        if (_images.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade50,
            ),
            child: Column(
              children: [
                Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text('Belum ada foto', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showImagePreview(_images[index]),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_images[index], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        SizedBox(height: 12),
        if (_images.length < widget.maxImages)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addImageFromCamera,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Kamera'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addImageFromGallery,
                  icon: Icon(Icons.photo_library),
                  label: Text('Galeri'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

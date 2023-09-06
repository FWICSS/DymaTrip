import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testflutter/providers/city_provider.dart';

class ActivityFormImagePicker extends StatefulWidget {
  final Function updateUrl;

  const ActivityFormImagePicker({super.key, required this.updateUrl});

  @override
  State<ActivityFormImagePicker> createState() =>
      _ActivityFormImagePickerState();
}

class _ActivityFormImagePickerState extends State<ActivityFormImagePicker> {
  late File? _deviceImage;
  final ImagePicker imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      XFile? _pickedFile = await imagePicker.pickImage(source: source);
      if (_pickedFile != null) {
        _deviceImage = File(_pickedFile.path);
        final url = await Provider.of<CityProvider>(context, listen: false)
            .uploadImage(_deviceImage!);
        print(url);
        widget.updateUrl(url);
        setState(() {});
        print('image selected');
      } else
        print('no image selected');
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    _deviceImage = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                },
                icon: Icon(Icons.photo_outlined),
                label: Text('Galerie'),
              ),
              TextButton.icon(
                onPressed: () {
                  _pickImage(ImageSource.camera);
                },
                icon: Icon(Icons.camera_alt_outlined),
                label: Text('Camera'),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            child: _deviceImage != null
                ? Image.file(_deviceImage!)
                : Text('Aucune Image'),
          )
        ],
      ),
    );
  }
}

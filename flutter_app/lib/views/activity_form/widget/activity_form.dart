import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testflutter/views/activity_form/widget/activity_form_image_picker.dart';

import '../../../models/activity_model.dart';
import '../../../providers/city_provider.dart';
import 'activity_form_autocomplete.dart';

class ActivityForm extends StatefulWidget {
  final String cityName;

  const ActivityForm({super.key, required this.cityName});

  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Activity _newActivity;
  late TextEditingController _priceController;
  final TextEditingController _urlController = TextEditingController();
  late TextEditingController _addressController;
  late FocusNode _priceFocusNode;
  late FocusNode _urlFocusNode;
  late FocusNode _locationFocusNode;
  late String _nameInputAsync;
  bool _isLoading = false;

  // RegExp _numeric = RegExp(r'^[0-9,.]*$');
  FormState get form {
    return _formKey.currentState!;
  }

  @override
  void initState() {
    _newActivity = Activity(
      name: '',
      image: '',
      price: 0,
      location: LocationActivity(address: '', latitude: null, longitude: null),
      status: ActivityStatus.ongoing,
      city: widget.cityName,
    );
    _priceController =
        TextEditingController(text: _newActivity.price.toString());
    _priceFocusNode = FocusNode();
    _urlFocusNode = FocusNode();
    _addressController =
        TextEditingController(text: _newActivity.location!.address);
    _locationFocusNode = FocusNode();
    _locationFocusNode.addListener(() async {
      if (_locationFocusNode.hasFocus) {
        var location = await showInputAutocomplete(context);
        if (location != null)
          setState(() {
            _newActivity.location = location;
            _addressController.text = location.address;
          });

        _urlFocusNode.requestFocus();
      }
      if (!_locationFocusNode.hasFocus) {
        print("no focus");
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _priceFocusNode.dispose();
    _urlFocusNode.dispose();
    _urlController.dispose();
    _locationFocusNode.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void updateUrlField(String url) {
    setState(() {
      _urlController.text = url;
    });
  }

  Future<void> submitForm() async {
    try {
      form.save();
      setState(() => _isLoading = true);
      CityProvider cityProvider =
          Provider.of<CityProvider>(context, listen: false);
      _nameInputAsync = await cityProvider.checkIfActivityNameIsUnique(
          widget.cityName, _newActivity.name);
      if (form.validate()) {
        print(_newActivity.toJson());
        await cityProvider.addActivityToCity(_newActivity);
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error: $e");
    }
  }

  // Future<LocationActivity> showInputAutocomplete() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                if (_nameInputAsync != null && _nameInputAsync != "Ok")
                  return _nameInputAsync;
                return null;
              },
              textInputAction: TextInputAction.next,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'activité',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _newActivity.name = value!,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_priceFocusNode),
            ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remplissez l\'url';
                }
                return null;
              },
              focusNode: _priceFocusNode,
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Prix de l\'activité',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_locationFocusNode),
              onSaved: (value) => _newActivity.price = double.parse(value!),
            ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              focusNode: _locationFocusNode,
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse de l\'activité',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _newActivity.location!.address = value!,
            ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              focusNode: _urlFocusNode,
              controller: _urlController,
              keyboardType: TextInputType.url,
              onFieldSubmitted: (_) => submitForm(),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remplissez l\'url';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Url image de l\'activité',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _newActivity.image = value!,
            ),
            const SizedBox(
              height: 30,
            ),
            ActivityFormImagePicker(updateUrl: updateUrlField),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('annuler'),
                ),
                ElevatedButton(
                  onPressed: () => _isLoading ? null : submitForm(),
                  child: Text('Sauvegarder'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

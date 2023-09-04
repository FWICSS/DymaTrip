import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/activity_model.dart';
import '../../../providers/city_provider.dart';

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
  late FocusNode _priceFocusNode;
  late FocusNode _urlFocusNode;
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
      status: ActivityStatus.ongoing,
      city: widget.cityName,
    );
    _priceController =
        TextEditingController(text: _newActivity.price.toString());
    _priceFocusNode = FocusNode();
    _urlFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _priceFocusNode.dispose();
    _urlFocusNode.dispose();
    super.dispose();
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
                if (_nameInputAsync != null) return _nameInputAsync;
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
              height: 10,
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
                  FocusScope.of(context).requestFocus(_urlFocusNode),
              onSaved: (value) => _newActivity.price = double.parse(value!),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              focusNode: _urlFocusNode,
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
              height: 10,
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

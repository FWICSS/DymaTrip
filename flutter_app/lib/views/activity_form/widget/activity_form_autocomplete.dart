import 'dart:async';

import 'package:flutter/material.dart';
import 'package:testflutter/models/place_model.dart';

import '../../../api/google_api.dart';
import '../../../models/activity_model.dart';

Future showInputAutocomplete(BuildContext context) {
  return showDialog(context: context, builder: (_) => InputAddress());
}

class InputAddress extends StatefulWidget {
  const InputAddress({Key? key}) : super(key: key);

  @override
  _InputAddressState createState() => _InputAddressState();
}

class _InputAddressState extends State<InputAddress> {
  List<Place> _places = [];
  Timer? _debounce;

  Future<void> searchAddress(String value) async {
    try {
      if (_debounce?.isActive == true) _debounce?.cancel();
      Timer(Duration(seconds: 1), () async {
        print(value);
        if (value.isEmpty) return;
        _places = await GetAutocompleteSuggestion(value);
        setState(() {});
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getPlaceDetails(String placeId) async {
    try {
      LocationActivity? locationActivity = await GetPlaceDetailsApi(placeId);
      if (locationActivity != null) Navigator.pop(context, locationActivity);
      if (locationActivity == null) Navigator.pop(context);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              TextField(
                decoration: InputDecoration(
                    labelText: "Rechercher", prefixIcon: Icon(Icons.search)),
                onChanged: searchAddress,
              ),
              Positioned(
                  top: 5,
                  right: 3,
                  child: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _places.length,
                itemBuilder: (_, i) {
                  var place = _places[i];
                  return ListTile(
                    leading: Icon(Icons.place),
                    title: Text(place.description),
                    onTap: () => getPlaceDetails(place.placeId),
                  );
                }),
          )
        ],
      ),
    );
  }
}

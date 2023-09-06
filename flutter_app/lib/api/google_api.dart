import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:testflutter/api/google_api_key.dart';
import 'package:testflutter/models/place_model.dart';

import '../models/activity_model.dart';

Uri _queryAutocompleBuilder(String query) {
  return Uri.parse(
      "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?input=$query&key=$GOOGLE_API_KEY");
}

Uri _queryPlaceDetailsBuilder(String placeId) {
  return Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$GOOGLE_API_KEY");
}

Future<List<Place>> GetAutocompleteSuggestion(String query) async {
  try {
    var response = await http.get(_queryAutocompleBuilder(query));
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      return (body["predictions"] as List)
          .map((place) => Place(
              description: place['description'], placeId: place['place_id']))
          .toList();
    } else {
      return [];
    }
  } catch (e) {
    rethrow;
  }
}

Future<LocationActivity?> GetPlaceDetailsApi(String placeId) async {
  try {
    var response = await http.get(_queryPlaceDetailsBuilder(placeId));
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body)['result'];
      return LocationActivity(
          address: body['formatted_address'],
          latitude: body['geometry']['location']['lat'],
          longitude: body['geometry']['location']['lng']);
    } else {
      return null;
    }
  } catch (e) {
    rethrow;
  }
}

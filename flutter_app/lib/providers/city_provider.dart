import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

import '../models/activity_model.dart';
import '../models/city_model.dart';

class CityProvider extends ChangeNotifier {
  final String host = '10.0.2.2';
  final String hostIOS = 'localhost';
  List<City> _cities = [];
  bool isLoading = false;

  UnmodifiableListView<City> get cities => UnmodifiableListView(_cities);

  City getCityByName(String cityName) =>
      cities.firstWhere((city) => city.name == cityName);

  Future<void> fetchData() async {
    try {
      isLoading = true;
      http.Response response = await http
          .get(Uri.http((Platform.isAndroid ? host : hostIOS), '/api/cities'));
      if (response.statusCode == 200) {
        _cities = (json.decode(response.body) as List)
            .map((cityJson) => City.fromJson(cityJson))
            .toList();
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      isLoading = false;
      rethrow;
    }
  }

  Future<void> addActivityToCity(Activity newActivity) async {
    try {
      String cityId = getCityByName(newActivity.city).id!;
      http.Response response = await http.post(
          Uri.http(Platform.isAndroid ? host : hostIOS,
              '/api/city/${cityId}/activity'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(newActivity.toJson()));
      if (response.statusCode == 200) {
        print("send");
        int index = cities.indexWhere((city) => city.id == cityId);
        _cities[index] = City.fromJson(json.decode(response.body));
        notifyListeners();
      }
    } catch (e) {
      print("error $e");
    }
  }

  Future<dynamic> checkIfActivityNameIsUnique(
      String cityName, String activityName) async {
    try {
      String cityId = getCityByName(cityName).id!;
      http.Response response = await http.get(Uri.http(
          Platform.isAndroid ? host : hostIOS,
          '/api/city/${cityId}/activities/verify/${activityName}'));
      if (response.body != 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("error $e");
    }
  }

  Future<String> uploadImage(File pickedImage) async {
    try {
      var request =
          http.MultipartRequest("POST", Uri.http(host, '/api/activity/image'));
      request.files.add(
        http.MultipartFile.fromBytes(
          'activity',
          pickedImage.readAsBytesSync(),
          filename: basename(pickedImage.path),
          contentType: MediaType("multipart", "form-data"),
        ),
      );
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        return json.decode(responseData);
      } else {
        throw 'error';
      }
    } catch (e) {
      rethrow;
    }
  }
}

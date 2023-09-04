import 'dart:io';

import 'activity_model.dart';

class City {
  String? id;
  String image;
  String name;
  List<Activity> activities;

  City({
    required this.id,
    required this.image,
    required this.name,
    required this.activities,
  });

  City.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        image = Platform.isAndroid
            ? json['image'].replaceAll('localhost', '10.0.2.2')
            : json['image'],
        name = json['name'],
        activities = (json['activities'] as List)
            .map((activityJson) => Activity.fromJson(activityJson))
            .toList();
}

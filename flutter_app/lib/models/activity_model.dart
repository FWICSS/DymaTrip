import 'dart:io';

enum ActivityStatus { ongoing, done }

class Activity {
  String? id;
  String name;
  String image;
  String city;
  double price;
  ActivityStatus status;
  LocationActivity? location;

  Activity({
    required this.name,
    required this.city,
    this.id,
    required this.image,
    required this.price,
    this.location,
    this.status = ActivityStatus.ongoing,
  });

  Activity.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        name = json['name'],
        image = Platform.isAndroid
            ? json['image'].replaceAll('localhost', '10.0.2.2')
            : json['image'],
        city = json['city'],
        price = json['price'].toDouble(),
        status =
            json['status'] == 0 ? ActivityStatus.ongoing : ActivityStatus.done;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> value = {
      'name': name,
      'image': image,
      'city': city,
      'price': price,
      'status': status == ActivityStatus.ongoing ? 0 : 1
    };
    if (id != null) value['_id'] = id;
    return value;
  }
}

class LocationActivity {
  String? address;
  double? longitude;
  double? latitude;

  LocationActivity(
      {required this.address, required this.longitude, required this.latitude});
}

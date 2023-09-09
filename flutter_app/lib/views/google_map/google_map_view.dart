import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testflutter/models/activity_model.dart';
import 'package:testflutter/providers/trip_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleMapsView extends StatefulWidget {
  const GoogleMapsView({super.key});
  static const String routeName = '/google-map';

  @override
  State<GoogleMapsView> createState() => _GoogleMapsViewState();
}

class _GoogleMapsViewState extends State<GoogleMapsView> {
  bool _isLoaded = false;
  late Activity _activity;
  late GoogleMapController _controller;

  @override
  void didChangeDependencies() {
    if (!_isLoaded) {
      var arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _activity = Provider.of<TripProvider>(context, listen: false)
          .getActivityByIds(arguments['activityId'], arguments['tripId']);
    }
  }

  get _activityLatLng {
    return LatLng(
        _activity.location!.latitude!, _activity.location!.longitude!);
  }

  Future<void> _openUrl() async {
    final url = 'google.navigation:q=${_activity.location!.address}';
    final Uri uriUrl = Uri.parse(url);
    try{
      await launchUrl(uriUrl);
    } catch (e) {
      rethrow;
    }
  }
  get _initialCameraPosition => CameraPosition(
        target: _activityLatLng,
        zoom: 14.4746,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_activity.name),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) => _controller = controller,
        markers: Set.of({
          Marker(
            markerId: MarkerId(_activity.id!),
            flat: true,
            position: _activityLatLng,
          )
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(

          onPressed: _openUrl,
          icon: Icon(Icons.directions_car),
          label: Text('Go')),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

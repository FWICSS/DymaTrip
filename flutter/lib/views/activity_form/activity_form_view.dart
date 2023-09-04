import 'package:flutter/material.dart';
import 'package:testflutter/views/activity_form/widget/activity_form.dart';
import 'package:testflutter/widgets/dyma_drawer.dart';

class ActivityFormView extends StatelessWidget {
  static const String routeName = '/activity-form';

  @override
  Widget build(BuildContext context) {
    String cityName = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une activité'),
      ),
      drawer: DymaDrawer(),
      body: Center(
        child: ActivityForm(cityName: cityName),
      ),
    );
  }
}

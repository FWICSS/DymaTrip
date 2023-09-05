import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testflutter/views/city/widgets/trip_overview_city.dart';

import '../../../models/trip_model.dart';

class TripOverview extends StatelessWidget {
  final VoidCallback setDate;
  final Trip mytrip;
  final String cityName;
  final String cityImage;
  final double amount;

  const TripOverview(
      {super.key,
      required this.setDate,
      required this.mytrip,
      required this.cityName,
      required this.cityImage,
      required this.amount});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final size = MediaQuery.of(context).size;

    return Container(
      width:
          orientation == Orientation.landscape ? size.width * 0.5 : size.width,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TripOverviewCity(
            cityName: cityName,
            cityImage: cityImage,
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    mytrip.date != null
                        ? DateFormat('d/M/y').format(mytrip.date!)
                        : 'Sélectionnez une date',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                ElevatedButton(
                  onPressed: setDate,
                  child: const Text('Sélectionnez une date'),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Montant / personne',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Text(
                  '$amount€',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}

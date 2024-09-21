import 'package:Britebox/MainPage/More/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locker Location',style: TextStyle(color: Colors.white),),
        leading: Icon(Icons.arrow_back_sharp,color: Colors.white,),
        backgroundColor: MyColorScheme.navyBlue,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(26.245088036089026, 50.62898791584583), // Default to San Francisco
          initialZoom: 5.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(26.245088036089026, 50.62898791584583), // Marker position
                child: Container(
                  child: Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
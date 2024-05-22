import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:qosambassadors/model/site.dart';
import 'package:qosambassadors/services/cell_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';



import '../model/cell_5g.dart';

class Cellule5G extends StatefulWidget {
  const Cellule5G({Key? key}) : super(key: key);

  @override
  State<Cellule5G> createState() => _Cellule5GState();
}

class _Cellule5GState extends State<Cellule5G> {
  String? _darkMapStyle;


  String _selectedOption = '0';
  bool isLoading = false;
  GoogleMapController? mapController;
  Location _location = Location();
  MapType _currentMapType = MapType.normal;




  List<SiteModel>? data;

  Future<List<SiteModel>> fetchData() async {
    print("---------------");
  print(_selectedOption);
    final response = await http.get(Uri.parse('${CellService.baseUrl}/sites5gs/${_selectedOption}'));
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<SiteModel> dataList = jsonList.map((json) => SiteModel.fromJson(json)).toList();

      setState(() {
        data = dataList;
        isLoading = true;
      });

      return dataList;
    } else {
      throw Exception('Failed to load 5G');
    }
  }


  @override
  void initState() {
    super.initState();
    _loadMapStyles();

  }
  Future _loadMapStyles() async {
    _darkMapStyle  = await rootBundle.loadString('assets/json/dark_mode_style.json');
  }

  Future<void> openGoogleMaps(double latitude, double longitude) async {
    var googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

  Set<Marker> markers = {};
  Future<void> updateMarkers() async {
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(0.1, 0.1)),
        'assets/images/bts.png'
    );

    setState(() {
      markers.clear();
      if (data != null) {
        markers.addAll(data!.map((celluleData) {
          double latitude = double.tryParse(celluleData.latitude.toString()) ?? 0.0;
          double longitude = double.tryParse(celluleData.longitude.toString()) ?? 0.0;
          return Marker(
            markerId: MarkerId(celluleData.nomSite ?? 'N/A'),
            position: LatLng(longitude, latitude),
            icon: customIcon,
            infoWindow: InfoWindow(title: celluleData.nomSite ?? 'N/A'),
            onTap: () {
              showMarkerDetailDialog(celluleData);
            },
          );
        }).toList());
      }
    });
  }

  void showMarkerDetailDialog(SiteModel celluleData) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(celluleData.nomSite ?? 'N/A'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  for (var cell in celluleData.cells)
                    Text("Cellule: ${cell.nomCellule ?? 'N/A'}"),
                  Text("Band: ${celluleData.band ?? 'N/A'}"),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Itinéraire'),
                onPressed: () {
                  double latitude = double.tryParse(celluleData.latitude.toString()) ?? 0.0;
                  double longitude = double.tryParse(celluleData.longitude.toString()) ?? 0.0;
                  Navigator.of(context).pop();
                  openGoogleMaps(longitude, latitude);
                },
              ),
              TextButton(
                child: Text('Fermer'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller, BuildContext context) async {
    print("-----------------------------------------------------------------------------------------------");
    mapController = controller;

    var theme = Theme.of(context);
    if (theme.brightness == Brightness.dark && _darkMapStyle != null) {
      mapController?.setMapStyle(_darkMapStyle);
    } else {
      mapController?.setMapStyle(null);
    }

    await fetchData();

    print("--------------------$data");
    var currentLocation = await _location.getLocation();
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 15,
        ),
      ),
    );
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(0.1, 0.1)),
        'assets/images/bts.png'
    );


    if (data != null) {
      setState(() {
        markers.addAll(data!.map((celluleData) {
          double latitude = double.tryParse(celluleData.latitude.toString()) ?? 0.0;
          double longitude = double.tryParse(celluleData.longitude.toString()) ?? 0.0;
          print('Latitude: $latitude, Longitude: $longitude');

          return Marker(
            markerId: MarkerId(celluleData.nomSite ?? 'N/A'),
            position: LatLng(longitude, latitude),

            infoWindow: InfoWindow(title: celluleData.nomSite ?? 'N/A '),
            icon: customIcon,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(celluleData.nomSite ?? 'N/A'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            for(var cell in celluleData.cells)
                              Text("Cellule: ${cell.nomCellule ?? 'N/A'}"),

                            Text("Band: ${celluleData.band ?? 'N/A'}"),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Itinéraire'),
                          onPressed: () {
                            double latitude = double.tryParse(celluleData.latitude.toString()) ?? 0.0;
                            double longitude = double.tryParse(celluleData.longitude.toString()) ?? 0.0;
                            Navigator.of(context).pop();
                            openGoogleMaps(longitude, latitude);
                          },
                        ),
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }

              );
            },
          );
        }).toList());
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RAN5G'),
        actions: [],
      ),
      body: Stack(
        children: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return GoogleMap(
                mapType: _currentMapType,
                onMapCreated: (GoogleMapController controller) {
                  _onMapCreated(controller, context);
                },
                markers: markers,
                initialCameraPosition: CameraPosition(
                  target: LatLng(14.741186, -17.509013),
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              );
            },
          ),
          Positioned(
            top: 1.0,
            left: 100,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Row(
                children: [
                  Text("    Bande : "),
                  DropdownButton<String>(
                    value: _selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue!;
                        fetchData().then((_) {
                          updateMarkers();
                        });
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: '0',
                        child: Text('Toutes'),
                      ),
                      DropdownMenuItem<String>(
                        value: '3500',
                        child: Text('3500'),
                      ),
                      DropdownMenuItem<String>(
                        value: '700',
                        child: Text('700'),
                      ),
                    ].toList(),
                    underline: Container(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(

            bottom: 50,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.layers, size: 36.0),
            ),
          ),
        ],
      ),
    );
  }
}

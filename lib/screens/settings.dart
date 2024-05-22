import 'dart:async';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import '../controller/settings_controller.dart';
import '../main.dart';
import 'home.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isSpeedTestEnabled = false;
  SettingsController _controller = SettingsController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isActivated = false;
  bool isFormVisible = false;
  bool isFormModified = false;
  bool isButtonEnabled = true;
  Home home = Home();

  @override
  void initState() {
    super.initState();
    _loadSpeedTestEnabledState();
    _initSwitchState();
    _loadFieldValues();
    _controller.loadNombreDeTestsSelectionne().then((_) {
      setState(() {});
    });
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isButtonEnabled = prefs.getBool('isButtonEnabled') ?? true;
        isFormModified = prefs.getBool('isFormModified') ?? false;
      });
    });

    initializeService();
  }

  void _loadSpeedTestEnabledState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isSpeedTestEnabled = prefs.getBool('speedTestEnabled') ?? false;
    });
  }
  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.locationWhenInUse,
      Permission.locationAlways,
      Permission.location,
    ].request();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }

    if (Platform.isAndroid) {
      var backgroundStatus = await Permission.locationAlways.status;
      if (!backgroundStatus.isGranted) {
        await Permission.locationAlways.request();

      }
    }
  }

  void _saveSpeedTestEnabledState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('speedTestEnabled', value);
  }

  Future<void> toggleSpeedTest(bool value) async {
    setState(() {
      isSpeedTestEnabled = value;
    });
    await requestLocationPermission();

    _saveSpeedTestEnabledState(value);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSpeedTestEnabled', value);

    if (isSpeedTestEnabled) {
      final int intervalInMinutes = _controller.calculateIntervalInMinutes();
      if (intervalInMinutes > 0) {
        await prefs.setInt('intervalInMinutes', intervalInMinutes);
        FlutterBackgroundService().startService();
      }
    } else {
      FlutterBackgroundService().invoke('stopService');
    }
  }

  void _initSwitchState() async {
    bool switchState = await _controller.loadButtonState();
    setState(() {
      isActivated = switchState;
      isFormVisible = switchState;
    });
  }

  void _loadFieldValues() async {
    final prefs = await SharedPreferences.getInstance();
    final ulminValue = prefs.getString('newULmin') ?? '';
    final dlminValue = prefs.getString('newDLmin') ?? '';
    final nombreDeTests = prefs.getInt('nombreDeTests') ?? 10;

    setState(() {
      _controller.newULmin = ulminValue;
      _controller.newDLmin = dlminValue;
      _controller.ulminController.text = ulminValue;
      _controller.dlminController.text = dlminValue;
      _controller.nombreDeTestsSelectionne = nombreDeTests;
    });
  }

  @override
  void dispose() {
    super.dispose();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isButtonEnabled', isButtonEnabled);
      prefs.setBool('isFormModified', isFormModified);
    });
  }

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: (service) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> testTimes = _controller.calculateTestTimes();
    final int intervalInMinutes = _controller.calculateIntervalInMinutes();
    String formatDuration(int totalMinutes) {
      final int hours = totalMinutes ~/ 60;
      final int minutes = totalMinutes % 60;
      return '${hours > 0 ? "$hours h " : ""}${minutes.toString().padLeft(2, '0')} mn';
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => home),
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paramètres'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Mode sombre",
                            style: TextStyle(fontSize: 18),
                          ),
                          Switch(
                            value: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark,
                            onChanged: (value) {
                              if (value) {
                                AdaptiveTheme.of(context).setDark();
                              } else {
                                AdaptiveTheme.of(context).setLight();
                              }
                            },
                            inactiveThumbColor: Colors.orange,
                            activeTrackColor: Colors.orangeAccent[100],
                            activeColor: Colors.orange,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSpeedTestEnabled
                                ? "     LeBonCoin"
                                : "     LeBonCoin",
                            style: TextStyle(fontSize: 18),
                          ),
                          Switch(
                            value: isSpeedTestEnabled,
                            onChanged: (value) {
                              setState(() async {
                                await toggleSpeedTest(value);
                              });
                            },
                            inactiveThumbColor: Colors.orange,
                            activeTrackColor: Colors.orangeAccent[100],
                            activeColor: Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text("Activer les tests en background pour détecter les endroits avec un bon débit . "),
                  SizedBox(height: 20),
                  Visibility(
                    visible: isSpeedTestEnabled,
                    child: Form(
                      key: _controller.formKey,
                      child: Column(
                        children: [
                          Card(
                            elevation: 0,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                            child: TextFormField(
                              controller: _controller.ulminController,
                              focusNode: _controller.ulFocusNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entrez une valeur';
                                }
                                final number = int.tryParse(value);
                                if (number == null) {
                                  return 'La valeur saisie doit être un nombre entier.';
                                }
                                if (number <= 0) {
                                  return 'La valeur doit être supérieure à zéro.';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText:
                                _controller.newULmin != null ? 'ULmin' : '',
                                suffixText: 'Mbps',
                                hintText: "ULmin",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.orange,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelStyle: TextStyle(
                                  color: _controller.ulFocusNode.hasFocus
                                      ? Colors.orange
                                      : Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                ),
                                prefixIcon: const Icon(
                                  Icons.upload,
                                  color: Colors.orange,
                                ),
                              ),
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                              ),
                              cursorColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                              onChanged: (ul) {
                                setState(() {
                                  _controller.newULmin = ul;
                                  isFormModified = true;
                                  isButtonEnabled = true;
                                });
                                _controller.saveFormFieldValue('newULmin', ul);
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Card(
                            elevation: 0,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                            child: TextFormField(
                              controller: _controller.dlminController,
                              focusNode: _controller.dlFocusNode,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entrez une valeur';
                                }
                                final number = int.tryParse(value);
                                if (number == null) {
                                  return 'La valeur saisie doit être un nombre entier.';
                                }
                                if (number <= 0) {
                                  return 'La valeur doit être supérieure à zéro.';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText:
                                _controller.newDLmin != null ? 'DLmin' : '',
                                suffixText: 'Mbps',
                                hintText: "DLmin",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.orange,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelStyle: TextStyle(
                                  color: _controller.dlFocusNode.hasFocus
                                      ? Colors.orange
                                      : Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                ),
                                prefixIcon: const Icon(
                                  Icons.download,
                                  color: Colors.orange,
                                ),
                              ),
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                              ),
                              cursorColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                              onChanged: (dl) {
                                setState(() {
                                  _controller.newDLmin = dl;
                                  isFormModified = true;
                                  isButtonEnabled = true;
                                });
                                _controller.saveFormFieldValue('newDLmin', dl);
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Card(
                            elevation: 0,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                            child: DropdownButtonFormField<int>(
                              value: _controller.nombreDeTestsSelectionne,
                              items: _controller.optionsNombreDeTests.map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                );
                              }).toList(),
                              onChanged: (int? value) async {
                                setState(() {
                                  _controller.nombreDeTestsSelectionne = value!;
                                  isFormModified = true;
                                  isButtonEnabled = true;
                                });
                                await _controller.saveNombreDeTestsSelectionne(value!);
                                await SharedPreferences.getInstance().then((prefs) {
                                  prefs.setInt('nombreDeTestsSelectionne', value);
                                });
                              },
                              dropdownColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.white,
                              decoration: InputDecoration(
                                labelText: "Nombre de tests",
                                suffixText: '/jour',
                                hintText: "Tests",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusColor: Colors.transparent,
                                labelStyle: TextStyle(
                                  color: _controller.testsFocusNode.hasFocus
                                      ? Colors.orange
                                      : Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                ),
                                prefixIcon: const Icon(
                                  Icons.assessment,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 40),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Les tests seront effectués chaque"),
                                  Text(
                                    "${intervalInMinutes > 60 ? formatDuration(intervalInMinutes) : '$intervalInMinutes mn'} de 7h45 à 18h00",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isSpeedTestEnabled,
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              isButtonEnabled ? Colors.orange : Colors.grey),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          elevation: MaterialStateProperty.all<double>(0.9),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: isButtonEnabled && isFormModified
                            ? () async {
                          _controller.handleSubmit();
                          await toggleSpeedTest(!isSpeedTestEnabled);
                          toggleSpeedTest(!isSpeedTestEnabled);
                          setState(() {
                            isButtonEnabled = false;
                          });
                          await _requestPermissions();
                        }
                            : null,
                        child: Text(
                          "Enregistrer",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

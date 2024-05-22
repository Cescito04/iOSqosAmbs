import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';

import '../services/image_service.dart';
import '../services/otp_service.dart';

class Otp extends StatefulWidget {
  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final int CELL_COUNT = 6;
  String _otpCode = '';
  List<String> codeValues = List.filled(6, '');
  double spaceBetweenFields = 8.0;

  @override
  void initState() {
    super.initState();
    _listenForOtp();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  void _listenForOtp() async {
    await SmsAutoFill().listenForCode;
  }

  Future<void> submitVerification(String code) async {
     String apiUrl = '${OtpService.otpEndpoint}';
    const String message =
        'Votre code de vérification est incorrect. Veuillez réessayer.';

    try {
      final response = await http.get(Uri.parse('${OtpService.otpEndpoint}$code'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status']) {
          Navigator.pushNamed(context, '/home');
        } else {
          _showErrorDialog(message);
        }
      } else {
        _showErrorDialog(message);
      }
    } catch (error) {
      _showErrorDialog(message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Column(
                children: [
                  Image(
                    image: ImageService.getImageAsset('otp.png'), // Utilisation du service d'image
                    width: double.infinity,
                    height: 300,
                  ),
                  const SizedBox(height: 60.0),
                  Text(
                    'Verification de l\'authentification',
                    style: TextStyle( fontSize: 20,fontWeight: FontWeight.bold ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Veuillez entrer le code de vérification reçu par sms.',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(height: 40),
                  PinFieldAutoFill(
                    decoration: UnderlineDecoration(
                      textStyle: TextStyle(fontSize: 20, color: Colors.black),
                      colorBuilder: FixedColorBuilder(Colors.black.withOpacity(0.3)),
                    ),
                    currentCode: _otpCode,
                    onCodeSubmitted: (code) {},
                    onCodeChanged: (code) {
                      if (code?.length == CELL_COUNT) {
                        _otpCode = code!;
                        submitVerification(_otpCode);
                      }
                    },
                    codeLength: CELL_COUNT,
                  ),
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

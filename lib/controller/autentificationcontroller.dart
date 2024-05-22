import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../controller/session_utilisateur.dart';
class AuthentificationController {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final String _errorMessage = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void storeUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ambassadorId', userId);
    if (kDebugMode) {
      print("id : $userId");
    }
  }

  Future<void> getAmbassadorsInfo(BuildContext context, String phoneNumber) async {
    if (kDebugMode) {
      print("numero : $phoneNumber");
    }

    try {
      var response = await AuthentificationService.get(
        AuthentificationService.filteredAmbassadorUrl(phoneNumber),
        {},
      );

      if (kDebugMode) {
        print('API Response: $response');
      }

      bool isNumberFound = false;

      if (response is List && response.isNotEmpty) {
        for (var ambassador in response) {
          if (ambassador is Map && ambassador['id'] != null) {
            if (ambassador['numero'] == phoneNumber) {
              storeUserId(ambassador['id']);
              await UserSession.setLoggedIn();
              await SmsAutoFill().listenForCode();
              String code = await SmsAutoFill().getAppSignature;
              print("--------code"+code);
              await AuthentificationService.post(
                AuthentificationService.sendOTPUrl(phoneNumber),
                {},
              );

              Navigator.pushNamed(
                context,
                '/otp',
              );

              isNumberFound = true;
              break;
            }
          }
        }
      }

      if (!isNumberFound) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Désolé'),
              content: const Text(
                'Vous ne faites pas partie de la communauté des QOS Ambassadors. Merci de contacter les administrateurs.',
              ),
              actions: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Color(0xFF168887), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      // Handle errors here
    }
  }
}

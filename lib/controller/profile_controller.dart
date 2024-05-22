import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/profil_service.dart';

class ProfilController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final FocusNode nomFocusNode = FocusNode();
  final FocusNode prenomFocusNode = FocusNode();
  final FocusNode telephoneFocusNode = FocusNode();

  late String newNom = '';
  late String newPrenom = '';
  late String newNumero = '';
  late String ambassadorId;

  String getPhoneNumber() {
    return newNumero;
  }



  Future<void> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ambassadorId = prefs.getString('ambassadorId') ?? "";

    try {
      var res = await ProfilService.getUserProfile(ambassadorId);
      if (res != null) {
        newNom = res['nom'];
        newPrenom = res['prenom'];
        newNumero = res['numero'];
        print("Numero: $newNumero");

        nomController.text = newNom;
        prenomController.text = newPrenom;

        // Le reste de votre code...
      } else {
        if (kDebugMode) {
          print("User information not found");
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print("An error occurred during the request: $error");
      }
    }
  }

  Future<void> handleSubmit() async {
    if (formKey.currentState?.validate() ?? false) {
      if (kDebugMode) {
        print('Nom is $newNom');
      }
      if (kDebugMode) {
        print('Prenom is $newPrenom');
      }
      if (kDebugMode) {
        print('Numero is $newNumero');
      }

      try {
        if (kDebugMode) {
          print('Before API call');
        }
        bool success = await ProfilService.updateUserProfile(ambassadorId, newPrenom, newNom);
        if (success) {
          if (kDebugMode) {
            print('Update successful');
          }
        } else {
          if (kDebugMode) {
            print('Update failed');
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print('Error calling API: $error');
        }
      }
    }
  }


}

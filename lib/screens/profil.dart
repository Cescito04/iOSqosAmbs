import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../controller/profile_controller.dart';
import '../services/image_service.dart';


class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final ProfilController _controller = ProfilController();


  @override
  void initState() {
    _controller.getUserProfile();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: ListView(
        children: [Center(

          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  CircleAvatar(
                    radius: 50,
                    backgroundImage:  ImageService.getImageAsset('user.png'),
                  ),

                  const Text(
                    "Mon profil",
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,

                    child: TextFormField(

                      controller: _controller.nomController,
                      focusNode: _controller.nomFocusNode,
                      validator: (value) {
                        if (_controller.newNom.isEmpty &&
                            (value == null || value.isEmpty)) {
                          return 'Entrez votre nom';
                        } else if (_controller.newNom.isEmpty &&
                            value != null &&
                            value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                          return 'Le nom ne peut pas contenir de symboles';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(

                        labelText: _controller.newNom != null ? 'Nom' : '',
                        hintText: "Nom",
                        hintStyle: TextStyle(
                            color: Colors.orange
                        ),
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
                          color: _controller.prenomFocusNode.hasFocus
                              ? Colors.orange
                              : Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,

                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.orange,
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,

                      ),           cursorColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,

                      onChanged: (nom) {
                        setState(() {
                          _controller.newNom = nom;
                        });
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
                      controller: _controller.prenomController,
                      focusNode: _controller.prenomFocusNode,
                      validator: (value) {
                        if (_controller.newPrenom.isEmpty &&
                            (value == null || value.isEmpty)) {
                          return 'Entrez votre prénom';
                        } else if (_controller.newPrenom.isEmpty &&
                            value != null &&
                            value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                          return 'Le prénom ne peut pas contenir de symboles';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: _controller.newPrenom != null ? 'Prénom' : '',
                        hintText: "Prénom",
                        hintStyle: TextStyle(
                          color: Colors.orange
                        ),
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
                          color: _controller.prenomFocusNode.hasFocus
                              ? Colors.orange
                              : Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,

                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.orange,
                        ),
                      ),
                        style: TextStyle(
                          // Vérifie le mode du thème et ajuste la couleur en conséquence
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,

                        ),
                      cursorColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      onChanged: (prenom) {
                        setState(() {
                          _controller.newPrenom = prenom;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
              FutureBuilder<void>(
                future: _controller.getUserProfile() ,
                builder: (context, snapshot) {
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,

                    child: TextFormField(
                      focusNode: _controller.telephoneFocusNode,
                      enabled: false,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: _controller.newNumero ,
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
                        labelStyle:
                        TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,


                    ),
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Colors.orange,
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,

                      ), cursorColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,

                      onChanged: (numero) {
                        setState(() {
                          _controller.newNumero = numero;
                        });
                      },
                    ),
                  );
                },
              ),

              const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _controller.handleSubmit();
                        if (_controller.formKey.currentState?.validate() ?? false) {
                          if (kDebugMode) {
                            print('Formulaire validé');
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Votre profil est enregistré'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          if (kDebugMode) {
                            print('Formulaire non validé');
                          }
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.orange),
                        foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                        elevation: MaterialStateProperty.all<double>(0.9),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Enregistrer",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ]
      ),
    );
  }
}

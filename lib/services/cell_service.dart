import 'package:http/http.dart' as http;
import 'dart:convert';
 class CellService{
   static const String baseUrl = 'https://qosambassadors.herokuapp.com';
    static const String cellsEndpoint4g = '$baseUrl/cell4gs';
    static const String cellsEndpoint3g = '$baseUrl/cell3gs';
   static const String cellsEndpoint2g = '$baseUrl/cell2gs';

    static const String cellsEndpoint5g = '$baseUrl/cell5gs';
    static const String sites = '$baseUrl/sites5gs';

    static Future<List<dynamic>> fetchCells4G() async {
      final response = await http.get(Uri.parse('$cellsEndpoint4g'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load cells');
      }
    }


     static Future<String> fetchCells4GByCidTac(int eNb, int cid, int tac) async {
        final response = await http.get(Uri.parse('$cellsEndpoint4g?filter={"where": {"and":[{"enodeBId":"$eNb", "localCellId": "$cid"},{"tac": "$tac"}]}}'
        ));
        print(response.statusCode);
        if (response.statusCode == 200) {
          //print(json.decode(response.body));
          return json.decode(response.body)[0]['nomCellule'];



        } else {
          throw Exception('Failed to load cells');
        }
      }


   static Future<Map<String, String>> fetchCells4GByCidTacLocation(int eNb, int cid, int tac) async {
     final response = await http.get(Uri.parse('$cellsEndpoint4g?filter={"where": {"and":[{"enodeBId":"$eNb", "localCellId": "$cid"},{"tac": "$tac"}]}}'));
     if (response.statusCode == 200) {
       var data = json.decode(response.body);
       if (data.isNotEmpty) {
         return {
           'latitude': data[0]['latitude'].toString(),
           'longitude': data[0]['longitude'].toString()
         };
       } else {
         return {'latitude': 'Not available', 'longitude': 'Not available'};
       }
     } else {
       throw Exception('Failed to load cell data');
     }
   }


   static Future<List<dynamic>> fetchCells3G() async {
     final response = await http.get(Uri.parse('$cellsEndpoint3g'));
     if (response.statusCode == 200) {
       return json.decode(response.body);
     } else {
       throw Exception('Failed to load cells');
     }
   }


   static Future<String> fetchCells3GByCidLac(int cid, int lac) async {
     final response = await http.get(Uri.parse('$cellsEndpoint3g?filter={"where": {"and":[{"cellId": "$cid"},{"lac": "$lac"}]}}'
     ));
     print(response.statusCode);
     if (response.statusCode == 200) {
       //print(json.decode(response.body));
       return json.decode(response.body)[0]['nomCellule'] ?? '-';




     } else {
       throw Exception('Failed to load cells');
     }
   }


   static Future<Map<String, String>> fetchCells3GByCidLacLocation(int cid, int lac) async {
     final response = await http.get(Uri.parse('$cellsEndpoint3g?filter={"where": {"and":[{"cellId": "$cid"},{"lac": "$lac"}]}}'));
     if (response.statusCode == 200) {
       var data = json.decode(response.body);
       if (data.isNotEmpty) {
         return {
           'latitude': data[0]['latitude'].toString(),
           'longitude': data[0]['longitude'].toString()
         };
       } else {
         return {'latitude': 'Not available', 'longitude': 'Not available'};
       }
     } else {
       throw Exception('Failed to load cell data');
     }
   }


   static Future<List<dynamic>> fetchCells2G() async {
     final response = await http.get(Uri.parse('$cellsEndpoint2g'));
     if (response.statusCode == 200) {
       return json.decode(response.body);
     } else {
       throw Exception('Failed to load cells');
     }
   }


   static Future<String> fetchCells2GByCidLac(int cid, int lac) async {
     final response = await http.get(Uri.parse('$cellsEndpoint2g?filter={"where": {"and":[{"ci": "$cid"},{"lac": "$lac"}]}}'
     ));
     print(response.statusCode);
     if (response.statusCode == 200) {
       //print(json.decode(response.body));
       return json.decode(response.body)[0]['nomCellule'] ?? '-';

     } else {
       throw Exception('Failed to load cells');
     }
   }

  // fetchCells2GByCidTacLocation
   static Future<Map<String, String>> fetchCells2GByCidLacLocation(int cid, int lac) async {
     final response = await http.get(Uri.parse('$cellsEndpoint2g?filter={"where": {"and":[{"ci": "$cid"},{"lac": "$lac"}]}}'));
     if (response.statusCode == 200) {
       var data = json.decode(response.body);
       if (data.isNotEmpty) {
         return {
           'latitude': data[0]['latitude'].toString(),
           'longitude': data[0]['longitude'].toString()
         };
       } else {
         return {'latitude': 'Not available', 'longitude': 'Not available'};
       }
     } else {
       throw Exception('Failed to load cell data');
     }
   }


   static Future<List<dynamic>> fetchCells5G() async {
     final response = await http.get(Uri.parse('$cellsEndpoint2g'));
     if (response.statusCode == 200) {
       return json.decode(response.body);
     } else {
       throw Exception('Failed to load cells');
     }
   }
   static Future<String> fetchCells5GByCidTac(int cid, int tac) async {
    // print('$cid , $tac');
     final response = await http.get(Uri.parse('$cellsEndpoint2g?filter={"where": {"and":[{"physicalCellId": "$cid"},{"tac": "$tac"}]}}'
     ));
     print(response.statusCode);
     if (response.statusCode == 200) {
       if (json.decode(response.body).length > 0)
        return json.decode(response.body)[0]['nomCellule'];
       else return '';

     } else {
       throw Exception('Failed to load cells');
     }
   }
   static Future<Map<String, String>> fetchCells5GByCidTacLocation(int cid, int tac) async {
     final response = await http.get(Uri.parse('$cellsEndpoint4g?filter={"where": {"and":[{"physicalCellId": "$cid"},{"tac": "$tac"}]}}'));
     if (response.statusCode == 200) {
       var data = json.decode(response.body);
       if (data.isNotEmpty) {
         return {
           'latitude': data[0]['latitude'].toString(),
           'longitude': data[0]['longitude'].toString()
         };
       } else {
         return {'latitude': 'Not available', 'longitude': 'Not available'};
       }
     } else {
       throw Exception('Failed to load cell data');
     }
   }

   static Future<List<dynamic>> fetchSite() async {
     final response = await http.get(Uri.parse('$sites'));
     if (response.statusCode == 200) {
       return json.decode(response.body);
     } else {
       throw Exception('Failed to load cells');
     }
   }


 }
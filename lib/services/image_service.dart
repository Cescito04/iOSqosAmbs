import 'package:flutter/widgets.dart';

class ImageService {
  static AssetImage getImageAsset(String assetName) {
    return AssetImage('assets/images/$assetName');
  }
}

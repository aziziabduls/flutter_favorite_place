import 'package:favorite_place/models/favorite_place.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  final List<FavoritePlaceItem> _favPlaceItem = [];

  // get FavoritePlaceItem => all
  List<FavoritePlaceItem> get favPlaceItem => _favPlaceItem;

  void addToCart(FavoritePlaceItem item, int qty) {
    _favPlaceItem.add(
      FavoritePlaceItem(
        name: item.name,
        image: item.image,
        location: item.location,
        lat: item.lat,
        lng: item.lng,
      ),
    );
    notifyListeners();
  }
}

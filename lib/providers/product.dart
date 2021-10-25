import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _updateFav(bool newStatus) {
    isFavorite = newStatus;
    notifyListeners();
  }

  Future<void> toggleFavoriteProduct(String token, String userId) async {
    var param = {
      'auth': token,
    };
    final url = Uri.https(
      'flutter-shop-app-257d4-default-rtdb.europe-west1.firebasedatabase.app',
      '/user-favorites/$userId/$id.json',
      param,
    );
    final oldStatus = isFavorite;
    _updateFav(!isFavorite);
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      print(json.decode(response.body));
      if (response.statusCode >= 400) {
        _updateFav(oldStatus);
        throw HttpException('Could not add to favorite.');
      }
    } catch (error) {
      _updateFav(oldStatus);
      throw error;
    }

    notifyListeners();
  }
}

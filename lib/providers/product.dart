import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  static const baseUrl =
      'https://flutter-shop-2a80e-default-rtdb.firebaseio.com/';

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    try {
      final url = '$baseUrl/products/$id.json';
      await http.patch(
        Uri.parse(url),
        body: json.encode({'isFavorite': !isFavorite}),
      );
      isFavorite = !isFavorite;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}

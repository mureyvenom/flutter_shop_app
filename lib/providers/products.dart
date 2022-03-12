import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//
import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  static const baseUrl =
      'https://flutter-shop-2a80e-default-rtdb.firebaseio.com/';
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return [..._items.where((item) => item.isFavorite).toList()];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> getProducts() async {
    const url = '$baseUrl/products.json';
    try {
      final response = await http.get(Uri.parse(url));
      List<Product> loadedProducts = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((prodId, data) {
        loadedProducts.add(Product(
          id: prodId,
          title: data['title'],
          description: data['description'],
          price: data['price'],
          imageUrl: data['imageUrl'],
          isFavorite: data['isFavorite'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      const url = '$baseUrl/products.json';
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        id: DateTime.now().toString(),
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    try {
      final prodIndex = _items.indexWhere((prod) => prod.id == id);
      if (prodIndex >= 0) {
        final url = '$baseUrl/products/$id.json';
        await http.patch(
          Uri.parse(url),
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }),
        );
        _items[prodIndex] = newProduct;
        notifyListeners();
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final url = '$baseUrl/products/$productId.json';
      // final existingProductIndex = _items.indexWhere((prod) => prod.id == productId);
      // final existingProduct = _items[existingProductIndex];
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete');
      }
      _items.removeWhere((prod) => prod.id == productId);
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}

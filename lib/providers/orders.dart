import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  static const baseUrl =
      'https://flutter-shop-2a80e-default-rtdb.firebaseio.com/';

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> getOrders() async {
    try {
      const url = '$baseUrl/orders.json';
      final response = await http.get(Uri.parse(url));
      List<OrderItem> loadedOrders = [];
      if (json.decode(response.body) == null) {
        _orders = [];
        notifyListeners();
        return;
      }
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((orderId, order) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: order['amount'],
            products: (order['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ),
                )
                .toList(),
            dateTime: DateTime.parse(order['dateTime']),
          ),
        );
      });
      _orders = loadedOrders;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    try {
      const url = '$baseUrl/orders.json';
      final timeStamp = DateTime.now();
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList()
        }),
      );
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp,
        ),
      );
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}

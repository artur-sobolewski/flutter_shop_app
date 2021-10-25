import 'dart:convert';
import 'package:flutter/foundation.dart';
import './cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(
    this.authToken,
    this.userId,
    this._orders,
  );

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    var param = {
      'auth': authToken,
    };
    final url = Uri.https(
      'flutter-shop-app-257d4-default-rtdb.europe-west1.firebasedatabase.app',
      '/orders/$userId.json',
      param,
    );
    final response = await http.get(url);
    final List<OrderItem> loadedItems = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      _orders = loadedItems;
      notifyListeners();
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedItems.add(
        OrderItem(
          id: orderId,
          amount: orderData["amount"],
          dateTime: DateTime.parse(orderData["dateTime"]),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (ordIt) => CartItem(
                  id: ordIt['id'],
                  title: ordIt['title'],
                  quantity: ordIt['quantity'],
                  price: ordIt['price'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedItems.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    var param = {
      'auth': authToken,
    };
    final url = Uri.https(
      'flutter-shop-app-257d4-default-rtdb.europe-west1.firebasedatabase.app',
      '/orders/$userId.json',
      param,
    );
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((prod) => {
                    'id': prod.id,
                    'title': prod.title,
                    'quantity': prod.quantity,
                    'price': prod.price,
                  })
              .toList(),
        }));
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
  }
}

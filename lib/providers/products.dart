import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../models/http_exception.dart';
import './product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prod) => prod.isFavorite == true).toList();
    // }
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((prod) => prod.isFavorite == true).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetData([bool filterByUser = false]) async {
    var params = filterByUser
        ? {
            'auth': authToken,
            'orderBy': json.encode('creatorId'),
            'equalTo': json.encode(userId),
          }
        : {
            'auth': authToken,
          };
    var url = Uri.https(
      'flutter-shop-app-257d4-default-rtdb.europe-west1.firebasedatabase.app',
      '/products.json',
      params,
    );
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.https(
        'flutter-shop-app-257d4-default-rtdb.europe-west1.firebasedatabase.app',
        '/user-favorites/$userId.json',
        params,
      );
      final favoriteResponse = await http.get(url);
      final favoriteData =
          json.decode(favoriteResponse.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite:
              (favoriteData == null) ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    // final url = Uri.parse(
    //     'https://flutter-shop-app-257d4-default-rtdb.europe-west1.firebasedatabase.app/products.json');
    var params = {
      'auth': authToken,
    };
    final url = Uri.https(
      'flutter-shop-app-257d4-default-rtdb.europe-west1.firebasedatabase.app',
      '/products.json',
      params,
    );
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    var params = {
      'auth': authToken,
    };
    if (prodIndex >= 0) {
      final url = Uri.https(
        'flutter-shop-app-257d4-default-rtdb.europe-west1.firebasedatabase.app',
        '/products/$id.json',
        params,
      );
      try {
        final response = await http.patch(url,
            body: json.encode(
              {
                'title': newProduct.title,
                'description': newProduct.description,
                'imageUrl': newProduct.imageUrl,
                'price': newProduct.price,
              },
            ));
      } catch (error) {
        print(error);
        throw error;
      }
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    var params = {
      'auth': authToken,
    };
    final url = Uri.https(
      'flutter-shop-app-257d4-default-rtdb.europe-west1.firebasedatabase.app',
      '/products/$id.json',
      params,
    );
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
    notifyListeners();
  }
}

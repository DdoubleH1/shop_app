import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((prod) => prod.isFavourite == true).toList();
  }

  Product findById(String id) {
    return items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
        'https://shop-app-9c8ad-default-rtdb.asia-southeast1.firebasedatabase.app/products.json');
    try {
      final response = await http.get(
        url,
      );
      final extractedData = json.decode(response.body);
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      print(extractedData);
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavourite: prodData['isFavourite'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-app-9c8ad-default-rtdb.asia-southeast1.firebasedatabase.app/products.json');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavourite': product.isFavourite,
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product updatedProduct) async {
    final productId = _items.indexWhere((prod) => prod.id == id);
    if (productId >= 0) {
      final url = Uri.parse(
          'https://shop-app-9c8ad-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json');
      await http.patch(url,
          body: json.encode({
            'title': updatedProduct.title,
            'description': updatedProduct.description,
            'imageUrl': updatedProduct.imageUrl,
            'price': updatedProduct.price,
          }));
      _items[productId] = updatedProduct;
    } else {}
    notifyListeners();
  }

  Future<void> removeProduct(String id) async {
    final url = Uri.parse(
        'https://shop-app-9c8ad-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw const HttpException('Could not delete product');
    }
    existingProduct =
        Product(id: '', title: '', description: '', price: 0, imageUrl: '');
  }
}

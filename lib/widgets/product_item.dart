import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem({this.id, this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final loadedProduct = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 7,
            spreadRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: loadedProduct.id,
              );
            },
            child: Image.network(
              loadedProduct.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: Consumer<Product>(
              builder: (ctx, loadedProduct, child) => IconButton(
                // <- never chang child
                icon: Icon(
                  loadedProduct.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 20,
                ),
                // label: child,       <- example for using never changing child
                color: Theme.of(context).accentColor,
                onPressed: () {
                  loadedProduct.toggleFavoriteProduct();
                },
              ),
              // child: Text("Label"),  <- Never change
            ),
            title: Text(
              loadedProduct.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.shopping_cart,
                size: 20,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {
                cart.addItem(
                    loadedProduct.id, loadedProduct.price, loadedProduct.title);
              },
            ),
          ),
        ),
      ),
    );
  }
}

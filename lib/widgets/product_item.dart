import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem({this.id, this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final loadedProduct = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    final scaffold = Scaffold.of(context);
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
            child: Hero(
              tag: loadedProduct.id,
              child: FadeInImage(
                placeholder:
                    AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(loadedProduct.imageUrl),
                fit: BoxFit.cover,
              ),
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
                onPressed: () async {
                  try {
                    await loadedProduct.toggleFavoriteProduct(
                      authData.token,
                      authData.userId,
                    );
                  } catch (error) {
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Adding to favorite failed.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
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
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Container(
                      child: Text(
                        'Added item to cart!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleItem(loadedProduct.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

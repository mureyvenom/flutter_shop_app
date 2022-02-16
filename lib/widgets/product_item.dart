import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  void handleNavigate(BuildContext context, String id) {
    Navigator.of(context).pushNamed('/product-details', arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 5,
        child: GridTile(
          child: GestureDetector(
            onTap: () => handleNavigate(context, product.id),
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: Consumer<Product>(
              builder: (ctx, product, child) {
                return IconButton(
                  onPressed: product.toggleFavoriteStatus,
                  icon: Icon(!product.isFavorite
                      ? Icons.favorite_outline
                      : Icons.favorite),
                  color: Theme.of(context).colorScheme.secondary,
                );
              },
            ),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(product.id, product.price, product.title, 1);
              },
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}

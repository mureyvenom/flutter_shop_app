import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import 'edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const AppDrawer(),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemBuilder: (ctx, i) {
            return Column(
              children: [
                UserProductItem(
                  id: products.items[i].id,
                  title: products.items[i].title,
                  imageUrl: products.items[i].imageUrl,
                ),
                const Divider(),
              ],
            );
          },
          itemCount: products.items.length,
        ),
      ),
    );
  }
}

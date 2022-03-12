import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.cartTotal}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                      onPressed: cart.cartTotal <= 0
                          ? null
                          : () async {
                              try {
                                setState(() {
                                  _isLoading = true;
                                });
                                await Provider.of<Orders>(context,
                                        listen: false)
                                    .addOrder(
                                  cart.items.values.toList(),
                                  cart.cartTotal,
                                );
                                setState(() {
                                  _isLoading = false;
                                });
                                cart.clearCart();
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Order Now'))
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: ((context, index) => CartItem(
                  id: cart.items.values.toList()[index].id,
                  productId: cart.items.keys.toList()[index],
                  title: cart.items.values.toList()[index].title,
                  quantity: cart.items.values.toList()[index].quantity,
                  price: cart.items.values.toList()[index].price)),
            ),
          )
        ],
      ),
    );
  }
}

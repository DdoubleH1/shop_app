import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
import '../widget/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);
  static const routeName = './cart_screen';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartItem = Provider.of<Cart>(context);
    var isLoading = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text(
                      '\$${cartItem.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  ElevatedButton(
                    onPressed: (cartItem.totalAmount <= 0 || isLoading)
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });
                            await Provider.of<Order>(context, listen: false)
                                .addOrderItem(cartItem.items.values.toList(),
                                    cartItem.totalAmount);
                            setState(() {
                              isLoading = false;
                            });
                            cartItem.clearCart();
                          },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('ORDER NOW'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
                itemBuilder: (ctx, index) => CartItem(
                    cartItem.items.values.toList()[index].id,
                    cartItem.items.keys.toList()[index],
                    cartItem.items.values.toList()[index].price,
                    cartItem.items.values.toList()[index].quantity,
                    cartItem.items.values.toList()[index].title),
                itemCount: cartItem.items.length),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
import '../providers/product.dart';
import '../providers/products.dart';

class ScreenArgs {
  final dynamic id;
  ScreenArgs({required this.id});
}

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  String _imageUrl = '';
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0.00,
    imageUrl: '',
    isFavorite: false,
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, String>;
        final productId = args['id'];
        if (productId != null) {
          _editedProduct = Provider.of<Products>(context).findById(productId);
          _initValues = {
            'title': _editedProduct.title,
            'price': _editedProduct.price.toString(),
            'description': _editedProduct.description,
            'imageUrl': '',
          };
          _imageUrlController.text = _editedProduct.imageUrl;
        }
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final _isValid = _form.currentState?.validate();
    if (!_isValid!) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id.isEmpty) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
        Navigator.of(context).pop();
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Something went wrong'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              )
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        // Navigator.of(context).pop();
      }
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
        _isLoading = false;
        Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Something went wrong'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit product'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _form,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: _initValues['title'] as String,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a title';
                                } else {
                                  return null;
                                }
                              },
                              decoration:
                                  const InputDecoration(labelText: 'Title'),
                              textInputAction: TextInputAction.next,
                              onSaved: (value) {
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: value!,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imageUrl: _editedProduct.imageUrl,
                                  isFavorite: _editedProduct.isFavorite,
                                );
                              },
                            ),
                            TextFormField(
                              initialValue: _initValues['price'] as String,
                              validator: (value) {
                                if (double.tryParse(value!) == null) {
                                  return 'Invalid input';
                                }
                                if (double.parse(value) <= 0) {
                                  return 'Enter a value greater than 0';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration:
                                  const InputDecoration(labelText: 'Price'),
                              textInputAction: TextInputAction.next,
                              onSaved: (value) {
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  price: double.parse(value!),
                                  imageUrl: _editedProduct.imageUrl,
                                  isFavorite: _editedProduct.isFavorite,
                                );
                              },
                            ),
                            TextFormField(
                              initialValue:
                                  _initValues['description'] as String,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter a description';
                                } else {
                                  if (value.length < 10) {
                                    return 'Description should be at least 10 characters long';
                                  }
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                              ),
                              onSaved: (value) {
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  description: value!,
                                  price: _editedProduct.price,
                                  imageUrl: _editedProduct.imageUrl,
                                  isFavorite: _editedProduct.isFavorite,
                                );
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: 100,
                                  height: 100,
                                  margin:
                                      const EdgeInsets.only(top: 10, right: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                    width: 1,
                                    color: Colors.grey,
                                  )),
                                  child: _imageUrl.isEmpty
                                      ? const Text('Enter a URL')
                                      : FittedBox(
                                          child: Image.network(
                                            _imageUrlController.text,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter a url';
                                      } else {
                                        if (!value.startsWith('http://') &&
                                            !value.startsWith('https://')) {
                                          return 'Enter a valid url';
                                        }
                                        return null;
                                      }
                                    },
                                    onEditingComplete: () {
                                      setState(() {
                                        _imageUrl = _imageUrlController.text;
                                      });
                                    },
                                    controller: _imageUrlController,
                                    decoration: const InputDecoration(
                                      labelText: 'Image URL',
                                    ),
                                    keyboardType: TextInputType.url,
                                    textInputAction: TextInputAction.done,
                                    onSaved: (value) {
                                      _editedProduct = Product(
                                        id: _editedProduct.id,
                                        title: _editedProduct.title,
                                        description: _editedProduct.description,
                                        price: _editedProduct.price,
                                        imageUrl: value!,
                                        isFavorite: _editedProduct.isFavorite,
                                      );
                                    },
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

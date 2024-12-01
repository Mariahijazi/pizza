import 'package:flutter/material.dart';

void main() => runApp(PizzaOrderApp());

class PizzaOrderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PizzaOrderPage(),
      theme: ThemeData(primarySwatch: Colors.orange),
    );
  }
}

class PizzaOrderPage extends StatefulWidget {
  @override
  _PizzaOrderPageState createState() => _PizzaOrderPageState();
}

class _PizzaOrderPageState extends State<PizzaOrderPage> {
  final List<Map<String, dynamic>> _orders = [];
  final _formKey = GlobalKey<FormState>();

  String? _pizzaType, _size = 'Small', _addOn = 'None'; // Default values
  int? _quantity = 1; // Default quantity
  double _basePrice = 0.0;
  double _sizePrice = 0.0;
  double _addOnPrice = 0.0;
  double _totalPrice = 0.0;

  // Pizza menu with base prices
  final Map<String, double> _pizzaMenu = {
    'Margherita': 5.0,
    'Pepperoni': 8.0,
    'Veggie': 6.0,
  };

  // Size and Add-On prices
  final Map<String, double> _sizePrices = {
    'Small': 2.0,
    'Medium': 4.0,
    'Large': 6.0,
  };

  final Map<String, double> _addOnPrices = {
    'None': 0.0,
    'Ketchup': 1.0,
    'Mayonnaise': 1.5,
    'Sauce': 2.0,
  };

  void _calculateTotalPrice() {
    setState(() {
      _totalPrice = (_basePrice + _sizePrice + _addOnPrice) * (_quantity ?? 1);
    });
  }

  void _addOrEditOrder({int? index}) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _calculateTotalPrice();
      setState(() {
        final order = {
          'pizzaType': _pizzaType,
          'size': _size,
          'addOn': _addOn,
          'quantity': _quantity,
          'price': _totalPrice,
        };

        if (index == null) {
          _orders.add(order);
        } else {
          _orders[index] = order;
        }
      });
      Navigator.pop(context);
    }
  }

  void _deleteOrder(int index) {
    setState(() {
      _orders.removeAt(index);
    });
  }

  void _openForm({int? index}) {
    if (index != null) {
      final order = _orders[index];
      _pizzaType = order['pizzaType'];
      _size = order['size'];
      _addOn = order['addOn'];
      _quantity = order['quantity'];
      _basePrice = _pizzaMenu[_pizzaType]!;
      _sizePrice = _sizePrices[_size]!;
      _addOnPrice = _addOnPrices[_addOn]!;
    } else {
      _pizzaType = null;
      _size = 'Small'; // Default size
      _addOn = 'None'; // Default add-on
      _quantity = 1; // Default quantity
      _basePrice = 0.0;
      _sizePrice = 0.0;
      _addOnPrice = 0.0;
    }

    _calculateTotalPrice();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(index == null ? 'Add Pizza Order' : 'Edit Pizza Order'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pizza Type Dropdown
                DropdownButtonFormField<String>(
                  value: _pizzaType,
                  decoration: InputDecoration(
                    labelText: 'Pizza Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _pizzaMenu.keys
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _pizzaType = value;
                      _basePrice = _pizzaMenu[value]!;
                      _calculateTotalPrice();
                    });
                  },
                  onSaved: (value) => _pizzaType = value,
                  validator: (value) =>
                      value == null ? 'Select a pizza type' : null,
                ),
                SizedBox(height: 10),

                // Size Radio Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Size",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ..._sizePrices.keys.map((size) {
                      return RadioListTile<String>(
                        title: Text(size),
                        value: size,
                        groupValue: _size,
                        onChanged: (value) {
                          setState(() {
                            _size = value;
                            _sizePrice = _sizePrices[value]!;
                            _calculateTotalPrice();
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
                SizedBox(height: 10),

                // Add-On Radio Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add-On",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ..._addOnPrices.keys.map((addOn) {
                      return RadioListTile<String>(
                        title: Text(addOn),
                        value: addOn,
                        groupValue: _addOn,
                        onChanged: (value) {
                          setState(() {
                            _addOn = value;
                            _addOnPrice = _addOnPrices[value]!;
                            _calculateTotalPrice();
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
                SizedBox(height: 10),

                // Quantity Input
                TextFormField(
                  initialValue: _quantity?.toString(),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _quantity = int.tryParse(value) ?? 1;
                      _calculateTotalPrice();
                    });
                  },
                  onSaved: (value) => _quantity = int.tryParse(value!),
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Total Price Display
                Text(
                  'Total Price:                  \$${_totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addOrEditOrder(index: index),
            child: Text(index == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pizza Order App'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://tse1.mm.bing.net/th?id=OIP.Jyw0-OLOMx_daTScv09fewHaE7&pid=Api'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: _orders.isEmpty
                      ? Center(
                          child: Text(
                            'No Orders Yet!',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                                Colors.grey[300]),
                            dataRowColor:
                                MaterialStateProperty.all(Colors.grey[200]),
                            columns: [
                              DataColumn(label: Text('Pizza Type')),
                              DataColumn(label: Text('Size')),
                              DataColumn(label: Text('Add-On')),
                              DataColumn(label: Text('Quantity')),
                              DataColumn(label: Text('Total Price')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: _orders.map((order) {
                              final index = _orders.indexOf(order);
                              return DataRow(cells: [
                                DataCell(Text(order['pizzaType'])),
                                DataCell(Text(order['size'])),
                                DataCell(Text(order['addOn'])),
                                DataCell(Text(order['quantity'].toString())),
                                DataCell(Text(
                                    '\$${order['price'].toStringAsFixed(2)}')),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () =>
                                            _openForm(index: index),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _deleteOrder(index),
                                      ),
                                    ],
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: Icon(Icons.add),
),);
}
}
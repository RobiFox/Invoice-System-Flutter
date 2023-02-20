import 'dart:convert';

import 'package:flutter/material.dart';
import 'constants.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoice System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Invoice System'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _tableKey = GlobalKey();

  Future<http.Response>? response;
  List<Product> products = [];

  void refreshTable() {
    setState(() {
      products = [];
    });
    response = http.get(Uri.parse(Constants.urlProducts))
      ..catchError((error) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(error.toString()),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"))
              ],
            );
          },
        );
      })
      ..then((value) => {
            setState(() {
              List<dynamic> list = List.from(jsonDecode(value.body));
              for (var e in list) {
                products.add(Product.fromJson(e));
              }
            })
          });
  }

  @override
  void initState() {
    super.initState();
    refreshTable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  FutureBuilder(
                    future: response,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                            child: SizedBox(
                                width: 32, child: CircularProgressIndicator()));
                      }
                      if (snapshot.hasError) {
                        return const Icon(Icons.error);
                      }
                      return ProductTable(
                        key: _tableKey,
                        products: products,
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 64,
                child: ElevatedButton(
                    onPressed: () async {
                      List<int> ids = [];
                      for (Product p in products) {
                        if (p.checked) ids.add(p.id);
                      }
                      http
                          .get(Uri.parse(
                              "${Constants.urlInvoice}?id=${ids.join(",")}"))
                          .then((value) async {
                        var uri = Uri.parse(jsonDecode(
                            value.body)[Constants.invoiceRedirectUrl]);
                        if (!await canLaunchUrl(uri)) {
                          return;
                        }
                        launchUrl(uri);
                      });
                    },
                    child: const Text(
                      "Generate Invoice",
                      style: TextStyle(fontSize: 32),
                    )))
          ],
        ));
  }
}

class ProductTable extends StatefulWidget {
  final List<Product> products;

  const ProductTable({Key? key, required this.products}) : super(key: key);

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: Colors.black,
      ),
      children: [
        TableRow(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0),
            ),
            children: const [
              SizedBox(
                  height: 24,
                  child: Text("Name",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(
                  height: 24,
                  child: Text("Amount",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(
                  height: 24,
                  child: Text("Include in Invoice",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ]),
        for (Product p in widget.products)
          TableRow(children: [
            Text(p.name, textAlign: TextAlign.center),
            Text(p.amount.toString(), textAlign: TextAlign.center),
            Checkbox(
                value: p.checked,
                onChanged: (value) =>
                    setState(() => p.checked = value ?? false))
          ])
      ],
    );
  }
}

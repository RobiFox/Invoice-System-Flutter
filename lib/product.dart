import 'constants.dart';

class Product {
  final String name;
  final int id;
  final int amount;
  bool checked;

  Product(this.name, this.id, this.amount, {this.checked = false});

  Product.fromJson(Map<String, dynamic> json) :
    name = json[Constants.productName],
    amount = json[Constants.productAmount],
  id = json[Constants.productId],
  checked = false;

  Map<String, dynamic> toJson() => {
    Constants.productName: name,
    Constants.productAmount: amount
  };
}
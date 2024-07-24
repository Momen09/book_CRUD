import 'package:cloud_firestore/cloud_firestore.dart';


class Book {
  String id;
  String title;
  int quantity;
  String photo;
  int currentQuantity;

  Book({required this.title,required this.id,required this.currentQuantity,required this.quantity, required this.photo});

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Book(
      title: data['title'] ?? '',
      quantity: data['quantity'] ?? 0,
      photo: data['photo'] ?? '',
      currentQuantity: data['currentQuantity']??0,
      id:doc.id,
    );
  }
}

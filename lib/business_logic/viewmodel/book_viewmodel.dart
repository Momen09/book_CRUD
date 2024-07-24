import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/model.dart';

class BookViewModel extends ChangeNotifier {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userCodeController = TextEditingController();
  List<Book> books = [];

  void setUserName(String name) {
    userNameController.text = name;
    notifyListeners();
  }

  void setUserCode(String code) {
    userCodeController.text = code;
    notifyListeners();
  }

  Future<void> getBooks() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('books').get();
      books = querySnapshot.docs.map((doc) {
        final book = Book.fromFirestore(doc);
        book.currentQuantity = book.currentQuantity != 0 ? book.currentQuantity : book.quantity;
        return book;
      }).toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> borrowBook(int index) async {
    if (books[index].currentQuantity > 0) {
      books[index].currentQuantity -= 1;
      notifyListeners();
      try {
        await FirebaseFirestore.instance
            .collection('books')
            .doc(books[index].id)
            .update({'currentQuantity': books[index].currentQuantity});
        await FirebaseFirestore.instance.collection('borrowBooks').add({
          'userName': userNameController.text,
          'userCode': userCodeController.text,
          'bookTitle': books[index].title,
        });
      } catch (e) {
        print("Error updating Firestore: $e");
      }
    }
  }

  Future<void> returnBook(int index) async {
      if (books[index].currentQuantity < books[index].quantity) {
        books[index].currentQuantity += 1;
        notifyListeners();
        try {
          await FirebaseFirestore.instance
              .collection('books')
              .doc(books[index].id)
              .update({'currentQuantity': books[index].currentQuantity});

          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('borrowBooks')
              .where('userName', isEqualTo: userNameController.text)
              .where('userCode', isEqualTo: userCodeController.text)
              .where('bookTitle', isEqualTo: books[index].title)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            for (var doc in querySnapshot.docs) {
              await FirebaseFirestore.instance.collection('borrowBooks').doc(doc.id).delete();
            }
          }
        } catch (e) {
          print("Error updating Firestore: $e");
      }
    }
  }

  Future<bool> checkUserBook(String name, String code, index) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('borrowBooks')
          .where('userName', isEqualTo: name)
          .where('userCode', isEqualTo: code)
          .where('bookTitle', isEqualTo: books[index].title)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await FirebaseFirestore.instance.collection('borrowBooks').doc(doc.id).delete();
        }
      }
      return querySnapshot.docs.isNotEmpty;

    } catch (e) {
      print("Error checking user and book: $e");
      return false;
    }
  }
}

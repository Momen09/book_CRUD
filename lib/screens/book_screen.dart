import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../business_logic/model/model.dart';
import '../business_logic/viewmodel/book_viewmodel.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<BookViewModel>(context, listen: false);
    viewModel.getBooks();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BookViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Book Store'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _bookList(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _bookList(BookViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.books.length,
      itemBuilder: (context, index) {
        final book = viewModel.books[index];
        return Padding(
          padding: EdgeInsets.all(8.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: ListTile(
              leading: SizedBox(
                width: 50.w,
                height: 70.h,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    book.photo,
                  ),
                ),
              ),
              title: Text(book.title),
              subtitle: Text(
                'Available: ${book.currentQuantity}/${book.quantity}',
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _showBorrowDialog(context, viewModel, book, index);
                },
                child: const Text('Select'),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBorrowDialog(
      BuildContext context, BookViewModel viewModel, Book book, int index) {
    TextEditingController nameController = TextEditingController();
    TextEditingController codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Book Options'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailsText(
                  nameController,
                  'Name',
                  'Please enter your name',
                ),
                SizedBox(
                  height: 7.w,
                ),
                _detailsText(
                  codeController,
                  'Code',
                  'Please enter your code',
                ),
              ],
            ),
          ),
          actions: [
            _borrowButton(formKey, viewModel, nameController, codeController,
                index, context, book),
            _getBackButton(formKey, viewModel, nameController, codeController,
                book, index, context),
          ],
        );
      },
    );
  }

  Widget _getBackButton(
      GlobalKey<FormState> formKey,
      BookViewModel viewModel,
      TextEditingController nameController,
      TextEditingController codeController,
      Book book,
      int index,
      BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          bool userExists = await viewModel.checkUserBook(
            nameController.text,
            codeController.text,
            index,
          );
          if (userExists) {
            await viewModel.returnBook(index);
            Navigator.of(context).pop();
            if (book.currentQuantity == book.quantity) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All copies of ${book.title} are already returned',
                  ),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'User or book not found',
                ),
              ),
            );
          }
        }
      },
      child: const Text('Get Back'),
    );
  }

  Widget _borrowButton(
      GlobalKey<FormState> formKey,
      BookViewModel viewModel,
      TextEditingController nameController,
      TextEditingController codeController,
      int index,
      BuildContext context,
      Book book) {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          viewModel.setUserName(nameController.text);
          viewModel.setUserCode(codeController.text);
          await viewModel.borrowBook(index);
          Navigator.of(context).pop();
          if (book.currentQuantity == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'No more book ${book.title} available',
                ),
              ),
            );
          }
        }
      },
      child: const Text('Borrow'),
    );
  }

  Widget _detailsText(controller, text, validate) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: text,
        // fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.h),
          // borderSide: BorderSide.none
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validate;
        }
        return null;
      },
    );
  }
}

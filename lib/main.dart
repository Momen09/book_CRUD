import 'package:elocalize_test/screens/book_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'business_logic/viewmodel/book_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyAKqa4mEANozZCSknzaE_8AwE2SufXAhjk',
          appId: '1:412431963048:android:70b815ae893efd6052c39d',
          messagingSenderId: '811505743152',
          projectId: 'elocalize'));
  runApp( const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BookViewModel(),
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.white
            ),
            debugShowCheckedModeBanner: false,
            home: const BookScreen(),
          );
        },
      ),
    );
  }
}

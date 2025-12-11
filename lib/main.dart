import 'package:family_home/src/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyAaLaWkhHL1XCOUsSfBwJobpGuCMQ9BLIE",
    authDomain: "family-home-8938e.firebaseapp.com",
    projectId: "family-home-8938e",
    storageBucket: "family-home-8938e.firebasestorage.app",
    messagingSenderId: "729680587676",
    appId: "1:729680587676:web:d41d9a9fac23b15ba8b659"
  );
  await Firebase.initializeApp(
    options: kIsWeb ? firebaseConfig : null
  );
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child){
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(),
          home: SplashScreen(),
        );
      }
    );
  }
}


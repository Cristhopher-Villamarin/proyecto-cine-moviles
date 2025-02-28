import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'services/firestore_service.dart';
import 'views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Para Web, usa FirebaseOptions
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyC5FXqHDCZmMUnDOQ3mqDPWOisnxxqppSc", // Clave de API web
        authDomain: "proyecto-cine-ea02c.firebaseapp.com", // authDomain del proyecto
        projectId: "proyecto-cine-ea02c", // ID del proyecto
        storageBucket: "proyecto-cine-ea02c.appspot.com", // Storage bucket
        messagingSenderId: "1067716693159", // Sender ID del proyecto
        appId: "1:1067716693159:android:611e4c63c3276ab242df82", // App ID del proyecto
      ),
    );
  } else {
    // Para Android e iOS, Firebase detecta automáticamente los archivos de configuración
    await Firebase.initializeApp();
  }
  FirestoreService firestoreService = FirestoreService();
  await firestoreService.agregarPeliculas();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cine App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: LoginScreen(),
    );
  }
}

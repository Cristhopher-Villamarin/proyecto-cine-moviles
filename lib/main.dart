import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// 🔹 Importar WebViewFlutter
import 'services/firestore_service.dart';
import 'views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Para Web, usa FirebaseOptions
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAysPjX7iFU_bszqKo70DZ-sY3nzFkOYRE",
        authDomain: "cine-movil-e195d.firebaseapp.com",
        projectId: "cine-movil-e195d",
        storageBucket: "cine-movil-e195d.appspot.com",
        messagingSenderId: "836982216924",
        appId: "1:836982216924:android:94a28e568e528b94aa7c19",
      ),
    );
  } else {
    await Firebase.initializeApp();
  // 🔹 Inicializa WebView en Android
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

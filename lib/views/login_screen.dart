import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'pantalla_cine.dart'; // Importa la nueva pantalla


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      await GoogleSignIn().signOut();
      await _firebaseAuth.signOut();

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
        final user = userCredential.user;

        if (user != null) {
          _navigateToCinemaScreen(user.displayName ?? user.email ?? "Usuario");
        }
      }
    } catch (e) {
      print('Error al iniciar sesión con Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  void _navigateToCinemaScreen(String username) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaCine(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Fondo degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black, // Negro en la parte superior
                  Color(0xFF3533CD), // Azul oscuro en la parte inferior
                ],
              ),
            ),
          ),

          /// Imagen PNG superpuesta como marca de agua
          Positioned.fill(
            child: Image.asset(
              'assets/fondo.png', // Imagen de marca de agua
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.srcOver,

            ),
          ),


          /// Imagen PNG superpuesta como marca de agua
          Positioned.fill(
            child: Image.asset(
              'assets/fondo.png', // Imagen de marca de agua
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.srcOver,

            ),
          ),

          /// Imágenes en las 4 esquinas con efecto "metido"
          Positioned(
            top: -40, left: -30, // Parte fuera de la pantalla
            child: Image.asset(
              'assets/objeto1.png',
              width: 250, // Más grande para que sobresalga
            ),
          ),
          Positioned(
            top: -40, right: -30, // Parte fuera de la pantalla
            child: Image.asset(
              'assets/objeto2.png',
              width: 250,
            ),
          ),
          Positioned(
            bottom: -40, left: -30, // Parte fuera de la pantalla
            child: Image.asset(
              'assets/objeto3.png',
              width: 250,
            ),
          ),
          Positioned(
            bottom: -40, right: -30, // Parte fuera de la pantalla
            child: Image.asset(
              'assets/objeto4.png',
              width: 250,
            ),
          ),

          /// Contenido principal con el nuevo diseño
          Center(
            child: Card(
              color: Colors.black.withOpacity(0.4), // Fondo negro con transparencia
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Logo reemplazado
                    Image.asset(
                      'assets/logo2.png', // Asegúrate de tener este logo en assets
                      height: 80, // Ajusta el tamaño según necesidad
                    ),
                    SizedBox(height: 20),

                    /// Título "CINE HOUSE" con estilos
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "CINE",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.red, // Rojo
                              fontFamily: 'Bebas Neue', // Cambia la fuente si es necesario
                            ),
                          ),
                          TextSpan(
                            text: " HOUSE",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue, // Azul
                              fontFamily: 'Bebas Neue',
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8),

                    /// Frase debajo del título en blanco
                    Text(
                      'Tu asiento, el mejor lugar para vivir la aventura.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Blanco
                        fontFamily: 'Arial',
                      ),
                    ),

                    SizedBox(height: 20),

                    /// Botón de inicio de sesión
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.red),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(250, 60),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                      icon: Image.asset(
                        'assets/google_logo.png',
                        height: 20,
                        width: 20,
                      ),
                      label: _isSigningIn
                          ? CircularProgressIndicator()
                          : Text(
                        'Iniciar sesión con Google',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: _isSigningIn ? null : _signInWithGoogle,
                    ),
                    SizedBox(height: 16),
                  ],


                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
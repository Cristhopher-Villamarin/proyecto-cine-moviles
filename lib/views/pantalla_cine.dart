import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantalla_fecha_hora.dart';

class PantallaCine extends StatefulWidget {
  @override
  _PantallaCineState createState() => _PantallaCineState();
}

class _PantallaCineState extends State<PantallaCine> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  // 🔹 Lista de imágenes locales (asegúrate de agregarlas en `pubspec.yaml`)
  final List<String> imagenesCarrusel = [
    "assets/avatar.png",
    "assets/carrusel_1.png",
    "assets/spiderman.png",
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), _moverCarrusel);
  }

  void _moverCarrusel() {
    if (_pageController.hasClients) {
      int nextPage = (_currentPage + 1) % imagenesCarrusel.length;
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage = nextPage;
      });
      Future.delayed(Duration(seconds: 4), _moverCarrusel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // 🔹 Centra el título y el icono
          children: [
            Icon(Icons.local_movies, color: Colors.white, size: 28), // 🎬 Icono de cine
            SizedBox(width: 8), // 🔹 Espacio entre el icono y el texto
            Text(
              "CARTELERA DE PELÍCULAS",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
          backgroundColor: Colors.indigo,
        ),
      body: SingleChildScrollView( // 🔹 Permite desplazamiento en toda la pantalla
        child: Column(
          children: [
            SizedBox(height: 20), // 🔹 Espacio debajo del AppBar

            // 🔹 Carrusel de imágenes
            SizedBox(
              height: 400, // 🔹 Se mantiene la altura ajustada
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagenesCarrusel.length,
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: index == _currentPage ? 0 : 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagenesCarrusel[index],
                        fit: BoxFit.cover, // 🔹 Se adapta sin recortar
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20), // 🔹 Más espacio debajo del carrusel

            // 🔹 Título de la cartelera
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "CARTELERA",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Azul
                  fontFamily: 'Bebas Neue',
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // 🔹 Catálogo de películas
            StreamBuilder(
              stream: _firestore.collection("peliculas").snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var peliculas = snapshot.data!.docs;

                return Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: peliculas.length,
                      shrinkWrap: true, // 🔹 Evita que el GridView ocupe todo el espacio
                      physics: NeverScrollableScrollPhysics(), // 🔹 Desactiva su scroll para que dependa del SingleChildScrollView
                      itemBuilder: (context, index) {
                        var pelicula = peliculas[index];
                        var data = pelicula.data() as Map<String, dynamic>;

                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 5,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                  child: AspectRatio(
                                    aspectRatio: 0.7,
                                    child: Image.network(
                                      data["imagen"],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.broken_image, size: 50, color: Colors.grey);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  data["titulo"] ?? "Sin título",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PantallaFechaHora(
                                          peliculaId: pelicula.id,
                                          titulo: data["titulo"],
                                          imagen: data["imagen"],
                                          sinopsis: data["sinopsis"],
                                          precio: data["precio"].toDouble(),
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  child: Text(
                                    "Comprar",
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}

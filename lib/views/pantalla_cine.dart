import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantalla_fecha_hora.dart'; // Importa la pantalla de selección de fecha y horario

class PantallaCine extends StatefulWidget {
  @override
  _PantallaCineState createState() => _PantallaCineState();
}

class _PantallaCineState extends State<PantallaCine> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cartelera de Películas"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder(
        stream: _firestore.collection("peliculas").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var peliculas = snapshot.data!.docs;

          return Center( // 🔹 Centra el contenido en la pantalla
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9, // 🔹 Reduce el ancho del Grid
              child: GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 🔹 3 películas por fila
                  childAspectRatio: 0.55, // 🔹 Reduce el tamaño de las tarjetas
                  crossAxisSpacing: 12, // 🔹 Espacio entre columnas
                  mainAxisSpacing: 12, // 🔹 Espacio entre filas
                ),
                itemCount: peliculas.length,
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
                            child: AspectRatio( // 🔹 Asegura que la imagen se adapta sin perder calidad
                              aspectRatio: 0.7, // Mantiene la proporción
                              child: Image.network(
                                data["imagen"],
                                fit: BoxFit.cover, // 🔹 Se adapta sin recortarse
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
                                borderRadius: BorderRadius.circular(8), // 🔹 Mejora el diseño del botón
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), // 🔹 Ajusta el tamaño del botón
                            ),
                            child: Text(
                              "Comprar",
                              style: TextStyle(fontSize: 14, color: Colors.white), // 🔹 Hace el texto más visible
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
    );
  }
}

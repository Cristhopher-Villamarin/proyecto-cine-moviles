import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantalla_fecha_hora.dart'; // Importa la nueva pantalla de selección de fecha y horario

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
        title: Text("Catálogo de Películas"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder(
        stream: _firestore.collection("peliculas").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var peliculas = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 películas por fila
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: peliculas.length,
            itemBuilder: (context, index) {
              var pelicula = peliculas[index];
              var data = pelicula.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.network(
                          data["imagen"],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 100, color: Colors.grey);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        data["titulo"] ?? "Sin título",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
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
                      ),
                      child: Text("Comprar"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

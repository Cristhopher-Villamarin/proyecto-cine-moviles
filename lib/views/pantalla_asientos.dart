import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantalla_pago.dart';

class PantallaAsientos extends StatefulWidget {
  final String peliculaId;
  final String titulo;
  final double precio;
  final String fechaSeleccionada;
  final String horaSeleccionada;

  const PantallaAsientos({
    Key? key,
    required this.peliculaId,
    required this.titulo,
    required this.precio,
    required this.fechaSeleccionada,
    required this.horaSeleccionada,
  }) : super(key: key);

  @override
  _PantallaAsientosState createState() => _PantallaAsientosState();
}

class _PantallaAsientosState extends State<PantallaAsientos> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _asientosSeleccionados = [];
  double _totalPago = 0.0;

  void _toggleAsiento(String asientoId) {
    setState(() {
      if (_asientosSeleccionados.contains(asientoId)) {
        _asientosSeleccionados.remove(asientoId);
      } else {
        _asientosSeleccionados.add(asientoId);
      }
      _totalPago = _asientosSeleccionados.length * widget.precio;

      print("📌 Asientos seleccionados: $_asientosSeleccionados");
      print("💰 Total a pagar: $_totalPago");
    });
  }

  void _irAPantallaDePago() {
    if (_asientosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona al menos un asiento")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaPago(
          totalPago: _totalPago,
          peliculaId: widget.peliculaId, // ✅ Se pasa correctamente
          peliculaTitulo: widget.titulo,

          fechaSeleccionada: widget.fechaSeleccionada,
          horaSeleccionada: widget.horaSeleccionada,
          asientosSeleccionados: _asientosSeleccionados,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccionar Asientos - ${widget.titulo}"),
        backgroundColor: Colors.indigo,
      ),
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
              'assets/fondo.png',
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.srcOver,
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          /// Contenido principal
          Column(
            children: [
              SizedBox(height: 20),

              /// Pantalla del cine más pequeña y gruesa
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "PANTALLA",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              SizedBox(height: 20),

              /// Muestra los asientos
              Expanded(
                child: StreamBuilder(
                  stream: _firestore
                      .collection("peliculas")
                      .doc(widget.peliculaId)
                      .collection("fechas_disponibles")
                      .doc(widget.fechaSeleccionada)
                      .collection("horarios")
                      .doc(widget.horaSeleccionada)
                      .collection("asientos")
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var asientos = snapshot.data!.docs;
                    Map<String, List<QueryDocumentSnapshot>> filas = {};
                    for (var asiento in asientos) {
                      String fila = asiento["numero"][0];
                      filas.putIfAbsent(fila, () => []).add(asiento);
                    }

                    return Column(
                      children: filas.entries.map((entry) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: entry.value.map((asiento) {
                            bool esOcupado = asiento["estado"] == "ocupado";
                            bool esSeleccionado =
                            _asientosSeleccionados.contains(asiento.id);

                            return GestureDetector(
                              onTap: () {
                                if (!esOcupado) _toggleAsiento(asiento.id);
                              },
                              child: Container(
                                margin: EdgeInsets.all(5),
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: esOcupado
                                      ? Colors.red // Ocupado (Rojo)
                                      : (esSeleccionado
                                      ? Colors.green // Seleccionado (Verde)
                                      : Colors.grey[300]), // Disponible (Gris)
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    asiento["numero"],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),


              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildColorIndicator(Colors.grey[300]!, "Disponible"),
                  _buildColorIndicator(Colors.green, "Seleccionado"),
                  _buildColorIndicator(Colors.red, "Ocupado"),
                ],
              ),
              SizedBox(height: 20),

              /// Total a pagar
              Text(
                "Total a Pagar: \$${_totalPago.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              /// Botón de pago
              FloatingActionButton.extended(
                onPressed: _irAPantallaDePago,
                label: Text("Ir a Pagar"),
                icon: Icon(Icons.payment),
                backgroundColor: Colors.white,
              ),



              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
Widget _buildColorIndicator(Color color, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        SizedBox(width: 5),
        Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
      ],
    ),
  );
}
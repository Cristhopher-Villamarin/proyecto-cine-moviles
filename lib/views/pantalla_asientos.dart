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
      body: Column(
        children: [
          SizedBox(height: 20),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text("PANTALLA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 20),
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
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

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
                        bool esSeleccionado = _asientosSeleccionados.contains(asiento.id);

                        return GestureDetector(
                          onTap: () {
                            if (!esOcupado) _toggleAsiento(asiento.id);
                          },
                          child: Container(
                            margin: EdgeInsets.all(4),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: esOcupado ? Colors.red : (esSeleccionado ? Colors.green : Colors.grey[300]),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                asiento["numero"],
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          Text("Total a Pagar: \$${_totalPago.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: _irAPantallaDePago,
            label: Text("Ir a Pagar"),
            icon: Icon(Icons.payment),
            backgroundColor: Colors.indigo,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

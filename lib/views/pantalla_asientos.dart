import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantalla_confirmacion.dart'; // Importa la pantalla de confirmación.

class PantallaAsientos extends StatefulWidget {
  final String peliculaId;
  final String titulo;

  const PantallaAsientos({Key? key, required this.peliculaId, required this.titulo}) : super(key: key);

  @override
  _PantallaAsientosState createState() => _PantallaAsientosState();
}

class _PantallaAsientosState extends State<PantallaAsientos> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _asientosSeleccionados = [];

  void _toggleAsiento(String asientoId) {
    setState(() {
      if (_asientosSeleccionados.contains(asientoId)) {
        _asientosSeleccionados.remove(asientoId);
      } else {
        _asientosSeleccionados.add(asientoId);
      }
    });
  }

  Future<void> _confirmarReserva() async {
    if (_asientosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona al menos un asiento")),
      );
      return;
    }

    // Marcar los asientos como ocupados en Firestore
    for (String asiento in _asientosSeleccionados) {
      await _firestore.collection("asientos").doc(asiento).update({"estado": "ocupado"});
    }

    // Navegar a la pantalla de confirmación
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaConfirmacion(
          peliculaTitulo: widget.titulo,
          asientos: _asientosSeleccionados,
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
          SizedBox(height: 10),
          Text(
            "Selecciona tus asientos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection("asientos")
                  .where("peliculaId", isEqualTo: widget.peliculaId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var asientos = snapshot.data!.docs;

                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8, // Número de asientos por fila
                    childAspectRatio: 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: asientos.length,
                  itemBuilder: (context, index) {
                    var asiento = asientos[index];
                    bool esOcupado = asiento["estado"] == "ocupado";
                    bool esSeleccionado = _asientosSeleccionados.contains(asiento.id);

                    return GestureDetector(
                      onTap: () {
                        if (!esOcupado) {
                          _toggleAsiento(asiento.id);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: esOcupado
                              ? Colors.red
                              : esSeleccionado
                              ? Colors.green
                              : Colors.grey[300],
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
                  },
                );
              },
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _confirmarReserva,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text("Confirmar Reserva", style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

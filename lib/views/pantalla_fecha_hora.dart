import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantalla_asientos.dart';

class PantallaFechaHora extends StatefulWidget {
  final String peliculaId;
  final String titulo;
  final String imagen;
  final String sinopsis;
  final double precio;

  const PantallaFechaHora({
    Key? key,
    required this.peliculaId,
    required this.titulo,
    required this.imagen,
    required this.sinopsis,
    required this.precio,
  }) : super(key: key);

  @override
  _PantallaFechaHoraState createState() => _PantallaFechaHoraState();
}

class _PantallaFechaHoraState extends State<PantallaFechaHora> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? fechaSeleccionada;
  String? fechaTextoSeleccionada;
  String? horarioSeleccionado;
  List<String> horariosDisponibles = [];

  void _seleccionarFecha(String fechaId, String fechaTexto, List<String> horarios) {
    setState(() {
      fechaSeleccionada = fechaId;
      fechaTextoSeleccionada = fechaTexto;
      horariosDisponibles = horarios;
      horarioSeleccionado = null; // Reiniciar horario seleccionado
    });
  }

  void _seleccionarHorario(String horario) {
    setState(() {
      horarioSeleccionado = horario;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccionar Fecha y Horario"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(widget.imagen, height: 200, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(widget.titulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.sinopsis, textAlign: TextAlign.center),
            Text("Precio: \$${widget.precio}", style: TextStyle(fontSize: 18, color: Colors.green)),
            SizedBox(height: 20),

            Text("Selecciona una Fecha", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            StreamBuilder(
              stream: _firestore.collection("peliculas").doc(widget.peliculaId)
                  .collection("fechas_disponibles").snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var fechas = snapshot.data!.docs;

                return Wrap(
                  spacing: 10,
                  children: fechas.map((fecha) {
                    var data = fecha.data() as Map<String, dynamic>;
                    String fechaTexto = "${data["dia_letras"]} ${data["dia_numero"]} ${data["mes"]}";

                    return ChoiceChip(
                      label: Text(fechaTexto),
                      selected: fechaSeleccionada == fecha.id,
                      onSelected: (_) => _seleccionarFecha(
                          fecha.id, fechaTexto, List<String>.from(data["horarios"])
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 20),

            if (horariosDisponibles.isNotEmpty) ...[
              Text("Selecciona un Horario", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: horariosDisponibles.map((horario) {
                  return ChoiceChip(
                    label: Text(horario),
                    selected: horarioSeleccionado == horario,
                    onSelected: (_) => _seleccionarHorario(horario),
                  );
                }).toList(),
              ),
            ],
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: (fechaSeleccionada != null && horarioSeleccionado != null)
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaAsientos(
                      peliculaId: widget.peliculaId,
                      titulo: widget.titulo,
                      precio: widget.precio,
                      fechaSeleccionada: fechaSeleccionada!, // 📌 Pasar fecha seleccionada
                      horaSeleccionada: horarioSeleccionado!, // 📌 Pasar horario seleccionado
                    ),
                  ),
                );
              }
                  : null, // Deshabilitar si no ha seleccionado fecha y horario
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: Text("Seleccionar Asientos"),
            ),
          ],
        ),
      ),
    );
  }
}

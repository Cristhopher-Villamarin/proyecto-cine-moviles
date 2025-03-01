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
      horarioSeleccionado = null;
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
      body: Stack(
        children: [
          /// Fondo degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Color(0xFF3533CD),
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
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                /// Tarjeta con la información de la película
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Imagen de la película
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.imagen,
                            height: 220,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 12),

                        /// Información de la película
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.titulo,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                              SizedBox(height: 8),
                              Text(
                                widget.sinopsis,
                                textAlign: TextAlign.justify,
                                style: TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Precio: \$${widget.precio}",
                                style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                /// Selección de Fecha
                Text(
                  "Selecciona una Fecha",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                SizedBox(height: 10),

                StreamBuilder(
                  stream: _firestore.collection("peliculas").doc(widget.peliculaId)
                      .collection("fechas_disponibles").snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                    var fechas = snapshot.data!.docs;

                    return Wrap(
                      spacing: 10,
                      children: fechas.map((fecha) {
                        var data = fecha.data() as Map<String, dynamic>;
                        String fechaTexto = "${data["dia_letras"]} ${data["dia_numero"]} ${data["mes"]}";

                        return ChoiceChip(
                          label: Text(
                            fechaTexto,
                            style: TextStyle(
                              color: fechaSeleccionada == fecha.id ? Colors.white : Colors.black,
                            ),
                          ),
                          selectedColor: Colors.red,
                          selected: fechaSeleccionada == fecha.id,
                          onSelected: (_) => _seleccionarFecha(fecha.id, fechaTexto, List<String>.from(data["horarios"])),
                        );
                      }).toList(),
                    );
                  },
                ),

                SizedBox(height: 20),

                /// Selección de Horario
                if (horariosDisponibles.isNotEmpty) ...[
                  Text(
                    "Selecciona un Horario",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: horariosDisponibles.map((horario) {
                      return ChoiceChip(
                        label: Text(
                          horario,
                          style: TextStyle(
                            color: horarioSeleccionado == horario ? Colors.white : Colors.black,
                          ),
                        ),
                        selectedColor: Colors.red,
                        selected: horarioSeleccionado == horario,
                        onSelected: (_) => _seleccionarHorario(horario),
                      );
                    }).toList(),
                  ),
                ],

                SizedBox(height: 20),

                /// Botón de Selección de Asientos
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: (fechaSeleccionada != null && horarioSeleccionado != null)
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantallaAsientos(
                            peliculaId: widget.peliculaId,
                            titulo: widget.titulo,
                            precio: widget.precio,
                            fechaSeleccionada: fechaSeleccionada!,
                            horaSeleccionada: horarioSeleccionado!,
                          ),
                        ),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      "Seleccionar Asientos",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
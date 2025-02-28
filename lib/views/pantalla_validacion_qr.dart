import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PantallaValidacionQR extends StatefulWidget {
  @override
  _PantallaValidacionQRState createState() => _PantallaValidacionQRState();
}

class _PantallaValidacionQRState extends State<PantallaValidacionQR> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _mensaje = "Escanea un código QR";

  void _verificarReserva(String qrData) async {
    try {
      List<String> data = qrData.split("\n");
      String pelicula = data[0].replaceFirst("Película: ", "").trim();
      String asientos = data[1].replaceFirst("Asientos: ", "").trim();

      // Buscar en Firestore si los asientos están reservados
      QuerySnapshot reservaSnapshot = await _firestore
          .collection("reservas")
          .where("pelicula", isEqualTo: pelicula)
          .where("asientos", isEqualTo: asientos)
          .get();

      if (reservaSnapshot.docs.isNotEmpty) {
        setState(() {
          _mensaje = "✅ Acceso permitido para $pelicula\nAsientos: $asientos";
        });
      } else {
        setState(() {
          _mensaje = "❌ Código no válido o reserva no encontrada";
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = "❌ Error al procesar el código QR";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Validación de Entrada"),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (barcode) {
                if (barcode.barcodes.isNotEmpty) {
                  String qrData = barcode.barcodes.first.rawValue ?? "";
                  _verificarReserva(qrData);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _mensaje = "Escanea un código QR";
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
            ),
            child: Text("Escanear otro código"),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

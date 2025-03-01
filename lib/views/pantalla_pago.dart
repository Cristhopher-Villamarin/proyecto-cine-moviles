import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pago_exito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pantalla_cine.dart';

class PantallaPago extends StatefulWidget {
  final double totalPago;
  final String peliculaId;
  final String peliculaTitulo; // ✅ Agregado para evitar errores
  final String fechaSeleccionada;
  final String horaSeleccionada;
  final List<String> asientosSeleccionados;

  const PantallaPago({
    Key? key,
    required this.totalPago,
    required this.peliculaId,
    required this.peliculaTitulo, // ✅ Se pasa correctamente
    required this.fechaSeleccionada,
    required this.horaSeleccionada,
    required this.asientosSeleccionados,
  }) : super(key: key);

  @override
  _PantallaPagoState createState() => _PantallaPagoState();
}

class _PantallaPagoState extends State<PantallaPago> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController nombreTitularController = TextEditingController();
  final TextEditingController numeroTarjetaController = TextEditingController();
  final TextEditingController fechaExpiracionController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  Future<void> _procesarPago() async {
    final User? user = FirebaseAuth.instance.currentUser; // 🔹 Obtener el usuario autenticado
    if (nombreTitularController.text.isEmpty ||
        numeroTarjetaController.text.isEmpty ||
        fechaExpiracionController.text.isEmpty ||
        cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    print("💳 Procesando pago de: \$${widget.totalPago}");
    print("🎬 Película: ${widget.peliculaTitulo}");
    print("🔹 Asientos: ${widget.asientosSeleccionados}");

    try {
      // 🔹 Guardar el pago en Firestore
      DocumentReference pagoRef = await _firestore.collection("pagos").add({
        "total": widget.totalPago,
        "peliculaId": widget.peliculaId,
        "peliculaTitulo": widget.peliculaTitulo, // ✅ Agregado para claridad
        "fecha_funcion": widget.fechaSeleccionada,
        "hora_funcion": widget.horaSeleccionada,
        "asientos": widget.asientosSeleccionados,
        "titular": nombreTitularController.text,
        "numero_tarjeta": numeroTarjetaController.text,
        "fecha_expiracion": fechaExpiracionController.text,
        "cvv": cvvController.text,
        "estado": "APROBADO",
        "timestamp": FieldValue.serverTimestamp(),
      });

      print("✅ Pago registrado con ID: ${pagoRef.id}");

      // 🔹 Actualizar los asientos en Firestore
      for (String asiento in widget.asientosSeleccionados) {
        DocumentReference asientoRef = _firestore
            .collection("peliculas")
            .doc(widget.peliculaId)
            .collection("fechas_disponibles")
            .doc(widget.fechaSeleccionada)
            .collection("horarios")
            .doc(widget.horaSeleccionada)
            .collection("asientos")
            .doc(asiento);

        // 🔹 Verificar si el asiento existe antes de actualizarlo
        DocumentSnapshot asientoSnapshot = await asientoRef.get();
        if (asientoSnapshot.exists) {
          await asientoRef.update({"estado": "ocupado"});
          print("🔄 Asiento $asiento actualizado como ocupado");
        } else {
          print("⚠️ Advertencia: El asiento $asiento no existe en Firestore");
        }
      }

      // 🔹 Redirigir a la pantalla de pago exitoso
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PagoExitosoScreen(
            total: widget.totalPago,
            peliculatitulo:widget.peliculaTitulo,
            fechapelicula:widget.fechaSeleccionada,
            horapelicula:widget.horaSeleccionada,
            asientos:widget.asientosSeleccionados,
            comprador: user?.displayName ?? user?.email ?? "Usuario Anónimo",

          ),

        ),
      );

    } catch (error) {
      print("❌ Error al procesar el pago: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al procesar el pago")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pago de boletos")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total a pagar: \$${widget.totalPago.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Película: ${widget.peliculaTitulo}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Asientos seleccionados: ${widget.asientosSeleccionados.join(', ')}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            TextField(
              controller: nombreTitularController,
              decoration: InputDecoration(labelText: "Nombre del titular"),
            ),
            TextField(
              controller: numeroTarjetaController,
              decoration: InputDecoration(labelText: "Número de tarjeta"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: fechaExpiracionController,
              decoration: InputDecoration(labelText: "Fecha de expiración (MM/YY)"),
            ),
            TextField(
              controller: cvvController,
              decoration: InputDecoration(labelText: "CVV"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _procesarPago,
              child: Text("Pagar"),
            ),
          ],
        ),
      ),
    );
  }
}

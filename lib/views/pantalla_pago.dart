import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'pago_exito.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaPago extends StatefulWidget {
  final double totalPago;
  final String peliculaId;
  final String peliculaTitulo;
  final String fechaSeleccionada;
  final String horaSeleccionada;
  final List<String> asientosSeleccionados;

  const PantallaPago({
    Key? key,
    required this.totalPago,
    required this.peliculaId,
    required this.peliculaTitulo,
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

  bool _isProcessing = false; // 🔹 Variable para manejar la carga

  Future<void> _procesarPago() async {
    if (_isProcessing) return; // Evita múltiples clics
    setState(() => _isProcessing = true); // 🔹 Activa la animación de carga

    final User? user = FirebaseAuth.instance.currentUser;

    if (nombreTitularController.text.isEmpty ||
        numeroTarjetaController.text.isEmpty ||
        fechaExpiracionController.text.isEmpty ||
        cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      setState(() => _isProcessing = false); // 🔹 Desactiva la animación si hay error
      return;
    }

    try {
      DocumentReference pagoRef = await _firestore.collection("pagos").add({
        "total": widget.totalPago,
        "peliculaId": widget.peliculaId,
        "peliculaTitulo": widget.peliculaTitulo,
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

        DocumentSnapshot asientoSnapshot = await asientoRef.get();
        if (asientoSnapshot.exists) {
          await asientoRef.update({"estado": "ocupado"});
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PagoExitosoScreen(
            total: widget.totalPago,
            peliculatitulo: widget.peliculaTitulo,
            fechapelicula: widget.fechaSeleccionada,
            horapelicula: widget.horaSeleccionada,
            asientos: widget.asientosSeleccionados,
            comprador: user?.displayName ?? user?.email ?? "Usuario Anónimo",
          ),
        ),
      );
    } catch (error) {
      print("❌ Error al procesar el pago: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al procesar el pago")),
      );
    } finally {
      setState(() => _isProcessing = false); // 🔹 Desactiva la animación
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

            // Campo Nombre Titular
            TextField(
              controller: nombreTitularController,
              decoration: InputDecoration(labelText: "Nombre del titular"),
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
              ],
            ),

            // Campo Número de Tarjeta
            TextField(
              controller: numeroTarjetaController,
              decoration: InputDecoration(labelText: "Número de tarjeta"),
              keyboardType: TextInputType.number,
              maxLength: 19,
              onChanged: (value) {
                value = value.replaceAll(RegExp(r'\s'), '');
                if (value.length > 16) value = value.substring(0, 16);
                String formatted = '';
                for (int i = 0; i < value.length; i++) {
                  if (i % 4 == 0 && i != 0) formatted += ' ';
                  formatted += value[i];
                }
                numeroTarjetaController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              },
            ),

            // Campo Fecha de Expiración (MM/YY)
            TextField(
              controller: fechaExpiracionController,
              decoration: InputDecoration(labelText: "Fecha de expiración (MM/YY)"),
              keyboardType: TextInputType.number,
              maxLength: 5,
              onChanged: (value) {
                value = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (value.length > 4) value = value.substring(0, 4);
                if (value.length >= 2 && !value.contains('/')) {
                  value = value.substring(0, 2) + '/' + value.substring(2);
                }
                fechaExpiracionController.value = TextEditingValue(
                  text: value,
                  selection: TextSelection.collapsed(offset: value.length),
                );
              },
            ),

            // Campo CVV
            TextField(
              controller: cvvController,
              decoration: InputDecoration(labelText: "CVV"),
              keyboardType: TextInputType.number,
              maxLength: 3,
              obscureText: true,
            ),

            SizedBox(height: 20),

            // Botón de pago con animación de carga
            ElevatedButton(
              onPressed: _isProcessing ? null : _procesarPago, // 🔹 Deshabilita el botón mientras carga
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: _isProcessing
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text("Pagar"),
            ),
          ],
        ),
      ),
    );
  }
}

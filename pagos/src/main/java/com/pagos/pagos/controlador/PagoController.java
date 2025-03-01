package com.pagos.pagos.controlador;

import com.pagos.pagos.model.Pago;
import com.pagos.pagos.service.PagoService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pagos")
@CrossOrigin("*") // Permite llamadas desde Flutter
public class PagoController {
    private final PagoService pagoService;

    public PagoController(PagoService pagoService) {
        this.pagoService = pagoService;
    }

    // 🔹 Endpoint para registrar un pago
    @PostMapping
    public Pago realizarPago(@RequestBody Pago pago) {
        return pagoService.procesarPago(pago);
    }

    // 🔹 Endpoint para obtener todos los pagos
    @GetMapping
    public List<Pago> obtenerTodosLosPagos() {
        return pagoService.obtenerTodosLosPagos();
    }

    // 🔹 Endpoint para obtener un pago por ID
    @GetMapping("/{id}")
    public Pago obtenerPagoPorId(@PathVariable Long id) {
        return pagoService.obtenerPagoPorId(id);
    }
}

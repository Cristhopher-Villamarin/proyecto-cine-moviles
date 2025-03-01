package com.pagos.pagos.service;

import com.pagos.pagos.model.Pago;
import com.pagos.pagos.repository.PagoRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Random;

@Service
public class PagoService {
    private final PagoRepository pagoRepository;

    public PagoService(PagoRepository pagoRepository) {
        this.pagoRepository = pagoRepository;
    }

    public Pago procesarPago(Pago pago) {
        pago.setFechaPago(LocalDateTime.now());
        pago.setEstado("PENDIENTE");

        // 🔹 Validar tarjeta (simulado)
        if (!validarTarjeta(pago)) {
            pago.setEstado("RECHAZADO");
            return pagoRepository.save(pago);
        }

        // 🔹 Simular autorización del banco
        boolean aprobado = new Random().nextBoolean();
        pago.setEstado(aprobado ? "APROBADO" : "RECHAZADO");

        return pagoRepository.save(pago);
    }

    private boolean validarTarjeta(Pago pago) {
        // Validar que el número de tarjeta tenga 16 dígitos
        if (!pago.getNumeroTarjeta().matches("\\d{16}")) return false;

        // Validar que la fecha de expiración sea válida (MM/YY)
        if (!pago.getFechaExpiracion().matches("(0[1-9]|1[0-2])/\\d{2}")) return false;

        // Validar que el CVV tenga 3 o 4 dígitos
        return pago.getCvv().matches("\\d{3,4}");
    }


public List<Pago> obtenerTodosLosPagos() {
    return pagoRepository.findAll();
}

public Pago obtenerPagoPorId(Long id) {
    return pagoRepository.findById(id).orElseThrow(() -> new RuntimeException("Pago no encontrado"));
}

}


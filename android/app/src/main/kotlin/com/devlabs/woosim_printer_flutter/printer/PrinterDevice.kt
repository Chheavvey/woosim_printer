package com.devlabs.woosim_printer_flutter.printer

data class PrinterDevice(
    val name: String,
    val address: String
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "name" to name,
            "address" to address
        )
    }
}
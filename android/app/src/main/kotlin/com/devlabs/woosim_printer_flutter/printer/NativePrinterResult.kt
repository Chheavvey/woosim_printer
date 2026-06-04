package com.devlabs.woosim_printer_flutter.printer

data class NativePrinterResult(
    val success: Boolean,
    val error: String? = null,
    val message: String? = null
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "success" to success,
            "error" to error,
            "message" to message
        )
    }
}
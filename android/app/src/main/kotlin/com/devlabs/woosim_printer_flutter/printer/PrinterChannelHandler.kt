package com.devlabs.woosim_printer_flutter.printer

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PrinterChannelHandler(
    context: Context
) : MethodChannel.MethodCallHandler {

    private val printerManager = BluetoothPrinterManager(context)
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isBluetoothEnabled" -> {
                result.success(printerManager.isBluetoothEnabled())
            }

            "isConnected" -> {
                result.success(printerManager.isConnected())
            }

            "getBondedPrinters" -> {
                runAsync(result) {
                    printerManager.getBondedPrinters().map { it.toMap() }
                }
            }

            "connect" -> {
                runAsync(result) {
                    val name = call.argument<String>("name") ?: "Unknown Printer"
                    val address = call.argument<String>("address").orEmpty()

                    if (address.isBlank()) {
                        NativePrinterResult(
                            success = false,
                            error = "Printer address is empty"
                        ).toMap()
                    } else {
                        printerManager.connect(
                            PrinterDevice(
                                name = name,
                                address = address
                            )
                        ).toMap()
                    }
                }
            }

            "disconnect" -> {
                runAsync(result) {
                    printerManager.disconnect()
                    NativePrinterResult(
                        success = true,
                        message = "Disconnected"
                    ).toMap()
                }
            }

            "printTestReceipt" -> {
                runAsync(result) {
                    printerManager.printTestReceipt().toMap()
                }
            }

            "printImage" -> {
                runAsync(result) {
                    val imagePath = call.argument<String>("imagePath").orEmpty()
                    val paperWidth = call.argument<Int>("paperWidth") ?: 576

                    printerManager.printImage(
                        imagePath = imagePath,
                        paperWidth = paperWidth
                    ).toMap()
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun runAsync(
        result: MethodChannel.Result,
        block: () -> Any?
    ) {
        Thread {
            try {
                val value = block()

                mainHandler.post {
                    result.success(value)
                }
            } catch (e: Exception) {
                mainHandler.post {
                    result.success(
                        NativePrinterResult(
                            success = false,
                            error = e.message ?: "Native printer error"
                        ).toMap()
                    )
                }
            }
        }.start()
    }
}
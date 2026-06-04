import 'package:flutter/services.dart';

import '../models/printer_device.dart';
import '../models/printer_operation_result.dart';

class WoosimPrinterService {
  static const MethodChannel _channel = MethodChannel('woosim_printer');

  Future<bool> isBluetoothEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isBluetoothEnabled');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('isConnected');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<List<PrinterDevice>> getBondedPrinters() async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getBondedPrinters',
    );

    return (result ?? [])
        .map((item) => PrinterDevice.fromMap(Map<dynamic, dynamic>.from(item)))
        .toList();
  }

  Future<PrinterOperationResult> connect(PrinterDevice device) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'connect',
        {
          'name': device.name,
          'address': device.address,
        },
      );

      return PrinterOperationResult.fromMap(result);
    } catch (e) {
      return PrinterOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<PrinterOperationResult> disconnect() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'disconnect',
      );

      return PrinterOperationResult.fromMap(result);
    } catch (e) {
      return PrinterOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<PrinterOperationResult> printTestReceipt() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'printTestReceipt',
      );

      return PrinterOperationResult.fromMap(result);
    } catch (e) {
      return PrinterOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<PrinterOperationResult> printImage({
    required String imagePath,
    int paperWidth = 576,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'printImage',
        {
          'imagePath': imagePath,
          'paperWidth': paperWidth, // 80mm only
        },
      );

      return PrinterOperationResult.fromMap(result);
    } catch (e) {
      return PrinterOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }
}

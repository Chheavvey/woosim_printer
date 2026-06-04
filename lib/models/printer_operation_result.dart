class PrinterOperationResult {
  const PrinterOperationResult({
    required this.success,
    this.error,
    this.message,
  });

  final bool success;
  final String? error;
  final String? message;

  factory PrinterOperationResult.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const PrinterOperationResult(
        success: false,
        error: 'Empty native response',
      );
    }

    return PrinterOperationResult(
      success: map['success'] == true,
      error: map['error']?.toString(),
      message: map['message']?.toString(),
    );
  }
}

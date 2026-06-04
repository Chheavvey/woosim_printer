import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestPrinterPermissions() async {
    if (!Platform.isAndroid) return true;

    final permissions = <Permission>[
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
      Permission.photos,
      Permission.storage,
    ];

    final statuses = await permissions.request();

    // Some permissions are ignored depending on Android version. The printer can
    // continue if at least one relevant runtime permission is granted/limited.
    return statuses.values.any((status) => status.isGranted || status.isLimited);
  }
}

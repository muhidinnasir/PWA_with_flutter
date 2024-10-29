// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions(BuildContext context) async {
  var status = await Permission.storage.status;
  if (status.isDenied) {
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
    if (await Permission.storage.request().isGranted) {
      // Permissions are granted, proceed with the operation
    } else {
      // Permissions are denied, show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Storage permission is required to download files.'),
      ));
    }
  } else if (status.isPermanentlyDenied) {
    // Permissions are permanently denied, handle appropriately
    openAppSettings();
  }
}

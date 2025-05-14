import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

final logger = Logger();

Future<void> requestNotificationPermission() async {
  // Check if notification permission is granted
  PermissionStatus status = await Permission.notification.status;
  
  if (status.isGranted) {
    // Permission is already granted
    logger.i("Notification permission granted");
  } else if (status.isDenied) {
    // If permission is denied, request it
    PermissionStatus newStatus = await Permission.notification.request();
    if (newStatus.isGranted) {
      logger.i("Notification permission granted after request");
    } else {
      logger.w("Notification permission denied");
      // You can show a dialog explaining why the permission is necessary.
    }
  } else if (status.isPermanentlyDenied) {
    // If permission is permanently denied, show a message explaining why they need to grant permission.
    logger.w("Notification permission permanently denied, opening settings...");
    openAppSettings(); // This will open the settings app to let the user change their permission
  }
}

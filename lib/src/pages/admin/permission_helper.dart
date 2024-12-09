import 'package:permission_handler/permission_handler.dart';

Future<void> requestSMSPermission() async {
  PermissionStatus status = await Permission.sms.status;
  if (!status.isGranted) {
    status = await Permission.sms.request();
  }

  if (status.isGranted) {
    print('Permiso de SMS concedido.');
  } else {
    print('Permiso de SMS denegado.');
  }
}

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestMic() async {
    final s = await Permission.microphone.request();
    return s.isGranted;
  }

  Future<bool> requestCamera() async {
    final s = await Permission.camera.request();
    return s.isGranted;
  }
}

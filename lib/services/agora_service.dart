import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static const String appId = 'YOUR_AGORA_APP_ID'; // Replace with your Agora App ID
  RtcEngine? _engine;
  List<int> remoteUids = [];
  bool isJoined = false;

  Future<void> initAgora(String channelName, Function(int, int) onUserJoined) async {
    await [Permission.camera, Permission.microphone].request();
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: appId));
    await _engine!.enableVideo();
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          isJoined = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          onUserJoined(remoteUid, elapsed);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          remoteUids.remove(remoteUid);
        },
      ),
    );
    await _engine!.joinChannel(
      token: '', // Use Agora token for production
      channelId: channelName,
      uid: 0,
      options: ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
      isJoined = false;
      remoteUids.clear();
    }
  }

  RtcEngine? get engine => _engine;
  List<int> get uids => remoteUids;
}
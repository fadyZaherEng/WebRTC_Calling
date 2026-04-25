import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Foreground message received: ${message.data}');
      if (message.data['type'] == 'CALL') {
        showIncomingCall(message.data);
      }
    });
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    log('Background message received: ${message.data}');
    if (message.data['type'] == 'CALL') {
      showIncomingCall(message.data);
    }
  }

  static Future<void> showIncomingCall(Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    final params = CallKitParams(
      id: uuid,
      nameCaller: data['callerName'] ?? 'Unknown',
      appName: 'Vocalis',
      avatar: data['callerAvatar'],
      handle: '0123456789',
      type: 0, // 0: Audio, 1: Video
      duration: 30000,
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0F172A',
        actionColor: '#6366F1',
      ),
      ios: const IOSParams(
        iconName: 'AppIcon',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);

    FlutterCallkitIncoming.onEvent.listen((event) {
      switch (event!.event) {
        case Event.actionCallAccept:
          log('Call Accepted');
          // Handle navigation to call screen
          break;
        case Event.actionCallDecline:
          log('Call Declined');
          break;
        default:
          break;
      }
    });
  }
}

import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/call_model.dart';
import '../../core/constants.dart';

class SignalingService {
  io.Socket? _socket;
  final Function(CallModel call) onIncomingCall;
  final Function(Map<String, dynamic> data) onOfferReceived;
  final Function(Map<String, dynamic> data) onAnswerReceived;
  final Function(Map<String, dynamic> data) onIceCandidateReceived;
  final Function() onCallEnded;

  SignalingService({
    required this.onIncomingCall,
    required this.onOfferReceived,
    required this.onAnswerReceived,
    required this.onIceCandidateReceived,
    required this.onCallEnded,
  });

  void connect(String userId) {
    _socket = io.io(AppConstants.signalingServerUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'userId': userId},
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      log('Connected to signaling server');
    });

    _socket!.on('incoming-call', (data) {
      final call = CallModel.fromJson(data);
      onIncomingCall(call);
    });

    _socket!.on('offer', (data) => onOfferReceived(data));
    _socket!.on('answer', (data) => onAnswerReceived(data));
    _socket!.on('ice-candidate', (data) => onIceCandidateReceived(data));
    _socket!.on('call-ended', (_) => onCallEnded());

    _socket!.onDisconnect((_) => log('Disconnected from signaling server'));
  }

  void sendOffer(String receiverId, Map<String, dynamic> offer) {
    _socket!.emit('offer', {'receiverId': receiverId, 'offer': offer});
  }

  void sendAnswer(String callerId, Map<String, dynamic> answer) {
    _socket!.emit('answer', {'callerId': callerId, 'answer': answer});
  }

  void sendIceCandidate(String peerId, Map<String, dynamic> candidate) {
    _socket!.emit('ice-candidate', {'peerId': peerId, 'candidate': candidate});
  }

  void startCall(CallModel call) {
    _socket!.emit('start-call', call.toJson());
  }

  void endCall(String peerId) {
    _socket!.emit('end-call', {'peerId': peerId});
  }

  void dispose() {
    _socket?.dispose();
  }
}

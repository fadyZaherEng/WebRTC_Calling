import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/call_model.dart';
import '../../data/services/signaling_service.dart';
import '../../data/services/webrtc_service.dart';
import 'call_state.dart';

class CallCubit extends Cubit<CallState> {
  late SignalingService _signalingService;
  late WebRTCService _webRTCService;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? _currentUserId;

  CallCubit() : super(CallInitial()) {
    _initRenderers();
    _initServices();
  }

  String? get currentUserId => _currentUserId;

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _initServices() {
    _signalingService = SignalingService(
      onIncomingCall: _onIncomingCall,
      onOfferReceived: _onOfferReceived,
      onAnswerReceived: _onAnswerReceived,
      onIceCandidateReceived: _onIceCandidateReceived,
      onCallEnded: _onCallEnded,
    );

    _webRTCService = WebRTCService(
      onLocalStream: (stream) => _localRenderer.srcObject = stream,
      onRemoteStream: (stream) => _remoteRenderer.srcObject = stream,
      onIceCandidate: (candidate) {
        if (state is CallActive) {
          final call = (state as CallActive).call;
          final peerId = call.callerId == _currentUserId ? call.receiverId : call.callerId;
          _signalingService.sendIceCandidate(peerId, candidate.toMap());
        }
      },
    );
  }

  void connect(String userId) {
    _currentUserId = userId;
    _signalingService.connect(userId);
  }

  // Actions
  Future<void> startCall(String receiverId, String receiverName, CallType type) async {
    final call = CallModel(
      id: const Uuid().v4(),
      callerId: _currentUserId ?? 'unknown',
      callerName: _currentUserId ?? 'User',
      receiverId: receiverId,
      receiverName: receiverName,
      type: type,
      timestamp: DateTime.now(),
      status: CallStatus.ringing,
    );

    emit(CallRinging(call));
    _signalingService.startCall(call);

    await _webRTCService.initialize(isVideo: type == CallType.video);
    final offer = await _webRTCService.createOffer();
    _signalingService.sendOffer(receiverId, offer.toMap());
    
    emit(CallActive(
      call: call,
      localRenderer: _localRenderer,
      remoteRenderer: _remoteRenderer,
    ));
  }

  RTCSessionDescription? _pendingOffer;

  // Signaling Handlers
  void _onIncomingCall(CallModel call) {
    emit(CallRinging(call));
  }

  Future<void> _onOfferReceived(Map<String, dynamic> data) async {
    _pendingOffer = RTCSessionDescription(data['sdp'], data['type']);
  }

  final List<RTCIceCandidate> _iceCandidateQueue = [];

  Future<void> acceptCall() async {
    if (state is CallRinging && _pendingOffer != null) {
      final call = (state as CallRinging).call;
      await _webRTCService.initialize(isVideo: call.type == CallType.video);
      
      final answer = await _webRTCService.createAnswer(_pendingOffer!);
      _signalingService.sendAnswer(call.callerId, answer.toMap());
      _pendingOffer = null;

      // Process queued candidates
      for (var candidate in _iceCandidateQueue) {
        await _webRTCService.addIceCandidate(candidate);
      }
      _iceCandidateQueue.clear();

      emit(CallActive(
        call: call.copyWith(status: CallStatus.connected),
        localRenderer: _localRenderer,
        remoteRenderer: _remoteRenderer,
      ));
    }
  }

  Future<void> _onIceCandidateReceived(Map<String, dynamic> data) async {
    final candidate = RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
    if (state is CallActive) {
      await _webRTCService.addIceCandidate(candidate);
    } else {
      _iceCandidateQueue.add(candidate);
    }
  }

  Future<void> _onAnswerReceived(Map<String, dynamic> data) async {
    if (state is CallActive) {
      final answer = RTCSessionDescription(data['sdp'], data['type']);
      await _webRTCService.setRemoteDescription(answer);
    }
  }

  void endCall() {
    if (state is CallActive) {
      final call = (state as CallActive).call;
      final peerId = call.callerId == _currentUserId ? call.receiverId : call.callerId;
      _signalingService.endCall(peerId);
    }
    _cleanup();
    emit(const CallEnded('Call Finished'));
  }

  void toggleMute() {
    if (state is CallActive) {
      final activeState = state as CallActive;
      _webRTCService.toggleMute(!activeState.isMuted);
      emit(activeState.copyWith(isMuted: !activeState.isMuted));
    }
  }

  void toggleVideo() {
    if (state is CallActive) {
      final activeState = state as CallActive;
      _webRTCService.toggleVideo(!activeState.isVideoOff);
      emit(activeState.copyWith(isVideoOff: !activeState.isVideoOff));
    }
  }

  void _onCallEnded() {
    _cleanup();
    emit(const CallEnded('Remote user ended the call'));
  }

  void _cleanup() {
    _webRTCService.dispose();
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
  }

  @override
  Future<void> close() {
    _cleanup();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _signalingService.dispose();
    return super.close();
  }
}

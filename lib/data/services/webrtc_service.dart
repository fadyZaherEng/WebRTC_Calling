import 'dart:developer';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../core/constants.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  
  final Function(MediaStream stream) onLocalStream;
  final Function(MediaStream stream) onRemoteStream;
  final Function(RTCIceCandidate candidate) onIceCandidate;

  WebRTCService({
    required this.onLocalStream,
    required this.onRemoteStream,
    required this.onIceCandidate,
  });

  Future<void> initialize({bool isVideo = true}) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': isVideo ? {'facingMode': 'user'} : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    onLocalStream(_localStream!);

    _peerConnection = await createPeerConnection(AppConstants.iceServers);

    _peerConnection!.onIceCandidate = (candidate) {
      onIceCandidate(candidate);
    };

    _peerConnection!.onAddStream = (stream) {
      onRemoteStream(stream);
    };

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });
  }

  Future<RTCSessionDescription> createOffer() async {
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer(RTCSessionDescription offer) async {
    await _peerConnection!.setRemoteDescription(offer);
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await _peerConnection!.setRemoteDescription(description);
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection!.addCandidate(candidate);
  }

  void switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  void toggleMute(bool isMuted) {
    if (_localStream != null) {
      _localStream!.getAudioTracks()[0].enabled = !isMuted;
    }
  }

  void toggleVideo(bool isVideoOff) {
    if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
      _localStream!.getVideoTracks()[0].enabled = !isVideoOff;
    }
  }

  void dispose() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _peerConnection?.dispose();
  }
}

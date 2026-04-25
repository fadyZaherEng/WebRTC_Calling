import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../data/models/call_model.dart';

abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object?> get props => [];
}

class CallInitial extends CallState {}

class CallRinging extends CallState {
  final CallModel call;
  const CallRinging(this.call);

  @override
  List<Object?> get props => [call];
}

class CallActive extends CallState {
  final CallModel call;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final bool isMuted;
  final bool isVideoOff;

  const CallActive({
    required this.call,
    required this.localRenderer,
    required this.remoteRenderer,
    this.isMuted = false,
    this.isVideoOff = false,
  });

  CallActive copyWith({
    bool? isMuted,
    bool? isVideoOff,
  }) {
    return CallActive(
      call: call,
      localRenderer: localRenderer,
      remoteRenderer: remoteRenderer,
      isMuted: isMuted ?? this.isMuted,
      isVideoOff: isVideoOff ?? this.isVideoOff,
    );
  }

  @override
  List<Object?> get props => [call, localRenderer, remoteRenderer, isMuted, isVideoOff];
}

class CallEnded extends CallState {
  final String reason;
  const CallEnded(this.reason);

  @override
  List<Object?> get props => [reason];
}

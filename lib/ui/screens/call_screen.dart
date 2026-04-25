import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../logic/call_cubit/call_cubit.dart';
import '../../logic/call_cubit/call_state.dart';
import '../widgets/call_controls_widget.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallCubit, CallState>(
      listener: (context, state) {
        if (state is CallEnded) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        if (state is! CallActive) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final call = state.call;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Remote Video
              Positioned.fill(
                child: RTCVideoView(
                  state.remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),

              // Local Video (PiP)
              Positioned(
                top: 50,
                right: 20,
                width: 120,
                height: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: RTCVideoView(
                    state.localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),

              // Call Info
              Positioned(
                top: 60,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.callerId == 'me' ? call.receiverName : call.callerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                    const Text(
                      'Connected',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CallControlsWidget(
                  isMuted: state.isMuted,
                  isVideoOff: state.isVideoOff,
                  onMuteToggle: () => context.read<CallCubit>().toggleMute(),
                  onVideoToggle: () => context.read<CallCubit>().toggleVideo(),
                  onHangup: () => context.read<CallCubit>().endCall(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

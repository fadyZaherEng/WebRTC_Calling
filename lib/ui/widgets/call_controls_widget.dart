import 'package:flutter/material.dart';

class CallControlsWidget extends StatelessWidget {
  final bool isMuted;
  final bool isVideoOff;
  final VoidCallback onMuteToggle;
  final VoidCallback onVideoToggle;
  final VoidCallback onHangup;
  final bool isAudioOnly;

  const CallControlsWidget({
    super.key,
    required this.isMuted,
    required this.isVideoOff,
    required this.onMuteToggle,
    required this.onVideoToggle,
    required this.onHangup,
    this.isAudioOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlBtn(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            color: isMuted ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
            onPressed: onMuteToggle,
          ),
          FloatingActionButton(
            onPressed: onHangup,
            backgroundColor: Colors.redAccent,
            elevation: 0,
            child: const Icon(Icons.call_end, size: 28, color: Colors.white),
          ),
          if (!isAudioOnly)
            _ControlBtn(
              icon: isVideoOff ? Icons.videocam_off : Icons.videocam,
              color: isVideoOff ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
              onPressed: onVideoToggle,
            ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ControlBtn({required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/call_model.dart';
import '../../logic/call_cubit/call_cubit.dart';
import '../../logic/call_cubit/call_state.dart';
import 'call_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _targetIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocalis Call'),
        centerTitle: true,
      ),
      body: BlocListener<CallCubit, CallState>(
        listener: (context, state) {
          if (state is CallActive) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CallScreen()),
            );
          } else if (state is CallRinging) {
             _showIncomingCallDialog(context, (state as CallRinging).call);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.video_chat_rounded, size: 80, color: Color(0xFF6366F1)),
              const SizedBox(height: 32),
              TextField(
                controller: _targetIdController,
                decoration: InputDecoration(
                  labelText: 'Target User ID',
                  hintText: 'Enter ID to call',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _initiateCall(context, CallType.audio),
                      icon: const Icon(Icons.call),
                      label: const Text('Audio Call'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _initiateCall(context, CallType.video),
                      icon: const Icon(Icons.videocam),
                      label: const Text('Video Call'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initiateCall(BuildContext context, CallType type) {
    final targetId = _targetIdController.text.trim();
    if (targetId.isNotEmpty) {
      context.read<CallCubit>().startCall(targetId, 'User $targetId', type);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a target ID')),
      );
    }
  }

  void _showIncomingCallDialog(BuildContext context, CallModel call) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Incoming Call'),
        content: Text('${call.callerName} is calling you...'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<CallCubit>().endCall();
              Navigator.pop(context);
            },
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
          FilledButton(
            onPressed: () {
              context.read<CallCubit>().acceptCall();
              Navigator.pop(context);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}

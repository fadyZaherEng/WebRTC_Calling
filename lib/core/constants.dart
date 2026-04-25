class AppConstants {
  static const String signalingServerUrl =
      'https://thick-terms-hammer.loca.lt'; // Replace with your actual signaling server URL
  static const Map<String, dynamic> iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      // Add TURN servers here for production
    ]
  };
}

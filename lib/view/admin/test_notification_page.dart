import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:avm_global_web/services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';

class TestNotificationPage extends StatefulWidget {
  const TestNotificationPage({super.key});

  @override
  State<TestNotificationPage> createState() => _TestNotificationPageState();
}

class _TestNotificationPageState extends State<TestNotificationPage> {
  final Color themeColor = const Color(0xFF146EB8);
  final Color darkBlue = const Color(0xFF0A192F);

  String? _fcmToken;
  bool _isLoading = false;
  String _statusMessage = 'Click "Get Browser Token" to begin test.';
  int _countdown = 0;
  Timer? _countdownTimer;

  static const String testFunctionUrl =
      'https://us-central1-avmglobal-consultants-113.cloudfunctions.net/sendTestPushNotification';

  @override
  void initState() {
    super.initState();
    _checkInitialToken();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _checkInitialToken() {
    final cached = NotificationService.instance.cachedToken;
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _fcmToken = cached;
        _statusMessage = 'Active browser token found.';
      });
    }
  }

  Future<void> _fetchToken() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting browser notification permission & token...';
    });

    try {
      final token = await NotificationService.instance.getDeviceToken();
      setState(() {
        _fcmToken = token;
        _isLoading = false;
        if (token != null && token.isNotEmpty) {
          _statusMessage = 'Token successfully retrieved! You are ready to send a test push.';
        } else {
          _statusMessage = 'Unable to generate token. Please check browser notifications permissions (tap the lock icon in address bar to allow).';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error getting token: $e';
      });
    }
  }

  Future<void> _sendTestNotification({int delaySeconds = 0}) async {
    if (_fcmToken == null || _fcmToken!.isEmpty) {
      setState(() {
        _statusMessage = 'Please fetch the token first before sending test notification.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      if (delaySeconds > 0) {
        _countdown = delaySeconds;
        _statusMessage = 'Dispatched with $delaySeconds-second delay! Lock your phone or switch apps now!';
      } else {
        _statusMessage = 'Sending push notification to device...';
      }
    });

    if (delaySeconds > 0) {
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countdown > 1) {
          setState(() {
            _countdown--;
          });
        } else {
          timer.cancel();
          setState(() {
            _countdown = 0;
            _statusMessage = 'Test notification triggered on server!';
          });
        }
      });
    }

    try {
      final response = await http.post(
        Uri.parse(testFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': _fcmToken,
          'title': 'Job Alert Test | AVM Global',
          'body': 'This is a test notification! Tap to view live openings.',
          'url': 'https://avmglobalconsultants.com/jobs',
          'delaySeconds': delaySeconds,
        }),
      );

      setState(() {
        _isLoading = false;
        if (response.statusCode == 200) {
          _statusMessage =
              'Success! Push dispatched by Cloud Functions.\nResponse: ${response.body}';
        } else {
          _statusMessage =
              'Server returned status ${response.statusCode}:\n${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error calling test function: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Push Notification Test Center',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.notifications_active_outlined, color: themeColor, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step-by-Step Notification Test',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                          Text(
                            'Verify FCM background delivery & click-to-open',
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 36),

                // Step 1: Token status & fetch
                Text(
                  'Step 1: Obtain Browser Token',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: darkBlue),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _fcmToken != null ? Colors.green.withOpacity(0.08) : Colors.amber.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _fcmToken != null ? Colors.green.withOpacity(0.3) : Colors.amber.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _fcmToken != null ? Icons.check_circle : Icons.warning_amber_rounded,
                        color: _fcmToken != null ? Colors.green[700] : Colors.amber[800],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _fcmToken != null
                              ? 'Token: ${_fcmToken!.substring(0, 20)}...${_fcmToken!.substring(_fcmToken!.length - 10)}'
                              : 'No token registered yet',
                          style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_fcmToken != null)
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: 'Copy Token',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _fcmToken!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Token copied to clipboard')),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _fetchToken,
                  icon: const Icon(Icons.vpn_key_outlined, size: 18),
                  label: const Text('1. Request Permission & Get Token'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                const Divider(height: 36),

                // Step 2 & 3: Send Test Push
                Text(
                  'Step 2: Trigger Notification',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: darkBlue),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recommendation: Use the 5-second delayed test, then lock your phone screen or switch to home screen to test background notification popup.',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: (_isLoading || _fcmToken == null)
                            ? null
                            : () => _sendTestNotification(delaySeconds: 0),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Send Instant Push'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: themeColor,
                          side: BorderSide(color: themeColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (_isLoading || _fcmToken == null)
                            ? null
                            : () => _sendTestNotification(delaySeconds: 5),
                        icon: const Icon(Icons.timer_outlined, size: 18),
                        label: Text(_countdown > 0 ? 'Wait ($_countdown s)...' : 'Send (5s Delay)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 36),

                // Status Box
                Text(
                  'Execution Log / Result:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: darkBlue),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A192F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusMessage,
                    style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.greenAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.connection});

  final InternetConnection connection;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  InternetStatus? _status;
  InternetStatus? _previousStatus;
  Timer? _onlineTimer;

  @override
  void initState() {
    super.initState();
    _initConnectionStatus();

    widget.connection.onStatusChange.listen((status) {
      if (!mounted) return;

      _onlineTimer?.cancel();

      // Show "Online" only if previous status was disconnected
      bool showOnlineBanner =
          _previousStatus == InternetStatus.disconnected &&
          status == InternetStatus.connected;

      setState(() {
        _previousStatus = _status;
        _status = status;
      });

      // When back online, hide after 1 second
      if (showOnlineBanner) {
        _onlineTimer = Timer(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() {
            _onlineTimer = null;
          });
        });
      }
    });
  }

  Future<void> _initConnectionStatus() async {
    final status = await widget.connection.internetStatus;
    if (!mounted) return;

    setState(() {
      _status = status;
      _previousStatus = status;
    });
  }

  @override
  void dispose() {
    _onlineTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showBanner =
        _status == InternetStatus.disconnected || _onlineTimer != null;

    final text = _status == InternetStatus.disconnected
        ? 'Offline mode'
        : 'Online';
    final color = _status == InternetStatus.disconnected
        ? Colors.red
        : Colors.green;
    final icon = _status == InternetStatus.disconnected
        ? Icons.wifi_off
        : Icons.wifi;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: showBanner ? color : Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      curve: Curves.easeInOut,
      child: showBanner && _status != null
          ? SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

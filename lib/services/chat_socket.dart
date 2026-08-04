import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import '../config/app_config.dart';

/// Thin transport wrapper over a single realtime chat WebSocket connection.
///
/// Responsibilities are deliberately narrow: open the socket (authenticated via
/// the `?token=` query param the backend accepts), expose a decoded broadcast
/// stream of `{type, data}` event maps, and send outbound JSON. Reconnection,
/// auth-token sourcing and business logic live in [ChatProvider] — this class
/// stays dumb so it can be torn down and recreated on each (re)connect.
class ChatSocket {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  /// Decoded server events. Each backend frame may batch several messages
  /// separated by `\n` (see the hub's WritePump) — every line is decoded and
  /// emitted separately here.
  Stream<Map<String, dynamic>> get events => _controller.stream;

  bool _closed = false;
  bool get isConnected => _channel != null && !_closed;

  /// Opens the connection using [token] as the `?token=` query param.
  /// [onDone] fires when the socket closes or errors, so the owner can schedule
  /// a reconnect.
  void connect(String token, {required void Function() onDone}) {
    _closed = false;
    final uri = Uri.parse('${AppConfig.wsUrl}?token=$token');

    try {
      _channel = IOWebSocketChannel.connect(uri);
    } catch (e) {
      debugPrint('[ChatSocket] connect failed: $e');
      onDone();
      return;
    }

    _sub = _channel!.stream.listen(
      _onFrame,
      onDone: () {
        debugPrint('[ChatSocket] closed (code=${_channel?.closeCode})');
        if (!_closed) onDone();
      },
      onError: (Object e) {
        debugPrint('[ChatSocket] error: $e');
        if (!_closed) onDone();
      },
      cancelOnError: true,
    );
  }

  void _onFrame(dynamic frame) {
    if (frame is! String || frame.isEmpty) return;
    // A single frame can contain multiple newline-joined JSON messages.
    for (final line in frame.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          _controller.add(decoded);
        }
      } catch (e) {
        debugPrint('[ChatSocket] bad frame line: $e');
      }
    }
  }

  /// Sends an outbound event (e.g. a typing indicator). No-op when disconnected.
  void send(Map<String, dynamic> event) {
    final channel = _channel;
    if (channel == null || _closed) return;
    try {
      channel.sink.add(jsonEncode(event));
    } catch (e) {
      debugPrint('[ChatSocket] send failed: $e');
    }
  }

  /// Closes this connection. The instance is single-use afterwards.
  Future<void> close() async {
    _closed = true;
    await _sub?.cancel();
    _sub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    if (!_controller.isClosed) await _controller.close();
  }
}

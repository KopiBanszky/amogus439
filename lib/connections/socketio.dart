import 'package:socket_io_client/socket_io_client.dart';

import 'http.dart';

Future<Socket> connectToWebsocket() {
  Socket socket = io(
      "$PROTOCOL://$DOMAIN",
      OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
          .build());
  socket.onConnect((_) {
    // ignore: avoid_print
    print('connect, ${socket.id}');
    socket.emit('msg', 'test');
  });

  return Future.value(socket);
}

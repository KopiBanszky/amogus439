import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'http.dart';

Future<IO.Socket> connectToWebsocket(){
  IO.Socket socket = IO.io("$PROTOCOL://$DOMAIN:80");
  socket.onConnect((_) {
    print('connect, ${socket.id}');
    socket.emit('msg', 'test');
  });

  return Future.value(socket);
}

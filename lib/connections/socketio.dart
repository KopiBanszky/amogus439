
import 'package:socket_io_client/socket_io_client.dart';

import 'http.dart';

Future<Socket> connectToWebsocket(){
  print("asd");
  Socket socket = io("$PROTOCOL://$DOMAIN",
      OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .build());
  socket.onConnect((_) {
    print('connect, ${socket.id}');
    socket.emit('msg', 'test');
  });

  return Future.value(socket);
}

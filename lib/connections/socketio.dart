import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'http.dart';

IO.Socket socket = IO.io("$PROTOCOL://$DOMAIN");
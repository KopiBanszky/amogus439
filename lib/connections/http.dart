import 'dart:convert';
import 'package:http/http.dart' as http;

class RquestResult{
  bool ok;
  var data;
  RquestResult(this.data, this.ok);
}

const PROTOCOL = "http";
const PROTOCOLL_METHOD = Uri.http;
const DOMAIN = /*laptop "192.168.173.19"; PC:*/ "192.168.1.69";

Future<RquestResult> http_get(String route, [dynamic data]) async{

  //var dataStr = jsonEncode(data);//.replaceAll(":", "=").replaceAll(",", "&").replaceAll("{", "").replaceAll("}", "");
  Uri url = PROTOCOLL_METHOD(DOMAIN, route, data);
  var result = await http.get(url);
  return RquestResult(jsonEncode(result.body), true);
}
Future<RquestResult> http_post(String route, [dynamic data]) async{

  Uri url = PROTOCOLL_METHOD(DOMAIN, route);
  var dataStr = jsonEncode(data);
  var result = await http.post(url, body: dataStr, headers: {"Content-type": "application/json"});
  return RquestResult(result.body, true);
}
Future<RquestResult> http_put(String route, [dynamic data]) async{

  Uri url = PROTOCOLL_METHOD(DOMAIN, route);
  var dataStr = jsonEncode(data);
  var result = await http.put(url, body: dataStr, headers: {"Content-type": "application/json"});
  return RquestResult(result.body, true);
}
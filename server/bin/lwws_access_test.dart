/**
 * Sample to access a web service server (no credentials)
 * Gets Tokyo area weather forecast from LWWS as jsonObject
 */

import 'dart:io';
import 'dart:convert';

const host = "weather.livedoor.com/forecast/webservice/json/v1";
const cityCode = 130010; // Tokyo

main() {
  HttpClient client = new HttpClient();
  var bodyStr = '';
  client.getUrl(Uri.parse("http://${host}?city=${cityCode}"))
      .then((HttpClientRequest request) {
        return request.close();
      })
      .then((HttpClientResponse response) {
        // Process the response.
        response.transform(UTF8.decoder).listen((bodyChunk) {
          bodyStr = bodyStr + bodyChunk;
        }, onDone: (){
          // handle data
          print('***headers***\n${response.headers}');
          var jsonObj = JSON.decode(bodyStr);
          print('***bodyString***\n$bodyStr');
          print('***jsonObject***\n$jsonObj');
          print('**forecasts***\n${jsonObj["forecasts"]}');
          print('***description***\n${jsonObj["description"]}');
        });
      });
}
/*
  Dart code sample: simple application for Livedoor Weather Web Service (LWWS)
  This is a client side code that will be supplied by the server.
  Therefore, do not start this client from your Dart Editor.
  Call the server as http://127.0.0.1:8080/weather from your browser (except for IE).
  October 2014, by Terry
*/

import 'dart:html';
import 'dart:convert' show JSON;
import 'dart:async';

final LOG_REQUESTS = true;
const host = "127.0.0.1:8080/weather/lwws";
String cityCode = '130010';

void main() {
  window.onLoad.listen((ev){
    loadData().then((str){dartDom(str);});
    SelectElement smenu = document.getElementById("selectMenu");
    smenu.onChange.listen((ev){
      cityCode = smenu.value;
      loadData().then((str){dartDom(str);});
    });
  });
}

Future loadData() {
  log("Loading data");
  var url = "http://${host}?city=$cityCode";
  // call the web server asynchronously
  var completer = new Completer();
  var request = HttpRequest.getString(url, withCredentials: false)
    .then((responseText) {
      logFlesh('JSON data loaded : $responseText');
      completer.complete(responseText);
    })
    .catchError((error) {
      log('requested data is not available : $error');
    });
  return completer.future;
}

/**
create a dynamic HTML page
*/
dartDom(jsonStr) {
  try{

  var jsonObj = JSON.decode(jsonStr);
//  log('jsonObj = ' + jsonObj.toString());

  // title
  document.getElementById('forcastTitle').innerHtml = '<br>${jsonObj["title"]}';

  // each day display area
  List forecasts = jsonObj["forecasts"];
  var forecast;

  // images
  var cells = document.getElementById('imageCells');
  while (cells.childNodes.length != 0) cells.deleteCell(0);
  forecasts.forEach((forecast) {
    Element tdElement = new Element.tag('td');
    var img = document.createElement("IMG");
    Uri uri = Uri.parse(forecast['image']['url']);
    img.src="/weather/lwws?image=${uri.pathSegments.last}";
    tdElement.children = [img];
    document.getElementById('imageCells').append(tdElement);
  });

  // descriptions
  cells = document.getElementById('eachDayCells');
  while (cells.childNodes.length != 0) cells.deleteCell(0);
  forecasts.forEach((forecast) {
    Element tdElement = new Element.tag('td');
    tdElement.appendText(forecast["dateLabel"]);
    tdElement.appendText('\n' + forecast['telop']);
    Map temp = forecast['temperature']['max'];
    if (temp == null) tdElement.appendText('\n最高温度 ： ---');
    else  tdElement.appendText('\n最高温度 ： ${temp["celsius"]}°C');
    temp = forecast['temperature']['min'];
    if (temp == null) tdElement.appendText('\n最低温度 ： ---');
    else  tdElement.appendText('\n最低温度 ： ${temp["celsius"]}°C');
    document.getElementById('eachDayCells').append(tdElement);
  });
  document.getElementById('tableBottom').innerHtml
         = '予報発表時刻 ： ${format1(jsonObj["publicTime"])}';

  // description
  String text = jsonObj['description']['text'];
  text = text.replaceAll('\n\n', '\n');
  text = text.replaceAll('【', '\n【');
  document.getElementById('descriptionArea').innerHtml = '\n' + text;
  String bottomText = '概況発表時刻 ： ' + format1(jsonObj["description"]["publicTime"])
      + '\n\n${jsonObj["copyright"]["title"]}';
  document.getElementById('descriptionBottom').innerHtml = bottomText;

  }catch (err, st){
    print('$err \n $st');
  }
}

String format1(String str){
  str=str.substring(0, str.length-8);
  return str.replaceAll('T',' ');
}

void log(message) {
  if(LOG_REQUESTS) {
    print(message);
    querySelector("#log").innerHtml = querySelector("#log").innerHtml + "\n$message";
  }
}

void logFlesh(message) {
  if(LOG_REQUESTS) {
    print(message);
    querySelector("#log").innerHtml = "Log Messages:\n$message";
  }
}

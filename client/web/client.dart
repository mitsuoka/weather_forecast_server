/*
  Dart code sample: simple application for Livedoor Weather Web Service (LWWS)
  This is a client side code that will be supplied by the server.
  Call the server as http://127.0.0.1:8080/weather from your browser.
  October 2014, by Terry
  April 2019, made Dart 2 compliant
*/

import 'dart:html';
import 'dart:convert';
import 'dart:async';

final LOG_REQUESTS = true;
const host = "127.0.0.1:8080/weather/lwws";
String cityCode = '130010';

void main() {
  window.onLoad.listen((ev) {
    loadData().then((str) {
      dartDom(str);
    });
    SelectElement smenu = document.getElementById("selectMenu");
    smenu.onChange.listen((ev) {
      cityCode = smenu.value;
      loadData().then((str) {
        dartDom(str);
      });
    });
  });
}

Future loadData() {
  log("Loading data");
  var url = "http://${host}?city=$cityCode";
  // call the web server asynchronously
  var completer = new Completer<String>();
  HttpRequest.getString(url, withCredentials: false).then((responseText) {
    logFlesh('JSON data received : \n$responseText');
    completer.complete(responseText);
  }).catchError((error) {
    log('requested data is not available : $error');
  });
  return completer.future;
}

/**
    create a dynamic HTML page
 */
dartDom(jsonStr) {
  try {
    var jsonObj = jsonDecode(jsonStr);
    log('jsonObj = \n$jsonObj');

    // title
    document.getElementById('forcastTitle').innerHtml =
        '<br>${jsonObj["title"]}';

    // each day display area
    List forecasts = jsonObj["forecasts"];

    // images
    TableRowElement td0Cells = document.getElementById('imageCells');
    td0Cells.cells.forEach((cell) {
      cell.innerHtml = "";
    });
    var column = 0;
    forecasts.forEach((forecast) {
      Uri uri = Uri.parse(forecast['image']['url']);
      var img = new ImageElement();
      img.src = "/weather/lwws?image=${uri.pathSegments.last}";
      td0Cells.cells[column].append(img);
      column = column + 1;
    });

    // descriptions
    TableRowElement td1Cells = document.getElementById('eachDayCells');
    td1Cells.cells.forEach((cell) {
      cell.innerHtml = "";
    });
    column = 0;
    forecasts.forEach((forecast) {
      String txt = '${forecast["dateLabel"]}' + '\n' + '${forecast["telop"]}';

      Map temp = forecast['temperature']['max'];
      if (temp == null)
        txt = txt + '\n最高温度 ： ---';
      else
        txt = txt + '\n最高温度 ： ${temp["celsius"]}°C';
      temp = forecast['temperature']['min'];
      if (temp == null)
        txt = txt + '\n最低温度 ： ---';
      else
        txt = txt + '\n最低温度 ： ${temp["celsius"]}°C';
      td1Cells.cells[column].innerHtml = txt;
      column = column + 1;
    });
    if (column == 2) td1Cells.cells[column].innerHtml = '明後日\n(未発表)';

    document.getElementById('tableBottom').innerHtml =
        '予報発表時刻 ： ${format1(jsonObj["publicTime"])}';

    // description
    String text = jsonObj['description']['text'];
    text = text.replaceAll('\n\n', '\n');
    text = text.replaceAll('【', '\n【');
    document.getElementById('descriptionArea').innerHtml = '\n' + text;
    String bottomText = '概況発表時刻 ： ' +
        format1(jsonObj["description"]["publicTime"]) +
        '\n\n${jsonObj["copyright"]["title"]}';
    document.getElementById('descriptionBottom').innerHtml = bottomText;
  } catch (err, st) {
    print('$err \n $st');
  }
}

String format1(String str) {
  str = str.substring(0, str.length - 8);
  return str.replaceAll('T', ' ');
}

void log(message) {
  if (LOG_REQUESTS) {
    print(message);
    querySelector("#log").innerHtml =
        querySelector("#log").innerHtml + "\n$message";
  }
}

void logFlesh(message) {
  if (LOG_REQUESTS) {
    print(message);
    querySelector("#log").innerHtml = "Log Messages:\n$message";
  }
}

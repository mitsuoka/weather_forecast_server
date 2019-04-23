/*
  Dart code sample: simple application for Livedoor Weather Web Service (LWWS)
  1. Download and uncompress this repository.
  2. open the uncompressed directory from your IDE.
  3. from client/pubspec.yaml, build a build directory using build command.
  4. Run the server/bin/server.dart .
  5. Access the server from Chrome using http://localhost:8080/weather

  The server supplies necessary files to the client according to
  the browser's requests:
  * build/client.html
  * build/client.css
  * build/client.dart.js
  * server/resources/favicon.ico
  * server/resources/(stored gif files)
  This server serves as a Proxy for the LWWS server also. Necessary data will be
  provided to the client:
  * JSON weather forecast data for the requested city code
  * not saved image files for the forecast

  October 2014, by Terry
  April 2019, made Dart 2 compliant
*/

import 'dart:io';
import 'package:mime_type/mime_type.dart' as mime;
import 'dart:async';
import 'dart:convert';

final HOST = InternetAddress.loopbackIPv4;
final PORT = 8080;
final REQUEST_PATH = '/weather';
final LOG_REQUESTS = true;

final fileHandler = new FileHandler();
final lwwsProxy = new LwwsProxy();
final badRequestHandler = new BadRequestHandler();
final notFoundHandler = new NotFoundHandler();

final lwwsJson = 'weather.livedoor.com/forecast/webservice/json/v1';
final lwwsGif = 'weather.livedoor.com/img/icon/';

void main() {
  HttpServer.bind(HOST, PORT).then((HttpServer server) {
    server.listen((HttpRequest request) {
      request.response.done.then((d) {
        if (LOG_REQUESTS)
          log('sent response to the client for request : ' +
              '${request.uri} with status = ${request.response.statusCode}');
      }).catchError((e) {
        log("Error occured while sending response: $e");
      });
      if (LOG_REQUESTS)
        log('received a request from the client : ' +
            'method = ${request.method}, uri = ${request.uri}');
      if (request.uri.path.contains(REQUEST_PATH) && request.method == 'GET') {
        requestReceivedHandler(request);
      } else if (request.uri.toString().contains('favicon.ico')) {
        fileHandler.onRequest2(request, 'favicon.ico');
      } else {
        new BadRequestHandler().onRequest(request);
      }
    });
    log('Serving $REQUEST_PATH on http://${HOST}:${PORT}.');
  });
}

void requestReceivedHandler(HttpRequest request) {
  final HttpResponse response = request.response;
  try {
    //need LWWS access?
    if (request.uri.path.contains('lwws')) {
      if (request.uri.queryParameters['city'] != null) {
        lwwsProxy
            .getJsonFile(request.uri.queryParameters['city'], request)
            .then((bytes) {
          lwwsProxy.returnJson(request, bytes);
        });
      } else if (request.uri.queryParameters['image'] != null) {
        String imageFile = request.uri.queryParameters['image'];
        if (fileHandler.isExist(imageFile)) {
          fileHandler.onRequest2(request, imageFile);
        } else {
          lwwsProxy.getImageFile(imageFile, request).then((bytes) {
            if (bytes != null) {
              fileHandler.saveFile(imageFile, bytes).then((_) {
                fileHandler.onRequest2(request, imageFile);
              });
            } else
              badRequestHandler.onRequest(request);
          });
        }
      } else {
        badRequestHandler.onRequest(request);
      }
    }
    // request for client side files
    else {
      String clientFile = request.uri.path.replaceFirst('${REQUEST_PATH}', '');
      if (LOG_REQUESTS) log('requested client side file : $clientFile');
      if (clientFile == '') {
        fileHandler.onRequest1(request, 'client.html'); // default file
      } else {
        fileHandler.onRequest1(request, clientFile.substring(1));
      }
    }
  } catch (err, st) {
    log('requestReceivedHandler error : ${err.toString()}\n${st}');
  }
}

/**
 * LWWS ploxy
 * get json data from the Lwws
 * get image file from the Lwws
 * return json data to the client
 */
class LwwsProxy {
  Future<List<int>> getJsonFile(String cityCode, HttpRequest request) async {
    return await _getBytes(
        Uri.parse('http://${lwwsJson}?city=${cityCode}'), request);
  }

  Future<List<int>> getImageFile(String imageFile, HttpRequest request) async {
    return await _getBytes(Uri.parse('http://${lwwsGif}' + imageFile), request);
  }

  Future<List<int>> _getBytes(Uri uri, HttpRequest request) {
    List<int> bodyBytes = [];
    var completer = Completer<List<int>>();
    try {
      HttpClient client = new HttpClient();
      client.getUrl(uri).then((req) {
        if (LOG_REQUESTS) log('LWWS interface : sent request for $uri');
        req.close().then((res) {
          // Process the response.
          res.listen((bodyChunk) {
            bodyBytes.addAll(bodyChunk);
          }, onDone: () {
            // handle data
            if (res.statusCode == HttpStatus.ok) {
              if (LOG_REQUESTS)
                log('LWWS interface : received response : $uri with status = ${res.statusCode}');
              completer.complete(bodyBytes);
            } else
              notFoundHandler.onRequest(request); // not a status OK (200)
          });
        });
      });
    } catch (err, st) {
      log('LWWS Handler getLwws error : ${err.toString()}\n${st}');
    }
    return completer.future;
  }

  returnJson(HttpRequest req, List<int> bytes) async {
    if (bytes == null) {
      notFoundHandler.onRequest(req);
    } else {
      var res = req.response;
      addCorsHeaders(res);
      res.headers.contentType =
          new ContentType('application', 'json', charset: 'utf-8');
      res.add(bytes);
      res.flush().then((_) {
        res.close();
      });
    }
  }
}

/**
 * File handler
 * return requested file in the ..../client/web folder to the client
 * return requested file in the ../resouces folder to the client
 * save specified file into the ../resouces folder
 * check if exist the specified data in the ../resouces folder
 * list files in the specified directory
 */
class FileHandler {
  File file;
  String fname;

  // return specified file (like 'client.css') in the ../client directory to the client
  onRequest1(HttpRequest request, String fileName) {
    fname = '../client/build/' + fileName;
    _onRequest(request);
  }

  // return specified file (like '1.gif') in the ../resources directory to the client
  onRequest2(HttpRequest request, String fileName) {
    fname = 'resources/' + fileName;
    _onRequest(request);
  }

  _onRequest(HttpRequest request) {
    try {
      final HttpResponse response = request.response;
      if (LOG_REQUESTS) log('file handler : requested file : $fname');
      file = new File(fname);
      String mimeType;
      if (file.existsSync()) {
        mimeType = mime.mime(fname);
        if (mimeType == null) mimeType = 'text/plain; charset=UTF-8'; // default
        response.headers.set('Content-Type', mimeType);
        addCorsHeaders(response);
        RandomAccessFile openedFile = file.openSync();
        response.contentLength = openedFile.lengthSync();
        openedFile.closeSync();
        // Pipe the file content into the response.
        file.openRead().pipe(response).then((_) {
          request.response.close();
        });
      } else {
        if (LOG_REQUESTS) log('File not found : $fname');
        notFoundHandler.onRequest(request);
      }
    } catch (err, st) {
      log('File Handler send error ${err}\n${st}');
    }
  }

  Future<File> saveFile(String fname, List<int> bytes) {
    try {
      var completer = new Completer<File>();
      var file = new File('resources/' + fname);
      file.create().then((file) {
        file.writeAsBytes(bytes).then((_) {
          completer.complete(file);
        });
      });
      if (LOG_REQUESTS) log('file handler : saved file : $fname');
      return completer.future;
    } catch (err, st) {
      log('File Handler save error :  ${err}\n${st}');
    }
  }

  bool isExist(String fname) {
    var file = new File('resources/' + fname);
    return file.existsSync();
  }

  List<String> fileList(String pathName) {
    List<String> fileNames = [];
    final directory = new Directory(pathName);
    final List<FileSystemEntity> fileList = directory.listSync(recursive: true);
    fileList.forEach((file) {
      if (file is File) {
        fileNames.add(file.path.replaceAll(r'\', '/'));
      }
    });
    fileNames.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return fileNames;
  }
}

class BadRequestHandler {
  String badRequestPage;
  static final String badRequestPageHtml = '''
<html><head>
<title>400 Bad Request</title>
</head><body>
<h1>Bad Request</h1>
<p>The request could not be understood by the server due to malformed syntax.</p>
</body></html>''';

  void onRequest(HttpRequest request, [String badRequestPage = null]) {
    if (badRequestPage == null) {
      badRequestPage = badRequestPageHtml;
    }
    var response = request.response;
    addCorsHeaders(response);
    response
      ..statusCode = HttpStatus.badRequest
      ..headers.set('Content-Type', 'text/html; charset=UTF-8')
      ..write(badRequestPage)
      ..close();
  }
}

class NotFoundHandler {
  String notFoundPage;

  static final String notFoundPageHtml = '''
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL or File was not found on this server.</p>
</body></html>''';

  void onRequest(HttpRequest request, [String notFoundPage = null]) {
    if (notFoundPage == null) {
      notFoundPage = notFoundPageHtml;
    }
    var response = request.response;
    addCorsHeaders(response);
    response
      ..statusCode = HttpStatus.notFound
      ..headers.set('Content-Type', 'text/html; charset=UTF-8')
      ..write(notFoundPage)
      ..close();
  }
}

/**
 * Add Cross-site headers to enable accessing this server from pages
 * not served by this server
 *
 * See: http://www.html5rocks.com/en/tutorials/cors/
 * and http://enable-cors.org/server.html
 */
void addCorsHeaders(HttpResponse res) {
  res.headers.add("Access-Control-Allow-Origin", "*");
  res.headers.add("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
  res.headers.add("Access-Control-Allow-Headers",
      "Origin, X-Requested-With, Content-Type, Accept");
}

/**
 * Log messages
 */
void log(String mes) {
  print('${new DateTime.now().toString().substring(11)}: ' + mes);
}

// create log message for the request
StringBuffer createLogMessage(HttpRequest request, [String bodyString]) {
  var sb = new StringBuffer('''request.headers.host : ${request.headers.host}
request.headers.port : ${request.headers.port}
request.connectionInfo.localPort : ${request.connectionInfo.localPort}
request.connectionInfo.remoteAddress : ${request.connectionInfo.remoteAddress}
request.connectionInfo.remotePort : ${request.connectionInfo.remotePort}
request.method : ${request.method}
request.persistentConnection : ${request.persistentConnection}
request.protocolVersion : ${request.protocolVersion}
request.contentLength : ${request.contentLength}
request.uri : ${request.uri}
request.uri.path : ${request.uri.path}
request.uri.query : ${request.uri.query}
request.uri.queryParameters :
''');
  request.uri.queryParameters.forEach((key, value) {
    sb.write("  ${key} : ${value}\n");
  });
  sb.write('''request.cookies :
''');
  request.cookies.forEach((value) {
    sb.write("  ${value.toString()}\n");
  });
  sb.write('''request.headers.expires : ${request.headers.expires}
request.headers :
  ''');
  var str = request.headers.toString();
  for (int i = 0; i < str.length - 1; i++) {
    if (str[i] == "\n") {
      sb.write("\n  ");
    } else {
      sb.write(str[i]);
    }
  }
  sb.write('''\nrequest.session.id : ${request.session.id}
requset.session.isNew : ${request.session.isNew}
''');
  if (request.method == 'POST') {
    var enctype = request.headers['content-type'];
    if (enctype[0].contains('text')) {
      sb.write("request body string : ${bodyString.replaceAll('+', ' ')}");
    } else if (enctype[0].contains("urlencoded")) {
      sb.write(
          'request body string (URL decoded): ${Uri.decodeQueryComponent(bodyString)}');
    }
  }
  sb.write('\n');
  return sb;
}

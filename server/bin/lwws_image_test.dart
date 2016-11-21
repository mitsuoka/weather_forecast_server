/**
 * Sample to access a web service server (no credentials)
 * Get an image file and save in the ../resources directory
 */

import 'dart:io';
import 'dart:async';

const host = 'weather.livedoor.com/img/icon/';
var fileName = '2.gif';


main() {
  HttpClient client = new HttpClient();
  List<int> bodyBytes = [];
  client.getUrl(Uri.parse("http://${host}${fileName}"))
      .then((HttpClientRequest request) {
        return request.close();
      })
      .then((HttpClientResponse response) {
        // Process the response.
        response.listen((bodyChunk) {
          bodyBytes.addAll(bodyChunk);
        }, onDone: (){
          // handle data
          print('*** received an image file ***');
          print('status code : ${response.statusCode}');
          print('headers :\n${response.headers}');
          print('length : ${bodyBytes.length}');
          if (response.statusCode == HttpStatus.OK) {
            saveFile(fileName, bodyBytes).then((f){
            print('file saved : ${f.toString()}');
            });
          }
        });
      });
}

/**
main(){
  List<int> bytes = [1,2,3,4,5,6,7,8,9,10];
  String fname = '1.gif';
  saveFile(fname, bytes).then((file){
    print('saved');
  });
}
*/

// save file into the file system
// returns Future<file>
Future<File> saveFile(String fname, List<int> bytes) {
  var completer = new Completer();
  var file = new File('../resources/' + fname);
  file.create().then((file){
    file.writeAsBytes(bytes).then((_){
      completer.complete(file);
      });
    });
  return completer.future;
}
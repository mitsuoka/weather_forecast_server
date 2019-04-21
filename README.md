weather\_forecast\_server
==

**weather\_forecast\_server** is a **Dart 2** compliant sample REST server application utilizing Japanese Livedoor Weather Web Service (LWWS). This is a code sample and an attachment
to the ["Dart Language Gide"](http://www.cresc.co.jp/tech/java/Google_Dart/DartLanguageGuide.pdf) written in Japanese.

このリポジトリは[「プログラミング言語 Dartの基礎」](http://www.cresc.co.jp/tech/java/Google_Dart/DartLanguageGuide_about.html)の添付資料であり、「RESTfulウェブ・サービスとDart (Dart in RESTful web services)」の「 簡単なクライアントとサーバ」の節で解説されています。この節ではサービスへの登録や専用のAPIが不要なウェブ・サービスを使った簡単なアプリケーションのクライアントとサーバのコード例を示しています。使用するウェブ・サービスはLivedoorのお天気Webサービス（Livedoor Weather Web Service / LWWS）で、現在全国142カ所の今日、明日、および明後日の天気予報、予想気温、および都道府県の天気概況情報を提供しています。


### Installing ###

1. Download this repository, uncompress and rename the folder to "weather_forecast".
2. From your IDE, File > Open Existing Folder and select this weather_forecast folder.
3. Using client/pubspec.yaml, build a build directory using **build** command.


### Try it ###

1. Run the server/bin/server.dart.
2. From Chrome browser, call the server as **http://127.0.0.1:8080/weather**.
3. Select another city from the select menu.

***Note***: 
  The server supplies necessary files to the client according to
  the browser's requests:
  * build/client.html
  * build/client.css
  * build/client.dart.js
  * server/resources/favicon.ico
  * server/resources/(stored .gif image files)  
  This server serves as a Proxy for the LWWS server also. Necessary data will be
  provided to the client through this proxy:
  * JSON weather forecast data for the requested city code.
  * not saved .gif image files for the forecast.

### License ###
This sample is licensed under [MIT License](http://www.opensource.org/licenses/mit-license.php).
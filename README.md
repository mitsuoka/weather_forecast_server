weather\_forecast\_server
==

**weather\_forecast\_server** is a Dart sample REST server application utilizing Japanese Livedoor Weather Web Service (LWWS). This is a code
 sample and an attachment
to the ["Dart Language Gide"](http://www.cresc.co.jp/tech/java/Google_Dart/DartLanguageGuide.pdf) written in Japanese.

このリポジトリは[「プログラミング言語 Dartの基礎」](http://www.cresc.co.jp/tech/java/Google_Dart/DartLanguageGuide_about.html)の添付資料であり、「RESTfulウェブ・サービスとDart (Dart in RESTful web services)」の「 簡単なクライアントとサーバ」の節で解説されています。この節ではサービスへの登録や専用のAPIが不要なウェブ・サービスを使った簡単なアプリケーションのクライアントとサーバのコード例を示しています。使用するウェブ・サービスはLivedoorのお天気Webサービス（Livedoor Weather Web Service / LWWS）で、現在全国142カ所の今日、明日、および明後日の天気予報、予想気温、および都道府県の天気概況情報を提供しています。


### Installing ###

1. Download this repository, uncompress and rename the folder to "weather_forecast".
2. From Dart Editor, File > Open Existing Folder and select this weather_forecast folder.
3. Select Tools > Pub Install to install pub libraries.

### Try it ###

1. Run the server (server.dart) in the server\bin folder.
2. From any browser including Dartium (except for IE-9), call the server as **http://127.0.0.1:8080/weather**.
3. Select another city from the select menu.

Note: Do not start the client code (client.html) from Dart Editor. Client codes are supplied from the server.

### License ###
This sample is licensed under [MIT License][MIT].
[MIT]: http://www.opensource.org/licenses/mit-license.php
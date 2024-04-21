import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InfoPage extends StatefulWidget {
  final String? url;
  final bool localHtml;

  InfoPage(this.url, {this.localHtml = false});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  var title;

  StreamController<bool> loadingStream = StreamController<bool>.broadcast();

  final _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://flutter.dev'));
  final _navigationDelegate = NavigationDelegate();

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: title == null
                ? Image.asset(
                    'assets/img/ic_logo.png',
                    height: 45,
                  )
                : Text(title),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Builder(builder: (BuildContext context) {
                  return WebViewWidget(
                    controller: _controller,
                  );
                }),
                StreamBuilder<bool>(
                    stream: loadingStream.stream,
                    initialData: true,
                    builder: (BuildContext context,
                        AsyncSnapshot<bool> snapLoading) {
                      if (snapLoading.data == true) {
                        return Container(
                          child: Center(
                            child: Utils.loading(true),
                          ),
                        );
                      }
                      return Container();
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toasterJavascriptChannel(BuildContext context) {

  }

  void _loadHtmlFromAssets() async {
    var fileText = await rootBundle.loadString(widget.url!);
    await _controller.loadRequest(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString() as Uri);
  }
}

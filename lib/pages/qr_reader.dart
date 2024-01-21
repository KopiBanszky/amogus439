import 'dart:io';

import 'package:amogusvez2/utility/types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class SrReaderPage extends StatefulWidget {
  const SrReaderPage({super.key});

  @override
  State<SrReaderPage> createState() => _SrReaderPageState();
}

class _SrReaderPageState extends State<SrReaderPage> {
    dynamic arguments;
    late Color color;
    late Player plyr;


    final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
    Barcode? result;
    QRViewController? controller;

    // In order to get hot reload to work we need to pause the camera if the platform
    // is android, or resume the camera if the platform is iOS.
    @override
    void reassemble() {
      super.reassemble();
      if (Platform.isAndroid) {
        controller!.pauseCamera();
      } else if (Platform.isIOS) {
        controller!.resumeCamera();
      }
    }

    @override
    Widget build(BuildContext context) {
      arguments = ModalRoute.of(context)!.settings.arguments;
      plyr = arguments['player'];
      color = plyr.color;


      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Qr olvasó",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20
                  )
              ),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                    plyr.color,
                    BlendMode.modulate
                ),
                child: Image.asset("assets/${plyr.team ? "impostor.png" : "player.png"}",
                  width: MediaQuery.of(context).size.width * .1,

                ),
              )
            ],
          ),
          backgroundColor: Colors.grey[900],
        ),
        backgroundColor: Colors.grey[850],
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                overlay: QrScannerOverlayShape(
                  borderRadius: 10,
                  borderColor: Colors.red,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300,
                ) ,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            const Expanded(
              flex: 1,
              child: Center(
                child: Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 50,
                )),
              ),
          ],
        ),
      );
    }

    void _onQRViewCreated(QRViewController controller) {
      this.controller = controller;
      controller.scannedDataStream.listen((scanData) {
        setState(() {
          result = scanData;
        });
      });
    }

    @override
    void dispose() {
      controller?.dispose();
      super.dispose();
    }
}

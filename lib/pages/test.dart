import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 5,
              child: /*true
                ? */
                  Stack(
                children: [
                  MobileScanner(
                    controller: MobileScannerController(
                      autoStart: true,
                      detectionSpeed: DetectionSpeed.normal,
                      facing: CameraFacing.back,
                      torchEnabled: false,
                    ),
                    onDetect: (capture) {},
                    // scanWindow: Rect.fromCenter(
                    //     center: Offset.zero, width: 10.0, height: 10.0),
                  ),
                ],
              )
              // : QRView(
              //     key: qrKey,
              //     overlay: QrScannerOverlayShape(
              //       borderRadius: 10,
              //       borderColor: Colors.red,
              //       borderLength: 30,
              //       borderWidth: 10,
              //       cutOutSize: 300,
              //     ),
              //     onQRViewCreated: _onQRViewCreated,
              //   ),
              ),
          // const Expanded(
          //   flex: 1,
          //   child: Center(
          //       child: Icon(
          //     Icons.qr_code_scanner,
          //     color: Colors.white,
          //     size: 50,
          //   )),
          // ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

void showAlert(
    String title,
    String message,
    Color color,
    bool okBtn,
    Function okBtnFnc,
    String okBtnText,
    bool cancelBtn,
    Function cancelBtnFnc,
    String cancelBtnText,
    context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            actions: [
              if (okBtn)
                TextButton(
                  onPressed: () {
                    okBtnFnc();
                    Navigator.pop(context);
                  },
                  child: Text(
                    okBtnText,
                    style: TextStyle(color: color, fontSize: 20.0),
                  ),
                ),
              if (cancelBtn)
                TextButton(
                  onPressed: () {
                    cancelBtnFnc();
                    Navigator.pop(context);
                  },
                  child: Text(
                    cancelBtnText,
                    style: const TextStyle(color: Colors.blue, fontSize: 20.0),
                  ),
                ),
            ],
          ));
}

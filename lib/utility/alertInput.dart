import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputType { text, number, password }

dynamic showAlertInput(
    String title,
    String message,
    InputType type,
    String hint,
    Color color,
    bool okBtn,
    Function okBtnFnc,
    String okBtnText,
    bool cancelBtn,
    Function cancelBtnFnc,
    String cancelBtnText,
    context) {
  final TextEditingController _controller = TextEditingController();
  return showDialog(
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                TextField(
                  controller: _controller,
                  inputFormatters: <TextInputFormatter>[
                    if (type == InputType.number)
                      FilteringTextInputFormatter.digitsOnly,
                  ], // Only numbers can be entered
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            actions: [
              if (okBtn)
                TextButton(
                  onPressed: () {
                    okBtnFnc();
                    Navigator.pop(context, {
                      'input': _controller.text,
                    });
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

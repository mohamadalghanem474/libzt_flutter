import 'package:flutter/material.dart';

class InputDialog {
  static Future<String?> show(BuildContext context, {required String title, String? hint, String sendText = 'OK'}) async {
    return await showDialog<String>(
      context: context,
      builder: (context) {
        var textController = TextEditingController();
        return SimpleDialog(title: Text(title), children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  decoration: InputDecoration(hintText: hint),
                  autofocus: true,
                  onSubmitted: (val) => Navigator.of(context).pop(val),
                  controller: textController,
                ),
                const SizedBox(height: 16),
                SimpleDialogOption(
                  onPressed: () => Navigator.of(context).pop(textController.text),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(sendText),
                  ),
                )
              ],
            ),
          ),
        ]);
      },
    );
  }
}

class BoolDialog {
  static Future<bool?> show(BuildContext context, {required String title}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SimpleDialogOption(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('YES'),
                      ),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('NO'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionDialogAction {
  ActionDialogAction({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;
}

class ActionDialog {
  static Future<bool?> show(BuildContext context, {required String title, required List<ActionDialogAction> actions}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              ...actions.map((action) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).pop(true);
                    action.onPressed();
                  },
                  title: Text(action.text),
                );
              })
            ],
          ),
        ],
      ),
    );
  }
}

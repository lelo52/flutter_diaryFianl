import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  String filePath;
  AddPage({super.key, required this.filePath});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String filePath = '';

  List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filePath = widget.filePath;
  }

  Future<bool> fileSave() async {
    try {
      File file = File(filePath);
      List<dynamic> dataList = []; //기존파일데이터 읽어서 저장
      var data = {
        'title': controllers[0].text,
        'contents': controllers[1].text,
      };

      //기존파일이있는경우
      if (file.existsSync()) {
        var fileContents = await file.readAsString();
        dataList = jsonDecode(fileContents) as List<dynamic>;
      }
      //다시 값 바꾸기
      dataList.add(data);

      var jsonData = jsonEncode(dataList);
      var res = await file.writeAsString(jsonData);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(filePath),
        centerTitle: true,
      ),
      body: Form(
          child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextFormField(
              controller: controllers[0],
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text('title')),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: TextFormField(
                controller: controllers[1],
                maxLength: 50,
                maxLines: 5,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), label: Text('내용')),
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  var title = controllers[0].text;
                  var result = await fileSave(); //저장이 잘됨 True or false
                  print(title);
                  if (result == true) {
                    print(filePath);
                    Navigator.pop(context, 'ok');
                  } else {
                    print('실패');
                  }
                },
                child: const Text('저장')),
          ],
        ),
      )),
    );
  }
}

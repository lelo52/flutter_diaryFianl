import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_diary/add_page.dart';
import 'package:path_provider/path_provider.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Directory? directory;
  String filePath = '';
  dynamic myList = Text('준비');
  var dt1 = "";

  @override
  void initState() {
    super.initState();
    getPath().then((value) {
      showList();
    });
  }

  Future<void> getPath() async {
    directory = await getApplicationSupportDirectory();
    if (directory != null) {
      print(dt1);
      var fileName = '$dt1.json'; //날짜 할 경우 여기 바꿈
      filePath = '${directory!.path}/$fileName';
    }
  }

  Future<void> deleteFile() async {
    try {
      var file = File(filePath);
      var result =
          await file.delete(recursive: true).then((value) => print(value));
      showList();
    } catch (e) {
      print('delete error');
    }
  }

  deleteContents(int index) async {
    try {
      File file = File(filePath);

      var fileContents = await file.readAsString();
      List<dynamic> dataList = jsonDecode(fileContents) as List<dynamic>;

      dataList.removeAt(index);

      var jsonData = jsonEncode(dataList);
      await file.writeAsString(jsonData).then((value) {
        showList();
      });
    } catch (e) {
      print('delete error');
    }
  }

  Future<void> showList() async {
    try {
      var file = File(filePath);
      if (file.existsSync()) {
        setState(() {
          myList = FutureBuilder(
            future: file.readAsString(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var d = snapshot.data;
                var dataList = jsonDecode(d!) as List<dynamic>;
                if (dataList.isEmpty) {
                  return Text('텅텅');
                }
                return ListView.separated(
                  itemBuilder: (context, index) {
                    var data = dataList[index] as Map<String, dynamic>;
                    return ListTile(
                      title: Text('제목 : ${data['title']}'),
                      subtitle: Text('내용 : ${data['contents']}'),
                      trailing: IconButton(
                        onPressed: () {
                          deleteContents(index);
                        },
                        icon: Icon(Icons.delete),
                      ),
                      onTap: () {
                        // 파일 내용 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FileContentPage(
                              filePath: filePath,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: dataList.length,
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        });
      } else {
        setState(() {
          myList = Text('날짜를 선택하세요.\n또는 검색 버튼');
        });
      }
    } catch (e) {
      print('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 100,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(onPressed: showList, child: Text('조회')),
              ElevatedButton(
                onPressed: () async {
                  var dt = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                  );
                  if (dt != null) {
                    var date = dt.toString().split(' ')[0];
                    print(date);
                    setState(() {
                      dt1 = date.toString();
                    });
                    await getPath();
                    showList();
                  }
                },
                child: Icon(Icons.date_range_outlined),
              ),
              ElevatedButton(onPressed: deleteFile, child: Text('삭제')),
              IconButton(
                onPressed: () async {
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FileListPage(directory: directory!),
                      ));
                  if (result == 'ok') {
                    showList();
                  }
                },
                icon: Icon(Icons.folder_copy),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 0),
            child: Text(
              '${dt1} 파일',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: myList),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPage(filePath: filePath),
              ));
          if (result == 'ok') {
            showList();
          }
        },
        child: Icon(Icons.screen_search_desktop_outlined),
      ),
    );
  }
}

class FileListPage extends StatelessWidget {
  final Directory directory;

  FileListPage({required this.directory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('파일 목록'),
      ),
      body: FutureBuilder(
        future: directory.list().toList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var entities = snapshot.data as List<FileSystemEntity>;
            var files = entities.where((entity) => entity is File).toList();
            if (files.isEmpty) {
              return Center(child: Text('파일 없음'));
            }
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                var file = files[index] as File;
                return ListTile(
                  title: Text(file.path),
                  onTap: () {
                    // 해당 파일의 MainPage로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(child: Text('파일 목록 없음'));
          }
        },
      ),
    );
  }
}

class FileContentPage extends StatelessWidget {
  final String filePath;

  FileContentPage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('파일 내용'),
      ),
      body: FutureBuilder(
        future: File(filePath).readAsString(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var fileContents = snapshot.data.toString();
            // 파일 내용을 여기서 표시하거나 원하는 방식으로 처리
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fileContents),
                  ElevatedButton(
                    onPressed: () {
                      // MainPage로 돌아가기
                      Navigator.pop(context);
                    },
                    child: Text('뒤로 가기'),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('파일 내용 없음'));
          }
        },
      ),
    );
  }
}

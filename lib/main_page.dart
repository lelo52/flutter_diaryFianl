import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_diary/add_page.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({
    super.key,
  });
  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  late Directory? directory;
  String filePath = '';
  dynamic myList = Text('준비');
  var dt1 ="";
  @override
  void initState() {
    // TODO: implement initState
    //파일경로 = 찾기;
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

  Future<void> deleteFile() async{
   try {
    var file = File(filePath);
    var result= file.delete(recursive: true).then((value) => print(value));
    print(result.toString());
    showList();
   }catch(e) {
    print('delete error');
   }
  }

  deleteContents(int index) async{
    try{
      //파일 불러오기 -> 그것을 [{},{}] -> jsondecode 해서 List<map<dynamic>>으로 변환
      //List니까 배열 조작 원하는 인덱스 번지 삭제
      // LIst를 다시 encode 를 함 => 파일 쓰기 => showList() 

      File file = File(filePath);
        
      var fileContents = await file.readAsString();
      List<dynamic> dataList = jsonDecode(fileContents) as List<dynamic>;
      
      //다시 값 바꾸기
      dataList.removeAt(index);
  
      var jsonData = jsonEncode(dataList);
      await file.writeAsString(jsonData).then((value) {
        showList();
      });
    }catch(e) {
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
                var dataList = jsonDecode(d!) as List<dynamic>; //string -> map
                if(dataList.isEmpty) {
                  return Text('텅텅');
                }
                return ListView.separated(
                  itemBuilder: (context, index) {
                    var data = dataList[index] as Map<String, dynamic>;
                    return ListTile(
                      title: Text('제목 : ${data['title']}'),
                      subtitle: Text('내용 : ${data['contents']}'),
                      trailing: IconButton(onPressed: () {
                        deleteContents(index);
                      }, icon: Icon(Icons.delete),),
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
        // 날짜를 선택하지 않았을 경우
        setState(() {
          SizedBox(height: 50,);
          myList = Text('날짜를 선택하세요.\n 또는 검색 버튼');
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
              children:
              [
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
                      await getPath(); // 날짜를 선택한 후에 파일 경로 설정
                      showList();
                    }
                  },
                  child: Icon(Icons.date_range_outlined),
                ),
                ElevatedButton(onPressed:deleteFile, child: Text('삭제')),
                IconButton(onPressed: () {
                  
                }, icon: Icon(Icons.folder_copy)),
                
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(top: 8.0 ,bottom: 0),
            child: Text('${dt1} 파일',style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
            //결과 출력
          }
        },
        child: Icon(Icons.screen_search_desktop_outlined),
      ),
    );
  }
}


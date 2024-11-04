import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(MaterialApp(theme: style.theme, home: const MyApp()));
}

var likeFontWeight = const TextStyle(fontWeight: FontWeight.w600);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  List<dynamic> data = [];
  int morePage = 1;
  dynamic userImage;
  dynamic userContent;

  List<dynamic> storedData = [];
  ScrollController scroll = ScrollController();
  setScrollPositionZero() {
    setState(() {
      scroll.animateTo(0,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  saveData() async {
    var storage = await SharedPreferences.getInstance();
    storage.clear();

    for (int i = 0; i < data.length; i++) {
      var saveData = Map<String, dynamic>.from(data[i]);
      // File 객체인 경우 경로만 저장
      if (saveData['image'] is File) {
        saveData['image'] = saveData['image'].path;
        saveData['isLocalImage'] = true; // 로컬 이미지임을 표시
      } else {
        saveData['isLocalImage'] = false; // 서버 이미지임을 표시
      }
      await storage.setString('data$i', jsonEncode(saveData));
    }
    await storage.setInt('dataLength', data.length);
  }

  loadData() async {
    var storage = await SharedPreferences.getInstance();
    int? length = storage.getInt('dataLength');

    if (length != null && length > 0) {
      List<dynamic> loadedData = [];
      for (int i = 0; i < length; i++) {
        var item = storage.getString('data$i');
        if (item != null) {
          var decodedItem = jsonDecode(item);
          // 로컬 이미지인 경우 File 객체로 변환
          if (decodedItem['isLocalImage'] == true) {
            decodedItem['image'] = File(decodedItem['image']);
          }
          loadedData.add(decodedItem);
        }
      }
      setState(() {
        data = loadedData;
      });
    } else {
      await getData();
    }
  }

  addMyData() {
    String formattedDate = DateFormat('MMM d').format(DateTime.now());
    var mydata = {
      'id': data.length,
      'image': userImage, // File 객체
      'likes': 5,
      'date': formattedDate,
      'content': userContent ?? '',
      'liked': false,
      'user': 'John Kim'
    };
    setState(() {
      data.insert(0, mydata);
      saveData();
      setScrollPositionZero();
    });
  }

  getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    if (result.statusCode == 200) {
      var result2 = jsonDecode(result.body);
      setState(() {
        data = result2;
      });
      await saveData(); // 서버 데이터를 가져온 후 저장
    }
  }

  @override
  void initState() {
    super.initState();
    loadData(); // getData() 대신 loadData() 만 호출
  }

  setUserContent(a) {
    setState(() {
      userContent = a;
    });
  }

  getMoreData() async {
    http.Response result = await http.get(
        Uri.parse('https://codingapple1.github.io/app/more$morePage.json'));
    if (result.statusCode == 200) {
      dynamic result2 = jsonDecode(result.body);
      setState(() {
        if (data[data.length - 1]['id'] != result2['id']) {
          data.add(result2);
          morePage++;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram'),
        actions: [
          IconButton(
            onPressed: () async {
              ImagePicker picker = ImagePicker();
              XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              }

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Upload(
                            userImage: userImage,
                            setUserContent: setUserContent,
                            addMyData: addMyData,
                          )));
            },
            icon: const Icon(Icons.add_box_outlined),
            iconSize: 30,
          )
        ],
        shape:
            const Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      body: [
        Home(data: data, getMoreData: getMoreData, scroll: scroll),
        const Text('샵페이지')
      ][tab],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: tab,
        onTap: (i) {
          setState(() {
            tab = i;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: 'shop')
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, this.data, this.getMoreData, this.scroll});
  final dynamic data;
  final dynamic getMoreData;
  final scroll;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.scroll.addListener(() {
      if (widget.scroll.position.pixels ==
          widget.scroll.position.maxScrollExtent) {
        widget.getMoreData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
      return ListView.builder(
          itemCount: widget.data.length,
          controller: widget.scroll,
          itemBuilder: (c, i) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: TypeImage(
                            imageUri: widget.data[i]['image'],
                            imageHeight: 25,
                            imageWidth: 25,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        child: Text(widget.data[i]['user']),
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (c, a1, a2) => Profile(),
                                transitionsBuilder: (c, a1, a2, child) =>
                                    SlideTransition(
                                  position: Tween(
                                    begin: Offset(-1.0, 0.0),
                                    end: Offset(0.0, 0.0),
                                  ).animate(a1),
                                  child: child,
                                ),
                                // FadeTransition(
                                //   opacity: a1,
                                //   child: child,
                                // ),
                                // transitionDuration:
                                // Duration(milliseconds: 1500)
                              ));
                          // CupertinoPageRoute(
                          //     builder: (context) => Profile()));
                        },
                      )
                    ],
                  ),
                ),
                TypeImage(
                  imageUri: widget.data[i]['image'],
                ),
                Favorite(data: widget.data[i]),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 3, 10, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.data[i]['date']),
                      Text(widget.data[i]['content'])
                    ],
                  ),
                )
              ],
            );
          });
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

class Favorite extends StatefulWidget {
  const Favorite({super.key, this.data});
  final dynamic data;
  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: widget.data['liked']
              ? const Icon(
                  Icons.favorite,
                  color: Colors.redAccent,
                )
              : const Icon(Icons.favorite_border),
          onPressed: () {
            setState(() {
              if (widget.data['liked'] == false) {
                widget.data['liked'] = true;
                widget.data['likes'] += 1;
              } else {
                widget.data['liked'] = false;
                widget.data['likes'] -= 1;
              }
            });
          },
        ),
        Text(widget.data['likes'].toString())
      ],
    );
  }
}

class Upload extends StatelessWidget {
  Upload({
    super.key,
    this.userImage,
    this.addMyData,
    this.setUserContent,
  });
  final userImage;
  final setUserContent;
  final addMyData;

  TextEditingController text = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);

                addMyData();
              },
              icon: Icon(Icons.send))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TypeImage(imageUri: userImage),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (text) {
                  setUserContent(text);
                },
                controller: text,
                maxLines: null,
                decoration: InputDecoration(
                    hintText: "문구를 작성하거나 설문을 추가하세요...",
                    hintStyle: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w400)),
              ),
            ),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close))
          ],
        ),
      ),
    );
  }
}

class TypeImage extends StatelessWidget {
  const TypeImage({
    super.key,
    this.imageUri,
    this.imageWidth,
    this.imageHeight,
    this.fit,
  });

  final dynamic imageUri;
  final double? imageWidth;
  final double? imageHeight;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: imageUri is File
          ? Image.file(
              imageUri,
              width: imageWidth,
              height: imageHeight,
              fit: fit ?? BoxFit.cover,
            )
          : Image.network(
              imageUri,
              width: imageWidth,
              height: imageHeight,
              fit: fit ?? BoxFit.cover,
            ),
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Text('프로필페이지'),
    );
  }
}

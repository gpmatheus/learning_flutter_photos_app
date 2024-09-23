import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Random Images',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const ImagesPage(title: 'Images home page'),
    );
  }
}

class ImagesPage extends StatefulWidget {
  const ImagesPage({super.key, required this.title});

  final String title;

  // @override
  // State<ImagesPage> createState() => _MyHomePageState();
  @override
  State<ImagesPage> createState() {
    return _MyImagesPageState();
  }
}

class CardContent {
  final String author;
  final String description;
  final String url;

  const CardContent(
      {required this.author, required this.description, required this.url});

  factory CardContent.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    return switch (json) {
      {
        'author': String author,
        'download_url': String url,
      } =>
        CardContent(
            author: author,
            description:
                'Conteúdo da descrição da foto. Conteúdo da descrição da foto.',
            url: url),
      _ => throw const FormatException('Failed to load the images'),
    };
  }
}

class _MyImagesPageState extends State<ImagesPage> {
  late Future<List<CardContent>>? images;

  Future<List<CardContent>> fetchImages() async {
    final response = await http.get(Uri.parse('https://picsum.photos/v2/list'));
    List<dynamic> decodeResponse = jsonDecode(response.body) as List<dynamic>;
    return decodeResponse
        .map((res) => CardContent.fromJson(res as Map<String, dynamic>))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    images = fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: FutureBuilder(
            future: images,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: Container(
                              decoration: index == 0
                                  ? null
                                  : const BoxDecoration(
                                      border: Border(
                                          top: BorderSide(
                                              color: Color(0xCCCCCCFF)))),
                              margin:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Row(children: [
                                Expanded(
                                    child: Container(
                                  margin: const EdgeInsets.only(left: 10.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Image.network(
                                        snapshot.data![index].url),
                                  ),
                                )),
                                Expanded(
                                    child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30.0),
                                      child: Text(snapshot.data![index].author),
                                    ),
                                    // Text('Título'),
                                    Expanded(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            snapshot.data![index].description,
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      ],
                                    ))
                                  ],
                                ))
                              ])));
                    });
              }
              return const CircularProgressIndicator();
            }));
  }
}

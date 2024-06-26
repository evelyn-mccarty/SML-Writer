import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_switch/flutter_switch.dart';

import 'package:sml_writer/json_article.dart';

void main() {
  runApp(MyApp());
}

Future<String> uploadArticle(JsonArticle item) async {
  final response = await http.put(
    Uri.parse(
        'https://hjk9v5kjg1.execute-api.us-east-2.amazonaws.com/Articles'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(JsonArticle.toJson(item)),
  );

  if (response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return response.body;
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create album.');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SML Writer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 48,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 48,
            ),
            primary: Colors.blue,
            textStyle: TextStyle(fontSize: 20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(16),
        ),
      ),
      home: WriterPage(),
    );
  }
}

class WriterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SML Writer'),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Pick files
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    // Process picked files
                    print('Picked files:');
                    result.files.forEach((file) {
                      print(file.name);
                      print(file.path);
                      print(file.size);
                      print(file.extension);
                      print('');
                    });
                  } else {
                    // User canceled the picker
                    print('User canceled file picking');
                  }
                },
                child: Text('Upload Files'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TextEntryPage()),
                  );
                },
                child: Text('Input Text'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help Menu'),
          content: Text(
            'To upload files, click on the "Upload Files" button and select the files you want to upload.\n\n'
            'To input text manually, click on the "Input Text" button and enter the article title, content, and select tags in the provided fields.\n',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class TextEntryPage extends StatefulWidget {
  @override
  _TextEntryPageState createState() => _TextEntryPageState();
}

class _TextEntryPageState extends State<TextEntryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  List<String> tags = [
    "Education Tag",
    "Immigration Tag",
    "HealthCare Tag",
    "Housing Tag",
    "Archived"
  ]; // Updated list of tags
  List<String> selectedTags = [];
  bool esp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Article Title',
              ),
            ),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                hintText: 'Article Author',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Article Content',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Select Tags:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 16,
                ),
                Text(
                  "Language",
                  style: TextStyle(fontSize: 16.5),
                ),
                Spacer(),
                FlutterSwitch(
                  showOnOff: true,
                  width: 100,
                  value: esp,
                  activeColor: Colors.red,
                  inactiveColor: Colors.blue,
                  activeText: "Español",
                  inactiveText: "English",
                  activeTextFontWeight: FontWeight.normal,
                  inactiveTextFontWeight: FontWeight.normal,
                  onToggle: (bool value) {
                    setState(() {
                      esp = value;
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  return CheckboxListTile(
                    title: Text(tag),
                    value: selectedTags.contains(tag),
                    onChanged: (value) {
                      setState(() {
                        if (tag == "Archived") {
                          // If the "Archived" tag is selected, remove all other tags
                          selectedTags.clear();
                        } else if (selectedTags.contains("Archived")) {
                          // If the "Archived" tag is already selected, deselect it
                          selectedTags.remove("Archived");
                        }
                        if (value!) {
                          selectedTags.add(tag);
                        } else {
                          selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Process the entered text and selected tags
                if (esp) {
                  selectedTags.add("Spanish");
                } else {
                  selectedTags.add("English");
                }
                var temp = JsonArticle(
                    title: _titleController.text,
                    author: _authorController.text,
                    tags: selectedTags,
                    body: _contentController.text.split('\n'));
                var fut = uploadArticle(temp);
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

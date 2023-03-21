import 'package:bubble/bubble.dart';
import 'package:dialogflow_flutter/googleAuth.dart';
import 'package:flutter/material.dart';
import 'package:dialogflow_flutter/dialogflowFlutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
      ),
      home: const ChatBotScreen(),
    );
  }
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  ChatBotScreenState createState() => ChatBotScreenState();
}

class ChatBotScreenState extends State<ChatBotScreen> {
  final messageInsert = TextEditingController();
  List<Map> mappedMessages = [];

  void response(query) async {
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/flutterfaqbot_dialog_auth.json")
            .build();
    DialogFlow dialogflow = DialogFlow(authGoogle: authGoogle, language: "en");
    AIResponse aiResponse = await dialogflow.detectIntent(query);
    final messageList = aiResponse.getListMessage();

    if (messageList == null || messageList.isEmpty) return;

    setState(() {
      mappedMessages.insert(0,
          {"data": 0, "message": messageList[0]["text"]["text"][0].toString()});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 70.0,
        elevation: 10.0,
        title: const Text("Dailog Flow Chatbot"),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              reverse: true,
              itemCount: mappedMessages.length,
              itemBuilder: (context, index) => chat(
                mappedMessages[index]["message"].toString(),
                mappedMessages[index]["data"],
              ),
            ),
          ),
          const Divider(
            height: 6.0,
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 15.0,
              right: 15.0,
              bottom: 20.0,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    controller: messageInsert,
                    decoration: const InputDecoration.collapsed(
                      hintText: "Send your message",
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        size: 30.0,
                      ),
                      onPressed: () {
                        if (messageInsert.text.isEmpty) {
                          print("empty message");
                        } else {
                          setState(() {
                            mappedMessages.insert(
                                0, {"data": 1, "message": messageInsert.text});
                          });
                          response(messageInsert.text);
                          messageInsert.clear();
                        }
                      }),
                )
              ],
            ),
          ),
          const SizedBox(height: 15.0)
        ],
      ),
    );
  }

  Widget chat(String message, int data) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Bubble(
        radius: const Radius.circular(15.0),
        color: data == 0 ? Colors.grey[300] : Colors.blueAccent,
        elevation: 0.0,
        alignment: data == 0 ? Alignment.topLeft : Alignment.topRight,
        nip: data == 0 ? BubbleNip.leftBottom : BubbleNip.rightTop,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: AssetImage(
                  data == 0 ? "assets/bot.png" : "assets/user.png",
                ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color: data == 0 ? Colors.black : Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

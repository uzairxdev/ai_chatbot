import 'dart:convert';

import 'package:ai_chatbot/Core/chat_message_type.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Core/chat_message_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

Future<String> generateResponse(String prompt) async {
  const apiKey = "USE_YOUR_OWN_KEY";
  var url = Uri.https("api.openai.com", "/v1/completions");
  final response = await http.post(url,
      headers: {
        "Content-Type": "application/json",
        "Autherization": "Bearer $apiKey"
      },
      body: json.encode({
        "model": "text-davinci-003",
        "prompt": prompt,
        "temperature": 1,
        "max_tokens": 4000,
        "top_p": 1,
        "frequency_penalty": 0.0,
        "presence_penalty": 0.0,
      }));
  Map<String, dynamic> newresponse = jsonDecode(response.body);

  return newresponse['choices'][0]['text'];
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollCOntroller = ScrollController();
  final List<ChatMessage> _message = [];
  late bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
  }

  void _scrollDown() {
    _scrollCOntroller.animateTo(
      _scrollCOntroller.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI ChatBot"),
        backgroundColor: Color.fromRGBO(16, 163, 127, 1),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF343541),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCOntroller,
              itemCount: _message.length,
              itemBuilder: (context, index) {
                var message = _message[index];

                return ChatMessageWidget(
                  text: message.text,
                  chatMessageType: message.chatMessageType,
                );
              },
            ),
          ),
          Visibility(
            visible: isLoading,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(color: Colors.white),
                    controller: _textController,
                    decoration: InputDecoration(
                      fillColor: Color(0xFF444654),
                      filled: true,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                Visibility(
                    visible: !isLoading,
                    child: Container(
                      color: Color(0xFF444654),
                      child: IconButton(
                        icon: Icon(
                          Icons.send_rounded,
                          color: Color.fromRGBO(142, 142, 160, 1),
                        ),
                        onPressed: () async {
                          setState(() {
                            _message.add(
                              ChatMessage(
                                text: _textController.text,
                                chatMessageType: ChatMessageType.user,
                              ),
                            );
                            isLoading = true;
                          });
                          var input = _textController.text;
                          _textController.clear();
                          Future.delayed(Duration(milliseconds: 50))
                              .then((_) => null);
                          _scrollDown();
                          generateResponse(input).then((value) {
                            setState(() {
                              isLoading = false;
                              _message.add(ChatMessage(
                                  text: value,
                                  chatMessageType: ChatMessageType.bot));
                            });
                          });
                          _textController.clear();
                          Future.delayed(Duration(milliseconds: 50))
                              .then((_) => _scrollDown());
                        },
                      ),
                    ))
              ],
            ),
          )
        ]),
      ),
    );
  }
}

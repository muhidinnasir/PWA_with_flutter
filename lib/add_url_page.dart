import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:onlinecourse/open_url_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddURLPage extends StatefulWidget {
  const AddURLPage({super.key});

  @override
  State<AddURLPage> createState() => _AddURLPageState();
}

class _AddURLPageState extends State<AddURLPage> {
  List<String> listOfURL = [];
  final TextEditingController urlController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Map<String, Map<String, String>> loginDetails = {};

  initializSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    super.initState();
    initializSplash();
    loadURLs();
  }

  Future<void> loadURLs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      listOfURL = prefs.getStringList('urls') ?? [];
      loginDetails = (json.decode(prefs.getString('loginDetails') ?? '{}')
              as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, Map<String, String>.from(value)));
    });
  }

  Future<void> saveURLs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('urls', listOfURL);
  }

  Future<void> saveLoginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('loginDetails', json.encode(loginDetails));
  }

  bool addURL() {
    String url = urlController.text;
    String username = usernameController.text;
    String password = passwordController.text;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL cannot be empty')),
      );
      return false;
    }
    if (!Uri.parse(url).isAbsolute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
      return false;
    } else if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and password cannot be empty')),
      );
      return false;
    } else {
      setState(() {
        listOfURL.add(url);
        loginDetails[url] = {
          'username': usernameController.text,
          'password': passwordController.text,
        };
        urlController.clear();
        usernameController.clear();
        passwordController.clear();
        saveURLs();
        saveLoginDetails();
      });
      return true;
    }
  }

  void removeURL(int index) {
    setState(() {
      String url = listOfURL[index];
      listOfURL.removeAt(index);
      loginDetails.remove(url);
      saveURLs();
      saveLoginDetails();
    });
  }

  void openURL(String url) {
    if (loginDetails[url] == null ||
        loginDetails[url]!['username'] == null ||
        loginDetails[url]!['password'] == null ||
        loginDetails[url]!['username']!.isEmpty ||
        loginDetails[url]!['password']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and password cannot be empty')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OpenURLPage(
          url: url,
          username: loginDetails[url]!['username']!,
          password: loginDetails[url]!['password']!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Study Japanese Online',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 189,
                width: 189,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                    "https://kg-japaneseschool.jp/media/local/img/favicons/elearning.ico"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    hintText: 'https://example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  obscureText: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.orange.shade400),
                      shape: const MaterialStatePropertyAll(
                        BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          side: BorderSide.none,
                        ),
                      ),
                    ),
                    onPressed: () {
                      var isDone = addURL();
                      if (isDone) {
                        openURL(urlController.text);
                      }
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: listOfURL.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black12),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(10.0)),
                        ),
                        onPressed: () => openURL(listOfURL[index]),
                        child: Text(
                          listOfURL[index],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeURL(index),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

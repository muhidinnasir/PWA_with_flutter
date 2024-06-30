import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:onlinecourse/open_url_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddURLPage extends StatefulWidget {
  const AddURLPage({super.key});

  @override
  State<AddURLPage> createState() => _AddURLPageState();
}

class _AddURLPageState extends State<AddURLPage> {
  List<String> listOfURL = [];
  final TextEditingController urlController = TextEditingController();

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
    });
  }

  Future<void> saveURLs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('urls', listOfURL);
  }

  void addURL() {
    String url = urlController.text;
    if (url.isEmpty) {
      // Show an error message if the URL is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL cannot be empty')),
      );
      return;
    }

    // Simple URL validation
    if (!Uri.parse(url).isAbsolute) {
      // Show an error message if the URL is not valid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
      return;
    }

    setState(() {
      listOfURL.add(url);
      urlController.clear(); // Clear the text field after adding
      saveURLs();
    });
  }

  void removeURL(int index) {
    setState(() {
      listOfURL.removeAt(index);
      saveURLs();
    });
  }

  void openURL(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OpenURLPage(url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Ashewa Smart ERP',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 260,
                  height: 50,
                  child: TextFormField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      hintText: 'Write URL and add',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: addURL,
                  child: Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      onPressed: addURL,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                )
              ],
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
                          const EdgeInsets.all(10.0),
                        ),
                      ),
                      onPressed: () => openURL(listOfURL[index]),
                      child: Text(listOfURL[index]),
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
    );
  }
}

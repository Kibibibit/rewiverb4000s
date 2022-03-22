import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int currentIndex = 0;

  List<String> pageTitles = [
    "Patches",
    "EWI"
  ];

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[currentIndex]),
      ),
      body: SizedBox.expand(
        child: PageView(
          controller: _controller,
          children: [
            Container(color: Colors.red,),
            Container(color: Colors.blue,)
          ],
          onPageChanged: (index) {
            setState(() => currentIndex = index);
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            _controller.animateToPage(index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: "Patches",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.usb),
            label: "EWI",
          ),
        ],
      ),
    );
  }
}

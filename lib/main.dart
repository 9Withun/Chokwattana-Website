import 'package:flutter/material.dart';
import 'appUI/admin_page_contropanel.dart';
import 'appUI/ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChokWattanaHomeCenter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'ChokWattanaHomeCenter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.sizeOf(context).width < 700 ? 124 : 122,
        ),
        child: const HomeTopBar(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: const [
          BannerCardLayout(),
          SizedBox(height: 24),
          PromotionCarousel(),
          SizedBox(height: 24),
          ApiProductSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AdminControlPanel(),
            ),
          );
        },
        icon: const Icon(Icons.admin_panel_settings_outlined),
        label: const Text('Admin'),
      ),
    );
  }
}

import 'package:flutter/material.dart';

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
          MediaQuery.sizeOf(context).width <
                  HomeContentContainer.compactBreakpoint
              ? 124
              : 122,
        ),
        child: const HomeTopBar(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          HomeContentContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                BannerCardLayout(),
                SizedBox(height: 24),
                ApiProductSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

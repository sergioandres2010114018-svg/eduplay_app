import 'package:flutter/material.dart';
import '../widgets/common.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen(this.asset, this.title, {super.key});
  final String asset, title;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Column(children: [
          Expanded(child: Center(child: AssetVideo(asset, autoPlay: true))),
          const CreditFooter(),
        ]),
      );
}

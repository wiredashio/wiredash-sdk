// ignore_for_file: avoid_classes_with_only_static_members, missing_whitespace_between_adjacent_strings, avoid_positional_boolean_parameters, avoid_dynamic_calls, unsafe_html, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';

/// Big thanks to Mariano Zorrilla for this awsome clone of Netflix!
///
/// Follow him on twitter: https://twitter.com/marianozorrilla
/// Checkout more clones on codepen: https://codepen.io/mkiisoft
class Netflix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove when we drop support for Flutter v3.7.0-29.0.pre.
      // ignore: deprecated_member_use
      useInheritedMediaQuery: true,
      debugShowCheckedModeBanner: false,
      home: InitScreen(),
      theme: ThemeData().copyWith(
        primaryColor: NetflixColors.netflixRed,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: NetflixColors.netflixRed,
          secondary: Utils.colorAbout,
        ),
      ),
    );
  }
}

class Tuple<F, S> {
  F first;
  S second;

  Tuple(this.first, this.second);
}

class Utils {
  static const mainRed = Color(0xFFE50915);
  static const colorSeparator = Color(0xFF222222);
  static const colorAbout = Color(0xFF757575);
  static const colorLanguage = Color(0xFF999999);

  static int logoId = 0;
  static int iconId = 0;

  static Widget logo() {
    logoId += 1;
    final image = _createImageElement(
      'M105.06233,14.2806261 L110.999156,30 C109.249227,29.7497422 107.500234,29.4366857 105.718437,29.1554972 L102.374168,20.4686475 L98.9371075,28.4375293 C97.2499766,28.1563408 95.5928391,28.061674 93.9057081,27.8432843 L99.9372012,14.0931671 L94.4680851,-5.68434189e-14 L99.5313525,-5.68434189e-14 L102.593495,7.87421502 L105.874965,-5.68434189e-14 L110.999156,-5.68434189e-14 L105.06233,14.2806261 Z M90.4686475,-5.68434189e-14 L85.8749649,-5.68434189e-14 L85.8749649,27.2499766 C87.3746368,27.3437061 88.9371075,27.4055675 90.4686475,27.5930265 L90.4686475,-5.68434189e-14 Z M81.9055207,26.93692 C77.7186241,26.6557316 73.5307901,26.4064111 69.250164,26.3117443 L69.250164,-5.68434189e-14 L73.9366389,-5.68434189e-14 L73.9366389,21.8745899 C76.6248008,21.9373887 79.3120255,22.1557784 81.9055207,22.2804387 L81.9055207,26.93692 Z M64.2496954,10.6561065 L64.2496954,15.3435186 L57.8442216,15.3435186 L57.8442216,25.9996251 L53.2186709,25.9996251 L53.2186709,-5.68434189e-14 L66.3436123,-5.68434189e-14 L66.3436123,4.68741213 L57.8442216,4.68741213 L57.8442216,10.6561065 L64.2496954,10.6561065 Z M45.3435186,4.68741213 L45.3435186,26.2498828 C43.7810479,26.2498828 42.1876465,26.2498828 40.6561065,26.3117443 L40.6561065,4.68741213 L35.8121661,4.68741213 L35.8121661,-5.68434189e-14 L50.2183897,-5.68434189e-14 L50.2183897,4.68741213 L45.3435186,4.68741213 Z M30.749836,15.5928391 C28.687787,15.5928391 26.2498828,15.5928391 24.4999531,15.6875059 L24.4999531,22.6562939 C27.2499766,22.4678976 30,22.2495079 32.7809542,22.1557784 L32.7809542,26.6557316 L19.812541,27.6876933 L19.812541,-5.68434189e-14 L32.7809542,-5.68434189e-14 L32.7809542,4.68741213 L24.4999531,4.68741213 L24.4999531,10.9991564 C26.3126816,10.9991564 29.0936358,10.9054269 30.749836,10.9054269 L30.749836,15.5928391 Z M4.78114163,12.9684132 L4.78114163,29.3429562 C3.09401069,29.5313525 1.59340144,29.7497422 0,30 L0,-5.68434189e-14 L4.4690224,-5.68434189e-14 L10.562377,17.0315868 L10.562377,-5.68434189e-14 L15.2497891,-5.68434189e-14 L15.2497891,28.061674 C13.5935889,28.3437998 11.906458,28.4375293 10.1246602,28.6868498 L4.78114163,12.9684132 Z',
    );
    // ignore:undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory('marianos_clones$logoId', (int viewId) => image);
    final element =
        HtmlElementView(key: UniqueKey(), viewType: 'marianos_clones$logoId');
    return element;
  }

  // Thank you so much, Simon Lightfoot! SVG on Flutter Web
  // https://twitter.com/devangelslondon
  static html.HtmlElement _createImageElement(String path) {
    final data = base64.encode(
      utf8.encode(
        '<svg viewBox="0 0 111 30" xmlns="http://www.w3.org/2000/svg"><path '
        'd="$path" fill="#E50915"/></svg>',
      ),
    );
    return html.ImageElement()..src = 'data:image/svg+xml;base64,$data';
  }

  static Widget svgIcon(String svg) {
    iconId += 1;
    // ignore:undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'icon$iconId',
      (int viewId) => _createFromSVG(svg),
    );
    final element = HtmlElementView(key: UniqueKey(), viewType: 'icon$iconId');
    return element;
  }

  static html.HtmlElement _createFromSVG(String svg) {
    final data = base64.encode(utf8.encode(svg));
    return html.ImageElement()..src = 'data:image/svg+xml;base64,$data';
  }

  static Tuple<Widget, html.VideoElement> video(
    String url,
    String id,
    bool autoPlay,
  ) {
    final video = html.VideoElement();
    video.autoplay = autoPlay;
    video.loop = true;
    video.src = url;
    video.onClick
        .listen((event) => video.paused ? video.play() : video.pause());
    // ignore:undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory('video_tv$url$id', (int viewId) => video);
    return Tuple(
      HtmlElementView(key: UniqueKey(), viewType: 'video_tv$url$id'),
      video,
    );
  }
}

class InitScreen extends StatefulWidget {
  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  final Widget _logo = Utils.logo();
  static int _videoTVId = 1;
  static int _videoDevicesId = 1;
  final _videoTv = Utils.video(
    'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/video-tv.m4v',
    'a$_videoTVId',
    true,
  );
  final _videoDevices = Utils.video(
    'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/video-devices.m4v',
    'b$_videoDevicesId',
    true,
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      color: Colors.black,
      child: ListView(
        children: [
          _topSectionDesktop(size, context),
          Container(height: 10, color: Utils.colorSeparator),
          _enjoyTVSection(size),
          Container(height: 40, color: Colors.black),
          Container(height: 10, color: Utils.colorSeparator),
          _downloadShowsSection(size),
          Container(height: 40, color: Colors.black),
          Container(height: 10, color: Utils.colorSeparator),
          Container(height: 40, color: Colors.black),
          _enjoyEverywhereSection(size),
          Container(height: 40, color: Colors.black),
          Container(height: 10, color: Utils.colorSeparator),
          Container(height: 70, color: Colors.black),
          _faqSection(size),
          Container(height: 10, color: Utils.colorSeparator),
          Container(height: 40, color: Colors.black),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.15),
            child: Text(
              'Questions? Contact us.',
              style: TextStyle(color: Utils.colorAbout),
            ),
          ),
          Container(height: 40, color: Colors.black),
          _aboutUs(size),
          _language(size),
          Container(height: 40, color: Colors.black),
        ],
      ),
    );
  }

  Widget _topSectionDesktop(Size size, BuildContext context) {
    final isTablet = size.width < 1000;
    return SizedBox(
      height: size.height * 0.93,
      width: size.width,
      child: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.network(
              'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/netlix_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.8),
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.42),
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Container(
            height: 44,
            width: breakpoint(size.width, 134, 134, 110),
            margin: EdgeInsets.only(
              left: breakpoint(size.width, 55, 40, 30),
              top: 25,
            ),
            child: _logo,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () =>
                      Wiredash.of(context).show(inheritMaterialTheme: true),
                  child: Container(
                    height: 34,
                    width: 136,
                    margin: EdgeInsets.only(
                      right: 25,
                      top: 25,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Utils.colorAbout,
                    ),
                    child: HandCursor(
                      child: Center(
                        child: Text(
                          'Send Feedback',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ),
                  child: Container(
                    height: 34,
                    width: 84,
                    margin: EdgeInsets.only(
                      right: breakpoint(size.width, 55, 40, 30),
                      top: 25,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Utils.mainRed,
                    ),
                    child: HandCursor(
                      child: Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    size.width * breakpoint(size.width, 0.255, 0.15, 0.10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 90),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: breakpoint(size.width, 40, 30, 0),
                    ),
                    child: Text(
                      'Unlimited movies, TV shows, and more.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: breakpoint(size.width, 48, 40, 32),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Watch anywhere. Cancel anytime.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: breakpoint(size.width, 26, 22, 22),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  if (isTablet)
                    Column(
                      children: [
                        Text(
                          'Ready to watch? Enter your email to create or access your account.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: breakpoint(size.width, 19, 17, 17),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  _tryItNow(size),
                  if (!isTablet)
                    Column(
                      children: [
                        Text(
                          'Ready to watch? Enter your email to create or access your account.',
                          style: TextStyle(color: Colors.white, fontSize: 19),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _enjoyTVSection(Size size) {
    _videoTVId += 1;
    return ColoredBox(
      color: Colors.black,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        children: [
          Container(
            height: breakpoint(size.width, 400, 200, 150),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: breakpoint(
                size.width,
                CrossAxisAlignment.start,
                CrossAxisAlignment.center,
                CrossAxisAlignment.center,
              ),
              mainAxisAlignment: breakpoint(
                size.width,
                MainAxisAlignment.center,
                MainAxisAlignment.end,
                MainAxisAlignment.end,
              ),
              children: [
                Text(
                  'Enjoy on your TV.',
                  textAlign: breakpoint(
                    size.width,
                    TextAlign.start,
                    TextAlign.center,
                    TextAlign.center,
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: breakpoint(size.width, 45, 40, 28),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Watch on Smart TVs, Playstation, Xbox,\nChromecast, Apple TV, Blu-ray players, and\nmore.',
                  textAlign: breakpoint(
                    size.width,
                    TextAlign.start,
                    TextAlign.center,
                    TextAlign.center,
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: breakpoint(size.width, 25, 20, 15),
                  ),
                ),
              ],
            ),
          ),
          FittedBox(
            child: SizedBox(
              height: 400,
              width: 530,
              child: Stack(
                children: [
                  Container(
                    height: 220,
                    width: 220 * 1.77,
                    margin: const EdgeInsets.only(top: 80, left: 70),
                    child: RepaintBoundary(child: _videoTv.first),
                  ),
                  Image.network(
                    'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/device_tv.png',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tryItNow(Size size) {
    final isTable = size.width < 1000;
    return Container(
      height: isTable ? null : 60,
      width: size.width,
      decoration: BoxDecoration(
        border: isTable
            ? null
            : Border(
                bottom: BorderSide(),
                right: BorderSide(),
              ),
      ),
      child: isTable
          ? Column(
              children: [
                ColoredBox(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Email address',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 125,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Color(0xFFDE0511),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.only(left: 10),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'TRY IT NOW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: ColoredBox(
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Email address',
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: size.height,
                      color: Color(0xFFDE0511),
                      padding: const EdgeInsets.only(left: 30, right: 20),
                      child: Center(
                        child: Row(
                          children: [
                            Text(
                              'TRY IT NOW',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.white,
                              size: 35,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _downloadShowsSection(Size size) {
    return ColoredBox(
      color: Colors.black,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 400,
            width: 530,
            child: FittedBox(
              child: Stack(
                children: [
                  Image.network(
                    'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/mobile.jpg',
                  ),
                  SizedBox(
                    height: 400,
                    width: 530,
                    child: Align(
                      alignment: Alignment(0.8, 1.25),
                      child: Container(
                        height: 115,
                        width: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Color(0xFF404040),
                            width: 2.5,
                          ),
                          color: Colors.black,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Image.network(
                              'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/stranger.png',
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Stranger Things',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Downloading...',
                                    style: TextStyle(
                                      color: Color(0xFF0071EB),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: breakpoint(size.width, 400, 200, 150),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: breakpoint(
                size.width,
                CrossAxisAlignment.start,
                CrossAxisAlignment.center,
                CrossAxisAlignment.center,
              ),
              mainAxisAlignment: breakpoint(
                size.width,
                MainAxisAlignment.center,
                MainAxisAlignment.end,
                MainAxisAlignment.end,
              ),
              children: [
                Text(
                  'Download your shows\nto watch offline.',
                  textAlign: breakpoint(
                    size.width,
                    TextAlign.start,
                    TextAlign.center,
                    TextAlign.center,
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: breakpoint(size.width, 45, 40, 28),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Save your favorites easily and always have\nsomething to watch.',
                  textAlign: breakpoint(
                    size.width,
                    TextAlign.start,
                    TextAlign.center,
                    TextAlign.center,
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: breakpoint(size.width, 25, 20, 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _enjoyEverywhereSection(Size size) {
    _videoDevicesId += 1;
    return ColoredBox(
      color: Colors.black,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        children: [
          Container(
            height: breakpoint(size.width, 400, 200, 150),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: breakpoint(
                size.width,
                CrossAxisAlignment.start,
                CrossAxisAlignment.center,
                CrossAxisAlignment.center,
              ),
              mainAxisAlignment: breakpoint(
                size.width,
                MainAxisAlignment.center,
                MainAxisAlignment.end,
                MainAxisAlignment.end,
              ),
              children: [
                Text(
                  'Watch everywhere.',
                  textAlign: breakpoint(
                    size.width,
                    TextAlign.start,
                    TextAlign.center,
                    TextAlign.center,
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: breakpoint(size.width, 45, 40, 28),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Stream unlimited movies and TV shows on\nyour phone, tablet, laptop, and TV without\npaying more.',
                  textAlign: breakpoint(
                    size.width,
                    TextAlign.start,
                    TextAlign.center,
                    TextAlign.center,
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: breakpoint(size.width, 25, 20, 15),
                  ),
                ),
              ],
            ),
          ),
          FittedBox(
            child: SizedBox(
              height: 400,
              width: 530,
              child: Stack(
                children: [
                  Container(
                    height: 190,
                    width: 190 * 1.77,
                    margin: const EdgeInsets.only(top: 45, left: 100),
                    child: _videoDevices.first,
                  ),
                  Image.network(
                    'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/devices.png',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqSection(Size size) {
    final isTablet = size.width < 1000;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: size.width * breakpoint(size.width, 0.2, 0.15, 0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              color: Colors.white,
              fontSize: breakpoint(size.width, 50, 45, 30),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          _faq('What is Netflix?', '', size),
          _faq('How much does Netflix cost?', '', size),
          _faq('Where can I watch?', '', size),
          _faq('How do I cancel?', '', size),
          _faq('What can I watch on Netflix?', '', size),
          SizedBox(height: 40),
          if (isTablet)
            Column(
              children: [
                Text(
                  'Ready to watch? Enter your email to create or access your account.',
                  style: TextStyle(color: Colors.white, fontSize: 19),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
              ],
            ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: breakpoint(size.width, 60, 40, 30),
            ),
            child: _tryItNow(size),
          ),
          SizedBox(height: 10),
          if (!isTablet)
            Text(
              'Ready to watch? Enter your email to create or access your account.',
              style: TextStyle(color: Colors.white, fontSize: 19),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _faq(String title, String content, Size size) {
    return Column(
      children: [
        Container(
          height: 80,
          color: Color(0xFF303030),
          padding: EdgeInsets.symmetric(
            horizontal: breakpoint(size.width, 30, 20, 20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: breakpoint(size.width, 28, 22, 18),
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.add,
                color: Colors.white,
                size: breakpoint(size.width, 40, 32, 26),
              ),
            ],
          ),
        ),
        Container(height: 10, color: Colors.black),
      ],
    );
  }

  Widget _aboutUs(Size size) {
    return Container(
      height: 180,
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.15, vertical: 20),
      child: GridView(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          childAspectRatio: 7,
        ),
        children: [
          Text('FAQ', style: TextStyle(color: Utils.colorAbout)),
          Text('Help Center', style: TextStyle(color: Utils.colorAbout)),
          Text('Account', style: TextStyle(color: Utils.colorAbout)),
          Text('Media Center', style: TextStyle(color: Utils.colorAbout)),
          Text('Investor Relations', style: TextStyle(color: Utils.colorAbout)),
          Text('Jobs', style: TextStyle(color: Utils.colorAbout)),
          Text('Ways to Watch', style: TextStyle(color: Utils.colorAbout)),
          Text('Terms of Use', style: TextStyle(color: Utils.colorAbout)),
          Text('Privacy', style: TextStyle(color: Utils.colorAbout)),
          Text('Cookie Preferences', style: TextStyle(color: Utils.colorAbout)),
          Text(
            'Corporate Information',
            style: TextStyle(color: Utils.colorAbout),
          ),
          Text('Contact Us', style: TextStyle(color: Utils.colorAbout)),
          Text('Speed Test', style: TextStyle(color: Utils.colorAbout)),
          Text('Legal Notice', style: TextStyle(color: Utils.colorAbout)),
          Text('Netflix Originals', style: TextStyle(color: Utils.colorAbout)),
        ],
      ),
    );
  }

  Widget _language(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            width: 140,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF333333), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.language, color: Utils.colorLanguage),
                SizedBox(width: 10),
                Text('English', style: TextStyle(color: Utils.colorLanguage)),
                Icon(Icons.arrow_drop_down, color: Utils.colorLanguage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _logo = Utils.logo();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 650;
    return Material(
      child: ListView(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/netlix_bg.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.8),
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.42),
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: isMobile
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 45,
                        width: 165,
                        margin:
                            EdgeInsets.only(left: isMobile ? 0 : 55, top: 25),
                        child: _logo,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 450,
                    height: 675,
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.8),
                    padding: EdgeInsets.symmetric(
                      horizontal: breakpoint(size.width, 60, 40, 30),
                      vertical: 65,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Color(0xFF333333),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Email '
                                  'or phone number',
                              labelStyle: TextStyle(color: Color(0xFF8C8C8C)),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Color(0xFF333333),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Color(0xFF8C8C8C)),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(),
                            ),
                            (_) => false,
                          ),
                          child: HandCursor(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Utils.mainRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Icon(
                              Icons.check_box,
                              color: Color(0xFF8C8C8C),
                              size: 20,
                            ),
                            SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                'Remember me',
                                style: TextStyle(
                                  color: Color(0xFF8C8C8C),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              'Need help?',
                              style: TextStyle(
                                color: Color(0xFF8C8C8C),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 50),
                        Row(
                          children: [
                            SizedBox(width: 10),
                            Text(
                              'Login with Facebook',
                              style: TextStyle(
                                color: Color(0xFF737373),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'New to Netflix?',
                              style: TextStyle(
                                color: Color(0xFF737373),
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Sign up now.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Text(
                            "This page is protected by Google reCAPTCHA to ensure you're not a bot. Learn more.",
                            style: TextStyle(
                              color: Color(0xFF737373),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 100),
                  Container(
                    width: size.width,
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.5),
                    height: 240,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.15,
                          ),
                          child: Text(
                            'Questions? Contact us.',
                            style: TextStyle(color: Utils.colorAbout),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 60,
                          margin: EdgeInsets.symmetric(
                            horizontal: size.width * 0.15,
                          ),
                          child: GridView(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 300,
                              childAspectRatio: 7,
                            ),
                            children: [
                              Text(
                                'Gift Card Terms',
                                style: TextStyle(color: Utils.colorAbout),
                              ),
                              Text(
                                'Terms of Use',
                                style: TextStyle(color: Utils.colorAbout),
                              ),
                              Text(
                                'Privacy Statement',
                                style: TextStyle(color: Utils.colorAbout),
                              ),
                            ],
                          ),
                        ),
                        _language(size),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _language(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            width: 140,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.8),
              border: Border.all(color: Color(0xFF333333), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.language, color: Utils.colorLanguage),
                SizedBox(width: 10),
                Text('English', style: TextStyle(color: Utils.colorLanguage)),
                Icon(Icons.arrow_drop_down, color: Utils.colorLanguage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _logo = Utils.logo();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 650;
    return Material(
      child: ColoredBox(
        color: isMobile ? Colors.black : Color(0xFF141414),
        child: Column(
          children: [
            SizedBox(
              height: 70,
              width: size.width,
              child: Stack(
                children: [
                  Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          // ignore: deprecated_member_use
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Align(
                    alignment:
                        isMobile ? Alignment.center : Alignment.centerLeft,
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 70,
                          margin: EdgeInsets.symmetric(
                            horizontal: size.width * 0.042,
                          ),
                          child: _logo,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      "Who's watching?",
                      style: TextStyle(
                        fontSize: isMobile ? 30 : 50,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),
                    Wrap(
                      spacing: 10,
                      runSpacing: 20,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => BrowseScreen()),
                            (route) => false,
                          ),
                          child: HandCursor(
                            child: ProfileItem(
                              name: 'Mariano',
                              color: Utils.mainRed,
                              isUser: true,
                            ),
                          ),
                        ),
                        ProfileItem(
                          name: 'FlutterDev',
                          color: Color(0xFF15AFE2),
                          isUser: true,
                        ),
                        ProfileItem(isUser: false),
                      ],
                    ),
                    SizedBox(height: 40),
                    if (!isMobile)
                      MaterialButton(
                        onPressed: () {},
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                          side: BorderSide(color: Color(0xFF737373)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          child: Text(
                            'MANAGE PROFILES',
                            style: TextStyle(
                              color: Color(0xFF737373),
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}

class ProfileItem extends StatefulWidget {
  final String? name;
  final Color? color;
  final bool isUser;

  const ProfileItem({super.key, this.name, this.color, required this.isUser});

  @override
  _ProfileItemState createState() => _ProfileItemState();
}

class _ProfileItemState extends State<ProfileItem> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: MouseRegion(
                onHover: (_) => setState(() => _isHover = true),
                onExit: (_) => setState(() => _isHover = false),
                child: Container(
                  width: 133,
                  height: 133,
                  color: _isHover ? Colors.white : Colors.transparent,
                  padding: const EdgeInsets.all(3),
                  child: widget.isUser
                      ? SizedBox(
                          width: 100,
                          height: 100,
                          child: FittedBox(
                            child: CustomPaint(
                              size: Size(100, 100),
                              painter: ProfileFace(
                                color: widget.color,
                                isSmall: false,
                              ),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.add_circle,
                          size: 90,
                          color: Color(0xFF737373),
                        ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.isUser ? widget.name ?? "-" : 'Add Profile',
              style: TextStyle(
                fontSize: 17,
                color: Color(_isHover ? 0xFFFFFFFF : 0xFF737373),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileFace extends CustomPainter {
  final Color? color;
  final bool isSmall;

  ProfileFace({this.color, required this.isSmall});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..lineTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height),
      Paint()..color = color ?? Colors.white,
    );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      isSmall ? 2 : 6,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      isSmall ? 2 : 6,
      Paint()..color = Colors.white,
    );
    final smilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSmall ? 2 : 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.4,
        size.height * (isSmall ? 0.3 : 0.45),
        size.width * 0.42,
        10,
      ),
      0.33,
      2.4,
      false,
      smilePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BrowseScreen extends StatefulWidget {
  @override
  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _scrollController = ScrollController();
  final _threshold = 100.0;
  var _fadePercentage = 0.0;

  final _logo = Utils.logo();
  final _gift = Utils.svgIcon(
    '<svg viewBox="0 0 20 21" xmlns="http://www.w3.org/2000/svg"><path d="M18'
    '.0246364,10.087 C18.0246364,10.1733636 17.9519091,10.2460909 17.8655455,10.2460909 L17'
    '.6782727,10.2460909 L16.3146364,10.2460909 L3.07372727,10.2460909 L1.71009091,10.2460909 L1'
    '.52281818,10.2460909 C1.43645455,10.2460909 1.36372727,10.1733636 1.36372727,10.087 L1'
    '.36372727,7.56518182 C1.36372727,7.47790909 1.43645455,7.40518182 1.52281818,7.40518182 L9'
    '.01190909,7.40518182 L14.601,7.40518182 L17.8655455,7.40518182 C17.9519091,7.40518182 18'
    '.0246364,7.47790909 18.0246364,7.56518182 L18.0246364,10.087 Z M16.3146364,18.6624545 C16'
    '.3146364,18.6988182 16.281,18.7324545 16.2446364,18.7324545 L10.3755455,18.7324545 L10.3755455,'
    '11.6097273 L16.3146364,11.6097273 L16.3146364,18.6624545 Z M9.01190909,18.7324545 L3.14372727,18'
    '.7324545 C3.10645455,18.7324545 3.07372727,18.6988182 3.07372727,18.6624545 L3.07372727,11'
    '.6097273 L9.01190909,11.6097273 L9.01190909,18.7324545 Z M6.711,1.36336364 C7.94918182,1'
    '.36336364 8.95554545,2.37063636 8.95554545,3.60790909 L8.95554545,5.85245455 L6.711,5.85245455 '
    'C5.47372727,5.85245455 4.46645455,4.84518182 4.46645455,3.60790909 C4.46645455,2.37063636 5'
    '.47372727,1.36336364 6.711,1.36336364 L6.711,1.36336364 Z M10.3755455,4.95790909 C10.3755455,3'
    '.86972727 11.261,2.98518182 12.3491818,2.98518182 C13.4382727,2.98518182 14.3228182,3.86972727 '
    '14.3228182,4.95790909 C14.3228182,5.36063636 14.1973636,5.73063636 13.9882727,6.04154545 L10'
    '.3755455,6.04154545 L10.3755455,4.95790909 Z M17.8655455,6.04154545 L15.4928182,6.04154545 C15'
    '.6128182,5.70154545 15.6864545,5.33972727 15.6864545,4.95790909 C15.6864545,3.11790909 14'
    '.1891818,1.62063636 12.3491818,1.62063636 C11.491,1.62063636 10.7155455,1.95609091 10.1237273,2'
    '.49063636 C9.65009091,1.04972727 8.30827273,-0.000272727273 6.711,-0.000272727273 C4.72190909,-0'
    '.000272727273 3.10281818,1.61881818 3.10281818,3.60790909 C3.10281818,4.55245455 3.47736364,5'
    '.40245455 4.07554545,6.04154545 L1.52281818,6.04154545 C0.682818182,6.04154545 9.09090909e-05,6'
    '.72518182 9.09090909e-05,7.56518182 L9.09090909e-05,10.087 C9.09090909e-05,10.927 0.682818182,11'
    '.6097273 1.52281818,11.6097273 L1.71009091,11.6097273 L1.71009091,18.6624545 C1.71009091,19'
    '.4533636 2.35281818,20.0960909 3.14372727,20.0960909 L16.2446364,20.0960909 C17.0355455,20'
    '.0960909 17.6782727,19.4533636 17.6782727,18.6624545 L17.6782727,11.6097273 L17.8655455,11'
    '.6097273 C18.7055455,11.6097273 19.3882727,10.927 19.3882727,10.087 L19.3882727,7.56518182 C19'
    '.3882727,6.72518182 18.7055455,6.04154545 17.8655455,6.04154545 L17.8655455,6.04154545 Z" '
    'fill="#FFFFFF"/></svg>',
  );

  final _video = Utils.video(
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    '3',
    true,
  );

  final List<Widget> _trending = [
    Row(
      children: [
        _movieItem(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/netflix_one.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieItem(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/netflix_two.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieItem(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/netflix_three.jpg',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieItem(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/netflix_four.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieItem(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/netflix_five.jpg',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieItem(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/netflix_six.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieItem(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/netflix_seven.jpg',
        ),
        SizedBox(width: 5),
      ],
    ),
  ];

  final List<Widget> _originals = [
    Row(
      children: [
        _movieOriginal(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/bbb.jpg',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieOriginal(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/original_two.jpg',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieOriginal(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/original_three.jpg',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieOriginal(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/original_four.jpg',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieOriginal(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/original_five.jpg',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieOriginal(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/original_six.jpg',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieOriginal(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/original_seven.jpg',
        ),
        SizedBox(width: 5),
      ],
    ),
  ];

  final List<Widget> _top = [
    Row(
      children: [
        _movieTop(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/avengers.jpg',
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/top_one.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieTop(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/blood.jpg',
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/top_two.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieTop(
          'https://a.wattpad.com/cover/214526225-352-k990092.jpg.png?alt=media',
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/top_three.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieTop(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/john.jpg',
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/top_four.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieTop(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/original_seven.jpg',
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/top_five.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieTop(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/dietodie.jpg',
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/top_six.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieTop(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/break.jpg',
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/top_seven.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieTop(
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/capmarvel.jpg',
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/top_eight.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieTop(
          'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSfkmPMDfVZLe3FoaHobQqYZ-SGIbeASuzwf21wTcQ8oCTyQmOF&usqp=CAU',
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/top_nine.png',
        ),
        SizedBox(width: 5),
      ],
    ),
    Row(
      children: [
        _movieTop(
          'https://images-na.ssl-images-amazon.com/images/I/71AErpCoZzL._AC_SY679_.jpg',
          'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/top_ten.png',
        ),
        SizedBox(width: 5),
      ],
    ),
  ];

  static bool _hoverPlay = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset <= 100) {
        setState(() {
          final fade = _scrollController.offset / _threshold;
          _fadePercentage = fade < 0 ? 0 : fade;
        });
      } else {
        setState(() => _fadePercentage = 1.0);
      }
    });
    scheduleMicrotask(() => _video.second.currentTime = 2);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 650;
    final currentRange = size.width / 500;
    const maxRange = 2.8;
    const minRange = 1.5;
    var scaleFactor = 1.0;
    if (currentRange >= minRange && currentRange <= maxRange) {
      scaleFactor = currentRange / maxRange;
    } else if (currentRange > maxRange) {
      scaleFactor = 1.0;
    } else {
      scaleFactor = 0.5;
    }
    return Scaffold(
      backgroundColor: Color(0xFF141414),
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            children: [
              if (isMobile)
                _topSectionMobile(size)
              else
                _topSection(size, scaleFactor),
              Transform(
                transform: Matrix4.identity()
                  ..translate(0, isMobile ? 30 : -80),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: 180,
                    width: size.width,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Text(
                            'Trending Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(left: 40, right: 40),
                            scrollDirection: Axis.horizontal,
                            children: _trending,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Transform(
                transform: Matrix4.identity()
                  ..translate(0, isMobile ? 40 : -60),
                child: SizedBox(
                  height: 500,
                  width: size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Text(
                          'Netflix Originals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            final item = _originals[index];
                            return GestureDetector(
                              onTap: () {
                                final navigator = Navigator.of(context);
                                Future.delayed(Duration(milliseconds: 500), () {
                                  if (!_video.second.paused) {
                                    _video.second.pause();
                                    _video.second.remove();
                                  }
                                  navigator.push(
                                    MaterialPageRoute(
                                      builder: (_) => PlayMovie(),
                                    ),
                                  );
                                });
                              },
                              child: HandCursor(child: item),
                            );
                          },
                          itemCount: _originals.length,
                          padding: const EdgeInsets.only(left: 40, right: 40),
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Transform(
                transform: Matrix4.identity()
                  ..translate(0, isMobile ? 70 : -20),
                child: SizedBox(
                  height: 240,
                  width: size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Text(
                          'Top 10 Today',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(left: 40, right: 40),
                          scrollDirection: Axis.horizontal,
                          children: _top,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 100 : 20),
              SizedBox(
                height: 240,
                width: size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Text(
                        'Award-Winning',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) => _trending[index],
                        itemCount: _trending.length,
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          if (isMobile) _appBarMobile(size) else _appBar(size),
        ],
      ),
      bottomNavigationBar: isMobile
          ? Theme(
              data: Theme.of(context).copyWith(canvasColor: Color(0xFF141414)),
              child: BottomNavigationBar(
                elevation: 0,
                showUnselectedLabels: true,
                backgroundColor: Colors.black,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey[700],
                selectedLabelStyle:
                    TextStyle(color: Colors.white, fontSize: 10),
                unselectedLabelStyle:
                    TextStyle(color: Colors.grey[700], fontSize: 10),
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.play_circle_outline),
                    label: 'Coming soon',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.file_download),
                    label: 'Downloads',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu),
                    label: 'More',
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _appBarMobile(Size size) {
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: _fadePercentage == 0 ? 0 : 1,
            duration: Duration(milliseconds: 250),
            child: Container(
              height: 50,
              width: size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // ignore: deprecated_member_use
                    Color(0xFF060606).withOpacity(_fadePercentage),
                    // ignore: deprecated_member_use
                    Color(0xFF141414).withOpacity(_fadePercentage),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.network(
                    'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/logo_net.png',
                  ),
                ),
                SizedBox(),
                Text(
                  'TV Shows',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Movies',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'My List',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(Size size) {
    final isTablet = size.width < 1000;
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            // ignore: deprecated_member_use
            Color(0xFF060606).withOpacity(0.8),
            // ignore: deprecated_member_use
            Color(0xFF141414).withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: _fadePercentage == 0 ? 0 : 1,
            duration: Duration(milliseconds: 250),
            child: Container(
              height: 60,
              width: size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // ignore: deprecated_member_use
                    Color(0xFF060606).withOpacity(_fadePercentage),
                    // ignore: deprecated_member_use
                    Color(0xFF141414).withOpacity(_fadePercentage),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Row(
            children: [
              SizedBox(width: 40),
              Container(
                width: 90,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _logo,
              ),
              SizedBox(width: 50),
              Text('Home', style: TextStyle(color: Colors.white)),
              SizedBox(width: 20),
              Text('TV Shows', style: TextStyle(color: Colors.white)),
              SizedBox(width: 20),
              Text('Movies', style: TextStyle(color: Colors.white)),
              SizedBox(width: 20),
              Text('Latest', style: TextStyle(color: Colors.white)),
              SizedBox(width: 20),
              Text('My List', style: TextStyle(color: Colors.white)),
              Expanded(child: SizedBox()),
              if (isTablet)
                Row(
                  children: [
                    CustomPaint(
                      size: Size(30, 30),
                      painter: ProfileFace(color: Utils.mainRed, isSmall: true),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(Icons.search, color: Colors.white, size: 30),
                    SizedBox(width: 25),
                    SizedBox(height: 28, width: 28, child: _gift),
                    SizedBox(width: 25),
                    SizedBox(
                      height: 25,
                      width: 30,
                      child: Stack(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 30,
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Utils.mainRed,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 2,
                              ),
                              child: Text(
                                '9+',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 25),
                    CustomPaint(
                      size: Size(30, 30),
                      painter: ProfileFace(color: Utils.mainRed, isSmall: true),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              SizedBox(width: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topSection(Size size, double scaleFactor) {
    return SizedBox(
      width: size.width,
      height: size.width / 1.78,
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: _hoverPlay,
            child: _video.first,
          ),
          Transform(
            transform: Matrix4.identity()..translate(0, 1),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 2,
                color: Color(0xFF141414),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // ignore: deprecated_member_use
                  colors: [Color(0xFF141414).withOpacity(0), Color(0xFF141414)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          _movieInfo(size, scaleFactor),
        ],
      ),
    );
  }

  Widget _movieInfo(Size size, double scaleFactor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: size.width * 0.06),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: size.width * 0.22,
              child: Image.network(
                'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/bbb_title.png',
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: size.width * 0.3,
              child: Text(
                'Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself.',
                style: TextStyle(color: Colors.white, fontSize: 20),
                // ignore: deprecated_member_use
                textScaleFactor: scaleFactor,
              ),
            ),
            SizedBox(height: 30),
            Transform.scale(
              scale: scaleFactor,
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _playMovie(112),
                  SizedBox(width: 10),
                  Container(
                    width: 150,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Color(0xFF535252),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 26,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'More Info',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topSectionMobile(Size size) {
    return SizedBox(
      width: size.width,
      height: size.height * 0.7,
      child: Stack(
        children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: Opacity(
              opacity: 0.7,
              child: Image.network(
                'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/bbb_top.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Transform(
            transform: Matrix4.identity()..translate(0, 1),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 2,
                color: Color(0xFF141414),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // ignore: deprecated_member_use
                  colors: [Color(0xFF141414).withOpacity(0), Color(0xFF141414)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 250,
                  child: Image.network(
                    'https://s3-us-west-2.amazonaws.com/s.cdpn.io/2399829/bbb_title.png',
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(height: 4),
                        Text(
                          'My List',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    HandCursor(child: _playMovie(100)),
                    Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(height: 4),
                        Text(
                          'Info',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _playMovie(double width) {
    return GestureDetector(
      onTap: () {
        final navigator = Navigator.of(context);
        Future.delayed(Duration(milliseconds: 500), () {
          if (!_video.second.paused) {
            _video.second.pause();
            _video.second.remove();
          }
          navigator.push(MaterialPageRoute(builder: (_) => PlayMovie()));
        });
      },
      child: MouseRegion(
        onHover: (_) => _hoverPlay = true,
        onExit: (_) => _hoverPlay = false,
        child: Container(
          width: width,
          height: 36,
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_arrow,
                color: Colors.black,
                size: 28,
              ),
              SizedBox(width: 5),
              Text(
                'Play',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _movieItem(String url) {
    return SizedBox(
      width: 260,
      height: 150,
      child: Image.network(url, fit: BoxFit.cover),
    );
  }

  static Widget _movieOriginal(String url) {
    return SizedBox(
      width: 260,
      height: 480,
      child: Image.network(url, fit: BoxFit.cover),
    );
  }

  static Widget _movieTop(String url, String index) {
    return SizedBox(
      width: 260,
      height: 240,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 130,
              height: 240,
              child: Image.network(index),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 240,
              width: 130,
              margin: const EdgeInsets.only(right: 15),
              child: Image.network(url, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

class PlayMovie extends StatefulWidget {
  @override
  _PlayMovieState createState() => _PlayMovieState();
}

class _PlayMovieState extends State<PlayMovie> with TickerProviderStateMixin {
  late AnimationController controller;
  bool playing = true;
  bool showFinishAnim = false;

  late FocusNode focusNode;
  static int _movieId = 5;
  final _movie = Utils.video(
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    '${++_movieId}',
    false,
  );

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() => _movie.second.pause());
    focusNode = FocusNode()..requestFocus();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    )
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          setState(() => playing = false);
        }
        if (status == AnimationStatus.completed) {
          scheduleMicrotask(() => _movie.second.play());
        }
      });
  }

  @override
  void dispose() {
    _movie.second.pause();
    _movie.second.currentTime = 0;
    controller.dispose();
    super.dispose();
  }

  Animation<double> getTween(
    double begin,
    double end,
    double intBegin,
    double intEnd, [
    Curve curve = Curves.linear,
  ]) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(intBegin, intEnd, curve: curve),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!playing)
            Column(
              children: [
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(child: SizedBox()),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.close, color: Colors.white, size: 30),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                Expanded(child: _movie.first),
                SizedBox(height: 40),
              ],
            ),
          Visibility(
            visible: playing,
            child: ColoredBox(
              color: Colors.black,
              child: Column(
                children: [
                  SizedBox(height: 70),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        return FadeTransition(
                          opacity: getTween(1.0, 0.0, 0.8, 1.0, Curves.easeOut),
                          child: CustomPaint(
                            painter: NetflixPainter(
                              controller,
                              AnimProps(
                                scale: getTween(
                                  1.0,
                                  20.0,
                                  0.2,
                                  0.7,
                                  Curves.easeInQuint,
                                ),
                                translate: getTween(0.0, 0.2, 0.2, 1.0),
                                secondaryTranslate: getTween(
                                  0.0,
                                  3.0,
                                  0.53,
                                  1.0,
                                  Curves.easeIn,
                                ),
                                leftLegClip: getTween(1.0, 0.0, 0.0, 0.05),
                                middleLegClip: getTween(0.0, 1.0, 0.05, 0.1),
                                rightLegClip: getTween(1.0, 0.0, 0.1, 0.15),
                                middleLegReverseClip:
                                    getTween(0.0, 1.0, 0.44, 0.50),
                                rightLegReverseClip:
                                    getTween(0.0, 1.0, 0.40, 0.45),
                                leftLegOpacity:
                                    getTween(1.0, 0.0, 0.45, 0.7, Curves.ease),
                                middleLegOpacity:
                                    getTween(1.0, 0.0, 0.40, 0.60, Curves.ease),
                                rightLegLinesOffset:
                                    getTween(0.0, 1.0, 0.30, 0.40),
                                leftLegLinesOffset:
                                    getTween(0.0, 1.0, 0.35, 0.60),
                                rainbowOffset: getTween(1.0, 30.0, 0.53, 1.0),
                                showFinishAnim: showFinishAnim,
                              ),
                            ),
                            child: SizedBox(
                              height: size.shortestSide,
                              width: size.shortestSide,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(
                            breakpoint(size.width, 10, 12, 14),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://pbs.twimg'
                              '.com/profile_images/1188517161192558593/gZC6Far3_400x400.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Dominik Roszkowski @OrestesGaolin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: breakpoint(size.width, 16, 14, 12),
                          ),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimProps {
  AnimProps({
    required Animation<double> leftLegClip,
    required Animation<double> middleLegClip,
    required Animation<double> rightLegClip,
    required Animation<double> middleLegReverseClip,
    required Animation<double> rightLegReverseClip,
    required Animation<double> leftLegOpacity,
    required Animation<double> middleLegOpacity,
    required Animation<double> rightLegLinesOffset,
    required Animation<double> leftLegLinesOffset,
    required Animation<double> scale,
    required Animation<double> translate,
    required Animation<double> rainbowOffset,
    required Animation<double> secondaryTranslate,
    required this.showFinishAnim,
  })  : _leftLegClip = leftLegClip,
        _middleLegClip = middleLegClip,
        _rightLegClip = rightLegClip,
        _middleLegReverseClip = middleLegReverseClip,
        _rightLegReverseClip = rightLegReverseClip,
        _leftLegOpacity = leftLegOpacity,
        _middleLegOpacity = middleLegOpacity,
        _rightLegLinesOffset = rightLegLinesOffset,
        _leftLegLinesOffset = leftLegLinesOffset,
        _scale = scale,
        _translate = translate,
        _secondaryTranslate = secondaryTranslate,
        _rainbowOffset = rainbowOffset;

  final Animation<double> _leftLegClip;
  final Animation<double> _middleLegClip;
  final Animation<double> _rightLegClip;
  final Animation<double> _middleLegReverseClip;
  final Animation<double> _rightLegReverseClip;
  final Animation<double> _leftLegOpacity;
  final Animation<double> _middleLegOpacity;
  final Animation<double> _rightLegLinesOffset;
  final Animation<double> _leftLegLinesOffset;
  final Animation<double> _scale;
  final Animation<double> _translate;
  final Animation<double> _secondaryTranslate;
  final Animation<double> _rainbowOffset;
  final bool showFinishAnim;

  double get leftLegClip => _leftLegClip.value;
  double get middleLegClip =>
      _middleLegClip.value - _middleLegReverseClip.value;
  double get rightLegClip => _rightLegClip.value + _rightLegReverseClip.value;
  double get leftLegOpacity => _leftLegOpacity.value;
  double get middleLegOpacity => _middleLegOpacity.value;
  double get rightLegLinesOffset => _rightLegLinesOffset.value;
  double get leftLegLinesOffset => _leftLegLinesOffset.value;
  double get scale => _scale.value;
  double get translate => _translate.value;
  double get secondaryTranslate => _secondaryTranslate.value;
  double get rightLegReverseClip => _rightLegReverseClip.value;
  double get rainbowOffset => _rainbowOffset.value;
}

// Dominik Roszkowski, thank you! Amazing work!
// Follow: https://twitter.com/OrestesGaolin
class NetflixPainter extends CustomPainter {
  final legWidth = 355.0;
  final letterWidth = 990.0;
  final letterHeight = 1800.0;
  final bottomArcHeight = 35.0;

  final redPaint = Paint()
    ..color = NetflixColors.netflixRed
    ..style = PaintingStyle.fill;
  final darkRredPaint = Paint()
    ..color = NetflixColors.netflixDarkRed
    ..style = PaintingStyle.fill;

  List<ui.Color?> rainbowColors = [
    Colors.red[900],
    Colors.red[900],
    Colors.red[900],
    Colors.green[200],
    Colors.red[900],
    Colors.red[900],
    Colors.red[900],
    Colors.red[900],
    Colors.yellow,
    Colors.red[900],
    Colors.red[900],
    Colors.yellow[800],
    Colors.pink,
    Colors.red[700],
    Colors.yellow[800],
    Colors.pink[300],
    Colors.purple[200],
    Colors.yellow[800],
    Colors.red[900],
    Colors.red[900],
    Colors.red[900],
    Colors.red[900],
    Colors.pink[100],
    Colors.red[700],
    Colors.yellow[500],
    Colors.red[900],
    Colors.red[900],
    Colors.blue[200],
    Colors.red[900],
    Colors.blue[300],
    Colors.blue[200],
    Colors.red[900],
    Colors.red[900],
    Colors.blue,
    Colors.blue[400],
  ];

  final AnimProps anim;

  NetflixPainter(AnimationController controller, this.anim)
      : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / letterHeight;

    canvas.translate(
      size.width / 2 - letterWidth * scale / 4 - anim.translate * size.width,
      size.height / 2 - letterHeight * scale / 4 * anim.scale,
    );
    canvas.translate(-anim.secondaryTranslate * size.width, 0);
    canvas.scale(scale / 2);
    canvas.scale(anim.scale);

    canvas.save();

    final leftLegOffset = anim.leftLegClip * letterHeight;
    final rightLegOffset = anim.rightLegClip * letterHeight;
    final topLeft = Offset(0.0, leftLegOffset);
    final bottomRightFirstLeg = Offset(legWidth, letterHeight);
    final bottomRight = Offset(letterWidth, letterHeight);
    final xRightLeg = letterWidth - legWidth;
    final topLeftSecondLeg = Offset(xRightLeg, rightLegOffset);

    final leftLeg = Rect.fromPoints(topLeft, bottomRightFirstLeg);
    final rightLeg = Rect.fromPoints(topLeftSecondLeg, bottomRight);

    _clipBottom(canvas);
    _drawLeftLeg(canvas, leftLeg);
    _drawRightLeg(canvas, rightLeg, xRightLeg);
    _drawMiddlePathWithShadow(canvas, xRightLeg);
    canvas.restore();
  }

  void _clipBottom(Canvas canvas) {
    final bottomArcClipPath = Path()
      ..moveTo(0, letterHeight)
      ..quadraticBezierTo(
        letterWidth / 2,
        letterHeight - 2 * bottomArcHeight,
        letterWidth,
        letterHeight,
      )
      ..lineTo(letterWidth, 0)
      ..lineTo(0, 0)
      ..lineTo(0, letterHeight);
    canvas.clipPath(bottomArcClipPath);
  }

  void _drawMiddlePathWithShadow(Canvas canvas, double xRightLeg) {
    if (anim.middleLegOpacity > 0) {
      canvas.save();
      final middleLegOffset = anim.middleLegClip * letterHeight;
      final middleLeg = Path()
        ..moveTo(0, 0)
        ..lineTo(xRightLeg, letterHeight)
        ..lineTo(letterWidth, letterHeight)
        ..lineTo(legWidth, 0)
        ..close();
      final middleLegClipPath =
          Rect.fromLTWH(0, 0, letterWidth, middleLegOffset);
      final shadowPath = Path()
        ..moveTo(20, 0)
        ..lineTo(xRightLeg - 70, letterHeight)
        ..lineTo(letterWidth - 20, letterHeight)
        ..lineTo(legWidth + 70, 0)
        ..close();
      final shadowPaint = Paint()
        // ignore: deprecated_member_use
        ..color = Colors.black.withOpacity(anim.middleLegOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30);
      final middleLegPaint = Paint()
        ..color =
            // ignore: deprecated_member_use
            NetflixColors.netflixDarkRed.withOpacity(anim.middleLegOpacity);
      canvas.clipRect(middleLegClipPath);
      canvas.drawPath(shadowPath, shadowPaint);
      canvas.drawPath(middleLeg, middleLegPaint);
      drawMiddleLines(xRightLeg, canvas);

      canvas.restore();
    }
  }

  void drawMiddleLines(double xRightLeg, Canvas canvas) {
    if (anim.middleLegOpacity > 0) {
      final gradientPaint = LinearGradient(
        colors: [Colors.black, Colors.transparent],
        stops: [0.0, 1.0],
        begin: Alignment.bottomRight,
        end: Alignment.topCenter,
      );

      final steps = [20, 55, 80, 180, 190, 205, 280, 300];
      final stepsE = [10, 5, 10, 10, 20, 5, 10, 15];
      final start = (1 - anim.rightLegLinesOffset) * letterHeight;
      final middleLegLinePath =
          Rect.fromLTWH(0, start, letterWidth, letterHeight);
      for (var i = 0; i < steps.length; i++) {
        final xTop = 20.0 + steps[i];
        final xBottom = xRightLeg + steps[i];
        final middleLinePath = Path()
          ..moveTo(xTop, 0)
          ..lineTo(xBottom, letterHeight)
          ..lineTo(xBottom + stepsE[i], letterHeight)
          ..lineTo(xTop + stepsE[i], 0)
          ..close();
        canvas.drawPath(
          middleLinePath,
          Paint()
            ..shader = gradientPaint.createShader(middleLegLinePath)
            ..maskFilter = MaskFilter.blur(BlurStyle.outer, 3),
        );
      }
    }
  }

  void _drawRightLeg(Canvas canvas, Rect rightLeg, double xRightLeg) {
    canvas.save();
    canvas.drawRect(rightLeg, darkRredPaint);
    final gradientPaint = LinearGradient(
      colors: [Colors.black, Colors.transparent],
      stops: [0.0, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final rightLegGradientOffset = letterHeight * anim.rightLegLinesOffset;
    final steps = [20, 55, 80, 180, 280, 300];
    final stepsE = [25, 60, 120, 230, 290, 340];
    for (var i = 0; i < steps.length; i++) {
      final rightShadowPath = Rect.fromLTRB(
        xRightLeg + steps[i],
        0,
        xRightLeg + stepsE[i],
        rightLegGradientOffset,
      );
      canvas.drawRect(
        rightShadowPath,
        Paint()
          ..shader = gradientPaint.createShader(rightShadowPath)
          ..maskFilter = MaskFilter.blur(BlurStyle.outer, 3),
      );
    }
    final rightLegGradient = Rect.fromLTWH(
      rightLeg.left - 2,
      rightLeg.top - 2,
      rightLeg.width + 4,
      rightLegGradientOffset - 120,
    );
    canvas.drawRect(
      rightLegGradient,
      Paint()..shader = gradientPaint.createShader(rightLegGradient),
    );
    canvas.restore();
  }

  void _drawLeftLeg(Canvas canvas, Rect leftLeg) {
    canvas.save();
    if (anim.leftLegOpacity > 0) {
      final leftLegPaint = Paint()
        // ignore: deprecated_member_use
        ..color = NetflixColors.netflixDarkRed.withOpacity(anim.leftLegOpacity);

      canvas.drawRect(
        leftLeg,
        leftLegPaint,
      );
    }

    if (anim.showFinishAnim == true) {
      if (anim.leftLegOpacity < 1) {
        canvas.save();

        for (var i = 0; i < 30; i++) {
          final rect = Rect.fromLTWH(
            (0.0 + i * 15.0) % legWidth * anim.rainbowOffset,
            0,
            i % 10.0,
            letterHeight,
          );
          canvas.drawRect(
            rect,
            Paint()
              ..color = rainbowColors[i % rainbowColors.length]!
                  // ignore: deprecated_member_use
                  .withOpacity(1.0 - anim.leftLegOpacity)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3),
          );
        }
        canvas.restore();
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class NetflixColors {
  static const Color netflixRed = Color(0xFFE50914);
  static const Color netflixDarkRed = Color(0xFFB20710);
}

Input breakpoint<Input>(
  double input,
  Input desktop,
  Input tablet,
  Input mobile,
) {
  if (input > 1000) {
    return desktop;
  } else if (input > 650 && input < 1000) {
    return tablet;
  } else {
    return mobile;
  }
}

// https://gist.github.com/slightfoot/37d3a9bde249c6660aeeb8ca9fc089b3
class HandCursor extends StatelessWidget {
  const HandCursor({
    super.key,
    this.onHover,
    this.enabled = true,
    required this.child,
  });

  final ValueChanged<bool>? onHover;
  final bool enabled;
  final Widget child;

  void _onHover(PointerHoverEvent evt) {
    html.window.document.documentElement!.style.cursor = 'pointer';
    onHover?.call(true);
  }

  void _onExit(PointerExitEvent evt) {
    html.window.document.documentElement!.style.cursor = 'auto';
    onHover?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: enabled ? _onHover : null,
      onExit: enabled ? _onExit : null,
      child: child,
    );
  }
}

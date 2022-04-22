import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';
import 'package:wiredash_example/marianos_clones/whatsapp_clone.dart';

void main() {
  runApp(const CustomizerApp());
}

class CustomizerApp extends StatelessWidget {
  const CustomizerApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.lightBlue,
      ),
      home: const CustomizePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CustomizePage extends StatefulWidget {
  const CustomizePage({Key? key}) : super(key: key);

  @override
  State<CustomizePage> createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: MinSize(
        minWidth: 800,
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: ThemeControls(),
              ),
            ),
            Material(
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                  left: 16,
                  top: 8,
                  bottom: 8,
                ),
                child: DeviceFrame(
                  child: WhatsApp(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ThemeControls extends StatelessWidget {
  const ThemeControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Primary Color'),
        ],
      ),
    );
  }
}

class DeviceFrame extends StatelessWidget {
  const DeviceFrame({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.black,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 22,
          bottom: 16,
          left: 10,
          right: 10,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  ),
                ),
                child: PrimaryScrollController(
                  controller: ScrollController(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Wiredash(
                      projectId: "Project ID from console.wiredash.io",
                      secret: "API Key from console.wiredash.io",
                      child: child,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Starts scrolling [child] vertically and horizontally when the widget sizes
/// reaches below [minWidth] or [minHeight]
class MinSize extends StatefulWidget {
  const MinSize({
    Key? key,
    this.minWidth,
    this.minHeight,
    required this.child,
  }) : super(key: key);

  final Widget child;

  final double? minWidth;

  final double? minHeight;

  @override
  State<MinSize> createState() => _MinSizeState();
}

class _MinSizeState extends State<MinSize> {
  late final _verticalController = ScrollController();
  late final _horizontalController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldScrollVertical = widget.minHeight != null &&
            constraints.maxHeight <= widget.minHeight!;
        final contentHeight =
            shouldScrollVertical ? widget.minHeight : constraints.maxHeight;
        final verticalPhysics = shouldScrollVertical
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics();

        final shouldScrollHorizontal =
            widget.minWidth != null && constraints.maxWidth <= widget.minWidth!;
        final contentWidth =
            shouldScrollHorizontal ? widget.minWidth : constraints.maxWidth;
        final horizontalPhysics = shouldScrollHorizontal
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics();

        return Scrollbar(
          controller: _verticalController,
          thumbVisibility: shouldScrollVertical,
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            physics: verticalPhysics,
            child: Scrollbar(
              interactive: true,
              controller: _horizontalController,
              thumbVisibility: shouldScrollHorizontal,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                physics: horizontalPhysics,
                child: UnconstrainedBox(
                  child: SizedBox(
                    height: contentHeight,
                    width: contentWidth,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

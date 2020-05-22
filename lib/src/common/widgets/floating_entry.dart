import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/wiredash_widget.dart';

class FloatingEntry extends StatefulWidget {
  final Widget child;

  const FloatingEntry({Key key, this.child}) : super(key: key);

  @override
  _FloatingEntryState createState() => _FloatingEntryState();
}

class _FloatingEntryState extends State<FloatingEntry> {
  Offset _position;

  bool showHandle = true;
  bool isDragging = false;

  void calculateRecyclePosition(Size biggestConstrains) {
    final removeArea = biggestConstrains.bottomLeft(Offset.zero);
    final shouldShowHandle = (removeArea - _position).distance > 100;

    if (shouldShowHandle != showHandle) {
      showHandle = shouldShowHandle;
      scheduleMicrotask(() {
        setState(() {
          // Update handle state
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        _position ??= constrains.biggest.bottomRight(-const Offset(72, 144));
        calculateRecyclePosition(constrains.biggest);

        return Stack(
          children: <Widget>[
            widget.child,
            if (WiredashOptions.of(context).showDebugFloatingEntryPoint) ...[
              Align(
                alignment: Alignment.bottomLeft,
                child: AnimatedOpacity(
                  opacity: isDragging ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.fastOutSlowIn,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                          Colors.transparent
                        ],
                      ),
                    ),
                    height: 100,
                    width: 100,
                    alignment: Alignment.bottomLeft,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(
                        WiredashIcons.trashcan,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _position.dx,
                top: _position.dy,
                child: Selector<FeedbackModel, FeedbackUiState>(
                  selector: (context, feedbackModel) =>
                      feedbackModel.feedbackUiState,
                  builder: (_, feedbackUiState, __) {
                    return FloatingHandle(
                      visible: showHandle &&
                          feedbackUiState == FeedbackUiState.hidden,
                      onTap: Wiredash.of(context).show,
                      onDragStart: () {
                        setState(() {
                          isDragging = true;
                        });
                      },
                      onDragEnd: () {
                        setState(() {
                          isDragging = false;
                        });
                      },
                      onDragUpdate: (details) {
                        setState(() {
                          _position =
                              details.globalPosition - const Offset(28, 28);
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class FloatingHandle extends StatefulWidget {
  final bool visible;
  final Function() onTap;
  final Function() onDragStart;
  final Function() onDragEnd;
  final Function(DragUpdateDetails) onDragUpdate;

  const FloatingHandle(
      {Key key,
      this.visible,
      this.onTap,
      this.onDragUpdate,
      this.onDragStart,
      this.onDragEnd})
      : super(key: key);

  @override
  _FloatingHandleState createState() => _FloatingHandleState();
}

class _FloatingHandleState extends State<FloatingHandle>
    with SingleTickerProviderStateMixin {
  final _curvedInterval = const Interval(0.4, 1.0, curve: Curves.elasticOut);

  AnimationController _animationController;
  bool _elevated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FloatingHandle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible) {
      _animationController.forward();
    } else {
      _animationController.reverse(from: 0.0);
    }
  }

  void _elevate(_) {
    setState(() {
      _elevated = true;
      widget.onDragStart();
    });
  }

  void _lower(_) {
    setState(() {
      _elevated = false;
      widget.onDragEnd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(
              _curvedInterval.transform(_animationController.value),
            ),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _elevate,
        onTapUp: _lower,
        onPanUpdate: widget.onDragUpdate,
        onPanEnd: _lower,
        child: Opacity(
          opacity: 0.85,
          child: Material(
            shape: const StadiumBorder(),
            elevation: _elevated ? 12 : 6,
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    WiredashTheme.of(context).primaryColor,
                    WiredashTheme.of(context).secondaryColor,
                  ],
                ),
              ),
              child: Image.asset(
                'assets/images/logo_white.png',
                package: 'wiredash',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

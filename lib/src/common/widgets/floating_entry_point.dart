import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/wiredash_widget.dart';

class FloatingEntryPoint extends StatefulWidget {
  final Widget child;

  const FloatingEntryPoint({Key key, this.child}) : super(key: key);

  @override
  _FloatingEntryPointState createState() => _FloatingEntryPointState();
}

class _FloatingEntryPointState extends State<FloatingEntryPoint> {
  Offset _position;
  bool _isButtonDiscarded = false;
  bool _isDragging = false;

  void calculateRecyclePosition(Size biggestConstrains) {
    final removeArea = biggestConstrains.bottomLeft(Offset.zero);
    final isButtonDiscarded = (removeArea - _position).distance <= 100;

    if (_isButtonDiscarded != isButtonDiscarded) {
      _isButtonDiscarded = isButtonDiscarded;
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
              IgnorePointer(
                ignoring: !_isDragging || _isButtonDiscarded,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: _buildDiscardCorner(),
                ),
              ),
              Positioned(
                left: _position.dx,
                top: _position.dy,
                child: _buildFloatingButton(),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDiscardCorner() {
    return AnimatedOpacity(
      opacity: _isDragging ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Colors.black54, Colors.transparent, Colors.transparent],
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
    );
  }

  Widget _buildFloatingButton() {
    return Selector<FeedbackModel, FeedbackUiState>(
      selector: (context, feedbackModel) => feedbackModel.feedbackUiState,
      builder: (context, feedbackUiState, __) {
        return FloatingButton(
          isVisible:
              !_isButtonDiscarded && feedbackUiState == FeedbackUiState.hidden,
          onTap: Wiredash.of(context).show,
          onDragStart: () {
            setState(() {
              _isDragging = true;
            });
          },
          onDragEnd: () {
            setState(() {
              _isDragging = false;
            });
          },
          onDragUpdate: (details) {
            setState(() {
              _position = details.globalPosition - const Offset(28, 28);
            });
          },
        );
      },
    );
  }
}

class FloatingButton extends StatefulWidget {
  final bool isVisible;
  final Function() onTap;
  final Function() onDragStart;
  final Function() onDragEnd;
  final Function(DragUpdateDetails) onDragUpdate;

  const FloatingButton({
    Key key,
    this.isVisible,
    this.onTap,
    this.onDragUpdate,
    this.onDragStart,
    this.onDragEnd,
  }) : super(key: key);

  @override
  _FloatingButtonState createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton>
    with SingleTickerProviderStateMixin {
  final _curvedInterval = const Interval(0.4, 1.0, curve: Curves.elasticOut);

  AnimationController _animationController;
  bool _isDragging = false;

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
  void didUpdateWidget(FloatingButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible) {
      _animationController.forward();
    } else {
      _animationController.reverse(from: _isDragging ? null : 0.0);
    }
  }

  void _elevate(_) {
    setState(() {
      _isDragging = true;
      widget.onDragStart();
    });
  }

  void _lower(_) {
    setState(() {
      _isDragging = false;
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
            elevation: _isDragging ? 12 : 6,
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
                width: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

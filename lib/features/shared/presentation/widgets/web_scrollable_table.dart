import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Vertically scrollable web table with a visible scrollbar.
///
/// Arrow Up/Down, Page Up/Down, Home, and End move the table when it is
/// focused. Click the table to focus it.
class WebScrollableTable extends StatefulWidget {
  final List<Widget> children;
  final double minWidth;
  final bool enableHorizontalScroll;

  const WebScrollableTable({
    super.key,
    required this.children,
    this.minWidth = 0,
    this.enableHorizontalScroll = true,
  });

  @override
  State<WebScrollableTable> createState() => _WebScrollableTableState();
}

class _WebScrollableTableState extends State<WebScrollableTable> {
  final ScrollController _verticalController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _verticalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!_verticalController.hasClients) {
      return KeyEventResult.ignored;
    }

    final position = _verticalController.position;
    final lineDelta = 56.0;
    final pageDelta = (position.viewportDimension * 0.9).clamp(120.0, 720.0);
    double? target;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      target = position.pixels + lineDelta;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      target = position.pixels - lineDelta;
    } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      target = position.pixels + pageDelta;
    } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      target = position.pixels - pageDelta;
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      target = 0;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      target = position.maxScrollExtent;
    }

    if (target == null) {
      return KeyEventResult.ignored;
    }

    _verticalController.animateTo(
      target.clamp(0, position.maxScrollExtent),
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
    );
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;
        final tableWidth = constraints.maxWidth < widget.minWidth
            ? widget.minWidth
            : constraints.maxWidth;

        Widget table = Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.children,
        );

        if (widget.enableHorizontalScroll && widget.minWidth > 0) {
          table = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: tableWidth, child: table),
          );
        }

        final scroller = Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          trackVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalController,
            primary: false,
            child: table,
          ),
        );

        final focused = Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKey,
          child: GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            behavior: HitTestBehavior.opaque,
            child: scroller,
          ),
        );

        if (!hasBoundedHeight) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 520),
            child: focused,
          );
        }

        return SizedBox(height: constraints.maxHeight, child: focused);
      },
    );
  }
}

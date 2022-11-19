import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/models/constants.dart';
import 'package:xterm/core.dart';
import 'package:xterm/ui.dart';

abstract class TerminalAxis {
  static const row = Axis.vertical;
  static const column = Axis.horizontal;
}

/// Infinite Root Tree (IRT) Algorithm
/// for holding all the terminal instance
class TerminalNode {
  final Set<TerminalNode> _children;

  final Terminal terminal;
  final TerminalController controller;
  final FocusNode focusNode;

  /// Axis/Direction of the Node
  Axis axis;

  List<TerminalNode> get children => _children.toList();

  bool get isLeaf => _children.isEmpty;

  /// Indication of whether the terminal is a root in the tree
  /// It's basically a root node in a General Tree
  bool get isRoot => parent == null;

  /// Custom property to separate all the children that are "not in" the group of the parent
  List<TerminalNode> get obedientChildren =>
      children.where((child) => child.parentAxis == axis).toList();

  /// Custom property to separate all the children that are "in" the group of the parent
  List<TerminalNode> get disobedientChildren =>
      children.where((child) => child.parentAxis != axis).toList();

  TerminalNode? parent;

  /// When Terminal is split in Grouper, it's assigned to allow deciding the axis of the child
  Axis? parentAxis;

  /// For notifying the tree for any changes
  final VoidCallback updateTree;

  TerminalNode({
    required this.updateTree,
    this.parent,
    this.parentAxis,
    this.axis = TerminalAxis.row,
    List<TerminalNode>? children,
    Terminal? terminal,
    TerminalController? controller,
    FocusNode? focusNode,
  })  : controller = controller ?? TerminalController(),
        _children = children?.toSet() ?? {},
        terminal = terminal ?? Constants.terminal(),
        focusNode = focusNode ?? FocusNode(),
        assert((parent == null && parentAxis == null) ||
            (parent != null && parentAxis != null));

  void addChild(TerminalNode child) {
    if (child.parent != this) {
      throw Exception("Can't add other parent's child to this node");
    }
    _children.add(child);
    updateTree();
  }

  void removeChild(TerminalNode child) {
    if (child.parent != this) {
      throw Exception("Can't remove other parent's child from this node");
    }
    if (!child.isLeaf) {
      for (var d2Child in child.children) {
        d2Child.parent = this;
        d2Child.parentAxis = axis;
        addChild(d2Child);
      }
    }
    child.dispose();
    _children.remove(child);

    updateTree();
  }

  void setDefaultAxis(Axis axis) {
    this.axis = axis;
    updateTree();
  }

  void split(Axis axis) {
    if (isLeaf) {
      this.axis = axis;
    }
    final node = TerminalNode(
      updateTree: updateTree,
      parentAxis: axis,
      parent: this,
    );
    addChild(node);
    updateTree();
    node.focusNode.requestFocus();
  }

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class TerminalTree with ChangeNotifier {
  final Ref<TerminalTree> ref;

  TerminalTree(this.ref) : _nodes = {};

  static final provider = ChangeNotifierProvider((ref) => TerminalTree(ref));

  final Set<TerminalNode> _nodes;

  List<TerminalNode> get nodes => _nodes.toList();

  TerminalNode? focused;

  TerminalNode? active;
  int? get activeIndex => active != null ? nodes.indexOf(active!) : null;

  void addNode(TerminalNode node) {
    if (node.isRoot) {
      _nodes.add(node);
      notifyListeners();
    }
  }

  void removeNode(TerminalNode node) {
    if (node == active) {
      active = null;
    }
    node.dispose();
    _nodes.remove(node);
    notifyListeners();
  }

  TerminalNode createNewTerminalTab([String? shell]) {
    final node = TerminalNode(
      updateTree: notifyListeners,
      terminal: Constants.terminal(shell),
    );
    addNode(node);
    active = node;
    node.focusNode.requestFocus();
    return node;
  }

  void closeTerminalTab([TerminalNode? node]) {
    if (_nodes.length <= 1 || !_nodes.contains(node ?? active)) return;
    // closes the Tab/Removes the tab
    removeNode(
      node ?? active!,
    );
    setActiveRoot(_nodes.last);
    active?.focusNode.requestFocus();
  }

  int cycleForwardTerminalTab() {
    int index = nodes.length - 1 == activeIndex ? 0 : activeIndex! + 1;
    setActiveRoot(nodes.elementAt(index));
    active?.focusNode.requestFocus();
    return index;
  }

  int cycleBackwardTerminalTab() {
    int index = activeIndex == 0 ? nodes.length - 1 : activeIndex! - 1;
    setActiveRoot(nodes.elementAt(index));
    active?.focusNode.requestFocus();
    return index;
  }

  void setActiveRoot(TerminalNode node) {
    if (_nodes.contains(node)) {
      active = node;
      notifyListeners();
    }
  }

  void setFocused(TerminalNode node) {
    focused = node;
    notifyListeners();
  }
}

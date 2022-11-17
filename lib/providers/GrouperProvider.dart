import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tuple/tuple.dart';
import 'package:wives/models/terminal_piece.dart';

class GrouperNode with ChangeNotifier {
  final Ref ref;
  String id;
  String? parent;

  Axis? direction;
  Axis? innerDirection;
  List<TerminalPiece>? group;
  List<TerminalPiece>? innerGroup;

  GrouperNode({
    required this.ref,
    required this.id,
    this.parent,
    this.direction,
    this.innerDirection,
    this.group,
    this.innerGroup,
  }) : super();

  void splitHorizontally() {
    if (direction == null || direction == Axis.vertical) {
      direction ??= Axis.vertical;
      group = [...?group, TerminalPiece()];
    } else {
      innerDirection = Axis.vertical;
      innerGroup = [...?innerGroup, TerminalPiece()];
    }
    notifyListeners();
  }

  void splitVertically() {
    if (direction == null || direction == Axis.horizontal) {
      direction = Axis.horizontal;
      group = [...?group, TerminalPiece()];
    } else {
      innerDirection = Axis.horizontal;
      innerGroup = [...?innerGroup, TerminalPiece()];
    }
    notifyListeners();
  }

  List<GrouperNode> get children {
    final childrenIds =
        ref.read(grouperNodeSkeletonProvider).findChildrenOf(id);
    return childrenIds
        .map((child) => ref.read(grouperNodeProvider(Tuple2(id, child))))
        .toList();
  }

  void removeInnerGroupTerminal(TerminalPiece terminal) {
    innerGroup?.remove(terminal);
    notifyListeners();
  }

  void removeGroupTerminal(TerminalPiece terminal) {
    group?.remove(terminal);
    notifyListeners();
  }

  @override
  void dispose() {
    ref.read(grouperNodeSkeletonProvider).removeNode(Tuple2(id, parent));
    super.dispose();
  }
}

class GrouperNodeSkeleton extends ChangeNotifier {
  Set<Tuple2<String, String?>> nodes = {};

  void addNode(Tuple2<String, String?> node) {
    nodes.add(node);
    notifyListeners();
  }

  void removeNode(Tuple2<String, String?> node) {
    nodes.remove(node);
    notifyListeners();
  }

  List<String> findChildrenOf(String? parent) {
    return nodes
        .where((element) => element.item2 == parent)
        .map((s) => s.item1)
        .toList();
  }

  String? findParentOf(String id) {
    return nodes.firstWhere((element) => element.item1 == id).item2;
  }
}

final grouperNodeSkeletonProvider = ChangeNotifierProvider<GrouperNodeSkeleton>(
  (ref) => GrouperNodeSkeleton(),
);

final grouperNodeProvider = ChangeNotifierProvider.autoDispose
    .family<GrouperNode, Tuple2<String, String?>>((ref, id) {
  return GrouperNode(ref: ref, id: id.item1, parent: id.item2);
});

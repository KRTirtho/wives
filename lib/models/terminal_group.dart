import 'package:wives/models/terminal_piece.dart';

class TerminalGroup {
  List<TerminalPiece> horizontalTerminals;
  List<TerminalPiece> verticalTerminals;

  final TerminalPiece active;

  TerminalGroup({
    this.horizontalTerminals = const [],
    this.verticalTerminals = const [],
  })  : assert(
          horizontalTerminals.isNotEmpty || verticalTerminals.isNotEmpty,
          "Both horizontal and vertical terminals cannot be empty",
        ),
        active = horizontalTerminals.isNotEmpty
            ? horizontalTerminals.first
            : verticalTerminals.first;
}

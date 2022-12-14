import 'dart:convert';
import 'dart:io';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:riverpod/riverpod.dart';
import 'package:wives/providers/preferences_provider.dart';
import 'package:wives/providers/terminal_tree.dart';
import 'package:wives/services/native.dart';
import 'package:xterm/xterm.dart';

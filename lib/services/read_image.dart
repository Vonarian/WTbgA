import 'dart:convert';
import 'dart:io';

// import 'package:path/path.dart' as p;
//
// String path = p.dirname(Platform.resolvedExecutable);

Future<String> getFileAsBase64String(String path) =>
    File(path).openRead().transform(base64.encoder).join();

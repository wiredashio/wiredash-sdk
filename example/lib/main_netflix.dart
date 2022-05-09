import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wiredash/wiredash.dart';
import 'package:wiredash_example/marianos_clones/netflix_clone.dart';

void main() {
  final app = Wiredash(
    projectId: "Project ID from console.wiredash.io",
    secret: "API Key from console.wiredash.io",
    child: Netflix(),
    // No theming here, the theme is inherited from context when calling
    // Wiredash.of(context).show(inheritMaterialTheme: true)
  );
  runApp(app);
}

import 'package:flutter/cupertino.dart';
import 'package:wiredash/wiredash.dart';
import 'package:wiredash_example/marianos_clones/whatsapp_clone.dart';

void main() {
  final app = Wiredash(
    projectId: "Project ID from console.wiredash.io",
    secret: "API Key from console.wiredash.io",
    theme: WiredashThemeData(
      primaryColor: WhatsappUtils.appBarMobile,
      secondaryColor: WhatsappUtils.softGreen,
      primaryBackgroundColor: WhatsappUtils.chatBackground,
      secondaryBackgroundColor: WhatsappUtils.chatBackground2,
    ),
    child: WhatsApp(),
  );
  runApp(app);
}

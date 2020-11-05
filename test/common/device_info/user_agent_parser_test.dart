import 'package:flutter/foundation.dart';
import 'package:test/test.dart';
import 'package:wiredash/src/common/device_info/user_agent_parser.dart';

void main() {
  group('UserAgentParser', () {
    group('Browser Parsing', () {
      for (final config in _browserTestConfigs) {
        test(config.title, () {
          final parser = UserAgentParser(config.ua);

          expect(parser.browserName, config.name);
          expect(parser.browserVersion, config.version);
        });
      }
    });
  });
}

const _browserTestConfigs = [
  _TestConfig(
    title: "Android Browser on Galaxy Nexus",
    ua: "Mozilla/5.0 (Linux; U; Android 4.0.2; en-us; Galaxy Nexus Build/ICL53F) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
    name: "Android Browser",
    version: "4.0",
  ),
  _TestConfig(
    title: "Android Browser on Galaxy S3",
    ua: "Mozilla/5.0 (Linux; Android 4.4.4; en-us; SAMSUNG GT-I9300I Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Version/1.5 Chrome/28.0.1500.94 Mobile Safari/537.36",
    name: "Android Browser",
    version: "1.5",
  ),
  _TestConfig(
    title: "Android Browser on HTC Flyer (P510E)",
    ua: "Mozilla/5.0 (Linux; U; Android 3.2.1; ru-ru; HTC Flyer P510e Build/HTK75C) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13",
    name: "Android Browser",
    version: "4.0",
  ),
  _TestConfig(
    title: "Android Browser on Huawei Honor Glory II (U9508)",
    ua: "Mozilla/5.0 (Linux; U; Android 4.0.4; ru-by; HUAWEI U9508 Build/HuaweiU9508) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30 ACHEETAHI/2100050044",
    name: "Android Browser",
    version: "4.0",
  ),
  _TestConfig(
    title: "Android Browser on Huawei P8 (H891L)",
    ua: "Mozilla/5.0 (Linux; Android 4.4.4; HUAWEI H891L Build/HuaweiH891L) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36",
    name: "Android Browser",
    version: "4.0",
  ),
  _TestConfig(
    title: "Android Browser on Samsung S6 (SM-G925F)",
    ua: "Mozilla/5.0 (Linux; Android 5.0.2; SAMSUNG SM-G925F Build/LRX22G) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/3.0 Chrome/38.0.2125.102 Mobile Safari/537.36",
    name: "Samsung Browser",
    version: "3.0",
  ),
  _TestConfig(
    title: "Sailfish Browser",
    ua: "Mozilla/5.0 (Linux; U; Sailfish 3.0; Mobile; rv:45.0) Gecko/45.0 Firefox/45.0 SailfishBrowser/1.0",
    name: "Sailfish Browser",
    version: "1.0",
  ),
  _TestConfig(
    title: "Arora",
    ua: "Mozilla/5.0 (Windows; U; Windows NT 5.1; de-CH) AppleWebKit/523.15 (KHTML, like Gecko, Safari/419.3) Arora/0.2",
    name: "Arora",
    version: "0.2",
  ),
  _TestConfig(
    title: "Avast Secure Browser",
    ua: "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36 Avast/72.0.1174.122",
    name: "Avast Secure Browser",
    version: "72.0.1174.122",
  ),
  _TestConfig(
    title: "AVG Secure Browser",
    ua: "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36 AVG/72.0.719.123",
    name: "AVG Secure Browser",
    version: "72.0.719.123",
  ),
  _TestConfig(
    title: "Baidu",
    ua: "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; baidubrowser 1.x)",
    name: "baidubrowser",
    version: "1.x",
  ),
  _TestConfig(
    title: "Bolt",
    ua: "Mozilla/5.0 (X11; 78; CentOS; US-en) AppleWebKit/527+ (KHTML, like Gecko) Bolt/0.862 Version/3.0 Safari/523.15",
    name: "Bolt",
    version: "0.862",
  ),
  _TestConfig(
    title: "Bowser",
    ua: "Mozilla/5.0 (iOS; like Mac OS X) AppleWebKit/536.36 (KHTML, like Gecko) not Chrome/27.0.1500.95 Mobile/10B141 Safari/537.36 Bowser/0.2.1",
    name: "Bowser",
    version: "0.2.1",
  ),
  _TestConfig(
    title: "Camino",
    ua: "Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10.4; en; rv:1.9.0.19) Gecko/2011091218 Camino/2.0.9 (like Firefox/3.0.19)",
    name: "Camino",
    version: "2.0.9",
  ),
  _TestConfig(
    title: "Chimera",
    ua: "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; pl-PL; rv:1.0.1) Gecko/20021111 Chimera/0.6",
    name: "Chimera",
    version: "0.6",
  ),
  _TestConfig(
    title: "Chrome",
    ua: "Mozilla/5.0 (Windows NT 6.2) AppleWebKit/536.6 (KHTML, like Gecko) Chrome/20.0.1090.0 Safari/536.6",
    name: "Chrome",
    version: "20.0.1090.0",
  ),
  _TestConfig(
    title: "Chrome Headless",
    ua: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome Safari/537.36",
    name: "Chrome Headless",
    version: 'Unknown Web Browser Version',
  ),
  _TestConfig(
    title: "Chrome Headless",
    ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/60.0.3112.113 Safari/537.36",
    name: "Chrome Headless",
    version: "60.0.3112.113",
  ),
  _TestConfig(
    title: "Chrome WebView",
    ua: "Mozilla/5.0 (Linux; Android 5.1.1; Nexus 5 Build/LMY48B; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/43.0.2357.65 Mobile Safari/537.36",
    name: "Chrome WebView",
    version: "43.0.2357.65",
  ),
  _TestConfig(
    title: "Chrome on iOS",
    ua: "Mozilla/5.0 (iPhone; U; CPU iPhone OS 5_1_1 like Mac OS X; en) AppleWebKit/534.46.0 (KHTML, like Gecko) CriOS/19.0.1084.60 Mobile/9B206 Safari/7534.48.3",
    name: "Chrome",
    version: "19.0.1084.60",
  ),
  _TestConfig(
    title: "Chromium",
    ua: "Mozilla/5.0 (X11; Linux i686) AppleWebKit/535.7 (KHTML, like Gecko) Ubuntu/11.10 Chromium/16.0.912.21 Chrome/16.0.912.21 Safari/535.7",
    name: "Chromium",
    version: "16.0.912.21",
  ),
  _TestConfig(
    title: "Chrome on Android",
    ua: "Mozilla/5.0 (Linux; U; Android-4.0.3; en-us; Galaxy Nexus Build/IML74K) AppleWebKit/535.7 (KHTML, like Gecko) CrMo/16.0.912.75 Mobile Safari/535.7",
    name: "Chrome",
    version: "16.0.912.75",
  ),
  _TestConfig(
    title: "Dillo",
    ua: "Dillo/2.2",
    name: "Dillo",
    version: "2.2",
  ),
  _TestConfig(
    title: "Dolphin",
    ua: "Mozilla/5.0 (SCH-F859/F859DG12;U;NUCLEUS/2.1;Profile/MIDP-2.1 Configuration/CLDC-1.1;480*800;CTC/2.0) Dolfin/2.0",
    name: "Dolphin",
    version: "2.0",
  ),
  _TestConfig(
    title: "Doris",
    ua: "Doris/1.15 [en] (Symbian)",
    name: "Doris",
    version: "1.15",
  ),
  _TestConfig(
    title: "Epiphany",
    ua: "Mozilla/5.0 (X11; U; FreeBSD i386; en-US; rv:1.7) Gecko/20040628 Epiphany/1.2.6",
    name: "Epiphany",
    version: "1.2.6",
  ),
  _TestConfig(
    title: "Waterfox",
    ua: "Mozilla/5.0 (X11; Linux x86_64; rv:55.0) Gecko/20100101 Firefox/55.2.2 Waterfox/55.2.2",
    name: "Waterfox",
    version: "55.2.2",
  ),
  _TestConfig(
    title: "PaleMoon",
    ua: "Mozilla/5.0 (X11; Linux x86_64; rv:52.9) Gecko/20100101 Goanna/3.4 Firefox/52.9 PaleMoon/27.6.1",
    name: "PaleMoon",
    version: "27.6.1",
  ),
  _TestConfig(
    title: "Basilisk",
    ua: "Mozilla/5.0 (X11; Linux x86_64; rv:55.0) Gecko/20100101 Goanna/4.0 Firefox/55.0 Basilisk/20171113",
    name: "Basilisk",
    version: "20171113",
  ),
  _TestConfig(
    title: "Facebook in-App Browser for Android",
    ua: "Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/43.0.2357.121 Mobile Safari/537.36 [FB_IAB/FB4A;FBAV/35.0.0.48.273;]",
    name: "Facebook",
    version: "35.0.0.48.273",
  ),
  _TestConfig(
    title: "Facebook in-App Browser for iOS",
    ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Mobile/14E304 [FBAN/FBIOS;FBAV/91.0.0.41.73;FBBV/57050710;FBDV/iPhone8,1;FBMD/iPhone;FBSN/iOS;FBSV/10.3.1;FBSS/2;FBCR/Telekom.de;FBID/phone;FBLC/de_DE;FBOP/5;FBRV/0])",
    name: "Facebook",
    version: "91.0.0.41.73",
  ),
  _TestConfig(
    title: "Falkon",
    ua: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Falkon/3.0.0 Chrome/61.0.3163.140 Safari/537.36",
    name: "Falkon",
    version: "3.0.0",
  ),
  _TestConfig(
    title: "Firebird",
    ua: "Mozilla/5.0 (Windows; U; Win98; en-US; rv:1.5) Gecko/20031007 Firebird/0.7",
    name: "Firebird",
    version: "0.7",
  ),
  _TestConfig(
    title: "Firefox",
    ua: "Mozilla/5.0 (Windows NT 6.1; rv:15.0) Gecko/20120716 Firefox/15.0a2",
    name: "Firefox",
    version: "15.0a2",
  ),
  _TestConfig(
    title: "Fennec",
    ua: "Mozilla/5.0 (X11; U; Linux armv61; en-US; rv:1.9.1b2pre) Gecko/20081015 Fennec/1.0a1",
    name: "Fennec",
    version: "1.0a1",
  ),
  _TestConfig(
    title: "Firefox Focus",
    ua: "Mozilla/5.0 (Linux; Android 7.0) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Focus/6.1.1 Chrome/68.0.3440.91 Mobile Safari/537.36",
    name: "Firefox Focus",
    version: "6.1.1",
  ),
  _TestConfig(
    title: "Flock",
    ua: "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008100716 Firefox/3.0.3 Flock/2.0",
    name: "Flock",
    version: "2.0",
  ),
  _TestConfig(
    title: "GoBrowser",
    ua: "Nokia5700XpressMusic/GoBrowser/1.6.91",
    name: "GoBrowser",
    version: "1.6.91",
  ),
  _TestConfig(
    title: "IceApe",
    ua: "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.19) Gecko/20110817 Iceape/2.0.14",
    name: "Iceape",
    version: "2.0.14",
  ),
  _TestConfig(
    title: "IceCat",
    ua: "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008092921 IceCat/3.0.3-g1",
    name: "IceCat",
    version: "3.0.3-g1",
  ),
  _TestConfig(
    title: "Iceweasel",
    ua: "Mozilla/5.0 (X11; U; Linux i686; de; rv:1.9.0.16) Gecko/2009121610 Iceweasel/3.0.6 (Debian-3.0.6-3)",
    name: "Iceweasel",
    version: "3.0.6",
  ),
  _TestConfig(
    title: "iCab",
    ua: "iCab/2.9.5 (Macintosh; U; PPC; Mac OS X)",
    name: "iCab",
    version: "2.9.5",
  ),
  _TestConfig(
    title: "IE 11 with IE token",
    ua: "Mozilla/5.0 (IE 11.0; Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko",
    name: "IE",
    version: "11.0",
  ),
  _TestConfig(
    title: "IE 11 without IE token",
    ua: "Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv 11.0) like Gecko",
    name: "IE",
    version: "11.0",
  ),
  _TestConfig(
    title: "K-Meleon",
    ua: "Mozilla/5.0 (Windows; U; Win98; en-US; rv:1.5) Gecko/20031016 K-Meleon/0.8.2",
    name: "K-Meleon",
    version: "0.8.2",
  ),
  _TestConfig(
    title: "Kindle Browser",
    ua: "Mozilla/4.0 (compatible; Linux 2.6.22) NetFront/3.4 Kindle/2.5 (screen 600x800; rotate)",
    name: "Kindle",
    version: "2.5",
  ),
  _TestConfig(
    title: "Konqueror",
    ua: "Mozilla/5.0 (compatible; Konqueror/3.5; Linux; X11; x86_64) KHTML/3.5.6 (like Gecko) (Kubuntu)",
    name: "Konqueror",
    version: "3.5",
  ),
  _TestConfig(
    title: "Konqueror",
    ua: "Mozilla/5.0 (X11; Linux i686) AppleWebKit/534.34 (KHTML, like Gecko) konqueror/5.0.97 Safari/534.34",
    name: "Konqueror",
    version: "5.0.97",
  ),
  _TestConfig(
    title: "LINE on Android",
    ua: "Mozilla/5.0 (Linux; Android 5.0; ASUS_Z00AD Build/LRX21V; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/51.0.2704.81 Mobile Safari/537.36 Line/6.5.1/IAB",
    name: "Line",
    version: "6.5.1",
  ),
  _TestConfig(
    title: "LINE on iOS",
    ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 11_2_6 like Mac OS X) AppleWebKit/604.5.6 (KHTML, like Gecko) Mobile/15D100 Safari Line/8.4.1",
    name: "Line",
    version: "8.4.1",
  ),
  _TestConfig(
    title: "Lunascape",
    ua: "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.1.2) Gecko/20090804 Firefox/3.5.2 Lunascape/5.1.4.5",
    name: "Lunascape",
    version: "5.1.4.5",
  ),
  _TestConfig(
    title: "Lynx",
    ua: "Lynx/2.8.5dev.16 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.6b",
    name: "Lynx",
    version: "2.8.5dev.16",
  ),
  _TestConfig(
    title: "Maemo Browser",
    ua: "Mozilla/5.0 (X11; U; Linux armv7l; ru-RU; rv:1.9.2.3pre) Gecko/20100723 Firefox/3.5 Maemo Browser 1.7.4.8 RX-51 N900",
    name: "Maemo Browser",
    version: "1.7.4.8",
  ),
  _TestConfig(
    title: "Midori",
    ua: "Midori/0.2.2 (X11; Linux i686; U; en-us) WebKit/531.2+",
    name: "Midori",
    version: "0.2.2",
  ),
  _TestConfig(
    title: "Minimo",
    ua: "Mozilla/5.0 (X11; U; Linux armv6l; rv 1.8.1.5pre) Gecko/20070619 Minimo/0.020",
    name: "Minimo",
    version: "0.020",
  ),
  _TestConfig(
    title: "MIUI Browser on Xiaomi Hongmi WCDMA (HM2013023)",
    ua: "Mozilla/5.0 (Linux; U; Android 4.2.2; ru-ru; 2013023 Build/HM2013023) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30 XiaoMi/MiuiBrowser/1.0",
    name: "MIUI Browser",
    version: "1.0",
  ),
  _TestConfig(
    title: "Mobile Safari",
    ua: "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7",
    name: "Mobile Safari",
    version: "4.0.5",
  ),
  _TestConfig(
    title: "Mosaic",
    ua: "NCSA_Mosaic/2.6 (X11; SunOS 4.1.3 sun4m)",
    name: "Mosaic",
    version: "2.6",
  ),
  _TestConfig(
    title: "Mozilla",
    ua: "Mozilla/5.0 (X11; U; SunOS sun4u; en-US; rv:1.7) Gecko/20070606",
    name: "Mozilla",
    version: "5.0",
  ),
  _TestConfig(
    title: "MSIE",
    ua: "Mozilla/4.0 (compatible; MSIE 5.0b1; Mac_PowerPC)",
    name: "IE",
    version: "5.0b1",
  ),
  _TestConfig(
    title: "NetFront",
    ua: "Mozilla/4.0 (PDA; Windows CE/1.0.1) NetFront/3.0",
    name: "NetFront",
    version: "3.0",
  ),
  _TestConfig(
    title: "Netscape on Windows ME",
    ua: "Mozilla/5.0 (Windows; U; Win 9x 4.90; en-US; rv:1.8.1.8pre) Gecko/20071015 Firefox/2.0.0.7 Navigator/9.0",
    name: "Netscape",
    version: "9.0",
  ),
  _TestConfig(
    title: "Netscape on Windows 2000",
    ua: "Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.7.5) Gecko/20050519 Netscape/8.0.1",
    name: "Netscape",
    version: "8.0.1",
  ),
  _TestConfig(
    title: "Nokia Browser",
    ua: "Mozilla/5.0 (Symbian/3; Series60/5.2 NokiaN8-00/025.007; Profile/MIDP-2.1 Configuration/CLDC-1.1 ) AppleWebKit/533.4 (KHTML, like Gecko) NokiaBrowser/7.3.1.37 Mobile Safari/533.4 3gpp-gba",
    name: "NokiaBrowser",
    version: "7.3.1.37",
  ),
  _TestConfig(
    title: "Oculus Browser",
    ua: "Mozilla/5.0 (Linux; Android 7.0; SM-G920I Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) OculusBrowser/3.4.9 SamsungBrowser/4.0 Chrome/57.0.2987.146 Mobile VR Safari/537.36",
    name: "Oculus Browser",
    version: "3.4.9",
  ),
  _TestConfig(
    title: "OmniWeb",
    ua: "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-US) AppleWebKit/85 (KHTML, like Gecko) OmniWeb/v558.48",
    name: "OmniWeb",
    version: "558.48",
  ),
  _TestConfig(
    title: "Opera > 9.80",
    ua: "Opera/9.80 (X11; Linux x86_64; U; Linux Mint; en) Presto/2.2.15 Version/10.10",
    name: "Opera",
    version: "10.10",
  ),
  _TestConfig(
    title: "Opera < 9.80 on Windows",
    ua: "Mozilla/4.0 (compatible; MSIE 5.0; Windows 95) Opera 6.01 [en]",
    name: "Opera",
    version: "6.01",
  ),
  _TestConfig(
    title: "Opera < 9.80 on OSX",
    ua: "Opera/8.5 (Macintosh; PPC Mac OS X; U; en)",
    name: "Opera",
    version: "8.5",
  ),
  _TestConfig(
    title: "Opera Mobile",
    ua: "Opera/9.80 (Android 2.3.5; Linux; Opera Mobi/ADR-1111101157; U; de) Presto/2.9.201 Version/11.50",
    name: "Opera Mobi",
    version: "11.50",
  ),
  _TestConfig(
    title: "Opera Webkit",
    ua: "Mozilla/5.0 AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.123 Mobile Safari/537.22 OPR/14.0.1025.52315",
    name: "Opera",
    version: "14.0.1025.52315",
  ),
  _TestConfig(
    title: "Opera Mini",
    ua: "Opera/9.80 (J2ME/MIDP; Opera Mini/5.1.21214/19.916; U; en) Presto/2.5.25",
    name: "Opera Mini",
    version: "5.1.21214",
  ),
  _TestConfig(
    title: "Opera Mini 8 above on iPhone",
    ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 9_2 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) OPiOS/12.1.1.98980 Mobile/13C75 Safari/9537.53",
    name: "Opera Mini",
    version: "12.1.1.98980",
  ),
  _TestConfig(
    title: "Opera Tablet",
    ua: "Opera/9.80 (Windows NT 6.1; Opera Tablet/15165; U; en) Presto/2.8.149 Version/11.1",
    name: "Opera Tablet",
    version: "11.1",
  ),
  _TestConfig(
    title: "Opera Coast",
    ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 9_3_2 like Mac OS X; en) AppleWebKit/601.1.46 (KHTML, like Gecko) Coast/5.04.110603 Mobile/13F69 Safari/7534.48.3",
    name: "Opera Coast",
    version: "5.04.110603",
  ),
  _TestConfig(
    title: "Opera Touch",
    ua: "Mozilla/5.0 (Linux; Android 7.0; Lenovo P2a42 Build/NRD90N) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/68.0.3440.91 Mobile Safari/537.36 OPT/1.10.33",
    name: "Opera Touch",
    version: "1.10.33",
  ),
  _TestConfig(
    title: "PhantomJS",
    ua: "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.2 Safari/534.34",
    name: "PhantomJS",
    version: "1.9.2",
  ),
  _TestConfig(
    title: "Phoenix",
    ua: "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.2b) Gecko/20021029 Phoenix/0.4",
    name: "Phoenix",
    version: "0.4",
  ),
  _TestConfig(
    title: "Polaris",
    ua: "LG-LX600 Polaris/6.0 MMP/2.0 Profile/MIDP-2.1 Configuration/CLDC-1.1",
    name: "Polaris",
    version: "6.0",
  ),
  _TestConfig(
    title: "QQ",
    ua: "Mozilla/5.0 (Linux; U; Android 4.4.4; zh-cn; OPPO R7s Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko)Version/4.0 Chrome/37.0.0.0 MQQBrowser/7.1 Mobile Safari/537.36",
    name: "QQBrowser",
    version: "7.1",
  ),
  _TestConfig(
    title: "QupZilla",
    ua: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/538.1 (KHTML, like Gecko) QupZilla/1.8.9 Safari/538.1",
    name: "QupZilla",
    version: "1.8.9",
  ),
  _TestConfig(
    title: "RockMelt",
    ua: "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.7 (KHTML, like Gecko) RockMelt/0.8.36.78 Chrome/7.0.517.44 Safari/534.7",
    name: "RockMelt",
    version: "0.8.36.78",
  ),
  _TestConfig(
    title: "Safari",
    ua: "Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US) AppleWebKit/533.17.8 (KHTML, like Gecko) Version/5.0.1 Safari/533.17.8",
    name: "Safari",
    version: "5.0.1",
  ),
  _TestConfig(
    title: "Samsung Browser",
    ua: "Mozilla/5.0 (Linux; Android 6.0.1; SAMSUNG-SM-G925A Build/MMB29K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/4.0 Chrome/44.0.2403.133 Mobile Safari/537.36",
    name: "Samsung Browser",
    version: "4.0",
  ),
  _TestConfig(
    title: "SeaMonkey",
    ua: "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1b4pre) Gecko/20090405 SeaMonkey/2.0b1pre",
    name: "SeaMonkey",
    version: "2.0b1pre",
  ),
  _TestConfig(
    title: "Silk Browser",
    ua: "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_3; en-us; Silk/1.1.0-84)",
    name: "Silk",
    version: "1.1.0-84",
  ),
  _TestConfig(
    title: "Skyfire",
    ua: "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_7; en-us) AppleWebKit/530.17 (KHTML, like Gecko) Version/4.0 Safari/530.17 Skyfire/2.0",
    name: "Skyfire",
    version: "2.0",
  ),
  _TestConfig(
    title: "Tizen Browser",
    ua: "Mozilla/5.0 (Linux; U; Tizen/1.0 like Android; en-us; AppleWebKit/534.46 (KHTML, like Gecko) Tizen Browser/1.0 Mobile",
    name: "Tizen Browser",
    version: "1.0",
  ),
  _TestConfig(
    title: "UC Browser",
    ua: "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 UBrowser/5.6.12860.7 Safari/537.36",
    name: "UCBrowser",
    version: "5.6.12860.7",
  ),
  _TestConfig(
    title: "UC Browser",
    ua: "Mozilla/5.0 (Linux; U; Android 6.0.1; en-US; Lenovo P2a42 Build/MMB29M) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 UCBrowser/11.2.0.915 U3/0.8.0 Mobile Safari/534.30",
    name: "UCBrowser",
    version: "11.2.0.915",
  ),
  _TestConfig(
    title: "UC Browser on Samsung",
    ua: "Mozilla/5.0 (Java; U; Pt-br; samsung-gt-s5620) UCBrowser8.2.1.144/69/352/UCWEB Mobile UNTRUSTED/1.0",
    name: "UCBrowser",
    version: "8.2.1.144",
  ),
  _TestConfig(
    title: "UC Browser on Nokia",
    ua: "Mozilla/5.0 (S60V3; U; en-in; NokiaN73)/UC Browser8.4.0.159/28/351/UCWEB Mobile",
    name: "UCBrowser",
    version: "8.4.0.159",
  ),
  _TestConfig(
    title: "UC Browser J2ME",
    ua: "UCWEB/2.0 (MIDP-2.0; U; zh-CN; HTC EVO 3D X515m) U2/1.0.0 UCBrowser/10.4.0.558 U2/1.0.0 Mobile",
    name: "UCBrowser",
    version: "10.4.0.558",
  ),
  _TestConfig(
    title: "UC Browser J2ME 2",
    ua: "JUC (Linux; U; 2.3.5; zh-cn; GT-I9100; 480*800) UCWEB7.9.0.94/139/800",
    name: "UCBrowser",
    version: "7.9.0.94",
  ),
  _TestConfig(
    title: "WeChat on iOS",
    ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 8_4_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12H321 MicroMessenger/6.3.6 NetType/WIFI Language/zh_CN",
    name: "WeChat",
    version: "6.3.6",
  ),
  _TestConfig(
    title: "WeChat on Android",
    ua: "Mozilla/5.0 (Linux; U; Android 5.1; zh-cn; Lenovo K50-t5 Build/LMY47D) AppleWebKit/533.1 (KHTML, like Gecko)Version/4.0 MQQBrowser/5.4 TBS/025478 Mobile Safari/533.1 MicroMessenger/6.3.5.50_r1573191.640 NetType/WIFI Language/zh_CN",
    name: "WeChat",
    version: "6.3.5.50_r1573191.640",
  ),
  _TestConfig(
    title: "Vivaldi",
    ua: "Mozilla/5.0 (Windows NT 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.89 Vivaldi/1.0.83.38 Safari/537.36",
    name: "Vivaldi",
    version: "1.0.83.38",
  ),
  _TestConfig(
    title: "Yandex",
    ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.5 (KHTML, like Gecko) YaBrowser/1.0.1084.5402 Chrome/19.0.1084.5402 Safari/536.5",
    name: "Yandex",
    version: "1.0.1084.5402",
  ),
  _TestConfig(
    title: "Puffin",
    ua: "Mozilla/5.0 (Linux; Android 6.0.1; Lenovo P2a42 Build/MMB29M; en-us) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Mobile Safari/537.36 Puffin/6.0.8.15804AP",
    name: "Puffin",
    version: "6.0.8.15804AP",
  ),
  _TestConfig(
    title: "Microsoft Edge",
    ua: "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36 Edge/12.0",
    name: "Edge",
    version: "12.0",
  ),
  _TestConfig(
    title: "Microsoft Edge on iOS",
    ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 11_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.0 EdgiOS/42.1.1.0 Mobile/15F79 Safari/605.1.15",
    name: "Edge",
    version: "42.1.1.0",
  ),
  _TestConfig(
    title: "Microsoft Edge on Android",
    ua: "Mozilla/5.0 (Linux; Android 8.0.0; G8441 Build/47.1.A.12.270) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.123 Mobile Safari/537.36 EdgA/42.0.0.2529",
    name: "Edge",
    version: "42.0.0.2529",
  ),
  _TestConfig(
    title: "Microsoft Edge Chromium",
    ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.48 Safari/537.36 Edg/74.1.96.24",
    name: "Edge",
    version: "74.1.96.24",
  ),
  _TestConfig(
    title: "Iridium",
    ua: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Iridium/43.8 Safari/537.36 Chrome/43.0.2357.132",
    name: "Iridium",
    version: "43.8",
  ),
  _TestConfig(
    title: "Firefox iOS",
    ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) FxiOS/1.1 Mobile/13B143 Safari/601.1.46",
    name: "Firefox",
    version: "1.1",
  ),
  _TestConfig(
    title: "QQ on iOS",
    ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_2 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Mobile/14A456 QQ/6.5.3.410 V1_IPH_SQ_6.5.3_1_APP_A Pixel/1080 Core/UIWebView NetType/WIFI Mem/26",
    name: "QQ",
    version: "6.5.3.410",
  ),
  _TestConfig(
    title: "QQ on Android",
    ua: "Mozilla/5.0 (Linux; Android 6.0; PRO 6 Build/MRA58K) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/37.0.0.0 Mobile MQQBrowser/6.8 TBS/036824 Safari/537.36 V1_AND_SQ_6.5.8_422_YYB_D PA QQ/6.5.8.2910 NetType/WIFI WebP/0.3.0 Pixel/1080",
    name: "QQ",
    version: "6.5.8.2910",
  ),
  _TestConfig(
    title: "baidu app on iOS",
    ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16C101 main%2F1.0 baiduboxapp/11.12.0.18 (Baidu; P2 12.1.2)",
    name: "baiduboxapp",
    version: "11.12.0.18",
  ),
  _TestConfig(
    title: "baidu app on Android",
    ua: "Mozilla/5.0 (Linux; Android 8.1.0; BKK-AL10 Build/HONORBKK-AL10; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/63.0.3239.83 Mobile Safari/537.36 T7/11.11 baiduboxapp/11.11.0.0 (Baidu; P1 8.1.0)",
    name: "baiduboxapp",
    version: "11.11.0.0",
  ),
  _TestConfig(
    title: "WeChat Desktop for Windows Built-in Browser",
    ua: "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36 MicroMessenger/6.5.2.501 NetType/WIFI WindowsWechat QBCore/3.43.901.400 QQBrowser/9.0.2524.400",
    name: "WeChat(Win) Desktop",
    version: "3.43.901.400",
  ),
  _TestConfig(
    title: "GSA on iOS",
    ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_2 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) GSA/30.1.161623614 Mobile/14F89 Safari/602.1",
    name: "GSA",
    version: "30.1.161623614",
  ),
  _TestConfig(
    title: "BaiDu Browser",
    ua: "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 BIDUBrowser/8.7 Safari/537.36",
    name: "BIDUBrowser",
    version: "8.7",
  ),
  _TestConfig(
    title: "2345 Browser",
    ua: "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.90 Safari/537.36 2345Explorer/9.2.1.17116",
    name: "2345Explorer",
    version: "9.2.1.17116",
  ),
  _TestConfig(
    title: "QQBrowserLite",
    ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/602.2.14 (KHTML, like Gecko) Version/10.0.1 Safari/602.2.14 QQBrowserLite/1.1.0",
    name: "QQBrowserLite",
    version: "1.1.0",
  ),
  _TestConfig(
    title: "Brave Browser",
    ua: "Brave/4.5.16 CFNetwork/893.13.1 Darwin/17.3.0 (x86_64)",
    name: "Brave",
    version: "4.5.16",
  ),
];

class _TestConfig {
  final String title;
  final String ua;
  final String name;
  final String version;

  const _TestConfig({
    @required this.title,
    @required this.ua,
    @required this.name,
    @required this.version,
  });
}

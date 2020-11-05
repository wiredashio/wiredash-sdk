class UserAgentParser {
  static const _unknownBrowserName = 'Unknown Web Browser';
  static const _unknownBrowserVersion = 'Unknown Web Browser Version';

  final String userAgent;

  const UserAgentParser(this.userAgent);

  String get browserName {
    for (final matcher in _browserMatchers) {
      for (final regex in matcher.regexes) {
        if (regex.hasMatch(userAgent)) {
          final name = matcher.name(regex.firstMatch(userAgent));

          if (name != null && name.isNotEmpty) {
            return name;
          } else {
            return _unknownBrowserName;
          }
        }
      }
    }

    return _unknownBrowserName;
  }

  String get browserVersion {
    for (final matcher in _browserMatchers) {
      for (final regex in matcher.regexes) {
        if (regex.hasMatch(userAgent)) {
          final version = matcher.version(regex.firstMatch(userAgent));

          if (version != null && version.isNotEmpty) {
            return version;
          } else {
            return _unknownBrowserVersion;
          }
        }
      }
    }

    return _unknownBrowserVersion;
  }
}

// Groups of regular expressions that allow us to extract the correct browser
// name and version from a User Agent string.
//
// Order is important.
//
// These are an adaptation from the original js lib UAParser.js
// https://github.com/faisalman/ua-parser-js
final _browserMatchers = [
  _NameFirstMatcher(regexes: [
    // Opera Mini
    RegExp(r'(opera\smini)\/([\w\.-]+)', caseSensitive: false),
    // Opera Mobi/Tablet
    RegExp(r'(opera\s[mobiletab]+).+version\/([\w\.-]+)', caseSensitive: false),
    // Opera > 9.80
    RegExp(r'(opera).+version\/([\w\.]+)', caseSensitive: false),
    // Opera < 9.80
    RegExp(r'(opera)[\/\s]+([\w\.]+)', caseSensitive: false),
  ]),
  _NameFirstMatcher(
    regexes: [
      // Opera mini on iphone >= 8.0
      RegExp(r'(opios)[\/\s]+([\w\.]+)', caseSensitive: false),
    ],
    defaultName: 'Opera Mini',
  ),
  _NameFirstMatcher(
    regexes: [
      // Opera Webkit
      RegExp(r'\s(opr)\/([\w\.]+)', caseSensitive: false),
    ],
    defaultName: 'Opera',
  ),
  _NameFirstMatcher(
    regexes: [
      RegExp(
        r'(kindle)\/([\w\.]+)',
        caseSensitive: false,
      ),
      RegExp(
        r'(lunascape|netfront|jasmine|blazer)[\/\s]?([\w\.]*)',
        caseSensitive: false,
      ),
      RegExp(
        r'(iemobile|slim)(?:browser)?[\/\s]?([\w\.]*)',
        caseSensitive: false,
      ),
      RegExp(
        r'(bidubrowser|baidubrowser)[\/\s]?([\w\.]+)',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:ms|\()(ie)\s([\w\.]+)',
        caseSensitive: false,
      ),
      RegExp(
        r'(rekonq)\/([\w\.]*)',
        caseSensitive: false,
      ),
      RegExp(
        r'(chromium|flock|rockmelt|midori|epiphany|silk|skyfire|ovibrowser|bolt|iron|vivaldi|iridium|phantomjs|bowser|quark|qupzilla|falkon)\/([\w\.-]+)',
        caseSensitive: false,
      ),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Konqueror',
    regexes: [
      RegExp(r'(konqueror)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'IE',
    regexes: [
      RegExp(r'(trident).+rv[:\s]([\w\.]+).+like\sgecko', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Edge',
    regexes: [
      RegExp(r'(edge|edgios|edga|edg)\/((\d+)?[\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Yandex',
    regexes: [
      RegExp(r'(yabrowser)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Avast Secure Browser',
    regexes: [
      RegExp(r'(Avast)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'AVG Secure Browser',
    regexes: [
      RegExp(r'(AVG)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Puffin',
    regexes: [
      RegExp(r'(puffin)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Firefox Focus',
    regexes: [
      RegExp(r'(focus)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Opera Touch',
    regexes: [
      RegExp(r'(opt)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'UCBrowser',
    regexes: [
      RegExp(
        r'((?:[\s\/])uc?\s?browser|(?:juc.+)ucweb)[\/\s]?([\w\.]+)',
        caseSensitive: false,
      ),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'WeChat(Win) Desktop',
    regexes: [
      RegExp(
        r'(windowswechat qbcore)\/([\w\.]+)',
        caseSensitive: false,
      ),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'WeChat',
    regexes: [
      RegExp(
        r'(micromessenger)\/([\w\.]+)',
        caseSensitive: false,
      ),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Brave',
    regexes: [
      RegExp(
        r'(brave)\/([\w\.]+)',
        caseSensitive: false,
      ),
    ],
  ),
  _NameFirstMatcher(
    regexes: [
      RegExp(r'(qqbrowserlite)\/([\w\.]+)', caseSensitive: false),
      RegExp(r'(QQ)\/([\d\.]+)', caseSensitive: false),
      RegExp(r'm?(qqbrowser)[\/\s]?([\w\.]+)', caseSensitive: false),
      RegExp(r'(baiduboxapp)[\/\s]?([\w\.]+)', caseSensitive: false),
      RegExp(r'(2345Explorer)[\/\s]?([\w\.]+)', caseSensitive: false),
    ],
  ),
  _VersionFirstMatcher(
    defaultName: 'MIUI Browser',
    regexes: [
      RegExp(r'xiaomi\/miuibrowser\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _VersionFirstMatcher(
    defaultName: 'Facebook',
    regexes: [
      RegExp(r';fbav\/([\w\.]+);', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    regexes: [
      RegExp(r'safari\s(line)\/([\w\.]+)', caseSensitive: false),
      RegExp(r'android.+(line)\/([\w\.]+)\/iab', caseSensitive: false),
    ],
  ),
  _VersionFirstMatcher(
    defaultName: 'Chrome Headless',
    regexes: [
      RegExp(r'headlesschrome(?:\/([\w\.]+)|\s)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Chrome WebView',
    regexes: [
      RegExp(r'\swv\).+(chrome)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Oculus Browser',
    regexes: [
      RegExp(r'((?:oculus)browser)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Samsung Browser',
    regexes: [
      RegExp(r'((?:samsung)browser)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _VersionFirstMatcher(
    defaultName: 'Android Browser',
    regexes: [
      RegExp(
        r'android.+version\/([\w\.]+)\s+(?:mobile\s?safari|safari)*',
        caseSensitive: false,
      ),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Sailfish Browser',
    regexes: [
      RegExp(r'(sailfishbrowser)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    regexes: [
      // Chrome/OmniWeb/Arora/Tizen/Nokia
      RegExp(
        r'(chrome|omniweb|arora|[tizenoka]{5}\s?browser)\/v?([\w\.]+)',
        caseSensitive: false,
      ),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Dolphin',
    regexes: [
      RegExp(r'(dolfin)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Chrome',
    regexes: [
      RegExp(r'((?:android.+)crmo|crios)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Opera Coast',
    regexes: [
      RegExp(r'(coast)\/([\w\.]+)', caseSensitive: false),
    ],
  ),
  _VersionFirstMatcher(
    defaultName: 'Firefox',
    regexes: [
      RegExp(r'fxios\/([\w\.-]+)', caseSensitive: false),
    ],
  ),
  _VersionFirstMatcher(
    defaultName: 'Mobile Safari',
    regexes: [
      RegExp(
        r'version\/([\w\.]+).+?mobile\/\w+\s(safari)',
        caseSensitive: false,
      ),
    ],
  ),
  _VersionFirstMatcher(
    regexes: [
      RegExp(
        r'version\/([\w\.]+).+?(mobile\s?safari|safari)',
        caseSensitive: false,
      ),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'GSA',
    regexes: [
      RegExp(
        r'webkit.+?(gsa)\/([\w\.]+).+?(mobile\s?safari|safari)(\/[\w\.]+)',
        caseSensitive: false,
      ),
    ],
  ),
  _NameFirstMatcher(
    defaultName: 'Netscape',
    regexes: [
      RegExp(
        r'(navigator|netscape)\/([\w\.-]+)',
        caseSensitive: false,
      ),
    ],
  ),
  _NameFirstMatcher(
    regexes: [
      RegExp(
        r'(icedragon|iceweasel|camino|chimera|fennec|maemo\sbrowser|minimo|conkeror)[\/\s]?([\w\.\+]+)',
        caseSensitive: false,
      ),
      RegExp(
        r'(firefox|seamonkey|k-meleon|icecat|iceape|firebird|phoenix|palemoon|basilisk|waterfox)\/([\w\.-]+)$',
        caseSensitive: false,
      ),
      RegExp(
        r'(mozilla)\/([\w\.]+).+rv\:.+gecko\/\d+',
        caseSensitive: false,
      ),
      RegExp(
        r'(polaris|lynx|dillo|icab|doris|amaya|w3m|netsurf|sleipnir)[\/\s]?([\w\.]+)',
        caseSensitive: false,
      ),
      RegExp(
        r'(links)\s\(([\w\.]+)',
        caseSensitive: false,
      ),
      RegExp(
        r'(gobrowser)\/?([\w\.]*)',
        caseSensitive: false,
      ),
      RegExp(
        r'(ice\s?browser)\/v?([\w\._]+)',
        caseSensitive: false,
      ),
      RegExp(
        r'(mosaic)[\/\s]([\w\.]+)',
        caseSensitive: false,
      ),
    ],
  ),
];

abstract class _UserAgentMatcher {
  final List<RegExp> regexes;
  final String defaultName;

  _UserAgentMatcher({
    this.regexes,
    this.defaultName,
  });

  bool hasMatch(String userAgent) =>
      regexes.any((regex) => regex.hasMatch(userAgent));

  String name(RegExpMatch match);

  String version(RegExpMatch match);
}

class _NameFirstMatcher extends _UserAgentMatcher {
  _NameFirstMatcher({
    final List<RegExp> regexes,
    final String defaultName,
  }) : super(regexes: regexes, defaultName: defaultName);

  @override
  String name(RegExpMatch match) {
    return defaultName ?? match.group(1);
  }

  @override
  String version(RegExpMatch match) {
    return match.group(2);
  }
}

class _VersionFirstMatcher extends _UserAgentMatcher {
  _VersionFirstMatcher({
    final List<RegExp> regexes,
    final String defaultName,
  }) : super(regexes: regexes, defaultName: defaultName);

  @override
  String name(RegExpMatch match) {
    return defaultName ?? match.group(2);
  }

  @override
  String version(RegExpMatch match) {
    return match.group(1);
  }
}

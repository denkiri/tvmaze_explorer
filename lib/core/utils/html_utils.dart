import 'package:html/parser.dart' as html_parser;

// Utility for stripping HTML tags from strings.
class HtmlUtils {
  const HtmlUtils._();
  static String stripHtml(String? htmlString) {
    if (htmlString == null || htmlString.isEmpty) return '';
    final document = html_parser.parseFragment(htmlString);
    return document.text ?? '';
  }
}

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlRenderer extends StatefulWidget {
  const HtmlRenderer({
    super.key,
    this.width,
    this.height,
    this.htmlContent,
  });

  final double? width;
  final double? height;
  final String? htmlContent;

  @override
  State<HtmlRenderer> createState() => _HtmlRendererState();
}

class _HtmlRendererState extends State<HtmlRenderer> {
  @override
  Widget build(BuildContext context) {
    if (widget.htmlContent == null || widget.htmlContent!.isEmpty) {
      return Container();
    }

    return Container(
      width: widget.width,
      constraints: BoxConstraints(
        maxWidth: widget.width ?? double.infinity,
      ),
      child: HtmlWidget(
        widget.htmlContent!,
        customStylesBuilder: (element) {
          if (element.localName == 'ul') {
            return {'margin-left': '5px', 'padding-left': '5px'};
          }
          if (element.localName == 'li') {
            return {'margin-bottom': '8px'};
          }
          return null;
        },
        onTapUrl: (url) async {
          // Extrair URL real de links JavaScript
          String finalUrl = url;
          if (url.startsWith('javascript:abrirUrl(')) {
            // Extrair a URL entre aspas simples
            final match =
                RegExp(r"javascript:abrirUrl\('([^']+)'\)").firstMatch(url);
            if (match != null) {
              finalUrl = match.group(1)?.trim() ?? url;
            }
          }

          if (await canLaunchUrl(Uri.parse(finalUrl))) {
            await launchUrl(Uri.parse(finalUrl),
                mode: LaunchMode.externalApplication);
            return true;
          }
          return false;
        },
      ),
    );
  }
}

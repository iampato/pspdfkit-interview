import 'package:flutter/material.dart';
import 'package:pspdfkit_example/utils/file_utils.dart';
import 'package:pspdfkit_example/utils/platform_utils.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:pspdfkit_flutter/widgets/pspdfkit_widget_controller.dart';
import 'package:pspdfkit_flutter/widgets/pspdfkit_widget.dart';

class PdfMergeDocuments extends StatefulWidget {
  const PdfMergeDocuments({Key? key}) : super(key: key);

  @override
  State<PdfMergeDocuments> createState() => _PdfMergeDocumentsState();
}

class _PdfMergeDocumentsState extends State<PdfMergeDocuments> {
  final String _documentPath = 'PDFs/PSPDFKit.pdf';
  final String _measurementsDocs = 'PDFs/Measurements.pdf';
  bool _isLoaded = false;
  String? results;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: PlatformUtils.isAndroid(),
      // Do not resize the the document view on Android or
      // it won't be rendered correctly when filling forms.
      resizeToAvoidBottomInset: PlatformUtils.isIOS(),
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          padding: PlatformUtils.isCupertino(context)
              ? null
              : const EdgeInsets.only(top: kToolbarHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: TextButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        _isLoaded = true;
                      });
                      final document1 =
                          await extractAsset(context, _documentPath);
                      final document2 =
                          await extractAsset(context, _measurementsDocs);
                      final documentPaths = [document1.path, document2.path];
                      results = await Pspdfkit.mergeDocuments(
                        documentPaths,
                        'merged-11.pdf',
                      );
                      print(results);
                    } catch (e) {
                      print('😆😆😆😆😆');
                      print(e);
                      print('😆😆😆😆😆');
                    } finally {
                      setState(() {
                        _isLoaded = false;
                      });
                    }
                  },
                  child: _isLoaded
                      ? const CircularProgressIndicator(
                          strokeWidth: 1.5,
                        )
                      : const Text('merge documents'),
                ),
              ),
              if (results != null)
                TextButton(
                  onPressed: () {
                    showDocument(results!);
                  },
                  child: const Text('Open merged document'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void showDocument(String docPath) async {
    await Navigator.of(context).push<dynamic>(
      MaterialPageRoute<dynamic>(
        builder: (_) => Scaffold(
          extendBodyBehindAppBar: PlatformUtils.isAndroid(),
          // Do not resize the the document view on Android or
          // it won't be rendered correctly when filling forms.
          resizeToAvoidBottomInset: PlatformUtils.isIOS(),
          appBar: AppBar(),
          body: SafeArea(
            top: false,
            bottom: false,
            child: Container(
              padding: PlatformUtils.isCupertino(context)
                  ? null
                  : const EdgeInsets.only(top: kToolbarHeight),
              child: PspdfkitWidget(
                documentPath: docPath,
                configuration: const {
                  scrollDirection: 'vertical',
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

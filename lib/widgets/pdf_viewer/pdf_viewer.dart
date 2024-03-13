import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sifr_latest/config/app_color.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

Future<void> pdfViewer({
  required BuildContext context,
  required String filePath,
}) async {

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
      return AlertDialog(
        insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * .02),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState1) {
            return Stack(
              children: [
                SfPdfViewer.file(File(filePath),pageSpacing:4),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.kRedColor,
                    ),
                    onPressed: () {
                      // onSubmit(false, "Verification Canceled By User",
                      //     statusCode: 100);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

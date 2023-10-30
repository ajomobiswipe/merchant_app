import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../config/config.dart';
import '../../../widgets/widget.dart';
import 'view_document.dart';

class UploadDocumentInfo extends StatefulWidget {
  const UploadDocumentInfo({Key? key, this.params}) : super(key: key);
  final dynamic params;
  @override
  State<UploadDocumentInfo> createState() => _UploadDocumentInfoState();
}

class _UploadDocumentInfoState extends State<UploadDocumentInfo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var documents = widget.params[0]['merchantDocs'];
    final da = documents.split(',');
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Document Details',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                Constants.verifyKYC,
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 30),
              // Card(
              //     child: Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              //   child: Column(
              //     children: [
              //       Align(
              //         child: Text(
              //           "National ID",
              //           style: Theme.of(context)
              //               .textTheme
              //               .bodyLarge
              //               ?.copyWith(fontWeight: FontWeight.w700),
              //         ),
              //       ),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           TextButton(
              //             onPressed: () {},
              //             child: const Text("Preview"),
              //           ),
              //           TextButton(
              //             onPressed: () {},
              //             child: const Text("Update"),
              //           ),
              //         ],
              //       )
              //     ],
              //   ),
              // )),
              ListTile(
                title: const Text('National ID Front'),
                // subtitle: Text(da[0].split('/').last),
                trailing: IconButton(
                    onPressed: () {
                      viewDoc(da[0], 'National ID Front');
                    },
                    icon: const Icon(LineAwesome.eye)),
              ),
              const Divider(),
              ListTile(
                title: const Text('National ID Back'),
                trailing: IconButton(
                    onPressed: () {
                      viewDoc(da[1], 'National ID Back');
                    },
                    icon: const Icon(LineAwesome.eye)),
              ),
              const Divider(),
              ListTile(
                title: const Text('Trade License'),
                trailing: IconButton(
                    onPressed: () {
                      viewDoc(da[2], 'Trade License');
                    },
                    icon: const Icon(LineAwesome.eye)),
              ),
              const Divider(),
              ListTile(
                title: const Text('Cancelled Cheque'),
                trailing: IconButton(
                    onPressed: () {
                      viewDoc(da[3], 'Cancelled Cheque');
                    },
                    icon: const Icon(LineAwesome.eye)),
              ),
              const Divider(),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'documentReUploads',
                        arguments: {'params': widget.params[0]});
                  },
                  child: const Text(
                    "Re-Upload",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  viewDoc(image, String title) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) {
          return ViewDocument(
            title: title,
            params: image,
          );
        },
        fullscreenDialog: true));
  }
}

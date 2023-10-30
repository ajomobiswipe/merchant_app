import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sifr_latest/config/config.dart';

import '../../../widgets/loading.dart';
import '../../../widgets/widget.dart';

class UpdateKycInfo extends StatefulWidget {
  const UpdateKycInfo({Key? key, this.params}) : super(key: key);
  final dynamic params;

  @override
  State<UpdateKycInfo> createState() => _UpdateKycInfoState();
}

class _UpdateKycInfoState extends State<UpdateKycInfo> {
  final GlobalKey<FormState> kycForm = GlobalKey<FormState>();
  final bool _isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.params;
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'KYC Information',
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ...kycDoc(data),
                  ],
                ),
              ),
            ),
    );
  }

  kycDoc(data) {
    return [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            Navigator.pushNamed(context, 'reUploadKyc',
                arguments: {'params': data});
          },
          child: const Text(
            "Update",
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "KYC front page of Emirates ID",
          // style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      Card(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: CachedNetworkImage(
          height: 200,
          fit: BoxFit.contain,
          width: double.maxFinite,
          imageUrl:
              Validators.urlDecrypt(data['customerFrontKycImg']).toString(),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => errorDocument(),
        ),
      )),
      const SizedBox(height: 20),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "KYC reverse page of Emirates ID",
          // style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: CachedNetworkImage(
            height: 200,
            fit: BoxFit.contain,
            width: double.maxFinite,
            imageUrl:
                Validators.urlDecrypt(data['customerBackKycImg']).toString(),
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => errorDocument(),
          ),
        ),
      ),
    ];
  }

  errorDocument() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          LineAwesome.file_image,
          color: Colors.grey,
        ),
        Text(
          "File loading error!",
          style: Theme.of(context)
              .textTheme
              .displaySmall
              ?.copyWith(color: Colors.red),
        )
      ],
    );
  }
}

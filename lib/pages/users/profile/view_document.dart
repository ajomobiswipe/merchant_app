import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../config/config.dart';
import '../../../widgets/widget.dart';

class ViewDocument extends StatelessWidget {
  const ViewDocument({Key? key, this.params, this.title}) : super(key: key);
  final dynamic params;
  final dynamic title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: title.toString(),
        action: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              if (title == "National ID") ...nationalId(context),
              if (title == "Trade License") ...tradeLicense(context),
              if (title == "Cancelled Cheque") ...canceledCheque(context),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  nationalId(context) {
    return [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            Navigator.pushNamed(context, 'emiratesUpload', arguments: {
              'params': {
                "key": "National ID",
                "content": params['merchantDocs'],
                "customerFrontKycImg": params['customer']
                    ['customerFrontKycImg'],
                "customerBackKycImg": params['customer']['customerBackKycImg'],
              }
            });
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
          "National ID Front",
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
          imageUrl: Validators.urlDecrypt(params['merchantDocs']).split(',')[0],
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      )),
      const SizedBox(height: 20),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "National ID Back",
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
                Validators.urlDecrypt(params['merchantDocs']).split(',')[1],
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    ];
  }

  tradeLicense(context) {
    return [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            Navigator.pushNamed(context, 'tradeUpload', arguments: {
              'params': {
                "key": "Trade License",
                "content": params['merchantDocs'],
                "customerFrontKycImg": params['customer']
                    ['customerFrontKycImg'],
                "customerBackKycImg": params['customer']['customerBackKycImg'],
              }
            });
          },
          child: const Text(
            "Update",
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text("Trade License"),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: CachedNetworkImage(
            height: 200,
            fit: BoxFit.contain,
            width: double.maxFinite,
            imageUrl:
                Validators.urlDecrypt(params['merchantDocs']).split(',')[2],
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      )
    ];
  }

  canceledCheque(context) {
    return [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            Navigator.pushNamed(context, 'cancelChequeUpload', arguments: {
              'params': {
                "key": "Cancelled Cheque",
                "content": params['merchantDocs'],
                "customerFrontKycImg": params['customer']
                    ['customerFrontKycImg'],
                "customerBackKycImg": params['customer']['customerBackKycImg'],
              }
            });
          },
          child: const Text(
            "Update",
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text("Cancelled Cheque"),
      ),
      Card(
        child: CachedNetworkImage(
          imageUrl: Validators.urlDecrypt(params['merchantDocs']).split(',')[3],
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      )
    ];
  }
}

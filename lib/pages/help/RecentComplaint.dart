import 'package:flutter/material.dart';

class RecentComplaint extends StatelessWidget {
  const RecentComplaint(this.list, {super.key});

  final dynamic list;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Card(
              // color: Theme.of(context).cardColor,
              margin:
                  const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                leading: CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.8),
                    child: const Icon(
                      Icons.edit_note_sharp,
                      color: Colors.white,
                      size: 25,
                    )),
                title: Text(list[index]['complaintMessage'],
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.normal, fontSize: 16),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis),
                subtitle: RichText(
                  text: TextSpan(
                      text: 'Complaint Status: ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.normal, color: Colors.grey),
                      children: [
                        TextSpan(
                          text: list[index]['requestcompleted'] == 'true'
                              ? 'Solved'
                              : 'Pending',
                          style: TextStyle(
                            fontSize: 12,
                            color: list[index]['requestcompleted'] == 'true'
                                ? Colors.green
                                : Colors.red,
                          ),
                        )
                      ]),
                ),
                isThreeLine: false,
                trailing: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, 'trackRequest',
                        arguments: list[index]);
                  },
                  child: Text('Track Status',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          )),
                ),
              ),
              // onTap: () => _viewTransactionReceipt(transaction),
            ),
          );
        });
  }
}

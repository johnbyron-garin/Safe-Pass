import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/models/account_model.dart';

class FilterPopout extends StatefulWidget {
  Account account;
  FilterPopout({super.key, required this.account});

  _FilterPopoutState createState() => _FilterPopoutState();
}

class _FilterPopoutState extends State<FilterPopout> {

  @override
   Widget build(BuildContext context) {
    final TextEditingController _filterController = TextEditingController();

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Filter by:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: _filterController,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.onSurface),
                        ),
                        onPressed: () {
                          // set state na magbabago ng screen
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Apply",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer),
                        ),
                      ),
                    )
                  ],
                ),
              ),   
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.onSurface),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Close",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer),
                        ),
                      ),
                    )
                  ],
                ),
              )          
            ],
          ),
        ),
      ),
    );
  }
}

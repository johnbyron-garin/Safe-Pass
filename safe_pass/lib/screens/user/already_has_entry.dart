import 'package:flutter/material.dart';

class AlreadyHasEntry extends StatelessWidget {
  const AlreadyHasEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: ListView(
          children: [
            _title(),
            _noteCard(context)
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return const Text(
      "Add an entry",
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _noteCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
              leading: Icon(
                Icons.info_outline,
                size: 40,
              ),
              title: Text(
                "You already have an entry for today.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  "View your generated building pass QR code in Profile or modify it in Today's Entry.",
                  style: TextStyle(fontWeight: FontWeight.w300))),
        ),
      ),
    );
  }
}

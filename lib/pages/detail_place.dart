import 'dart:convert';

import 'package:favorite_place/models/favorite_place.dart';
import 'package:flutter/material.dart';

class DetailPlace extends StatelessWidget {
  final List<FavoritePlaceItem> favPlace;
  final int index;

  const DetailPlace({
    super.key,
    required this.favPlace,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(favPlace[index].name!),
            Text(
              favPlace[index].location!,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Hero(
            tag: favPlace[index].image!,
            transitionOnUserGestures: true,
            child: Container(
              height: 300,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadiusDirectional.circular(10),
                image: DecorationImage(
                    image: MemoryImage(base64Decode(favPlace[index].image!)),
                    fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

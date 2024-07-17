import 'dart:convert';

import 'package:favorite_place/pages/add_place.dart';
import 'package:favorite_place/pages/detail_place.dart';
import 'package:favorite_place/providers/data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text('My Favorite Place'),
        ),
        body: ListView.builder(
          itemCount: value.favPlaceItem.length,
          padding: const EdgeInsets.only(bottom: 70),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPlace(
                      favPlace: value.favPlaceItem,
                      index: index,
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Hero(
                    tag: value.favPlaceItem[index].image!,
                    transitionOnUserGestures: true,
                    child: Container(
                      height: 300,
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadiusDirectional.circular(10),
                        image: DecorationImage(
                            image: MemoryImage(
                                base64Decode(value.favPlaceItem[index].image!)),
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Container(
                    height: 300,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            value.favPlaceItem[index].name.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            value.favPlaceItem[index].location.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTa5YiXnTNZOpLUn_ddM58v0TfGiWUspNVA_A&s',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddPlace(),
              ),
            );
          },
          child: const Icon(
            CupertinoIcons.plus,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';

class AddPlace extends StatefulWidget {
  const AddPlace({super.key});

  @override
  State<AddPlace> createState() => _AddPlaceState();
}

class _AddPlaceState extends State<AddPlace> with TickerProviderStateMixin {
  bool photo = false;
  bool location = false;
  bool map = false;
  bool shimmer = false;

  CameraController? cameraController;
  List? cameras;
  late int selectedCameraIndex = 0;

  File? imageFile;
  final imagepicker = ImagePicker();

  final TextEditingController textEditingController = TextEditingController();

  double lat = 0.0;
  double lng = 0.0;
  String city = '';

  late final _mapController = MapController();

  Future<bool> checkLocationPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always) {
      return true;
    } else {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse) {
        return true;
      } else {
        return false;
      }
    }
  }

  getCityFormLatLng() async {
    setState(() {
      shimmer = true;
    });
    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      debugPrint(position.latitude.toString());
      debugPrint(position.longitude.toString());
      setState(() {
        city = '${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].country}';
        lat = lat;
        lng = lng;
        shimmer = false;
      });
      _mapController.move(LatLng(lat, lng), 16.0);
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  getCityFormLatLng2(double lat, double lng) async {
    setState(() {
      shimmer = true;
    });
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        lng,
      );
      setState(() {
        city = '${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].country}';
        lat = lat;
        lng = lng;
        shimmer = false;
      });
      _mapController.move(LatLng(lat, lng), 16.0);
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Marker buildMarker(LatLng coordinates) {
    // return Marker(
    //   point: coordinates,
    //   width: 100,
    //   height: 12,
    //   child: null,
    // );
    return Marker(
      point: LatLng(coordinates.latitude, coordinates.longitude),
      child: const Icon(
        CupertinoIcons.location_solid,
        color: Colors.purple,
        size: 38,
      ),
    );
  }

  Future<void> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ],
      );
      if (croppedFile != null) {
        imageCache.clear();
        setState(() {
          this.imageFile = File(croppedFile.path);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getImageFromGallery() async {
    try {
      await imagepicker.pickImage(source: ImageSource.gallery, imageQuality: 50).then((value) {
        if (value != null) {
          _cropImage(File(value.path));
          // setState(() {
          //   imageFile = File(value.path);
          // });
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getImageFromCamera() async {
    try {
      await imagepicker
          .pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      )
          .then((value) {
        if (value != null) {
          _cropImage(File(value.path));
          // setState(() {
          //   imageFile = File(value.path);
          // });
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    checkLocationPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new place'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        children: [
          imageFile != null
              ? Stack(
                  children: [
                    ClipRRect(
                      child: Container(
                        height: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                          image: DecorationImage(
                            image: FileImage(
                              imageFile!,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            imageFile!.delete();
                            imageFile = null;
                          });
                        },
                        icon: const Icon(
                          CupertinoIcons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  height: 400,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                ),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () {
                                      _getImageFromCamera();
                                    },
                                    icon: const Icon(
                                      CupertinoIcons.camera,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Add Picture',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                ),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () {
                                      _getImageFromGallery();
                                    },
                                    icon: const Icon(
                                      CupertinoIcons.photo,
                                      color: Colors.black,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Add From Gallery',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          const SizedBox(height: 20),
          TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: 'Place Name',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.4),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.4),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          shimmer
              ? Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  child: Column(
                    children: [
                      Container(
                        height: 18,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : city != ''
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.map_pin_ellipse,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            city.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
          const SizedBox(height: 20),
          Visibility(
            visible: map,
            child: Column(
              children: [
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    // image: const DecorationImage(
                    //   image: NetworkImage(
                    //     'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTa5YiXnTNZOpLUn_ddM58v0TfGiWUspNVA_A&s',
                    //   ),
                    //   fit: BoxFit.cover,
                    // ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(-6.2115983, 106.8213),
                        initialZoom: 16.0,
                        onTap: (tapPosition, point) {
                          LatLng(point.latitude, point.longitude);
                          buildMarker(point);
                          setState(() {
                            lat = point.latitude;
                            lng = point.longitude;
                            getCityFormLatLng2(lat, lng);
                          });
                          // _mapController.move(LatLng(point.latitude, point.longitude), 10.0);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://www.google.cn/maps/vt?lyrs=m@189&gl=cn&x={x}&y={y}&z={z}',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            buildMarker(LatLng(lat, lng)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.grey.shade200),
                  ),
                  onPressed: () async {
                    setState(() {
                      location = !location;
                      map = false;
                    });

                    if (await checkLocationPermission()) {
                      getCityFormLatLng();
                    }
                  },
                  icon: const Icon(
                    CupertinoIcons.location,
                    size: 14,
                  ),
                  label: const Text('Use my location'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.purple),
                  ),
                  onPressed: () {
                    setState(() {
                      map = !map;
                    });
                  },
                  icon: const Icon(
                    CupertinoIcons.map,
                    color: Colors.white,
                    size: 14,
                  ),
                  label: const Text(
                    'Choose on map',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

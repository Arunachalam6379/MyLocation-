import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share/share.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String? _currentAddress;
  Position? _currentPosition;
  bool? isLoading = false;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setStatefun(Loading: false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        setStatefun(Loading: false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setStatefun(Loading: false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    try {
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) {
        setState(() => _currentPosition = position);
        _getAddressFromLatLng(_currentPosition!);
      }).catchError((e) {
        debugPrint(e);
      });
    } finally {
      setStatefun(Loading: false);
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(_currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _shareCurrentAddress() async {
    if (_currentAddress != null) {
      await Share.share('Check out my location: $_currentAddress');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Get the current location')));
    }
  }

  void setStatefun({required bool Loading}) {
    setState(() {
      isLoading = Loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
            IconButton(
              color: Colors.white,
              icon: const Icon(
                Icons.share,
              ),
              // the method which is called
              // when button is pressed
              onPressed: () {
                onPressed:
                _shareCurrentAddress();
              },
            ),
          ],
          backgroundColor: Color.fromARGB(255, 113, 100, 209),
          title: const Text(
            "Location Page",
            style: TextStyle(color: Colors.white),
          )),
      body: SafeArea(
        child: Center(
          child: RefreshIndicator(
            onRefresh: () async {
              _getCurrentPosition();
              setStatefun(Loading: true);
            },
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isLoading == true
                          ? ShimmerLoading()
                          : _currentAddress != null
                              ? Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                    //width: 300,
                                    //height: 400,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  spreadRadius: 1,
                                                  blurRadius: 1,
                                                  offset: Offset(0, 2), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                Card(
                                                  color: Color.fromARGB(255, 113, 100, 209),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    //set border radius more than 50% of height and width to make circle
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'ADDRESS:',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(20),
                                                    child: Text(
                                                      "${_currentAddress ?? ""}",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  spreadRadius: 1,
                                                  blurRadius: 1,
                                                  offset: Offset(0, 2), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                Card(
                                                  color: Color.fromARGB(255, 113, 100, 209),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    //set border radius more than 50% of height and width to make circle
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Latitude:',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(20),
                                                    child: Text(
                                                      "${_currentPosition?.latitude ?? ""}",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  spreadRadius: 1,
                                                  blurRadius: 1,
                                                  offset: Offset(0, 2), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                Card(
                                                  color: Color.fromARGB(255, 113, 100, 209),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    //set border radius more than 50% of height and width to make circle
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Longitude:',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(20),
                                                    child: Text(
                                                      "${_currentPosition?.longitude ?? ""}",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                    ]),
                                  ),
                                )
                              : Container(),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            //set border radius more than 50% of height and width to make circle
                          ),
                          //backgroundColor: Color.fromARGB(255, 113, 100, 209),
                        ),
                        onPressed: () => {
                          _getCurrentPosition(),
                          setStatefun(Loading: true),
                        },
                        child: const Text("Get Current Location"),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget ShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ... (other widgets)
                ShimmerLoadingCard('ADDRESS:'),
                ShimmerLoadingText(_currentAddress ?? ""),
                // ... (other widgets)
                ShimmerLoadingCard('Latitude:'),
                ShimmerLoadingText("${_currentPosition?.latitude ?? ""}"),
                // ... (other widgets)
                ShimmerLoadingCard('Longitude:'),
                ShimmerLoadingText("${_currentPosition?.longitude ?? ""}"),
                // ... (other widgets)
              ],
            ),
          ),
          Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  // Helper widget for shimmer loading of card with title
  Widget ShimmerLoadingCard(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Card(
              color: Colors.grey, // Change the color as per your design
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "", // Empty text for shimmer loading
                  style: TextStyle(color: Colors.transparent),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper widget for shimmer loading of text
  Widget ShimmerLoadingText(String text) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          text,
          style: TextStyle(color: Colors.transparent),
        ),
      ),
    );
  }
}

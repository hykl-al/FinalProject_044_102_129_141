import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

import '../model/model_terkini.dart';
import '../tools/tools.dart';

class FragmentTerkini extends StatefulWidget {
  const FragmentTerkini({super.key});

  @override
  State<FragmentTerkini> createState() => _FragmentTerkiniState();
}

class _FragmentTerkiniState extends State<FragmentTerkini> {
  String strLatLong = 'Belum Mendapatkan Lat dan Long';
  String strAlamat = 'Mencari lokasi...';
  double latitude = 0;
  double longitude = 0;

  @override
  initState() {
    getData();
    super.initState();
    initializeDateFormatting();
  }

  Future getData() async {
    Position position = await getGeoLocationPosition();
    setState(() {
      VariableGlobal.strLatitude = position.latitude;
      VariableGlobal.strLongitude = position.longitude;
      strLatLong = '${position.latitude}, ${position.longitude}';
    });

    getAddressFromLongLat(position);
  }

  //getLatLong
  Future<Position> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location service Not Enabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permission denied forever, we cannot access',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  //getAddress
  Future<void> getAddressFromLongLat(Position position) async {
    latitude = position.latitude;
    longitude = position.longitude;

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    setState(() {
      strAlamat = '${place.subLocality}';
      VariableGlobal.strAlamat = strAlamat;
    });
  }

  Future getDataTerkini() async {
    var url = Uri.parse('https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['Infogempa'];
      return ModelTerkini.fromJson(data);
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFf5f7f9),
      body: FutureBuilder(
        future: getDataTerkini(),
        builder: (context, data) {
          if (data.hasError) {
            return Center(child: Text("${data.error}"));
          } else if (data.hasData) {
            var items = data.data as ModelTerkini;

            var latlong = items.strCoordinates!.split(',');
            double dlatitude = double.parse(latlong[0]);
            double dlongitude = double.parse(latlong[1]);

            double dJarak = Geolocator.distanceBetween(
                latitude, longitude, dlatitude, dlongitude);
            double distanceInKiloMeters = dJarak / 1000;
            double roundDistanceInKM =
                double.parse((distanceInKiloMeters).toStringAsFixed(2));

            return ListView(
              children: [
                SizedBox(
                  height: 16,
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const Text(
                          'Gempabumi Dirasakan',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Image(
                                      image: AssetImage(
                                          'assets/images/ic_kedalaman.png'),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.center,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          items.strMagnitude.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'Poppins'),
                                          textAlign: TextAlign.center,
                                        ),
                                        const Text(
                                          'Magnitudo',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontFamily: 'Poppins'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Image(
                                      image: AssetImage(
                                          'assets/images/ic_magnitudo_card.png'),
                                      width: 35,
                                      height: 35,
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.center,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          items.strKedalaman.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'Poppins'),
                                          textAlign: TextAlign.center,
                                        ),
                                        const Text(
                                          'Kedalaman',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontFamily: 'Poppins'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Image(
                                      image: AssetImage(
                                          'assets/images/ic_location.png'),
                                      width: 35,
                                      height: 35,
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.center,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          items.strLintang.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: 'Poppins'),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          items.strBujur.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: 'Poppins'),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),

                //Detail Section
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Detail Informasi Gempa Terasa',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Poppins'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          dense: true,
                          visualDensity:
                              const VisualDensity(horizontal: 0, vertical: -4),
                          leading: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time, color: Colors.redAccent),
                            ],
                          ),
                          title: const Text(
                            'Waktu',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Poppins'),
                          ),
                          subtitle: Text(
                              SetTime.setTime(items.strDateTime.toString()),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: 'Poppins')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          dense: true,
                          visualDensity:
                              const VisualDensity(horizontal: 0, vertical: -4),
                          leading: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.adjust_rounded,
                                  color: Colors.redAccent),
                            ],
                          ),
                          title: const Text(
                            'Wilayah Dirasakan',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Poppins'),
                          ),
                          subtitle: Text(items.strDirasakan.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: 'Poppins')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          dense: true,
                          visualDensity:
                              const VisualDensity(horizontal: 0, vertical: -4),
                          leading: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.my_location, color: Colors.redAccent),
                            ],
                          ),
                          title: const Text(
                            'Lokasi Gempa',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Poppins'),
                          ),
                          subtitle: Text(items.strWilayah.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: 'Poppins')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          dense: true,
                          visualDensity:
                              const VisualDensity(horizontal: 0, vertical: -4),
                          leading: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.share_location_sharp,
                                  color: Colors.redAccent),
                            ],
                          ),
                          title: const Text(
                            'Potensi',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Poppins'),
                          ),
                          subtitle: Text(items.strPotensi.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: 'Poppins')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          dense: true,
                          visualDensity:
                              const VisualDensity(horizontal: 0, vertical: -4),
                          leading: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.compare_arrows,
                                  color: Colors.redAccent),
                            ],
                          ),
                          title: const Text(
                            'Jarak',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Poppins'),
                          ),
                          subtitle: Text(
                            '${roundDistanceInKM.round()} KM dari ${strAlamat != null && strAlamat.isNotEmpty ? strAlamat : "Lokasi saya"}',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24,),

                //Button Section to show map
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green, // Mengatur warna latar belakang
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Mengatur border radius
                      ),
                      minimumSize: Size(size.width, 40), // Mengatur lebar dan tinggi tombol
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 550, // Menentukan tinggi modal
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch, // Mengatur agar elemen memenuhi lebar
                              children: [
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 16.0),
                                      width: 75,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(50.0)
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10,),

                                Expanded(
                                  child: Image.network(
                                    'https://data.bmkg.go.id/DataMKG/TEWS/${items.strShakemap}',
                                    fit: BoxFit.fill,
                                    alignment: Alignment.center,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child; // Jika gambar selesai dimuat
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(), // Menampilkan indikator loading
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Text(
                                          'Gambar tidak dapat dimuat',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lihat Peta Guncangan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(width: 5,),
                        Icon(Icons.place)
                      ],
                    )
                  ),
                )
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
              ),
            );
          }
        },
      ),
    );
  }
}

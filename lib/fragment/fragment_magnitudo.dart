import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:ripple_wave/ripple_wave.dart';

import '../tools/tools.dart';

class FragmentMagnitudo extends StatefulWidget {
  const FragmentMagnitudo({super.key});

  @override
  State<FragmentMagnitudo> createState() => _FragmentMagnitudoState();
}

class _FragmentMagnitudoState extends State<FragmentMagnitudo> {
  List listDataTerkini = [];
  TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredListDataTerkini = [];

  @override
  void initState() {
    super.initState();
    getData().then((data) {
      setState(() {
        listDataTerkini = data;
        filteredListDataTerkini = data;
      });
    });
  }

  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredListDataTerkini = listDataTerkini;
      });
    } else {
      setState(() {
        filteredListDataTerkini = listDataTerkini.where((item) {
          try {
            return item['Wilayah'].toLowerCase().contains(query.toLowerCase());
          } catch (e) {
            print("Error filtering data: $e");
            return false;
          }
        }).toList();
      });
    }
  }

  Future getData() async {
    var url =
        Uri.parse('https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            listDataTerkini = data['Infogempa']['gempa'];
            filteredListDataTerkini = listDataTerkini;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Menangani error yang terjadi saat request atau parsing data
      print("Error: $e");
      if (mounted) {
        setState(() {
          // Update state dengan error message atau data kosong jika diperlukan
          listDataTerkini = [];
          filteredListDataTerkini = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf5f7f9),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSearchResults,
              decoration: InputDecoration(
                hintText: "Cari Nama Wilayah",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: listDataTerkini.isEmpty
                ? Center(child: CircularProgressIndicator())
                : filteredListDataTerkini.isEmpty
                    ? Center(child: Text("No data available"))
                    : ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: filteredListDataTerkini.length,
                        itemBuilder: (context, index) {
                          var latlong = filteredListDataTerkini[index]
                                  ['Coordinates']!
                              .split(',');
                          double dlatitude = double.parse(latlong[0]);
                          double dlongitude = double.parse(latlong[1]);

                          double dJarak = Geolocator.distanceBetween(
                              VariableGlobal.strLatitude,
                              VariableGlobal.strLongitude,
                              dlatitude,
                              dlongitude);
                          double distanceInKiloMeters = dJarak / 1000;
                          double roundDistanceInKM = double.parse(
                              (distanceInKiloMeters).toStringAsFixed(2));

                          return GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                isDismissible: true,
                                enableDrag: false,
                                context: context,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20))),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                builder: (BuildContext context) {
                                  return ListView(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            width: 75,
                                            height: 5,
                                            decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        50.0)),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Gempa Bumi Dirasakan',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Poppins'),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
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
                                                          alignment:
                                                              Alignment.center,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              filteredListDataTerkini[
                                                                      index]
                                                                  ['Magnitude'],
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontFamily:
                                                                      'Poppins'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            const Text(
                                                              'Magnitudo',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      'Poppins'),
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
                                                          alignment:
                                                              Alignment.center,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              filteredListDataTerkini[
                                                                      index]
                                                                  ['Kedalaman'],
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontFamily:
                                                                      'Poppins'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            const Text(
                                                              'Kedalaman',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      'Poppins'),
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
                                                          alignment:
                                                              Alignment.center,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              filteredListDataTerkini[
                                                                      index]
                                                                  ['Lintang'],
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Poppins'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            Text(
                                                              filteredListDataTerkini[
                                                                      index]
                                                                  ['Bujur'],
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Poppins'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
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
                                      Card(
                                        margin: const EdgeInsets.all(10),
                                        clipBehavior: Clip.antiAlias,
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                dense: true,
                                                visualDensity:
                                                    const VisualDensity(
                                                        horizontal: 0,
                                                        vertical: -4),
                                                leading: const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.access_time,
                                                        color:
                                                            Colors.redAccent),
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
                                                    SetTime.setTime(
                                                        filteredListDataTerkini[
                                                            index]['DateTime']),
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
                                                    const VisualDensity(
                                                        horizontal: 0,
                                                        vertical: -4),
                                                leading: const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .share_location_sharp,
                                                        color:
                                                            Colors.redAccent),
                                                  ],
                                                ),
                                                title: const Text(
                                                  'Potensi',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontFamily: 'Poppins'),
                                                ),
                                                subtitle: Text(
                                                    filteredListDataTerkini[
                                                        index]['Potensi'],
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
                                                    const VisualDensity(
                                                        horizontal: 0,
                                                        vertical: -4),
                                                leading: const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.my_location,
                                                        color:
                                                            Colors.redAccent),
                                                  ],
                                                ),
                                                title: const Text(
                                                  'Lokasi Gempa',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontFamily: 'Poppins'),
                                                ),
                                                subtitle: Text(
                                                    filteredListDataTerkini[
                                                        index]['Wilayah'],
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
                                                    const VisualDensity(
                                                        horizontal: 0,
                                                        vertical: -4),
                                                leading: const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.compare_arrows,
                                                        color:
                                                            Colors.redAccent),
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
                                                    '${roundDistanceInKM.round()} KM dari ${VariableGlobal.strAlamat}',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontFamily: 'Poppins')),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.all(10),
                              clipBehavior: Clip.antiAlias,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              color: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                  left: BorderSide(
                                    color: double.parse(
                                                filteredListDataTerkini[index]
                                                    ['Magnitude']) >=
                                            6
                                        ? Colors.redAccent
                                        : Colors.lightBlue,
                                    width: 5,
                                  ),
                                )),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        isThreeLine: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: SizedBox(
                                            width: 90,
                                            height: double.infinity,
                                            child: Stack(
                                              children: [
                                                RippleWave(
                                                  color: double.parse(
                                                              filteredListDataTerkini[
                                                                      index][
                                                                  'Magnitude']) >=
                                                          6
                                                      ? Colors.redAccent
                                                      : Colors.lightBlue,
                                                  repeat: true,
                                                  child: const SizedBox(),
                                                ),
                                                Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                    filteredListDataTerkini[
                                                        index]['Magnitude'],
                                                    style: TextStyle(
                                                        color: double.parse(
                                                                    filteredListDataTerkini[
                                                                            index]
                                                                        [
                                                                        'Magnitude']) >=
                                                                6
                                                            ? Colors.redAccent
                                                            : Colors.lightBlue,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'Poppins'),
                                                  ),
                                                ),
                                              ],
                                            )),
                                        title: Text(
                                          filteredListDataTerkini[index]
                                              ['Wilayah'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins'),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Icon(Icons.access_time,
                                                    color: Colors.redAccent,
                                                    size: 16),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                      SetTime.setTime(
                                                          filteredListDataTerkini[
                                                                  index]
                                                              ['DateTime']),
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontFamily:
                                                              'Poppins')),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.compare_arrows,
                                                    color: Colors.redAccent,
                                                    size: 16),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                      '${roundDistanceInKM.round()} KM dari ${VariableGlobal.strAlamat}',
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontFamily:
                                                              'Poppins')),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: const SizedBox(
                                            height: double.infinity,
                                            child: Icon(Icons
                                                .keyboard_arrow_right_outlined)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }
}

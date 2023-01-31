import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/config.dart';
import '../model/homestay.dart';
import '../model/user.dart';
import '../shared/mainmenu.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'detailscreen.dart';
import 'newhomestayscreen.dart';
import 'package:intl/intl.dart';
import 'package:ndialog/ndialog.dart';

class SellerScreen extends StatefulWidget {
  final User user;
  const SellerScreen({super.key, required this.user});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  var _lat, _lng;
  late Position position;
  var placemarks;
  String titlecenter = "Loading...";
  List<Homestay> homestayList = <Homestay>[];
  final df = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    loadHomestay();
  }

  @override
  void dispose() {
    homestayList = [];
    print("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async => false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Seller'),
        actions:[
        PopupMenuButton(
          itemBuilder: (context) {
          return[
            const PopupMenuItem<int>(
                  value: 0,
                  child: Text("New Product"),
            ),
            const PopupMenuItem<int>(
                  value: 1,
                  child: Text("My Order"),
            )
          ];
          },onSelected: (value){
            if (value == 0) {
                gotoNewProduct();
                print("My account menu is selected.");
              } else if (value == 1) {
                print("Settings menu is selected.");
              } else if (value == 2) {
                print("Logout menu is selected.");
              }
        }),
      ]),
      body: homestayList.isEmpty
      ? Center(
          child: Text(titlecenter,
            style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold)))
      : Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: List.generate(homestayList.length, (index){
                  return Card(
                    child: InkWell(
                      onTap: () {
                         showDetails(index);
                      },
                      onLongPress: () {
                          deleteDialog(index);
                      },
                      child: Column(children:[
                      Flexible(
                        flex: 6,
                        child: CachedNetworkImage(
                          width: 150,
                          fit: BoxFit.cover,
                          imageUrl: "${ServerConfig.server}/homestayfinal/assets/homestayimages/${homestayList[index].userId}.png",
                          placeholder: (context, url) => 
                            const LinearProgressIndicator(),
                          errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(truncateString(homestayList[index].homestayName.toString(),15),
                                style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                              Text("RM ${double.parse(homestayList[index].homestayPrice.toString()).toStringAsFixed(2)}"),
                              Text(df.format(DateTime.parse(homestayList[index].homestayDate.toString()))),
                            ],
                          ),
                        )
                      )
                    ]),
                    ),
                  );
                }),
              ),
            )
          ],
        ),
      drawer: MainMenuWidget(user: widget.user)),
      );
  }

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  Future<void> gotoNewProduct() async {
    if (widget.user.id == "0") {
      Fluttertoast.showToast(
          msg: "Please login/register",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (await checkPermissionGetLoc()) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (content) => NewHomestayScreen(
                  position: position,
                  user: widget.user,
                  placemarks: placemarks)));
      loadHomestay();
    } else {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }

  Future<bool> checkPermissionGetLoc() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: "Please allow the app to access the location",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        Geolocator.openLocationSettings();
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      Geolocator.openLocationSettings();
      return false;
    }
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    try {
      placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
    } catch (e) {
      Fluttertoast.showToast(
          msg:
              "Error in fixing your location. Make sure internet connection is available and try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return false;
    }
   return true;
  }

  void loadHomestay() {
    if (widget.user.id == "0") {
      //check if the user is registered or not
      Fluttertoast.showToast(
          msg: "Please register an account first", //Show toast
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
          titlecenter = "Please register an account";
          setState(() {
            
          });
      return; //exit method if true
    }
    //if registered user, continue get request
    http.get(Uri.parse("${ServerConfig.server}/homestayfinal/php/loadsellerhomestay.php?userid=${widget.user.id}"),
    )
        .then((response) {
      // wait for response from the request
      if (response.statusCode == 200) {
        //if statuscode OK
        var jsondata =
            jsonDecode(response.body); //decode response body to jsondata array
        if (jsondata['status'] == 'success') {
          //check if status data array is success
          var extractdata = jsondata['data']; //extract data from jsondata array
          if (extractdata['homestay'] != null) {
            //check if  array object is not null
            homestayList = <Homestay>[]; //complete the array object definition
            extractdata['homestay'].forEach((v) {
              //traverse products array list and add to the list object array productList
              homestayList.add(Homestay.fromJson(
                  v)); //add each product array to the list object array productList
            });
            titlecenter = "Found";
          } else {
            titlecenter =
                "No Homestay Available"; //if no data returned show title center
            homestayList.clear();
          }
        } else {
          titlecenter = "No Homestay Available";
        }
      } else {
        titlecenter = "No Homestay Available"; //status code other than 200
        homestayList.clear(); //clear productList array
      }
      setState(() {}); //refresh UI
    });
  }

  Future<void> showDetails(int index) async {
    Homestay homestay = Homestay.fromJson(homestayList[index].toJson());

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => DetailsScreen(
                  homestay: homestay,
                  user: widget.user,
                )));
    loadHomestay();
  }

  deleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text(
            "Delete ${truncateString(homestayList[index].homestayName.toString(), 15)}",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                deleteProduct(index);
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void deleteProduct(index) {
    try {
      http.post(Uri.parse("${ServerConfig.server}/homestayfinal/php/delete_homestay.php"), body: {
        "homestayid": homestayList[index].homestayId,
      }).then((response) {
        var data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['status'] == "success") {
          Fluttertoast.showToast(
              msg: "Success",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          loadHomestay();
          return;
        } else {
          Fluttertoast.showToast(
              msg: "Failed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          return;
        }
      });
    } catch (e) {
      print("An exception was thrown: $e");
    }
  }
  
}
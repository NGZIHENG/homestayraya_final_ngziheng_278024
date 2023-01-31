import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../model/config.dart';
import '../model/user.dart';
import 'package:http/http.dart' as http;


class NewHomestayScreen extends StatefulWidget {
  final User user;
  final Position position;
  final List<Placemark> placemarks;
  const NewHomestayScreen({super.key, required this.user, required this.position, required this.placemarks});

  @override
  State<NewHomestayScreen> createState() => _NewHomestayScreenState();
}

class _NewHomestayScreenState extends State<NewHomestayScreen> {
  final TextEditingController homestayidEditingController = TextEditingController();
  final TextEditingController homestaynameEditingController = TextEditingController();
  final TextEditingController homestaydescEditingController = TextEditingController();
  final TextEditingController homestaypriceEditingController = TextEditingController();
  final TextEditingController bedroomqtyEditingController = TextEditingController();
  final TextEditingController guestqtyEditingController = TextEditingController();
  final TextEditingController homestaystateEditingController = TextEditingController();
  final TextEditingController homestaylocalEditingController = TextEditingController();
  late Position position;
  final _formKey = GlobalKey<FormState>();
  var _lat, _lng;

  @override
  void initState(){
    super.initState();
    // _checkPermissionGetLoc();
    _lat = widget.position.latitude.toString();
    _lng = widget.position.longitude.toString();
    getAddress();
    homestaystateEditingController.text = widget.placemarks[0].administrativeArea.toString();
    homestaylocalEditingController.text = widget.placemarks[0].locality.toString();
  }
  File?_image;
  var pathAsset = "assets/take-a-photo.png";
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("New Homestay")), 
    body: SingleChildScrollView(
      child: Column(children: [
        GestureDetector(
          onTap: selectImageDialog,
          child: Card(
          elevation: 8,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _image == null
                ? AssetImage(pathAsset)
                : FileImage(_image!) as ImageProvider,
              fit: BoxFit.scaleDown,
              )
            ),
          ),
         ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Add New Homestay", 
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: homestaynameEditingController,
                  validator: (val) => val!.isEmpty || (val.length < 3)
                    ? "Homestay name must be longer than 3"
                    : null,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Homestay Name',
                    labelStyle: TextStyle(),
                    icon: Icon(Icons.home),
                    focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
              ))),
              TextFormField(
                textInputAction: TextInputAction.next,
                controller: homestaydescEditingController,
                validator: (val) => val!.isEmpty || (val.length < 10)
                    ? "Homestay description must be longer than 10"
                    : null,
                  maxLines: 4,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Homestay Description',
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(),
                    icon: Icon(Icons.home,),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0),
              ))),
              Row(
                    children: [
                      Flexible(
                        flex: 5,
                        child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: homestaypriceEditingController,
                            validator: (val) => val!.isEmpty
                                ? "Homestay price must contain value"
                                : null,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Homestay Price',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.money),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                      ),
                      Flexible(
                        flex: 5,
                        child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: bedroomqtyEditingController,
                            validator: (val) => val!.isEmpty
                                ? "Quantity should be more than 0"
                                : null,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Bedroom Quantity',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.bed),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                        ),
                      ],
                ),
                Row(children: [
                    Flexible(
                      flex: 5,
                      child: TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: guestqtyEditingController,
                          validator: (val) =>
                              val!.isEmpty ? "Must be more than zero" : null,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Guest Quantity',
                              labelStyle: TextStyle(),
                              icon: Icon(Icons.person),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 2.0),
                              ))),
                    ),
                    Flexible(
                        flex: 5,
                        child: CheckboxListTile(
                          title: const Text("Policy"), //    <-- label
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = value!;
                            });
                          },
                      )),
                  ]),
                Row(
                    children: [
                      Flexible(
                          flex: 5,
                          child: TextFormField(
                              textInputAction: TextInputAction.next,
                              validator: (val) =>
                                  val!.isEmpty || (val.length < 3)
                                      ? "Current State"
                                      : null,
                              enabled: false,
                              controller: homestaystateEditingController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  labelText: 'Current States',
                                  labelStyle: TextStyle(),
                                  icon: Icon(Icons.flag),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0),
                                  )))),
                      Flexible(
                        flex: 5,
                        child: TextFormField(
                            textInputAction: TextInputAction.next,
                            enabled: false,
                            validator: (val) => val!.isEmpty || (val.length < 3)
                                ? "Current Locality"
                                : null,
                            controller: homestaylocalEditingController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                labelText: 'Current Locality',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.map),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      child: const Text('Add Homestay'),
                      onPressed: () => {
                        newHomestayDialog(),
                      },
                    ),
                  ),
            ])
          )
        )
      ]),
    ));
  }
  
  newHomestayDialog() {
    if (_image == null) {
      Fluttertoast.showToast(
          msg: "Please take picture of your product/service",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please complete the form first",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    if (!_isChecked) {
      Fluttertoast.showToast(
          msg: "Please check agree checkbox",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Insert this product/service?",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                insertProduct();
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

  void selectImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: const Text(
              "Select picture from:",
              style: TextStyle(),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    iconSize: 64,
                    onPressed: onCamera,
                    icon: const Icon(Icons.camera)),
                IconButton(
                    iconSize: 64,
                    onPressed: onGallery,
                    icon: const Icon(Icons.browse_gallery)),
              ],
            ));
      },
    );
  }

  Future<void> onCamera() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    } else {
      print('No image selected.');
    }
  }

  Future<void> onGallery() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
      //setState(() {});
    } else {
      print('No image selected.');
    }
  }

  Future<void> cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        // CropAspectRatioPreset.ratio3x2,
        // CropAspectRatioPreset.original,
        // CropAspectRatioPreset.ratio4x3,
        // CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);
      _image = imageFile;
      setState(() {});
    }
  }

  getAddress() async{
    List<Placemark> placemarks = await placemarkFromCoordinates(widget.position.latitude,widget.position.longitude);
    setState(() {
      homestaystateEditingController.text = placemarks[0].administrativeArea.toString();
      homestaylocalEditingController.text = placemarks[0].locality.toString();
    });
  }
  
  void insertProduct() {
    String homestayid = homestayidEditingController.text;
    String homestayname = homestaynameEditingController.text;
    String homestaydesc = homestaydescEditingController.text;
    String homestayprice = homestaypriceEditingController.text;
    String bedroomqty = bedroomqtyEditingController.text;
    String guestqty = guestqtyEditingController.text;
    String homestaystate = homestaystateEditingController.text;
    String homestaylocal = homestaylocalEditingController.text;
    String base64Image = base64Encode(_image!.readAsBytesSync());

    http.post(Uri.parse("${ServerConfig.server}/homestayfinal/php/insert_homestay.php"), body: {
      "userid": widget.user.id,
      "homestayname": homestayname,
      "homestaydesc": homestaydesc,
      "homestayprice": homestayprice,
      "bedroomqty": bedroomqty,
      "guestqty": guestqty,
      "homestaystate": homestaystate,
      "homestaylocal": homestaylocal,
      "lat": _lat,
      "lng": _lng,
      "image": base64Image
    }).then((response) {
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == "success") {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
            Navigator.of(context).pop();
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
  }
}
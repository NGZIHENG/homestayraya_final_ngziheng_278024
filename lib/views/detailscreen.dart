import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/config.dart';
import '../model/homestay.dart';
import '../model/user.dart';


class DetailsScreen extends StatefulWidget {
  final Homestay homestay;
  final User user;
  const DetailsScreen({
    Key? key,
    required this.homestay,
    required this.user,
  }) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final TextEditingController homestayidEditingController = TextEditingController();
  final TextEditingController homestaynameEditingController = TextEditingController();
  final TextEditingController homestaydescEditingController = TextEditingController();
  final TextEditingController homestaypriceEditingController = TextEditingController();
  final TextEditingController bedroomqtyEditingController = TextEditingController();
  final TextEditingController guestqtyEditingController = TextEditingController();
  final TextEditingController homestaystateEditingController = TextEditingController();
  final TextEditingController homestaylocalEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File?_image;
  bool _isChecked = false;
  var pathAsset = "assets/take-a-photo.png";

  @override
  void initState() {
    super.initState();
    homestaynameEditingController.text = widget.homestay.homestayName.toString();
    homestaydescEditingController.text = widget.homestay.homestayDesc.toString();
    homestaypriceEditingController.text = widget.homestay.homestayPrice.toString();
    bedroomqtyEditingController.text = widget.homestay.bedroomQty.toString();
    guestqtyEditingController.text = widget.homestay.guestQty.toString();
    homestaystateEditingController.text = widget.homestay.homestayState.toString();
    homestaylocalEditingController.text = widget.homestay.homestayLocal.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Homestay Details")), 
    body: SingleChildScrollView(
      child: Column(children: [
        Card(
          elevation: 8,
          child: Container(
             child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl:"${ServerConfig.server}/homestayfinal/assets/homestayimages/${widget.homestay.userId}.png",
                    placeholder: (context, url) =>
                        const LinearProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
              )
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
                  "Edit Homestay", 
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
                      child: const Text('Update Homestay'),
                      onPressed: () => {
                        updateHomestayDialog(),
                      },
                    ),
                  ),
            ])
          )
        )
      ]),
    ));
  }
  
  updateHomestayDialog() {
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
                updateProduct();
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
  
  void updateProduct() {
    String homestayname = homestaynameEditingController.text;
    String homestaydesc = homestaydescEditingController.text;
    String homestayprice = homestaypriceEditingController.text;
    String bedroomqty = bedroomqtyEditingController.text;
    String guestqty = guestqtyEditingController.text;

    http.post(Uri.parse("${ServerConfig.server}/homestayfinal/php/update_homestay.php"), body: {
      "homestayid": widget.homestay.homestayId,
      "userid": widget.user.id,
      "homestayname": homestayname,
      "homestaydesc": homestaydesc,
      "homestayprice": homestayprice,
      "bedroomqty": bedroomqty,
      "guestqty": guestqty,
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

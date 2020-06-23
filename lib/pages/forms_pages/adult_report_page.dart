import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_photo_button_widget.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/could_see_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/mosquito_parts_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/mosquito_type_form.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'breeding_report_page.dart';
import 'components/biting_location_form.dart';

class AdultReportPage extends StatefulWidget {
  final Report editReport;
  final Function loadData;

  AdultReportPage({this.editReport, this.loadData});
  @override
  _AdultReportPageState createState() => _AdultReportPageState();
}

class _AdultReportPageState extends State<AdultReportPage> {
  PageController _pagesController;
  List<Widget> _formsRepot;
  StreamController<bool> loadingStream = new StreamController<bool>.broadcast();
  StreamController<bool> validStream = new StreamController<bool>.broadcast();

  List<Map> displayQuestions = [
    {
      "question": {
        "id": 6,
        "text": {
          "en": "What kind of mosquito do you think it is?",
          "ca": "Quin tipus de mosquit creus que és?",
          "es": "¿Que tipo de mosquito crees que es?"
        }
      },
      "answers": [
        {
          "id": 61,
          "img": "assets/img/ic_aedes.png",
          "text": {
            "en": "Invasive Aedes",
            "ca": "Aedes Invasiu",
            "es": "Invasive Aedes"
          }
        },
        {
          "id": 62,
          "img": "assets/img/ic_cluex.png",
          "text": {
            "en": "Common mosquito",
            "ca": "Mosquit comú",
            "es": "Mosquito común"
          }
        },
        {
          "id": 63,
          "img": "assets/img/ic_other_mosquito.png",
          "text": {
            "en": "Other",
            "ca": "Altres",
            "es": "Otro",
          }
        }
      ]
    },
    {
      "question": {
        "id": 7,
        "text": {
          "en": "How does your mosquito look?",
          "ca": "Quin aspecte té el teu mosquit?",
          "es": "¿Que aspecto tiene tu mosquito?"
        }
      },
      "answers": [
        [
          {
            "id": 711,
            "img": "assets/img/torax_711.png",
            "text": {"en": "Thorax 1", "ca": "Tòrax 1", "es": "Tórax 1"}
          },
          {
            "id": 712,
            "img": "assets/img/torax_712.png",
            "text": {"en": "Thorax 2", "ca": "Tòrax 2", "es": "Tórax 21"}
          },
          {
            "id": 713,
            "img": "assets/img/torax_713.png",
            "text": {"en": "Thorax 3", "ca": "Tòrax 3", "es": "Tórax 3"}
          },
          {
            "id": 714,
            "img": "assets/img/torax_714.png",
            "text": {"en": "Thorax 4", "ca": "Tòrax 4", "es": "Tórax 1"}
          },
        ],
        [
          {
            "id": 721,
            "img": "assets/img/abdomen_721.png",
            "text": {"en": "Abdomen 1", "ca": "Abdomen 1", "es": "Abdomen 1"}
          },
          {
            "id": 722,
            "img": "assets/img/abdomen_722.png",
            "text": {"en": "Abdomen 2", "ca": "Abdomen 2", "es": "Abdomen 2"}
          },
          {
            "id": 723,
            "img": "assets/img/abdomen_723.png",
            "text": {"en": "Abdomen 3", "ca": "Abdomen 3", "es": "Abdomen 3"}
          },
          {
            "id": 724,
            "img": "assets/img/abdomen_724.png",
            "text": {"en": "Abdomen 4", "ca": "Abdomen 4", "es": "Abdomen 4"}
          },
        ],
        [
          {
            "id": 731,
            "img": "assets/img/leg_731.png",
            "text": {"en": "3d leg 1", "ca": "3a cama 1", "es": "Pierna 1"}
          },
          {
            "id": 732,
            "img": "assets/img/leg_732.png",
            "text": {"en": "3d leg 2", "ca": "3a cama 2", "es": "Pierna 2"}
          },
          {
            "id": 733,
            "img": "assets/img/leg_733.png",
            "text": {"en": "3d leg 3", "ca": "3a cama 3", "es": "Pierna 3"}
          },
          {
            "id": 734,
            "img": "assets/img/leg_734.png",
            "text": {"en": "3d leg 4", "ca": "3a cama 4", "es": "Pierna 4"}
          }
        ],
      ]
    },
    {
      "question": {
        "id": 8,
        "text": {
          "en": "Did this mosquito bite you?",
          "ca": "T'ha picat el mosquit?",
          "es": "¿Te ha picado el mosquito?"
        }
      },
      "answers": [
        {
          "id": 101,
          "text": {"en": "Yes", "ca": "Sí", "es": "Si"}
        },
        {
          "id": 81,
          "text": {"en": "No", "ca": "No", "es": "No"}
        },
      ]
    }
  ];

  bool skip3 = false;
  bool addBiting = false;
  bool validContent = false;
  bool showCamera = false;
  String otherReport;

  @override
  void initState() {
    super.initState();
    if (widget.editReport != null) {
      Utils.setEditReport(widget.editReport);
      validContent = true;
    }
    _pagesController = PageController();
  }

  setSkip3(skip) {
    setState(() {
      skip3 = skip;
    });
  }

  setShowCamera(data) {
    setState(() {
      showCamera = data;
    });
  }

  addBitingReport(addReport) {
    setState(() {
      addBiting = addReport;
    });
  }

  addOtherReport(String reportType) {
    setState(() {
      otherReport = reportType;
    });
  }

  setValid(isValid) {
    validStream.add(isValid);
    // setState(() {
    //   validContent = isValid;
    // });
  }

  navigateOtherReport() async {
    switch (otherReport) {
      case "bite":
        Utils.addOtherReport("bite");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BitingReportPage()),
        );
        break;
      case "site":
        Utils.addOtherReport("site");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BreedingReportPage()),
        );
        break;
      case "adult":
        Utils.addOtherReport("adult");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdultReportPage()),
        );
        break;
      default:
        loadingStream.add(true);
        bool res = await Utils.createReport();

        !res ? _showAlertKo() : _showAlertOk();
        if (widget.editReport != null) {
          widget.loadData();
        }

        break;
    }
  }

  @override
  void dispose() {
    _pagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _formsRepot = [
      MosquitoTypeForm(
          setSkip3, displayQuestions.elementAt(0), setValid, setShowCamera),
      // AddPhotoButton(),
      MosquitoPartsForm(displayQuestions.elementAt(1), setValid),
      BitingLocationForm(setValid),
      CouldSeeForm(addBitingReport, displayQuestions.elementAt(2), setValid),
      AddOtherReportPage(addOtherReport, setValid, 0.0),
    ];

    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(
              icon: Style.iconBack,
              onPressed: () {
                double currentPage = _pagesController.page;
                if (currentPage == 0.0) {
                  if (Utils.reportsList != null &&
                      Utils.reportsList.isNotEmpty) {
                    Utils.deleteLastReport();
                  } else {
                    Utils.resetReport();
                  }
                  Navigator.pop(context);
                } else if (currentPage == 2.0 && skip3) {
                  _pagesController
                      .animateToPage(0,
                          duration: Duration(microseconds: 300),
                          curve: Curves.ease)
                      .then((value) => setValid(true));
                } else {
                  _pagesController
                      .previousPage(
                          duration: Duration(microseconds: 300),
                          curve: Curves.ease)
                      .then((value) {
                    setValid(true);
                    addOtherReport(null);
                  });
                }
              },
            ),
            title: Style.title(
                MyLocalizations.of(context, "adult_report_title"),
                fontSize: 16),
            // actions: <Widget>[
            //   StreamBuilder<bool>(
            //       stream: validStream.stream,
            //       initialData: false,
            //       builder: (BuildContext ctxt, AsyncSnapshot<bool> snapshot) {
            //         return Style.noBgButton(
            //             _pagesController.hasClients &&
            //                     _pagesController.page ==
            //                         _formsRepot.length - 1 &&
            //                     otherReport == 'none'
            //                 ? MyLocalizations.of(context, "finish")
            //                 : MyLocalizations.of(context, "next"),
            //             snapshot.data
            //                 ? () {
            //                     double currentPage = _pagesController.page;
            //                     if (currentPage == _formsRepot.length - 1 &&
            //                         !addBiting) {
            //                       navigateOtherReport();
            //                     } else if (currentPage == 3.0 && addBiting) {
            //                       Utils.addOtherReport('bite');
            //                       Navigator.push(
            //                         context,
            //                         MaterialPageRoute(
            //                             builder: (context) =>
            //                                 BitingReportPage()),
            //                       );
            //                     } else if (currentPage == 0.0 && skip3) {
            //                       _pagesController
            //                           .animateToPage(2,
            //                               duration: Duration(microseconds: 300),
            //                               curve: Curves.ease)
            //                           .then((value) =>
            //                               setValid(widget.editReport != null));
            //                     } else {
            //                       _pagesController
            //                           .nextPage(
            //                               duration: Duration(microseconds: 300),
            //                               curve: Curves.ease)
            //                           .then((value) =>
            //                               setValid(widget.editReport != null));
            //                     }
            //                   }
            //                 : null);
            //       })
            // ],
          ),
          body: Stack(
            children: <Widget>[
              PageView(
                controller: _pagesController,
                // itemCount: _formsRepot.length,
                physics: NeverScrollableScrollPhysics(),
                // itemBuilder: (BuildContext context, int index) {
                //   return _formsRepot[index];
                // }),
                children: _formsRepot,
                //  <Widget>[
                //   MosquitoTypeForm(
                //       setSkip3, displayQuestions.elementAt(0), setValid),
                //   MosquitoPartsForm(displayQuestions.elementAt(1), setValid),
                //   BitingLocationForm(setValid),
                //   CouldSeeForm(
                //       addBitingReport, displayQuestions.elementAt(2), setValid),
                //   AddOtherReportPage(addOtherReport, setValid),
                // ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: StreamBuilder<bool>(
                    stream: validStream.stream,
                    initialData: false,
                    builder: (BuildContext ctxt, AsyncSnapshot<bool> snapshot) {
                      return snapshot.data
                          ? GestureDetector(
                              onTap: () {
                                double currentPage = _pagesController.page;
                                if (currentPage == _formsRepot.length - 1 &&
                                    !addBiting) {
                                  navigateOtherReport();
                                } else if (currentPage == 3.0 && addBiting) {
                                  Utils.addOtherReport('bite');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BitingReportPage()),
                                  );
                                } else if (currentPage == 0.0 && skip3) {
                                  _pagesController
                                      .animateToPage(2,
                                          duration: Duration(microseconds: 300),
                                          curve: Curves.ease)
                                      .then((value) =>
                                          setValid(widget.editReport != null));
                                } else {
                                  if (showCamera) {
                                    _chooseTypeImage();
                                  } else {
                                    _pagesController
                                        .nextPage(
                                            duration:
                                                Duration(microseconds: 300),
                                            curve: Curves.ease)
                                        .then((value) => setValid(
                                            widget.editReport != null));
                                  }
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Style.colorPrimary,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Style.body(
                                    MyLocalizations.of(context, "continue_txt"),
                                    textAlign: TextAlign.center,
                                    color: Colors.white),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Style.body(
                                  MyLocalizations.of(
                                      context, "complete_all_txt"),
                                  textAlign: TextAlign.center,
                                  color: Colors.white),
                            );
                    }),
              ),
            ],
          ),
        ),
        StreamBuilder<bool>(
          stream: loadingStream.stream,
          initialData: false,
          builder: (BuildContext ctxt, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData == false || snapshot.data == false) {
              return Container();
            }
            return Utils.loading(
              snapshot.data,
            );
          },
        )
      ],
    );
  }

  _chooseTypeImage() {
    List<Widget> listForiOS = <Widget>[
      CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
          getGalleryImages();
        },
        child: Text(
          MyLocalizations.of(context, 'gallery'),
          style: TextStyle(color: Colors.blue),
        ),
      ),
      CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
          _showInfoImage();
        },
        child: Text(
          MyLocalizations.of(context, 'camara'),
          style: TextStyle(color: Colors.blue),
        ),
      ),
    ];
    List<Widget> listForAndroid = <Widget>[
      InkWell(
        onTap: () {
          Navigator.pop(context);
          _showInfoImage();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Text(MyLocalizations.of(context, 'camara'),
              style: TextStyle(color: Colors.blue, fontSize: 15)),
        ),
      ),
      Divider(height: 1.0),
      InkWell(
        onTap: () {
          Navigator.pop(context);
          getGalleryImages();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Text(MyLocalizations.of(context, 'gallery'),
              style: TextStyle(color: Colors.blue, fontSize: 15)),
        ),
      ),
    ];

    Utils.modalDetailTrackingforPlatform(
        Theme.of(context).platform == TargetPlatform.iOS
            ? listForiOS
            : listForAndroid,
        Theme.of(context).platform,
        context, () {
      Navigator.pop(context);
    });
  }

  getGalleryImages() async {
    List<File> files = await FilePicker.getMultiFile(
      type: FileType.image,
    );

    if (files != null) {
      setShowCamera(false);
      _pagesController
          .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
          .then((value) => setValid(widget.editReport != null));
    }

    if (files != null) {
      files.forEach((image) {
        Utils.saveImgPath(image);
      });
    }
  }

  _showInfoImage() {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: Container(
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Style.body(
                    " Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently",
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Style.noBgButton(
                        MyLocalizations.of(context, "ok_next_txt"),
                        () {
                          Navigator.of(context).pop();
                          getImage(ImageSource.camera);
                        },
                        textColor: Style.colorPrimary,
                      ),
                      Style.noBgButton(
                        MyLocalizations.of(context, "close"),
                        () {
                          Navigator.of(context).pop();
                        },
                        // textColor: Style.colorPrimary,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Future getImage(source) async {
    var image = await ImagePicker.pickImage(
      source: source,
    );

    if (image != null) {
      Utils.saveImgPath(image);
      setShowCamera(false);
      _pagesController
          .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
          .then((value) => setValid(widget.editReport != null));
    }
  }

  _showAlertOk() {
    loadingStream.add(false);
    Utils.showAlert(
      MyLocalizations.of(context, "app_name"),
      MyLocalizations.of(context, 'save_report_ok_txt'),
      context,
      onPressed: () {
        Navigator.pop(context);
        if (widget.editReport != null) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      barrierDismissible: false,
    );
  }

  _showAlertKo() {
    loadingStream.add(false);
    Utils.showAlert(
      MyLocalizations.of(context, "app_name"),
      MyLocalizations.of(context, 'save_report_ko_txt'),
      context,
      onPressed: () {
        Navigator.pop(context);
        if (widget.editReport != null) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      barrierDismissible: false,
    );
  }
}

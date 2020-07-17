import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/biting_location_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/could_see_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/questions_breeding_form.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BreedingReportPage extends StatefulWidget {
  final Report editReport;
  final Function loadData;

  BreedingReportPage({this.editReport, this.loadData});
  @override
  _BreedingReportPageState createState() => _BreedingReportPageState();
}

class _BreedingReportPageState extends State<BreedingReportPage> {
  PageController _pagesController;
  List<Widget> _formsRepot;
  StreamController<bool> loadingStream = new StreamController<bool>.broadcast();
  StreamController<bool> validStream = new StreamController<bool>.broadcast();
  StreamController<double> percentStream =
      new StreamController<double>.broadcast();

  List<Map> displayQuestions = [
    {
      "question": {
        "id": 9,
        "text": {
          "en": "It's a public or a private location?",
          "ca": "Estàs a un lloc públic o propietat privada?",
          "es": "Estàs a un lloc públic o propietat privada?"
        }
      },
      "answers": [
        {
          "id": 91,
          "text": {
            "en": "Public place",
            "ca": "Lloc públic",
            "es": "Lloc públic",
          }
        },
        {
          "id": 92,
          "text": {
            "en": "Private location",
            "ca": "Propietat privada",
            "es": "Propietat privada",
          }
        }
      ]
    },
    {
      "question": {
        "id": 10,
        "text": {
          "en": "Does it have water?",
          "ca": "Hi ha aigua?",
          "es": "Hi ha aigua?",
        }
      },
      "answers": [
        {
          "id": 101,
          "text": {"en": "Yes", "ca": "Sí", "es": "Sí"}
        },
        {
          "id": 81,
          "text": {"en": "No", "ca": "No", "es": "No"}
        }
      ]
    },
    {
      "question": {
        "id": 11,
        "text": {
          "en": "Have you seen mosquitoes around?",
          "ca": "Has vist mosquits a la vora?",
          "es": "¿Has visto mosquitos alrededor?"
        }
      },
      "answers": [
        {
          "id": 111,
          "text": {"en": "Mosquito", "ca": "Mosquit", "es": "Mosquito"}
        },
        {
          "id": 112,
          "text": {"en": "Bite", "ca": "Picada", "es": "Picadura"}
        },
        {
          "id": 81,
          "text": {"en": "No", "ca": "No", "es": "No"}
        },
      ]
    },
    {
      "question": {
        "id": 12,
        "text": {
          "en": "Is it a storm drain or other type of breeding site?",
          "ca": "És un embornal o un altre tipus de lloc de cria?",
          "es": "És un embornal o un altre tipus de lloc de cria?"
        }
      },
      "answers": [
        {
          "id": 121,
          "text": {
            "en": "Storm drain",
            "ca": "Embornal",
            "es": "Embornal",
          }
        },
        {
          "id": 122,
          "text": {
            "en": "Other breeding site",
            "ca": "Altres llocs de cria",
            "es": "Altres llocs de cria"
          }
        }
      ]
    },
    {
      "question": {
        "id": 6,
        "text": {
          "en": "Where were you when you saw the breeding site?",
          "ca": "On estaves quan vas veure el niu?",
          "es": "¿Donde estaabas cuando viste el nido?"
        }
      },
      "answers": [
        {
          "id": 61, //Location - value equals WKT of point
          "text": {"en": "", "ca": ""}
        }
      ]
    },
  ];

  bool skipReport = false;
  bool addMosquito = false;
  bool validContent = false;
  bool showCamera = false;
  String otherReport;

  double index = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.editReport != null) {
      Utils.setEditReport(widget.editReport);
      validContent = true;
    }
    _pagesController = PageController();

    _formsRepot = [
      // PublicBreedingForm(setSkipReport, displayQuestions.elementAt(0), setValid,
      //     widget.editReport != null),
      QuestionsBreedingForm(displayQuestions.elementAt(3), setValid),
      QuestionsBreedingForm(displayQuestions.elementAt(1), setValid),
      BitingLocationForm(
          setValid,
          displayQuestions.elementAt(4)['question']['text']
              [Utils.getLanguage()]),
      CouldSeeForm(
        addAdultReport,
        displayQuestions.elementAt(2),
        setValid,
        addOtherReport: addOtherReport,
      ),
      AddOtherReportPage(_createReport, setValid, percentStream),
    ];

    if (widget.editReport != null ||
        Utils.reportsList.isNotEmpty && Utils.reportsList.length == 1) {
      _formsRepot.removeAt(3);
    }
  }

  setSkipReport(skip) {
    setState(() {
      skipReport = skip;
    });
  }

  addAdultReport(addReport) {
    setState(() {
      addMosquito = addReport;
    });
  }

  addOtherReport(String reportType) {
    setState(() {
      otherReport = reportType;
    });
  }

  setShowCamera(data) {
    setState(() {
      showCamera = data;
    });
  }

  setValid(isValid) {
    validStream.add(isValid);
  }

  navigateOtherReport() async {
    switch (otherReport) {
      case "bite":
        Utils.addOtherReport('bite');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BitingReportPage()),
        );
        break;
      // case "site":
      //   Utils.addOtherReport('site');
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => BreedingReportPage()),
      //   );
      //   break;
      case "adult":
        Utils.addOtherReport('adult');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdultReportPage()),
        );
        break;
      default:
        break;
    }
  }

  _createReport() async {
    setState(() {
      percentStream.add(0.8);
    });
    loadingStream.add(true);
    bool res = await Utils.createReport();

    if (widget.editReport != null) {
      widget.loadData();
    }
    if (!res) {
      _showAlertKo();
    } else {
      _showAlertOk();
      setState(() {
        percentStream.add(1.0);
      });
    }
  }

  _saveReports() async {
    loadingStream.add(true);
    bool res = await Utils.saveReports();
    res == null || !res ? _showAlertKo() : _showAlertOk();
    Utils.resetReport();
  }

  @override
  void dispose() {
    _pagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onWillPop();
        return false;
      },
      child: Stack(
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
                  } else {
                    _pagesController
                        .previousPage(
                            duration: Duration(microseconds: 300),
                            curve: Curves.ease)
                        .then((value) => addOtherReport(null));
                  }
                  setState(() {
                    index = currentPage - 1;
                  });
                },
              ),
              title: Style.title(
                  MyLocalizations.of(context, "breeding_report_title"),
                  fontSize: 16),
            ),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                PageView(
                  controller: _pagesController,
                  // itemCount: _formsRepot.length,
                  physics: NeverScrollableScrollPhysics(),
                  // itemBuilder: (BuildContext context, int index) {
                  //   return _formsRepot[index];
                  // }),
                  children: _formsRepot,
                ),
                index != _formsRepot.length.toDouble() - 1
                    ? SafeArea(
                        child: Align(
                        alignment: Alignment.bottomCenter,
                        child: StreamBuilder<bool>(
                            stream: validStream.stream,
                            initialData: false,
                            builder: (BuildContext ctxt,
                                AsyncSnapshot<bool> snapshot) {
                              return snapshot.data
                                  ? Container(
                                      width: double.infinity,
                                      height: 54,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 12),
                                      child: Style.button(
                                          MyLocalizations.of(
                                              context, "continue_txt"), () {
                                        double currentPage =
                                            _pagesController.page;

                                        if (skipReport) {
                                          _saveReports();
                                        } else {
                                          if (currentPage == 0.0) {
                                            _chooseTypeImage();
                                            setState(() {
                                              index = currentPage + 1;
                                            });
                                          } else if (currentPage == 3.0 &&
                                                  otherReport == 'adult' ||
                                              otherReport == 'bite') {
                                            navigateOtherReport();
                                          } else {
                                            setState(() {
                                              index = currentPage + 1;
                                            });
                                            _pagesController
                                                .nextPage(
                                                    duration: Duration(
                                                        microseconds: 300),
                                                    curve: Curves.ease)
                                                .then((value) => setValid(
                                                    widget.editReport != null));
                                          }
                                        }
                                      }),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 54,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 12),
                                      child: Style.button(
                                          MyLocalizations.of(
                                              context, "continue_txt"),
                                          null),
                                    );
                            }),
                      ))
                    : Container(
                        width: double.infinity,
                        height: 54,
                        margin:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: Style.button(
                          MyLocalizations.of(context, "send_data"),
                          () {
                            _createReport();
                          },
                        ),
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
      ),
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

  _onWillPop() {
    Utils.showAlertYesNo(MyLocalizations.of(context, 'app_name'),
        MyLocalizations.of(context, 'close_report_no_save_txt'), () {
      if (Utils.reportsList != null && Utils.reportsList.isNotEmpty) {
        Utils.deleteLastReport();
      } else {
        Utils.resetReport();
        Utils.imagePath = null;
      }
      Navigator.pop(context);
    }, context);
  }
}

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/could_see_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/mosquito_parts_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/mosquito_type_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/other_mosquito_info.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/questions_breeding_form.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

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
  List<Widget> _initialformsRepot;
  List<Widget> _skipRepotForms;
  StreamController<bool> loadingStream = new StreamController<bool>.broadcast();
  StreamController<bool> validStream = new StreamController<bool>.broadcast();
  StreamController<bool> skipParts = new StreamController<bool>.broadcast();
  StreamController<double> percentStream =
      new StreamController<double>.broadcast();
  double index;

  List<Map> displayQuestions = [
    {
      "question": {
        "id": 6,
        "text": {
          "en": "What kind of mosquito do you think it is?",
          "ca": "Quin tipus de mosquit creus que és?",
          "es": "¿Qué tipo de mosquito crees que es?"
        }
      },
      "answers": [
        {
          "id": 61,
          "img": "assets/img/ic_invasive_aedes.png",
          "text": {
            "en": "Invasive Aedes",
            "ca": "Aedes invasor",
            "es": "Aedes invasor"
          }
        },
        {
          "id": 62,
          "img": "assets/img/ic_common_mosquito.png",
          "text": {
            "en": "Common mosquito",
            "ca": "Mosquit comú",
            "es": "Mosquito común"
          }
        },
        {
          "id": 63,
          "img": "assets/img/ic_other_mosquito.png",
          "text": {"en": "Other", "ca": "Altres", "es": "Otro"}
        },
        {
          "id": 64,
          "img": "assets/img/ic_dont_know.png",
          "text": {"en": "I don't know", "ca": "No ho sé", "es": "No lo sé"}
        }
      ]
    },
    {
      "question": {
        "id": 7,
        "text": {
          "en": "How does your mosquito look?",
          "ca": "Com és el mosquit?",
          "es": "¿Cómo es el mosquito?"
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
        "id": 13,
        "text": {
          "en": "Where did you find the mosquito?",
          "ca": "On has trobat el mosquit?",
          "es": "¿Dónde has encontrado el mosquito?"
        }
      },
      "answers": [
        {
          "id": 131,
          "text": {
            "en": "Inside a vehicle",
            "ca": "Dins d'un vehicle",
            "es": "Dentro de un vehículo"
          }
        },
        {
          "id": 132,
          "text": {
            "en": "Inside a building",
            "ca": "Dins d'un edifici",
            "es": "Dentro de un edificio"
          }
        },
        {
          "id": 133,
          "text": {
            "en": "Outdoors",
            "ca": "A l'exterior",
            "es": "En el exterior"
          }
        },
      ]
    },
    {
      "question": {
        "id": 8,
        "text": {
          "en": "Did mosquito bite you?",
          "ca": "T'ha picat el mosquit?",
          "es": "¿Te ha picado el mosquito?"
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
        },
      ]
    },
    {
      "question": {
        "id": 13,
        "text": {
          "en": "Where did you find the mosquito?",
          "ca": "On has trobat el mosquit?",
          "es": "¿Dónde has encontrado el mosquito?"
        }
      },
      "answers": [
        {
          "id": 131,
          "text": {
            "en": "Inside a car",
            "ca": "Dins d'un cotxe",
            "es": "Dentro de un coche"
          }
        },
        {
          "id": 132,
          "text": {
            "en": "Inside a building",
            "ca": "Dins d'un edifici",
            "es": "Dentro de un edificio"
          }
        },
        {
          "id": 133,
          "text": {
            "en": "Outdoors",
            "ca": "A l'exterior",
            "es": "En el exterior"
          }
        },
      ]
    }
  ];

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
    index = 0.0;
    _initialformsRepot = [
      MosquitoTypeForm(setSkip3, displayQuestions.elementAt(0), setValid,
          setShowCamera, _chooseTypeImage, _skipReport),
      MosquitoPartsForm(displayQuestions.elementAt(1), setValid, skipParts,
          widget.editReport != null),
      BitingLocationForm(
          setValid,
          displayQuestions.elementAt(2)['question']['text']
              [Utils.getLanguage()]),
      QuestionsBreedingForm(
          displayQuestions.elementAt(4), setValid, false, null),
      CouldSeeForm(
          addBitingReport, displayQuestions.elementAt(3), setValid, goNextPage),
      AddOtherReportPage(_createReport, setValid, percentStream),
    ];

    _formsRepot = _initialformsRepot;

    _skipRepotForms = [
      MosquitoTypeForm(setSkip3, displayQuestions.elementAt(0), setValid,
          setShowCamera, _chooseTypeImage, _skipReport),
      OtherMosquitoInfo(),
    ];

    if (widget.editReport != null ||
        Utils.reportsList.isNotEmpty && Utils.reportsList.length == 1) {
      _formsRepot.removeAt(4);
    }
  }

  setSkip3(skip) {
    print(skip);
    skipParts.add(skip);
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
  }

  goNextPage() {
    if (addBiting) {
      Utils.addOtherReport('bite');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BitingReportPage()),
      );
    } else {
      _pagesController
          .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
          .then((value) => setValid(widget.editReport != null));
      setState(() {
        index = _pagesController.page + 1;
      });
    }
  }

  _createReport() async {
    loadingStream.add(true);
    setState(() {
      percentStream.add(0.8);
    });
    bool res = await Utils.createReport();

    if (!res) {
      _showAlertKo();
    } else {
      _showAlertOk();
      setState(() {
        percentStream.add(1.0);
      });
    }
    loadingStream.add(false);
    if (widget.editReport != null) {
      widget.loadData();
    }
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
                    setState(() {
                      index = currentPage - 1;
                    });
                    if (Utils.reportsList != null &&
                        Utils.reportsList.isNotEmpty) {
                      Utils.deleteLastReport();
                    } else {
                      Utils.resetReport();
                    }
                    Navigator.pop(context);
                  } else {
                    if (currentPage == 2.0 && Utils.imagePath == null ||
                        Utils.imagePath.isEmpty) {
                      setState(() {
                        index = 0;
                      });
                      _pagesController
                          .animateToPage(0,
                              duration: Duration(microseconds: 300),
                              curve: Curves.ease)
                          .then((value) {
                        setValid(true);
                        addOtherReport(null);
                      });
                    } else {
                      setState(() {
                        index = currentPage - 1;
                      });
                      _pagesController
                          .previousPage(
                              duration: Duration(microseconds: 300),
                              curve: Curves.ease)
                          .then((value) {
                        setValid(true);
                        addOtherReport(null);
                      });
                    }
                  }
                },
              ),
              title: Style.title(
                  MyLocalizations.of(context, "adult_report_title"),
                  fontSize: 16),
            ),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                PageView(
                  controller: _pagesController,
                  physics: NeverScrollableScrollPhysics(),
                  children: _formsRepot,
                ),
                index < 1.0 || (index == 4.0 && _formsRepot.length == 6)
                    ? Container()
                    : index != _formsRepot.length.toDouble() - 1
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

                                            if (currentPage == 3.0 &&
                                                addBiting) {
                                              Utils.addOtherReport('bite');
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BitingReportPage()),
                                              );
                                            } else {
                                              if (showCamera) {
                                                _chooseTypeImage();
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
                                                        widget.editReport !=
                                                            null));
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
                        : _formsRepot.length == 2
                            ? Container(
                                width: double.infinity,
                                height: 54,
                                margin: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                child: Style.button(
                                  MyLocalizations.of(context, "understand_txt"),
                                  () {
                                    Navigator.pop(context);
                                    Utils.resetReport();
                                    Utils.imagePath = null;
                                  },
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                height: 54,
                                margin: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
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

  _skipReport(bool skip) {
    if (widget.editReport != null && skip) {
      Utils.showAlertYesNo(MyLocalizations.of(context, "app_name"),
          MyLocalizations.of(context, "editing_adult_info_type_txt"), () {
        Utils.deleteReport(widget.editReport);
        widget.loadData();
        Navigator.pop(context);
      }, context);
    } else {
      setState(() {
        _formsRepot = skip ? _skipRepotForms : _initialformsRepot;
        index = _pagesController.page + 1;
      });

      if (skip) {
        _pagesController
            .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
            .then((value) => setValid(true));
      }
    }
  }

  _chooseTypeImage() {
    _skipReport(false);
    if (widget.editReport == null) {
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
            Utils.infoAdultCamera(context, getImage);
          },
          child: Text(
            MyLocalizations.of(context, 'camara'),
            style: TextStyle(color: Colors.blue),
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            setShowCamera(false);

            setState(() {
              index = _pagesController.page + 2;
            });
            _pagesController
                .animateToPage(3,
                    duration: Duration(microseconds: 300), curve: Curves.ease)
                .then((value) => setValid(widget.editReport != null));
          },
          child: Text(
            MyLocalizations.of(context, 'continue_without_photo'),
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ];
      List<Widget> listForAndroid = <Widget>[
        InkWell(
          onTap: () {
            Navigator.pop(context);
            Utils.infoAdultCamera(context, getImage);
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
        Divider(height: 1.0),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            setShowCamera(false);

            setState(() {
              index = _pagesController.page + 2;
            });
            _pagesController
                .animateToPage(2,
                    duration: Duration(microseconds: 300), curve: Curves.ease)
                .then((value) => setValid(widget.editReport != null));
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Text(MyLocalizations.of(context, 'continue_without_photo'),
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

    } else {
      _pagesController
          .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
          .then((value) => setValid(widget.editReport != null));
    }
  }

  getGalleryImages() async {
    List<File> files = await FilePicker.getMultiFile(
      type: FileType.image,
    );

    if (files != null) {
      setShowCamera(false);
      setState(() {
        index = _pagesController.page + 1;
      });
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
      setState(() {
        index = _pagesController.page + 1;
      });
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

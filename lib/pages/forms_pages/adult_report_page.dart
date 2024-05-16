import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/owcampaing.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/could_see_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/mosquito_parts_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/mosquito_type_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/other_mosquito_info.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/questions_breeding_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/new_adult_report_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/campaign_tutorial_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:permission_handler/permission_handler.dart';

import 'components/biting_location_form.dart';

class AdultReportPage extends StatefulWidget {
  final Report? editReport;
  final Function? loadData;
  final List<File>? photos;

  AdultReportPage({this.editReport, this.loadData, this.photos});

  @override
  _AdultReportPageState createState() => _AdultReportPageState();
}

class _AdultReportPageState extends State<AdultReportPage> {
  PageController? _pagesController;
  List<Widget>? _formsRepot;
  List<Widget>? _initialformsRepot;
  List<Widget>? _skipRepotForms;
  StreamController<bool> loadingStream = StreamController<bool>.broadcast();
  StreamController<bool> validStream = StreamController<bool>.broadcast();
  StreamController<bool> skipParts = StreamController<bool>.broadcast();
  StreamController<double> percentStream =
      StreamController<double>.broadcast();
  double? index;

  List<Map> displayQuestions = [
    {
      'question': {'id': 13, 'text': 'question_13'},
      'answers': [
        {'id': 131, 'text': 'question_13_answer_131'},
        {'id': 132, 'text': 'question_13_answer_132'},
        {'id': 133, 'text': 'question_13_answer_133'},
      ]
    },
    {
      'question': {'id': 15, 'text': 'question_15'},
    },
    {
      'question': {'id': 8, 'text': 'question_8'},
      'answers': [
        {'id': 82, 'text': 'question_8_answer_82'},
        {'id': 81, 'text': 'question_8_answer_81'},
      ]
    },
  ];

  bool addBiting = false;
  bool showCamera = false;
  String? otherReport;
  late Report toEditReport;
  List<File>? photos;

  @override
  void initState() {
    super.initState();
    if (widget.editReport != null) {
      toEditReport = Report.fromJson(widget.editReport!.toJson());
      Utils.setEditReport(toEditReport);
    }
    _pagesController = PageController();
    index = 0.0;
    _initialformsRepot = [
      /*MosquitoTypeForm(setSkip3, displayQuestions.elementAt(0), setValid,
          setShowCamera, _chooseTypeImage, _skipReport),
      MosquitoPartsForm(displayQuestions.elementAt(1), setValid, skipParts,
          widget.editReport != null),*/
      //NewAdultReportPage(),
      BitingLocationForm(
          setValid, displayQuestions.elementAt(1)['question']['text']),
      QuestionsBreedingForm(
          displayQuestions.elementAt(0), setValid, false, null, ''),
      CouldSeeForm(
          addBitingReport, displayQuestions.elementAt(2), setValid, goNextPage),
      AddOtherReportPage(_createReport, setValid, percentStream),
    ];

    _formsRepot = _initialformsRepot;

    _skipRepotForms = [
      /*MosquitoTypeForm(setSkip3, displayQuestions.elementAt(0), setValid,
          setShowCamera, _chooseTypeImage, _skipReport),*/
      OtherMosquitoInfo(),
    ];

    if (widget.editReport != null ||
        Utils.reportsList!.isNotEmpty && Utils.reportsList!.length == 1) {
      _formsRepot!.removeAt(2);
    }
  }

  void setSkip3(skip) {
    print(skip);
    skipParts.add(skip);
  }

  void setShowCamera(data) {
    setState(() {
      showCamera = data;
    });
  }

  void addBitingReport(addReport) {
    setState(() {
      addBiting = addReport;
    });
  }

  void addOtherReport(String? reportType) {
    setState(() {
      otherReport = reportType;
    });
  }

  void setValid(isValid) {
    validStream.add(isValid);
  }

  void goNextPage() {
    if (addBiting) {
      Utils.addOtherReport('bite');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BitingReportPage()),
      );
    } else {
      _pagesController!
          .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
          .then((value) => setValid(widget.editReport != null));
      setState(() {
        index = _pagesController!.page! + 1;
      });
    }
  }

  void _createReport() async {
    loadingStream.add(true);
    setState(() {
      percentStream.add(0.8);
    });
    var res = await Utils.createReport();

    if (res!=null && !res) {
      _showAlertKo();
    } else {
      if (Utils.savedAdultReport != null &&
          Utils.savedAdultReport!.country != null) {
        List<Campaign> campaignsList =
            await ApiSingleton().getCampaigns(Utils.savedAdultReport!.country);
        var now = DateTime.now().toUtc();
        if (campaignsList.any((element) =>
            DateTime.parse(element.startDate!).isBefore(now) &&
            DateTime.parse(element.endDate!).isAfter(now))) {
          var activeCampaign = campaignsList.firstWhere((element) =>
              DateTime.parse(element.startDate!).isBefore(now) &&
              DateTime.parse(element.endDate!).isAfter(now));

          await Utils.showAlertCampaign(
            context,
            activeCampaign,
            (ctx) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => CampaignTutorialPage(
                          fromReport: true,
                        )),
              );
              Utils.resetReport();
            },
          );
        } else {
          _showAlertOk();
        }
      } else {
        _showAlertOk();
      }

      setState(() {
        percentStream.add(1.0);
      });
    }
    loadingStream.add(false);
    if (widget.editReport != null) {
      widget.loadData!();
    }
  }

  @override
  void dispose() {
    _pagesController!.dispose();
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
                  var currentPage = _pagesController!.page;

                  if (currentPage == 0.0) {
                    setState(() {
                      index = currentPage! - 1;
                    });
                    _onWillPop();
                  } else {
                    if (currentPage == 2.0 &&
                        !Utils.report!.responses!
                            .any((element) => element!.answer_id == 61)) {
                      setState(() {
                        index = 0;
                      });
                      _pagesController!
                          .animateToPage(0,
                              duration: Duration(microseconds: 300),
                              curve: Curves.ease)
                          .then((value) {
                        setValid(true);
                        addOtherReport(null);
                      });
                    } else if (currentPage == 4.0) {
                      addBitingReport(false);
                      _pagesController!.previousPage(
                          duration: Duration(microseconds: 300),
                          curve: Curves.ease);
                      setState(() {
                        index = currentPage! - 1;
                      });
                    } else {
                      setState(() {
                        index = currentPage! - 1;
                      });
                      _pagesController!
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
                  MyLocalizations.of(context, 'adult_report_title'),
                  fontSize: 16),
            ),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                PageView(
                  controller: _pagesController,
                  physics: NeverScrollableScrollPhysics(),
                  children: _formsRepot!,
                ),
                index! < 1.0 || (index == 4.0 && _formsRepot!.length == 4)
                    ? Container()
                    : index != _formsRepot!.length.toDouble() - 1
                        ? SafeArea(
                            child: Align(
                            alignment: Alignment.bottomCenter,
                            child: StreamBuilder<bool>(
                                stream: validStream.stream,
                                initialData: false,
                                builder: (BuildContext ctxt,
                                    AsyncSnapshot<bool> snapshot) {
                                  return snapshot.data!
                                      ? Container(
                                          width: double.infinity,
                                          height: 54,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 12),
                                          child: Style.button(
                                              MyLocalizations.of(
                                                  context, 'continue_txt'), () {
                                            var currentPage =
                                                _pagesController!.page;

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
                                                  index = currentPage! + 1;
                                                });
                                                _pagesController!
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
                                                  context, 'continue_txt'),
                                              null),
                                        );
                                }),
                          ))
                        : SafeArea(
                            child: _formsRepot!.length == 2
                                ? Container(
                                    width: double.infinity,
                                    height: 54,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 12),
                                    child: Style.button(
                                      MyLocalizations.of(
                                          context, 'understand_txt'),
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
                                      MyLocalizations.of(context, 'send_data'),
                                      () {
                                        _createReport();
                                      },
                                    ),
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
      Utils.showAlertYesNo(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'editing_adult_info_type_txt'), () {
        Utils.deleteReport(widget.editReport);
        widget.loadData!();
        Navigator.pop(context);
      }, context);
    } else {
      setState(() {
        _formsRepot = skip ? _skipRepotForms : _initialformsRepot;
        index = _pagesController!.page! + 1;
      });

      if (skip) {
        _pagesController!
            .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
            .then((value) => setValid(true));
      }
    }
  }

  _chooseTypeImage() {
    _skipReport(false);
    if (widget.editReport == null) {
      var listForiOS = <Widget>[
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            Utils.infoAdultCamera(context, getGalleryImages, gallery: true);
          },
          child: Text(
            MyLocalizations.of(context, 'gallery')!,
            style: TextStyle(color: Colors.blue),
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            Utils.infoAdultCamera(context, getImage);  // TODO: Here
          },
          child: Text(
            MyLocalizations.of(context, 'camara')!,
            style: TextStyle(color: Colors.blue),
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            setShowCamera(false);
            Utils.imagePath = [];
            var page = 2;
            if (Utils.report!.responses!
                .any((element) => element!.answer_id == 61)) {
              page = 1;
            }
            setState(() {
              index = _pagesController!.page! + page;
            });
            _pagesController!
                .animateToPage(page,
                    duration: Duration(microseconds: 300), curve: Curves.ease)
                .then((value) => setValid(widget.editReport != null));
          },
          child: Text(
            MyLocalizations.of(context, 'continue_without_photo')!,
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ];
      var listForAndroid = <Widget>[
        InkWell(
          onTap: () {
            Navigator.pop(context);
            Utils.infoAdultCamera(context, getImage);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Text(MyLocalizations.of(context, 'camara')!,
                style: TextStyle(color: Colors.blue, fontSize: 15)),
          ),
        ),
        Divider(height: 1.0),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            Utils.infoAdultCamera(context, getGalleryImages, gallery: true);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Text(MyLocalizations.of(context, 'gallery')!,
                style: TextStyle(color: Colors.blue, fontSize: 15)),
          ),
        ),
        Divider(height: 1.0),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            setShowCamera(false);
            Utils.imagePath = [];
            var page = 2;
            if (Utils.report!.responses!
                .any((element) => element!.answer_id == 61)) {
              page = 1;
            }

            setState(() {
              index = _pagesController!.page! + page;
            });
            _pagesController!
                .animateToPage(page,
                    duration: Duration(microseconds: 300), curve: Curves.ease)
                .then((value) => setValid(widget.editReport != null));
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Text(MyLocalizations.of(context, 'continue_without_photo')!,
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
      },
          title:
              '${MyLocalizations.of(context, 'bs_info_adult_title_optional')}:');
    } else {
      _pagesController!
          .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
          .then((value) => setValid(widget.editReport != null));
    }
  }

  getGalleryImages() async {
    var pickFiles = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (pickFiles != null &&
        pickFiles.files.isNotEmpty) {
      setShowCamera(false);
      setState(() {
        index = _pagesController!.page! + 1;
      });
      await _pagesController!
          .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
          .then((value) => setValid(widget.editReport != null));
    }

    if (pickFiles != null &&
        pickFiles.files.isNotEmpty) {
      pickFiles.files.forEach((image) {
        Utils.saveImgPath(File(image.path!));
      });
    }
  }

  Future getImage(source) async {
    if (await Permission.camera.isPermanentlyDenied && Platform.isIOS) {
      await openAppSettings();
      return;
    }

    final _picker = ImagePicker();
    var image = await _picker.pickImage(
        source: source, maxHeight: 1024, imageQuality: 60);

    if (image != null) {
      final file = File(image.path);
      Utils.saveImgPath(file);
      setShowCamera(false);

      await _pagesController!
          .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
          .then((value) => setValid(widget.editReport != null));
      setState(() {
        index = _pagesController!.page! + 1;
      });
    }
  }

  _showAlertOk() {
    loadingStream.add(false);

    Utils.showAlert(
      MyLocalizations.of(context, 'app_name'),
      widget.editReport == null
          ? MyLocalizations.of(context, 'save_report_ok_txt')
          : MyLocalizations.of(context, 'edited_report_ok_txt'),
      context,
      onPressed: () {
        Navigator.pop(context);
        if (widget.editReport != null) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).popUntil((r) => r.isFirst);
          Utils.resetReport();
        }
      },
      barrierDismissible: false,
    );
  }

  _showAlertKo() {
    loadingStream.add(false);
    Utils.showAlert(
      MyLocalizations.of(context, 'app_name'),
      MyLocalizations.of(context, 'save_report_ko_txt'),
      context,
      onPressed: () {
        Navigator.pop(context);
        if (widget.editReport != null) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).popUntil((r) => r.isFirst);
          Utils.resetReport();
        }
      },
      barrierDismissible: false,
    );
  }

  _onWillPop() {
    if (Utils.report!.responses!.isNotEmpty) {
      Utils.showAlertYesNo(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'close_report_no_save_txt'), () {
        if (Utils.reportsList != null && Utils.reportsList!.isNotEmpty) {
          Utils.deleteLastReport();
        } else {
          Utils.resetReport();
          Utils.imagePath = null;
        }
        Navigator.pop(context);
      }, context);
    } else {
      Navigator.pop(context);
    }
  }
}

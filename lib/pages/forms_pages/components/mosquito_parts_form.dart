import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_photo_button_widget.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class MosquitoPartsForm extends StatefulWidget {
  final Map displayQuestion;
  final Function setValid;
  final StreamController<bool> showParts;
  final bool isEditing;
  final List<File> photos;

  MosquitoPartsForm(
      this.displayQuestion, this.setValid, this.showParts, this.isEditing, this.photos);
  @override
  _MosquitoPartsFormState createState() => _MosquitoPartsFormState(photos: photos);
}

class _MosquitoPartsFormState extends State<MosquitoPartsForm> {
  List<Question?>? questions = [];
  List<File> photos;

  _MosquitoPartsFormState({required this.photos});

  @override
  void initState() {
    super.initState();

    widget.setValid(true);
    if (Utils.report != null) {
      for (var q in Utils.report!.responses!) {
        if (q!.question_id == widget.displayQuestion['question']['id']) {
          questions!.add(q);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              AddPhotoButton(widget.isEditing, false, photos),
              Style.bottomOffset,
            ],
          ),
        ),
      ),
    );
  }

  void onSelect(answer, answerId, int i) {
    Utils.addAdultPartsResponse(answer, answerId, i);

    widget.setValid(true);
    setState(() {
      questions = Utils.report!.responses;
    });
  }

  bool isDisabled(int index, int? aswerId) {
    var group = questions!
        .where((q) => q!.answer_id! >= index && q.answer_id! < index + 10)
        .toList();

    return group.any((q) => q!.answer_id != aswerId);
  }
}

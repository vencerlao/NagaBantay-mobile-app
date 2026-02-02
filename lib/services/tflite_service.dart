import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' as Math;

class TFLiteService {
  late Interpreter _interpreter;
  late Map<String, int> vocab;
  late List<String> officeLabels;
  late List<String> severityLabels;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/ml/office_severity_model.tflite',
    );

    vocab = await _loadVocab('assets/ml/vocab.json');
    officeLabels = await _loadLabels('assets/ml/office_labels.json');
    severityLabels = await _loadLabels('assets/ml/severity_labels.json');

    print('Input shape: ${_interpreter.getInputTensor(0).shape}');
    print('Output shapes: ${_interpreter.getOutputTensors().map((t) => t.shape)}');
  }

  List<int> _tokenize(String text, int maxLen) {
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'));

    final unkIndex = vocab['<UNK>'] ?? 0;
    final padIndex = vocab['<PAD>'] ?? 0;

    final tokens = words.map((w) => vocab[w] ?? unkIndex).toList();

    if (tokens.length > maxLen) return tokens.sublist(0, maxLen);
    while (tokens.length < maxLen) tokens.add(padIndex);

    return tokens;
  }

  Future<Map<String, dynamic>> predict(String text) async {
    final maxLen = _interpreter.getInputTensor(0).shape[1];
    final input = _tokenize(text, maxLen);
    final inputTensor = [input];

    final severityOutShape = _interpreter.getOutputTensor(0).shape;
    final severityOutput = List.generate(
      severityOutShape[0],
          (_) => List.filled(severityOutShape[1], 0.0),
    );

    final officeOutShape = _interpreter.getOutputTensor(1).shape;
    final officeOutput = List.generate(
      officeOutShape[0],
          (_) => List.filled(officeOutShape[1], 0.0),
    );

    _interpreter.runForMultipleInputs(
      [inputTensor],
      {
        0: severityOutput,
        1: officeOutput,
      },
    );

    final severityProbs = severityOutput[0];
    final officeProbs = officeOutput[0];

    if (officeProbs.isEmpty || severityProbs.isEmpty) {
      throw Exception("TFLite model returned empty output.");
    }

    final severityIndex =
    severityProbs.indexOf(severityProbs.reduce(Math.max));
    final officeIndex =
    officeProbs.indexOf(officeProbs.reduce(Math.max));

    return {
      'severity': severityLabels[severityIndex],
      'severity_confidence': severityProbs[severityIndex],
      'office': officeLabels[officeIndex],
      'office_confidence': officeProbs[officeIndex],
    };
  }

  Future<Map<String, int>> _loadVocab(String path) async {
    final jsonStr = await rootBundle.loadString(path);
    final List<dynamic> jsonList = json.decode(jsonStr);
    final Map<String, int> vocabMap = {};
    for (int i = 0; i < jsonList.length; i++) {
      vocabMap[jsonList[i].toString()] = i;
    }
    return vocabMap;
  }

  Future<List<String>> _loadLabels(String path) async {
    final jsonStr = await rootBundle.loadString(path);
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((e) => e.toString()).toList();
  }
}

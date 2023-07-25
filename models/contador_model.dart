import 'dart:async';
import 'package:flutter/foundation.dart';

class ContadorModel extends ChangeNotifier {
  int _valorInicialSegundos = 0; // 2 horas en segundos
  int _segundosRestantes = 0;
  Timer? _timer;

  int get segundosRestantes => _segundosRestantes;

  ContadorModel() {
    _iniciarContador();
  }

  void _iniciarContador() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _segundosRestantes++;
      notifyListeners();
    });
  }

  void reiniciarContador() {
    _segundosRestantes = _valorInicialSegundos;
    _timer?.cancel();
    _iniciarContador();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

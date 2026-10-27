import 'package:flutter/foundation.dart';

import '../datos/consumo_repository.dart';
import '../dominio/consumo.dart';
import '../dominio/meta.dart';

class ConsumosViewModel extends ChangeNotifier {
  ConsumosViewModel(this._repositorio);

  final ConsumoRepository _repositorio;

  List<Consumo> consumos = [];

  String? error;

  bool guardando = false;

  double meta = metaInicial;

  double get total =>
      consumos.fold(0.0, (suma, consumo) => suma + consumo.litros);

  double get avance => avanceDeMeta(total: total, meta: meta);

  bool get metaSuperada => total > meta;

  Future<void> cargar() async {
    consumos = await _repositorio.todos();
    notifyListeners();
  }

  Future<bool> guardar(String laboratorio, String litrosTexto) async {
    final texto = litrosTexto.trim().replaceAll(',', '.');
    final litros = double.tryParse(texto);
    final mensaje = validarLitros(litros);

    if (mensaje != null) {
      error = mensaje;
      notifyListeners();
      return false;
    }

    guardando = true;
    error = null;
    notifyListeners();

    await _repositorio.guardar(
      Consumo(laboratorio: laboratorio, litros: litros!),
    );
    consumos = await _repositorio.todos();

    guardando = false;
    notifyListeners();
    return true;
  }

  void subirMeta() {
    meta = ajustarMeta(meta, pasoMeta);
    notifyListeners();
  }

  void bajarMeta() {
    meta = ajustarMeta(meta, -pasoMeta);
    notifyListeners();
  }
}

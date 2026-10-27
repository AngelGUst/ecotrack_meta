import 'package:flutter/material.dart';

import '../datos/consumo_repository.dart';
import '../presentacion/consumos_view_model.dart';
import '../presentacion/vistas.dart';

/// Variante A: `ChangeNotifier` puro, con el ViewModel pasado por constructor.
class AppChangeNotifier extends StatefulWidget {
  const AppChangeNotifier({super.key, required this.repositorio});

  final ConsumoRepository repositorio;

  @override
  State<AppChangeNotifier> createState() => _AppChangeNotifierState();
}

class _AppChangeNotifierState extends State<AppChangeNotifier> {
  late final ConsumosViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ConsumosViewModel(widget.repositorio);
    _vm.cargar();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTrack Meta',
      home: PantallasEcoTrack(
        titulo: 'A · ChangeNotifier',
        registro: RegistroCN(vm: _vm),
        historial: HistorialCN(vm: _vm),
        meta: MetaCN(vm: _vm),
      ),
    );
  }
}

/// Adaptador de Registro: recibe el ViewModel y lo escucha.
class RegistroCN extends StatelessWidget {
  const RegistroCN({super.key, required this.vm});

  final ConsumosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, child) => FormularioRegistro(
        alGuardar: vm.guardar,
        error: vm.error,
        guardando: vm.guardando,
      ),
    );
  }
}

/// Adaptador de Historial: recibe el ViewModel y lo escucha.
class HistorialCN extends StatelessWidget {
  const HistorialCN({super.key, required this.vm});

  final ConsumosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, child) =>
          ListaHistorial(consumos: vm.consumos, total: vm.total),
    );
  }
}

/// Adaptador de Meta: recibe el ViewModel y lo escucha.
class MetaCN extends StatelessWidget {
  const MetaCN({super.key, required this.vm});

  final ConsumosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, child) => PanelMeta(
        usado: vm.total,
        meta: vm.meta,
        avance: vm.avance,
        superada: vm.metaSuperada,
        alSubir: vm.subirMeta,
        alBajar: vm.bajarMeta,
      ),
    );
  }
}

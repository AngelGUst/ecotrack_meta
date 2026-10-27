import 'package:flutter/material.dart';

import '../dominio/consumo.dart';

/// Formulario para registrar un consumo.
///
/// Es una vista tonta: recibe datos y callbacks. El laboratorio elegido y el
/// texto del campo son estado efímero y viven en este `State`.
class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({
    super.key,
    required this.alGuardar,
    required this.error,
    required this.guardando,
  });

  final Future<bool> Function(String laboratorio, String litros) alGuardar;
  final String? error;
  final bool guardando;

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  final TextEditingController _controlador = TextEditingController();
  String _laboratorio = laboratoriosUtez.first;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final guardado = await widget.alGuardar(_laboratorio, _controlador.text);
    if (!mounted || !guardado) {
      return;
    }
    _controlador.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Consumo guardado')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _laboratorio,
          decoration: const InputDecoration(labelText: 'Laboratorio'),
          items: [
            for (final laboratorio in laboratoriosUtez)
              DropdownMenuItem(value: laboratorio, child: Text(laboratorio)),
          ],
          onChanged: widget.guardando
              ? null
              : (valor) {
            if (valor != null) {
              setState(() => _laboratorio = valor);
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('litros'),
          controller: _controlador,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Litros',
            errorText: widget.error,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: widget.guardando ? null : _enviar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

/// Lista de consumos con el total en la primera fila.
///
/// Vista tonta: solo recibe la lista y el total ya calculados.
class ListaHistorial extends StatelessWidget {
  const ListaHistorial({
    super.key,
    required this.consumos,
    required this.total,
  });

  final List<Consumo> consumos;
  final double total;

  @override
  Widget build(BuildContext context) {
    if (consumos.isEmpty) {
      return const Center(child: Text('Sin consumos'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: consumos.length + 1,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            title: Text(
              'Total: ${total.toStringAsFixed(1)} L',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        final consumo = consumos[index - 1];
        return ListTile(
          title: Text(consumo.laboratorio),
          trailing: Text('${consumo.litros.toStringAsFixed(1)} L'),
        );
      },
    );
  }
}

/// Panel que compara lo usado con la meta semanal.
///
/// Vista tonta: recibe números, banderas y callbacks; no conoce al ViewModel.
class PanelMeta extends StatelessWidget {
  const PanelMeta({
    super.key,
    required this.usado,
    required this.meta,
    required this.avance,
    required this.superada,
    required this.alSubir,
    required this.alBajar,
  });

  final double usado;
  final double meta;
  final double avance;
  final bool superada;
  final VoidCallback alSubir;
  final VoidCallback alBajar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Usado: ${usado.toStringAsFixed(1)} de ${meta.toStringAsFixed(1)} L',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: avance),
        const SizedBox(height: 12),
        Text(
          superada ? 'Te pasaste de la meta' : 'Dentro de la meta',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              key: const Key('bajarMeta'),
              onPressed: alBajar,
              child: const Text('Bajar meta'),
            ),
            const SizedBox(width: 12),
            FilledButton(
              key: const Key('subirMeta'),
              onPressed: alSubir,
              child: const Text('Subir meta'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Pantalla con las tres pestañas que comparten el mismo estado.
///
/// La pestaña activa es estado efímero: vive en este `State` con `setState`.
class PantallasEcoTrack extends StatefulWidget {
  const PantallasEcoTrack({
    super.key,
    required this.titulo,
    required this.registro,
    required this.historial,
    required this.meta,
  });

  final String titulo;
  final Widget registro;
  final Widget historial;
  final Widget meta;

  @override
  State<PantallasEcoTrack> createState() => _PantallasEcoTrackState();
}

class _PantallasEcoTrackState extends State<PantallasEcoTrack> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: IndexedStack(
        index: _indice,
        children: [widget.registro, widget.historial, widget.meta],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (indice) => setState(() => _indice = indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Registro',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Historial',
          ),
          NavigationDestination(icon: Icon(Icons.flag_outlined), label: 'Meta'),
        ],
      ),
    );
  }
}

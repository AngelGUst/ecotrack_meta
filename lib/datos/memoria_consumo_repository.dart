import '../dominio/consumo.dart';
import 'consumo_repository.dart';

class MemoriaConsumoRepository implements ConsumoRepository {
  final List<Consumo> _guardados = [];

  @override
  Future<void> guardar(Consumo consumo) async {
    _guardados.add(consumo);
  }

  @override
  Future<List<Consumo>> todos() async => List.unmodifiable(_guardados);
}

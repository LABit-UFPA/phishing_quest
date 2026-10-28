import 'dart:convert';

import 'package:get/get.dart';
import 'package:phishing_quest/app/data/enumerators/storage_keys.enum.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';
import 'package:phishing_quest/app/data/repositories/telemetry/telemetry_repository.dart';
import 'package:phishing_quest/app/data/storage/memory_storage.dart';
import 'package:phishing_quest/app/data/util/ids/uuid_v4.dart';

/// Telemetria da caixa de entrada, enviada em lotes para
/// POST /telemetry-events. Os eventos ficam guardados no aparelho ate a
/// API aceitar o lote; como cada um tem id proprio, reenviar um lote que
/// ja tinha chegado nao duplica nada no servidor.
class TelemetryService extends GetxService {
  static const int batchSize = 10;
  static const int maxPending = 500;

  final _store = MemoryStore(StorageKeys.PENDING_TELEMETRY);
  final TelemetryRepository _repository;
  final List<Map<String, dynamic>> _pending = [];
  bool _flushing = false;

  TelemetryService({TelemetryRepository? repository}) : _repository = repository ?? TelemetryRepository();

  Future<TelemetryService> init() async {
    final saved = _store.read<String>();
    if (saved != null) {
      try {
        _pending.addAll((jsonDecode(saved) as List).cast<Map<String, dynamic>>());
      } catch (_) {
        await _store.remove();
      }
    }
    return this;
  }

  int get pendingCount => _pending.length;

  /// Registra um evento. `sessionId` liga o evento a sessao da caixa de
  /// entrada; `payload` vai em payloadJson.
  void track(String eventType, {String? sessionId, Map<String, dynamic>? payload}) {
    _pending.add({
      'id': uuidV4(),
      'eventType': eventType,
      if (sessionId != null) 'sessionId': sessionId,
      if (payload != null) 'payloadJson': payload,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    if (_pending.length > maxPending) {
      _pending.removeRange(0, _pending.length - maxPending);
    }
    _persist();
    if (_pending.length >= batchSize) {
      flush();
    }
  }

  /// Envia o que estiver pendente. Em caso de falha os eventos continuam
  /// guardados, com os mesmos ids, para a proxima tentativa. Um lote que
  /// a API recusa como invalido (400) e descartado, para nao travar a
  /// fila.
  Future<void> flush() async {
    if (_flushing || _pending.isEmpty) return;
    _flushing = true;
    try {
      while (_pending.isNotEmpty) {
        final batch = _pending.take(batchSize).toList();
        try {
          await _repository.sendBatch(batch);
        } on ApiException catch (e) {
          if (e.statusCode != 400) rethrow;
        }
        _pending.removeRange(0, batch.length);
        await _persist();
      }
    } catch (_) {
      // Sem rede ou API fora do ar: tenta de novo no proximo flush.
    } finally {
      _flushing = false;
    }
  }

  Future<void> _persist() => _store.write(jsonEncode(_pending));
}

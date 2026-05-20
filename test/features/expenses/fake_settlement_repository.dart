import 'package:ledger/core/result/result.dart';
import 'package:ledger/features/settlements/domain/models/settlement.dart';
import 'package:ledger/features/settlements/domain/settlement_repository.dart';

class FakeSettlementRepository implements SettlementRepository {
  FakeSettlementRepository({
    List<Settlement>? settlements,
    Result<Settlement, SettlementFailure>? recordResult,
  })  : _settlements = settlements ?? [],
        _recordResult = recordResult;

  final List<Settlement> _settlements;
  final Result<Settlement, SettlementFailure>? _recordResult;

  @override
  Stream<List<Settlement>> watchGroupSettlements(String groupId) =>
      Stream.value(_settlements);

  @override
  Future<Result<Settlement, SettlementFailure>> recordSettlement(
    Settlement settlement,
  ) async =>
      _recordResult ?? Ok(settlement);
}

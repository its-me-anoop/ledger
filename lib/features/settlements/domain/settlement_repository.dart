import '../../../core/result/result.dart';
import 'models/settlement.dart';

sealed class SettlementFailure {
  const SettlementFailure();
}

final class UnknownSettlementFailure extends SettlementFailure {
  const UnknownSettlementFailure([this.message]);
  final String? message;
}

abstract interface class SettlementRepository {
  Stream<List<Settlement>> watchGroupSettlements(String groupId);

  Future<Result<Settlement, SettlementFailure>> recordSettlement(
    Settlement settlement,
  );
}

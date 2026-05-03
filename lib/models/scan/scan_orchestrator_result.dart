import 'package:build_access/enum/state.dart';

class ScanOrchestratorResult {
  final ScanStatus status;
  final String command;
  ScanOrchestratorResult({required this.status, required this.command});
}

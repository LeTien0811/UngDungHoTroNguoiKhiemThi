import 'package:build_access/enum/config.dart';

class ProcessImageResult {
  final ProcessStatus status;
  final String? textDetect;
  final String? command;
  final String? error;

  ProcessImageResult(this.status, {this.textDetect, this.command, this.error});
}
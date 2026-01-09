import 'dart:async';

import 'package:hotronguoikhiemthi_app/model/ai_response.dart';
import 'package:hotronguoikhiemthi_app/services/log_error_services.dart';
import 'package:hotronguoikhiemthi_app/services/storage_service.dart';
import 'package:hotronguoikhiemthi_app/util/ai_process.dart';
import 'package:hotronguoikhiemthi_app/util/util_lib.dart';

class AIServices {
  final AIProcess aiProcess;

  AIServices(this.aiProcess);

  Future<AIResponse?> askAIResponse(String ask) async {
    // biến tổng chờ mọi thứ hoàn thành và trả về kết quả
    final Completer<AIResponse> completer = Completer();
    // lưu tạm kết quả trả về
    String fullResponseBuffer = '';
    try {
      if (aiProcess.engine == null) {
        LogErrorServices.showLog(
          where: 'AIServices -> askAIResponse',
          type: 'loi askAIResponse bat dau doc',
          message: 'Ai chua san sang',
        );
        return null;
      }

      // cấu trúc câu hỏi cho ai nhận dạng và trả lời
      final userTurn = '<start_of_turn>user\n${UtilLib.system_promts} \n Câu hỏi của user: "$ask" <end_of_turn>\n';
      final modelTrigger = '<start_of_turn>model\n';
      
      // lấy lịch sử để AI trả về thông minh hơn
      String? conversationHistory = await StorageService().getLocalHistoryChat() ?? '';
      
      // gom lại
      final fullPrompt = conversationHistory + userTurn + modelTrigger;
      
      // Tiến hahf 
      aiProcess.engine!
          .generateResponse(fullPrompt)
          .listen(
            (chunk) {
              // lắng nghe cộng dồn câu trả lời vì nó thuộc dang stream
              fullResponseBuffer += chunk;
            },
            onDone: () async {
              // khi hoàn thành
              LogErrorServices.showLog(
                // thằng này cấu trúc để hiển thị cho mình debug thôi
                where: 'AIServices -> askAIResponse',
                type: ' hoan thanh tra ve askAIResponse bat dau doc ',
                message: 'tra ve  $fullResponseBuffer',
              );
              // pare lại để sài
              final aiResponse = AIResponse.fromJsonString(fullResponseBuffer);
              
              // lưu lại câu trả lời
              final newHistoryEntry = userTurn + modelTrigger + fullResponseBuffer + '<end_of_turn>\n';
              await StorageService().saveLocalHistoryChat(newHistoryEntry);
              // nếu chưa haonf thành thì lấy
              if (!completer.isCompleted) {
                completer.complete(aiResponse);
              }
            },
            onError: (err) {
              //lỗi
              LogErrorServices.showLog(
                where: 'AIServices -> Stream',
                type: 'Error',
                message: 'Lỗi khi stream: $err',
              );
              if (!completer.isCompleted) completer.complete(null);
            },
          );
    } catch (e) {
      LogErrorServices.showLog(
        where: 'AIServices -> askAIResponse',
        type: 'loi askAIResponse bat dau doc o catch',
        message: 'loi $e',
      );
      return null;
    }
    return completer.future;
  }
}

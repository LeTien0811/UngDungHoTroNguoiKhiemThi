import 'package:build_access/config/my_colors.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/core/widgets/voice_confirm_widget.dart';
import 'package:build_access/providers/voice_interaction_provider.dart';
import 'package:build_access/services/hardware/haptic_hardware_service.dart';
import 'package:build_access/view_models/history_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Body extends StatelessWidget {
  final HistoryViewModel model;

  const Body({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (model.historyList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 80, color: MyColors.textWhite.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text(
              'Không có lịch sử',
              style: TextStyle(color: MyColors.textGrey, fontSize: 24),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      // Vuốt từ trái sang phải để xóa
      onHorizontalDragEnd: (details) async {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          if (getIt<VoiceInteractionProvider>().isSpeaking) {
            getIt<VoiceInteractionProvider>().stopSpeaking();
            await Future.delayed(const Duration(milliseconds: 100));
          }

          getIt<HapticHardwareService>().executeSystemVibration();
          final confirm = await VoiceConfirmWidget.show(
            message: "confirm_delete_all".tr,
          );

          if (confirm == true) {
            model.deleteCurrentHistory();
          }
        }
      },
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: model.historyList.length,
        onPageChanged: (index) {
          model.onPageChanged(index);
          getIt<HapticHardwareService>().executeSystemVibration();
        },
        itemBuilder: (context, index) {
          final item = model.historyList[index];

          return GestureDetector(
            onDoubleTap: () async {
              getIt<HapticHardwareService>().executeSystemVibration();
              if (getIt<VoiceInteractionProvider>().isSpeaking) {
                getIt<VoiceInteractionProvider>().stopSpeaking();
                await Future.delayed(const Duration(milliseconds: 100));
              } else {
                await model.readCurrentHistory();
              }
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        MyColors.primaryGold.withValues(alpha: 0.2),
                        MyColors.bgDark.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),

                // Nội dung chính
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chip hiển thị thời gian hoặc STT
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: MyColors.textWhite.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Mục ${index + 1} / ${model.historyList.length}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tiêu đề nổi bật (Màu vàng giống nguyên bản nhưng có shadow)
                        Text(
                          item.title.toUpperCase(),
                          style: TextStyle(
                            color: MyColors.primaryGold,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            shadows: const [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
                        const Divider(color: Colors.white24, thickness: 1),
                        const SizedBox(height: 16),

                        // Nội dung tóm tắt AI
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: MyColors.textWhite.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: MyColors.textWhite.withValues(alpha: 0.1)),
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                item.aiSummary,
                                style: const TextStyle(
                                  color: MyColors.textWhite,
                                  fontSize: 22,
                                  height:
                                      1.5, // Giúp người khiếm thị dễ đọc hơn nếu dùng kính lúp
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Hướng dẫn thao tác dưới đáy
                        Center(
                          child: Text(
                            "Chạm 2 lần để nghe đọc • Vuốt ngang để xóa",
                            style: TextStyle(
                              color: MyColors.textWhite.withValues(alpha: 0.3),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

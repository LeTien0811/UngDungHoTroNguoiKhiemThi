import 'package:build_access/services/navigator_service.dart';
import 'package:build_access/src/features/camera_feature/camera_features.dart';
import 'package:build_access/src/features/home_feature/components/derector_text.dart';
import 'package:build_access/view/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:build_access/constant/color.dart';
import 'package:build_access/core/utils/snackbar_util.dart';
import 'package:flutter/services.dart';

class Body extends StatefulWidget {
  final HomeViewModel model;
  const Body({
    super.key,
    required this.model,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          HapticFeedback.heavyImpact();
        },
        child: Scaffold(
          backgroundColor: MyColors.bgDark,

          body: Semantics(
            label: 'Màn hình chính. Chạm đúp vào giữa màn hình để nói hoặc quét thuốc. '
                'Vuốt sang trái để mở Lịch sử. Vuốt sang phải để mở Cài đặt.',
            explicitChildNodes: false,
            child: SafeArea(
              child: GestureDetector(
                onDoubleTap: () {
                  HapticFeedback.heavyImpact();
                  SnackbarUtil.show(context, message: "🎙️ ĐANG NGHE LỆNH...", bgColor: MyColors.highlightYellow);
                },
                onLongPress: () {
                  HapticFeedback.mediumImpact();
                  SnackbarUtil.show(context, message:"🔊 Đưa camera cách hộp thuốc 1 gang tay...", bgColor: MyColors.textWhite);
                },
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! < -300) {
                    HapticFeedback.lightImpact();
                    SnackbarUtil.show(context,message:  "Chuyển sang: Đọc Thông Tin", bgColor:  MyColors.actionCyan);
                    NavigatorService().navigateTo(CameraFeatures.routerName);

                  }
                },

                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: MyColors.textWhite.withOpacity(0.3), width: 4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.mic_none_rounded, size: 80, color: MyColors.textWhite),
                              SizedBox(height: 20),
                              Text(
                                "CHẠM ĐỂ\nNÓI / QUÉT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: MyColors.textWhite,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                      DerectorText(
                          text: "Đọc Thông Tin",
                          icon: Icons.keyboard_double_arrow_down_rounded,
                          bottom: 0,
                          right: 0,
                          left: 0,
                          top: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }
}

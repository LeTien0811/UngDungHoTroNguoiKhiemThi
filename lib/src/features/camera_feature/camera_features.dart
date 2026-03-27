import 'package:build_access/config/base_view.dart';
import 'package:build_access/enum/config.dart';
import 'package:build_access/src/features/camera_feature/components/body.dart';
import 'package:build_access/view/camera_view_model.dart';
import 'package:flutter/material.dart';

class CameraFeatures extends StatelessWidget {
  static String routerName = "/camera_feature";
  const CameraFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<CameraViewModel>(
        builder: (context, model, child) {
          if(model.state == ViewState.busy) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Body(model: model);
        },
      
        onModelReady: (model) async {
          await model.initCamera();
          },

        onModelDispose: (model)  {
          model.dispose();
        },
      child: null,

    );
  }
}

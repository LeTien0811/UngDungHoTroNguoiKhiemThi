import 'package:build_access/core/base/base_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class BaseView<T extends BaseModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget? child) builder;
  final Function(T)? onModelReady;
  final Function(T)? onModelDispose;
  final Widget? child;

  const BaseView({
    super.key,
    required this.builder,
    required this.onModelReady,
    required this.onModelDispose,
    required this.child,
  });

  @override
  _BaseViewState<T> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseModel> extends State<BaseView<T>> {
  T model = Get.find<T>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.onModelReady != null) {
      widget.onModelReady!(model);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(widget.onModelDispose != null) {
      widget.onModelDispose!(model);
    }
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: model,
        child: Consumer<T>(builder: (context, model, child) {
          return widget.builder(context, model, child);
        },
          child: widget.child,
        ),
    );
  }
}

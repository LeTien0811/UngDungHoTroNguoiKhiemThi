import 'package:build_access/config/base_model.dart';
import 'package:build_access/providers/locator.dart';
import 'package:flutter/material.dart';

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
  T model = getIt<T>();
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

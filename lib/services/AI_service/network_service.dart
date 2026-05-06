import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  Future<bool> hasRealInternet() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      final result = await InternetAddress.lookup('8.8.8.8')
          .timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
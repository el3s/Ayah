import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// كيطلب الصلاحية ويجيب الموقع الحالي دقيق (خط العرض والطول)
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'خدمة الموقع مطفية. عافاك فعّلها من إعدادات الهاتف.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException(
          'خاصنا صلاحية الموقع باش نحسبو وقت الأذان تلقائيًا.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'صلاحية الموقع مرفوضة نهائيًا. فعّلها من إعدادات التطبيق.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// حول الإحداثيات لاسم مدينة (يبان فالواجهة: "الرباط، المغرب")
  Future<String> getCityName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return '${p.locality ?? p.subAdministrativeArea ?? ''}, ${p.country ?? ''}';
      }
    } catch (_) {
      // إذا تعذر الحصول على الاسم، نرجعو الإحداثيات فقط
    }
    return '$lat, $lng';
  }
}

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);
  @override
  String toString() => message;
}

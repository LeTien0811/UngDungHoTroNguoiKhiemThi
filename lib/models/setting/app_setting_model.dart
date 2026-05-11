import 'dart:convert';
import 'package:build_access/core/utils/system_lang.dart';


class AppSettingsModel {
  final String ttsLanguage;
  final double ttsSpeech;
  final double ttsPitch;

  /// ID voice đã cache (tối ưu cho thiết bị)
  final String ttsVoiceId;

  /// male | female | auto
  final String ttsGenderPreference;

  final String hapticLevel;
  final bool autoEnableFlashlight;
  final bool forceLocalAiMode;
  final bool aiShortResponse;
  final String userMedicalProfile;

  AppSettingsModel({
    String? ttsLanguage,
    this.ttsSpeech = 0.5,
    this.ttsPitch = 1.0,
    this.ttsVoiceId = "",
    this.ttsGenderPreference = "auto",
    this.hapticLevel = "off",
    this.autoEnableFlashlight = true,
    this.forceLocalAiMode = false,
    this.aiShortResponse = true,
    this.userMedicalProfile = "",
  }) : ttsLanguage = ttsLanguage ?? getSystemLanguageTag();

  AppSettingsModel copyWith({
    String? ttsLanguage,
    double? ttsSpeech,
    double? ttsPitch,
    String? ttsVoiceId,
    String? ttsGenderPreference,
    String? hapticLevel,
    bool? autoEnableFlashlight,
    bool? forceLocalAiMode,
    bool? aiShortResponse,
    String? userMedicalProfile,
  }) {
    return AppSettingsModel(
      ttsLanguage: ttsLanguage ?? this.ttsLanguage,
      ttsSpeech: ttsSpeech ?? this.ttsSpeech,
      ttsPitch: ttsPitch ?? this.ttsPitch,
      ttsVoiceId: ttsVoiceId ?? this.ttsVoiceId,
      ttsGenderPreference: ttsGenderPreference ?? this.ttsGenderPreference,
      hapticLevel: hapticLevel ?? this.hapticLevel,
      autoEnableFlashlight: autoEnableFlashlight ?? this.autoEnableFlashlight,
      forceLocalAiMode: forceLocalAiMode ?? this.forceLocalAiMode,
      aiShortResponse: aiShortResponse ?? this.aiShortResponse,
      userMedicalProfile: userMedicalProfile ?? this.userMedicalProfile,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ttsLanguage': ttsLanguage,
      'ttsSpeech': ttsSpeech,
      'ttsPitch': ttsPitch,
      'ttsVoiceId': ttsVoiceId,
      'ttsGenderPreference': ttsGenderPreference,
      'hapticLevel': hapticLevel,
      'autoEnableFlashlight': autoEnableFlashlight,
      'forceLocalAiMode': forceLocalAiMode,
      'aiShortResponse': aiShortResponse,
      'userMedicalProfile': userMedicalProfile,
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      ttsLanguage: map['ttsLanguage'] ?? getSystemLanguageTag(),
      ttsSpeech: map['ttsSpeech']?.toDouble() ?? 0.5,
      ttsPitch: map['ttsPitch']?.toDouble() ?? 1.0,
      ttsVoiceId: map['ttsVoiceId'] ?? "",
      ttsGenderPreference: map['ttsGenderPreference'] ?? "auto",
      hapticLevel: map['hapticLevel'] ?? "off",
      autoEnableFlashlight: map['autoEnableFlashlight'] ?? true,
      forceLocalAiMode: map['forceLocalAiMode'] ?? false,
      aiShortResponse: map['aiShortResponse'] ?? true,
      userMedicalProfile: map['userMedicalProfile'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory AppSettingsModel.fromJson(String source) =>
      AppSettingsModel.fromMap(json.decode(source));
}

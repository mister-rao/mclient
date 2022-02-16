// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatrixLoginResponse _$MatrixLoginResponseFromJson(Map<String, dynamic> json) =>
    MatrixLoginResponse(
      matrixToken: json['matrix_token'] as String,
      deviceId: json['device_id'] as String,
      matrixUserId: json['matrix_user_id'] as String,
    );

Map<String, dynamic> _$MatrixLoginResponseToJson(
        MatrixLoginResponse instance) =>
    <String, dynamic>{
      'error': instance.error,
      'matrix_token': instance.matrixToken,
      'device_id': instance.deviceId,
      'matrix_user_id': instance.matrixUserId,
    };

MatrixGetProfileResponse _$MatrixGetProfileResponseFromJson(
        Map<String, dynamic> json) =>
    MatrixGetProfileResponse(
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$MatrixGetProfileResponseToJson(
        MatrixGetProfileResponse instance) =>
    <String, dynamic>{
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
    };

MatrixGetJoinedRoomsResponse _$MatrixGetJoinedRoomsResponseFromJson(
        Map<String, dynamic> json) =>
    MatrixGetJoinedRoomsResponse(
      rooms: json['rooms'] as List<dynamic>,
    );

Map<String, dynamic> _$MatrixGetJoinedRoomsResponseToJson(
        MatrixGetJoinedRoomsResponse instance) =>
    <String, dynamic>{
      'rooms': instance.rooms,
    };

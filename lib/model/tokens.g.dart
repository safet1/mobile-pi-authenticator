// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HOTPToken _$HOTPTokenFromJson(Map<String, dynamic> json) {
  return HOTPToken(
    label: json['label'] as String,
    isLocked: json['isLocked'] as bool,
    lockCanBeToggled: json['lockCanBeToggled'] as bool,
    issuer: json['issuer'] as String,
    id: json['id'] as String,
    algorithm: _$enumDecodeNullable(_$AlgorithmsEnumMap, json['algorithm']),
    digits: json['digits'] as int,
    secret: json['secret'] as String,
    counter: json['counter'] as int,
  )..type = json['type'] as String;
}

Map<String, dynamic> _$HOTPTokenToJson(HOTPToken instance) => <String, dynamic>{
      'type': instance.type,
      'isLocked': instance.isLocked,
      'lockCanBeToggled': instance.lockCanBeToggled,
      'label': instance.label,
      'id': instance.id,
      'issuer': instance.issuer,
      'algorithm': _$AlgorithmsEnumMap[instance.algorithm],
      'digits': instance.digits,
      'secret': instance.secret,
      'counter': instance.counter,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$AlgorithmsEnumMap = {
  Algorithms.SHA1: 'SHA1',
  Algorithms.SHA256: 'SHA256',
  Algorithms.SHA512: 'SHA512',
};

TOTPToken _$TOTPTokenFromJson(Map<String, dynamic> json) {
  return TOTPToken(
    label: json['label'] as String,
    isLocked: json['isLocked'] as bool,
    lockCanBeToggled: json['lockCanBeToggled'] as bool,
    issuer: json['issuer'] as String,
    id: json['id'] as String,
    algorithm: _$enumDecodeNullable(_$AlgorithmsEnumMap, json['algorithm']),
    digits: json['digits'] as int,
    secret: json['secret'] as String,
    period: json['period'] as int,
  )..type = json['type'] as String;
}

Map<String, dynamic> _$TOTPTokenToJson(TOTPToken instance) => <String, dynamic>{
      'type': instance.type,
      'label': instance.label,
      'isLocked': instance.isLocked,
      'lockCanBeToggled': instance.lockCanBeToggled,
      'id': instance.id,
      'issuer': instance.issuer,
      'algorithm': _$AlgorithmsEnumMap[instance.algorithm],
      'digits': instance.digits,
      'secret': instance.secret,
      'period': instance.period,
    };

PushToken _$PushTokenFromJson(Map<String, dynamic> json) {
  return PushToken(
    label: json['label'] as String,
    isLocked: json['isLocked'] as bool,
    lockCanBeToggled: json['lockCanBeToggled'] as bool,
    serial: json['serial'] as String,
    issuer: json['issuer'] as String,
    id: json['id'] as String,
    sslVerify: json['sslVerify'] as bool,
    enrollmentCredentials: json['enrollmentCredentials'] as String,
    url: json['url'] == null ? null : Uri.parse(json['url'] as String),
    expirationDate: json['expirationDate'] == null
        ? null
        : DateTime.parse(json['expirationDate'] as String),
  )
    ..type = json['type'] as String
    ..isRolledOut = json['isRolledOut'] as bool
    ..publicServerKey = json['publicServerKey'] as String
    ..privateTokenKey = json['privateTokenKey'] as String
    ..publicTokenKey = json['publicTokenKey'] as String
    ..pushRequests = json['pushRequests'] == null
        ? null
        : PushRequestQueue.fromJson(
            json['pushRequests'] as Map<String, dynamic>)
    ..knownPushRequests = json['knownPushRequests'] == null
        ? null
        : CustomIntBuffer.fromJson(
            json['knownPushRequests'] as Map<String, dynamic>);
}

Map<String, dynamic> _$PushTokenToJson(PushToken instance) => <String, dynamic>{
      'type': instance.type,
      'label': instance.label,
      'id': instance.id,
      'issuer': instance.issuer,
      'isLocked': instance.isLocked,
      'lockCanBeToggled': instance.lockCanBeToggled,
      'url': instance.url?.toString(),
      'isRolledOut': instance.isRolledOut,
      'publicServerKey': instance.publicServerKey,
      'privateTokenKey': instance.privateTokenKey,
      'publicTokenKey': instance.publicTokenKey,
      'serial': instance.serial,
      'sslVerify': instance.sslVerify,
      'enrollmentCredentials': instance.enrollmentCredentials,
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'pushRequests': instance.pushRequests,
      'knownPushRequests': instance.knownPushRequests,
    };

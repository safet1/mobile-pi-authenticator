// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

PushRequest _$PushRequestFromJson(Map<String, dynamic> json) {
  return PushRequest(
    title: json['title'] as String,
    question: json['question'] as String,
    uri: json['uri'] == null ? null : Uri.parse(json['uri'] as String),
    nonce: json['nonce'] as String,
    sslVerify: json['sslVerify'] as bool,
    id: json['id'] as int,
    expirationDate: json['expirationDate'] == null
        ? null
        : DateTime.parse(json['expirationDate'] as String),
  );
}

Map<String, dynamic> _$PushRequestToJson(PushRequest instance) =>
    <String, dynamic>{
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'id': instance.id,
      'nonce': instance.nonce,
      'sslVerify': instance.sslVerify,
      'uri': instance.uri?.toString(),
      'question': instance.question,
      'title': instance.title,
    };

PushRequestQueue _$PushRequestQueueFromJson(Map<String, dynamic> json) {
  return PushRequestQueue()
    ..list = (json['list'] as List)
        ?.map((e) =>
    e == null ? null : PushRequest.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$PushRequestQueueToJson(PushRequestQueue instance) =>
    <String, dynamic>{
      'list': instance.list,
    };

SerializableRSAPublicKey _$SerializableRSAPublicKeyFromJson(
    Map<String, dynamic> json) {
  return SerializableRSAPublicKey(
    json['modulus'] == null ? null : BigInt.parse(json['modulus'] as String),
    json['exponent'] == null ? null : BigInt.parse(json['exponent'] as String),
  );
}

Map<String, dynamic> _$SerializableRSAPublicKeyToJson(
    SerializableRSAPublicKey instance) =>
    <String, dynamic>{
      'modulus': instance.modulus?.toString(),
      'exponent': instance.exponent?.toString(),
    };

SerializableRSAPrivateKey _$SerializableRSAPrivateKeyFromJson(
    Map<String, dynamic> json) {
  return SerializableRSAPrivateKey(
    json['modulus'] == null ? null : BigInt.parse(json['modulus'] as String),
    json['exponent'] == null ? null : BigInt.parse(json['exponent'] as String),
    json['p'] == null ? null : BigInt.parse(json['p'] as String),
    json['q'] == null ? null : BigInt.parse(json['q'] as String),
  );
}

Map<String, dynamic> _$SerializableRSAPrivateKeyToJson(
    SerializableRSAPrivateKey instance) =>
    <String, dynamic>{
      'modulus': instance.modulus?.toString(),
      'exponent': instance.exponent?.toString(),
      'p': instance.p?.toString(),
      'q': instance.q?.toString(),
    };

CustomIntBuffer _$CustomIntBufferFromJson(Map<String, dynamic> json) {
  return CustomIntBuffer()
    ..list = (json['list'] as List)?.map((e) => e as int)?.toList();
}

Map<String, dynamic> _$CustomIntBufferToJson(CustomIntBuffer instance) =>
    <String, dynamic>{
      'list': instance.list,
    };

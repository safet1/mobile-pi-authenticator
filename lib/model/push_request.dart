/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/export.dart';

part 'push_request.g.dart';

@JsonSerializable()
class PushRequest {
  String _title;
  String _question;

  int _id;

  Uri _uri;
  String _nonce;
  bool _sslVerify;

  DateTime _expirationDate;

  DateTime get expirationDate => _expirationDate;

  int get id => _id;

  String get nonce => _nonce;

  bool get sslVerify => _sslVerify;

  Uri get uri => _uri;

  String get question => _question;

  String get title => _title;

  PushRequest(
      {String title,
        String question,
        Uri uri,
        String nonce,
        bool sslVerify,
        int id,
        DateTime expirationDate})
      : this._title = title,
        this._question = question,
        this._uri = uri,
        this._nonce = nonce,
        this._sslVerify = sslVerify,
        this._id = id,
        this._expirationDate = expirationDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PushRequest &&
              runtimeType == other.runtimeType &&
              _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    return 'PushRequest{_title: $_title, _question: $_question,'
        ' _id: $_id, _uri: $_uri, _nonce: $_nonce, _sslVerify: $_sslVerify}';
  }

  factory PushRequest.fromJson(Map<String, dynamic> json) =>
      _$PushRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PushRequestToJson(this);
}

@JsonSerializable()
class PushRequestQueue {
  PushRequestQueue();

  List<PushRequest> _list;

  // The get and set methods are needed for serialization.
  List<PushRequest> get list {
    _list ??= [];
    return _list;
  }

  set list(List<PushRequest> l) {
    if (_list != null) {
      throw ArgumentError(
          "Initializing [list] in [PushRequestQueue] is only allowed once.");
    }

    this._list = l;
  }

  int get length => list.length;

  void forEach(void f(PushRequest request)) => list.forEach((f));

  void removeWhere(bool f(PushRequest request)) => list.removeWhere(f);

  Iterable<PushRequest> where(bool f(PushRequest request)) => _list.where(f);

  bool any(bool f(PushRequest element)) => _list.any(f);

  void remove(PushRequest request) => _list.remove(request);

  bool get isEmpty => list.isEmpty;

  bool get isNotEmpty => list.isNotEmpty;

  bool contains(PushRequest r) => _list.contains(r);

  void add(PushRequest pushRequest) => list.add(pushRequest);

  PushRequest peek() => list.first;

  PushRequest pop() => list.removeAt(0);

  @override
  String toString() {
    return 'PushRequestQueue{_list: $list}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PushRequestQueue &&
              runtimeType == other.runtimeType &&
              _listsAreEqual(list, other.list);

  bool _listsAreEqual(List<PushRequest> l1, List<PushRequest> l2) {
    if (l1.length != l2.length) return false;

    for (int i = 0; i < l1.length - 1; i++) {
      if (l1[i] != l2[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode => list.hashCode;

  factory PushRequestQueue.fromJson(Map<String, dynamic> json) =>
      _$PushRequestQueueFromJson(json);

  Map<String, dynamic> toJson() => _$PushRequestQueueToJson(this);
}

@JsonSerializable()
class SerializableRSAPublicKey extends RSAPublicKey {
  SerializableRSAPublicKey(BigInt modulus, BigInt exponent)
      : super(modulus, exponent);

  factory SerializableRSAPublicKey.fromJson(Map<String, dynamic> json) =>
      _$SerializableRSAPublicKeyFromJson(json);

  Map<String, dynamic> toJson() => _$SerializableRSAPublicKeyToJson(this);
}

@JsonSerializable()
class SerializableRSAPrivateKey extends RSAPrivateKey {
  SerializableRSAPrivateKey(BigInt modulus, BigInt exponent, BigInt p, BigInt q)
      : super(modulus, exponent, p, q);

  factory SerializableRSAPrivateKey.fromJson(Map<String, dynamic> json) =>
      _$SerializableRSAPrivateKeyFromJson(json);

  Map<String, dynamic> toJson() => _$SerializableRSAPrivateKeyToJson(this);
}

@JsonSerializable()
class CustomIntBuffer {
  final int maxSize = 30;

  CustomIntBuffer();

  List<int> _list;

  // The get and set methods are needed for serialization.
  List<int> get list {
    _list ??= List();
    return _list;
  }

  set list(List<int> l) {
    if (_list != null) {
      throw ArgumentError(
          "Initializing [list] in [CustomStringBuffer] is only allowed once.");
    }

    if (l.length > maxSize) {
      throw ArgumentError(
          'The list $l is to long for a buffer of size $maxSize');
    }

    this._list = l;
  }

  void put(int value) {
    if (_list.length >= maxSize) list.removeAt(0);
    _list.add(value);
  }

  int get length => _list.length;

  bool contains(int value) => _list.contains(value);

  factory CustomIntBuffer.fromJson(Map<String, dynamic> json) =>
      _$CustomIntBufferFromJson(json);

  Map<String, dynamic> toJson() => _$CustomIntBufferToJson(this);
}
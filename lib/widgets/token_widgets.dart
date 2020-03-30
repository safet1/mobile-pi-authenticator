/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

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

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

class TokenWidget extends StatefulWidget {
  final Token _token;
  final VoidCallback _onDeleteClicked;

  TokenWidget({Key key, Token token, onDeleteClicked})
      : this._token = token,
        this._onDeleteClicked = onDeleteClicked,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    if (_token is HOTPToken) {
      return _HotpWidgetState(_token, _onDeleteClicked);
    } else if (_token is TOTPToken) {
      return _TotpWidgetState(_token, _onDeleteClicked);
    } else if (_token is PushToken) {
      return _PushWidgetState(_token, _onDeleteClicked);
    } else {
      throw ArgumentError.value(_token, "token",
          "The token [$_token] is of unknown type and not supported.");
    }
  }
}

abstract class _TokenWidgetState extends State<TokenWidget> {
  final Token _token;
  static final SlidableController _slidableController = SlidableController();
  String _label;

  final VoidCallback _onDeleteClicked;

  _TokenWidgetState(this._token, this._onDeleteClicked) {
    _saveThisToken();
    _label = _token.label;
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(_token.uuid),
      // This is used to only let one Slidable be open at a time.
      controller: _slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _buildTile(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: L10n.of(context).delete,
          color: getTonedColor(Colors.red, isDarkModeOn(context)),
          icon: Icons.delete,
          onTap: () => _deleteTokenDialog(),
        ),
        IconSlideAction(
          caption: L10n.of(context).rename,
          color: getTonedColor(Colors.blue, isDarkModeOn(context)),
          icon: Icons.edit,
          onTap: () => _renameTokenDialog(),
        ),
      ],
    );
  }

  void _renameTokenDialog() {
    final _nameInputKey = GlobalKey<FormFieldState>();
    String _selectedName = _label;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(L10n.of(context).renameDialogTitle),
            content: TextFormField(
              autofocus: true,
              initialValue: _label,
              key: _nameInputKey,
              onChanged: (value) => this.setState(() => _selectedName = value),
              decoration: InputDecoration(labelText: L10n.of(context).nameHint),
              validator: (value) {
                if (value.isEmpty) {
                  return L10n.of(context).nameHint;
                }
                return null;
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  L10n.of(context).cancel,
                  style: getDialogTextStyle(isDarkModeOn(context)),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text(
                  L10n.of(context).rename,
                  style: getDialogTextStyle(isDarkModeOn(context)),
                ),
                onPressed: () {
                  if (_nameInputKey.currentState.validate()) {
                    _renameClicked(_selectedName);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  void _renameClicked(String newLabel) {
    _token.label = newLabel;
    _saveThisToken();
    log(
      "Renamed token:",
      name: "token_widgets.dart",
      error: "\"${_token.label}\" changed to \"$newLabel\"",
    );

    setState(() {
      _label = _token.label;
    });
  }

  void _deleteTokenDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(L10n.of(context).deleteDialogTitle),
            content: RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: L10n.of(context).areYouSure,
                      style: getDialogTextStyle(isDarkModeOn(context)),
                    ),
                    TextSpan(
                      text: " \'$_label\'?",
                      style: getDialogTextStyle(isDarkModeOn(context)).copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ]),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  L10n.of(context).cancel,
                  style: getDialogTextStyle(isDarkModeOn(context)),
                ),
              ),
              FlatButton(
                onPressed: () {
                  _onDeleteClicked();
                  Navigator.of(context).pop();
                },
                child: Text(
                  L10n.of(context).delete,
                  style: getDialogTextStyle(isDarkModeOn(context)),
                ),
              ),
            ],
          );
        });
  }

  void _saveThisToken() {
    StorageUtil.saveOrReplaceToken(this._token);
  }

  Widget _buildTile();
}

class _PushWidgetState extends _TokenWidgetState {
  _PushWidgetState(Token token, VoidCallback onDeleteClicked)
      : super(token, onDeleteClicked);

  // TODO change rename and delete while roll out process is running

  PushToken get _token => super._token as PushToken;

  bool _rollOutFailed = false;

  @override
  void initState() {
    super.initState();

    if (!_token.isRolledOut) {
      _rollOutToken();
    }
  }

  void _rollOutToken() async {
    setState(() {
      _rollOutFailed = false;
    });

    // TODO check expiration date

    final keyPair = await generateRSAKeyPair();

    log(
      "Setting private key for token",
      name: "token_widgets.dart",
      error: "Token: $_token, key: ${keyPair.privateKey}",
    );
    _token.privateTokenKey = keyPair.privateKey;

    try {
      Response response =
          await doPost(sslVerify: _token.sslVerify, url: _token.url, body: {
        'enrollment_credential': _token.enrollmentCredentials,
        'serial': _token.serial,
        'fbtoken': _token.firebaseToken,
        'pubkey': serializeRSAPublicKeyPKCS8(keyPair.publicKey),
      });

      if (response.statusCode == 200) {
        RSAPublicKey publicServerKey = await _parseRollOutResponse(response);
        _token.publicServerKey = publicServerKey;

        log('Roll out successful', name: 'token_widgets.dart', error: _token);

        setState(() {
          _token.isRolledOut = true;
          _saveThisToken();
        });
      } else {
        log("Post request on roll out failed.",
            name: "token_widgets.dart",
            error: "Token: $_token, Status code: ${response.statusCode},"
                " Body: ${response.body}");

        setState(() {
          _rollOutFailed = true;
        });

        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Rolling out token ${_token.label} failed."
              "Error code: ${response.statusCode}"),
          // TODO translate
          duration: Duration(seconds: 3),
        ));
      }
    } on SocketException catch (e) {
      log("Roll out push token [$_token] failed.",
          name: "token_widgets.dart", error: e);

      setState(() {
        _rollOutFailed = true;
      });

      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("No internet connection, rollout not possible."),
          // TODO translate
          duration: Duration(seconds: 3)));
    } on Exception catch (e) {
      log("Roll out push token [$_token] failed.",
          name: "token_widgets.dart", error: e);

      setState(() {
        _rollOutFailed = true;
      });

      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("An unknown error occured, rollout not possible: $e"),
          // TODO translate
          duration: Duration(seconds: 5)));
    }
  }

  Future<RSAPublicKey> _parseRollOutResponse(Response response) async {
    response = Response("sdhg",
        200); // TODO remove this late -> just to force failing roll out right now.

    log("Parsing rollout response, try to extract public_key.",
        name: "token_widgets.dart", error: response.body);

    try {
      String key = json.decode(response.body)['detail']['public_key'];
      key = key.replaceAll('\n', '');

      log("Extracting public key was successful.",
          name: "token_widgets.dart", error: key);

      return deserializeRSAPublicKeyPKCS1(key);
    } on FormatException catch (e) {
      throw FormatException(
          "Response body does not contain RSA public key.", e);

      throw ArgumentError.value(response.body, "response.body",
          "Response body does not contain public RSA key of the server.");
    }
  }

  void acceptRequest() async {
    log('Push auth request accepted, sending message',
        name: 'token_widgets.dart', error: 'Url: ${_token.requestUri}');

    // signature ::=  {nonce}|{serial}

    //    POST https://privacyideaserver/validate/check
    //    nonce=<nonce_from_request>
    //    serial=<serial>
    //    signature=<signature>
    Map<String, String> body = {
      'nonce': _token.requestNonce,
      'serial': _token.serial,
      'signature': createBase32Signature(_token.privateTokenKey,
          utf8.encode('${_token.requestNonce}|${_token.serial}')),
    };

    try {
      Response response = await doPost(
          sslVerify: _token.requestSSLVerify,
          url: _token.requestUri,
          body: body);

      if (response.statusCode == 200) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Accepted push auth request for ${_token.label}."),
          // TODO translate
          duration: Duration(seconds: 2),
        ));
        resetRequest();
      } else {
        log("Accepting push auth request failed.",
            name: "token_widgets.dart",
            error: "Token: $_token, Status code: ${response.statusCode}, "
                "Body: ${response.body}");

        Scaffold.of(context).showSnackBar(SnackBar(
          content:
              Text("Accepting push auth request for ${_token.label} failed. "
                  "Error code: ${response.statusCode}"),
          // TODO translate
          duration: Duration(seconds: 3),
        ));
      }
    } on SocketException catch (e) {
      log("Accept push auth request for [$_token] failed.",
          name: "token_widgets.dart", error: e);
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("No internet connection, authentication not possible."),
          // TODO translate
          duration: Duration(seconds: 3)));
    } on Exception catch (e) {
      log("Accept push auth request for [$_token] failed.",
          name: "token_widgets.dart", error: e);
      Scaffold.of(context).showSnackBar(SnackBar(
          content:
              Text("An unknown error occured, accepting push authenticatinon"
                  " failed: $e"),
          // TODO translate
          duration: Duration(seconds: 5)));
    }
  }

  void declineRequest() async {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Declined push auth request for ${_token.label}."),
      // TODO translate
      duration: Duration(seconds: 2),
    ));
    resetRequest();
  }

  /// Reset the token status after push auth request was handled by the user.
  void resetRequest() {
    setState(() {
      _token.hasPendingRequest = false;
      _token.requestUri = null;
      _token.requestNonce = null;
      _token.requestSSLVerify = false;
    });
  }

  @override
  Widget _buildTile() {
    return ClipRect(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  _token.serial,
                  textScaleFactor: 2.3,
                ),
                subtitle: Text(
                  _label,
                  textScaleFactor: 2.0,
                ),
              ),
              Visibility(
                visible: _token.hasPendingRequest,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      // TODO style and translate
                      child: Text("Yes"),
                      onPressed: acceptRequest,
                    ),
                    RaisedButton(
                      // TODO style and translate
                      child: Text("No"),
                      onPressed: declineRequest,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _rollOutFailed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      // TODO style and translate
                      child: Text("Rollout failed, try again."),
                      onPressed: _rollOutToken,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Visibility(
              visible: !_token.isRolledOut && !_rollOutFailed,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Column(
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Text('Rollingn out'),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

abstract class _OTPTokenWidgetState extends _TokenWidgetState {
  String _otpValue;

  _OTPTokenWidgetState(OTPToken token, VoidCallback onDeleteClicked)
      : _otpValue = calculateOtpValue(token),
        super(token, onDeleteClicked);

  // This gets overridden in subclasses.
  void _updateOtpValue();

  @override
  Widget _buildTile() {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: _otpValue));
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(L10n.of(context).otpValueCopiedMessage(_otpValue)),
        ));
      },
      child: _buildNonClickableTile(),
    );
  }

  Widget _buildNonClickableTile();
}

class _HotpWidgetState extends _OTPTokenWidgetState {
  bool buttonIsDisabled = false;

  _HotpWidgetState(OTPToken token, Function delete) : super(token, delete);

  @override
  void _updateOtpValue() {
    setState(() {
      (_token as HOTPToken).incrementCounter();
      _otpValue = calculateOtpValue(_token);
      _saveThisToken(); // When the app reloads the counter should not be reset.

      _disableButtonForSomeTime();
    });
  }

  void _disableButtonForSomeTime() {
    // Disable the button for 1 s.
    buttonIsDisabled = true;
    Timer(Duration(seconds: 1), () => setState(() => buttonIsDisabled = false));
  }

  @override
  Widget _buildNonClickableTile() {
    return Stack(
      children: <Widget>[
        ListTile(
          title: Text(
            insertCharAt(_otpValue, " ", (_token as OTPToken).digits ~/ 2),
            textScaleFactor: 2.5,
          ),
          subtitle: Text(
            _label,
            textScaleFactor: 2.0,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: RaisedButton(
              onPressed: buttonIsDisabled ? null : () => _updateOtpValue(),
              child: Text(
                L10n.of(context).next,
                textScaleFactor: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TotpWidgetState extends _OTPTokenWidgetState
    with SingleTickerProviderStateMixin {
  AnimationController
      controller; // Controller for animating the LinearProgressAnimator

  _TotpWidgetState(OTPToken token, Function delete) : super(token, delete);

  @override
  void _updateOtpValue() {
    setState(() {
      _otpValue = calculateOtpValue(_token);
    });
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: (_token as TOTPToken).period),
      // Animate the progress for the duration of the tokens period.
      vsync:
          this, // By extending SingleTickerProviderStateMixin we can use this object as vsync, this prevents offscreen animations.
    )
      ..addListener(() {
        // Adding a listener to update the view for the animation steps.
        setState(() => {
              // The state that has changed here is the animation object’s value.
            });
      })
      ..addStatusListener((status) {
        // Add listener to restart the animation after the period, also updates the otp value.
        if (status == AnimationStatus.completed) {
          controller.forward(from: 0.0);
          _updateOtpValue();
        }
      })
      ..forward(); // Start the animation.

    // Update the otp value when the android app resumes, this prevents outdated otp values
    // ignore: missing_return
    SystemChannels.lifecycle.setMessageHandler((msg) {
      log(
        "SystemChannels:",
        name: "totpwidget.dart",
        error: msg,
      );
      if (msg == AppLifecycleState.resumed.toString()) {
        _updateOtpValue();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose the controller to prevent memory leak.
    super.dispose();
  }

  @override
  Widget _buildNonClickableTile() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            insertCharAt(_otpValue, " ", (_token as OTPToken).digits ~/ 2),
            textScaleFactor: 2.5,
          ),
          subtitle: Text(
            _label,
            textScaleFactor: 2.0,
          ),
        ),
        LinearProgressIndicator(
          value: controller.value,
        ),
      ],
    );
  }
}

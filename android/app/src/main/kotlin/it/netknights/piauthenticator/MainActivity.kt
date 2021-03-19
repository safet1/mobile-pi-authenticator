package it.netknights.piauthenticator

import android.os.Bundle
import android.view.WindowManager

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.app.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    GeneratedPluginRegistrant.registerWith(this)
  }
}

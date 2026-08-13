package com.pdfbarcode.pdf_barcode_decoder

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.Executors

class PdfBarcodeDecoderPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val executor = Executors.newCachedThreadPool()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pdf_barcode_decoder")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "decodePdf") {
            val pdfBytes = call.argument<ByteArray>("pdfBytes")
            val filePath = call.argument<String>("filePath")
            val config = call.argument<Map<String, Any>>("config") ?: emptyMap()

            executor.execute {
                try {
                    val manager = PdfDecodeManager(context)
                    val barcodes = manager.decodePdf(pdfBytes, filePath, config)
                    mainHandler.post {
                        result.success(barcodes)
                    }
                } catch (e: Exception) {
                    val message = e.message ?: "Unknown error"
                    val code = if (message.contains(":")) message.substringBefore(":") else "RENDER_FAILED"
                    val details = if (message.contains(":")) message.substringAfter(":").trim() else message
                    mainHandler.post {
                        result.error(code, details, null)
                    }
                }
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

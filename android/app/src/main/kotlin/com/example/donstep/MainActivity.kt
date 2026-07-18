package com.example.donstep

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        StepCounterHandler.registerWith(this, flutterEngine)
    }
}

class StepCounterHandler private constructor(context: Context) : EventChannel.StreamHandler {
    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
    private var listener: SensorEventListener? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (stepSensor == null) return
        listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent?) {
                event?.values?.firstOrNull()?.let { steps ->
                    events?.success(steps.toInt())
                }
            }
            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }
        sensorManager.registerListener(listener, stepSensor, SensorManager.SENSOR_DELAY_UI)
    }

    override fun onCancel(arguments: Any?) {
        listener?.let { sensorManager.unregisterListener(it) }
        listener = null
    }

    companion object {
        fun registerWith(activity: FlutterActivity, engine: FlutterEngine) {
            EventChannel(engine.dartExecutor.binaryMessenger, "com.donstep.app/steps")
                .setStreamHandler(StepCounterHandler(activity))
        }
    }
}

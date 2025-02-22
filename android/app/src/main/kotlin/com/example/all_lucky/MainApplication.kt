package com.example.all_lucky

import io.flutter.app.FlutterApplication
import androidx.multidex.MultiDexApplication
import android.content.Context
import androidx.multidex.MultiDex
import android.os.Process
import java.io.File
import java.io.FileOutputStream
import java.io.PrintWriter
import java.text.SimpleDateFormat
import java.util.*

class MainApplication : MultiDexApplication() {
    companion object {
        private const val TAG = "MainApplication"
        private const val CRASH_DIR = "crash_logs"
    }

    override fun onCreate() {
        super.onCreate()
        // 初始化錯誤處理
        setupErrorHandler()
        // 確保崩潰日誌目錄存在
        ensureCrashLogDir()
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        // 初始化 MultiDex
        MultiDex.install(this)
    }

    private fun setupErrorHandler() {
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            try {
                // 記錄崩潰日誌
                saveCrashLog(throwable)
                // 輸出到 LogCat
                android.util.Log.e(TAG, "Uncaught exception in thread ${thread.name}", throwable)
            } finally {
                // 結束程序
                Process.killProcess(Process.myPid())
            }
        }
    }

    private fun ensureCrashLogDir(): File {
        val crashDir = File(filesDir, CRASH_DIR)
        if (!crashDir.exists()) {
            crashDir.mkdirs()
        }
        return crashDir
    }

    private fun saveCrashLog(throwable: Throwable) {
        try {
            val timestamp = SimpleDateFormat("yyyy-MM-dd_HH-mm-ss", Locale.getDefault())
                .format(Date())
            val filename = "crash_$timestamp.txt"
            val crashFile = File(ensureCrashLogDir(), filename)

            FileOutputStream(crashFile).use { fos ->
                PrintWriter(fos).use { pw ->
                    pw.println("Time: $timestamp")
                    pw.println("Device: ${android.os.Build.MANUFACTURER} ${android.os.Build.MODEL}")
                    pw.println("Android: ${android.os.Build.VERSION.RELEASE} (API ${android.os.Build.VERSION.SDK_INT})")
                    pw.println("App Version: ${packageManager.getPackageInfo(packageName, 0).versionName}")
                    pw.println("\nStack Trace:")
                    throwable.printStackTrace(pw)
                }
            }
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Error saving crash log", e)
        }
    }
} 
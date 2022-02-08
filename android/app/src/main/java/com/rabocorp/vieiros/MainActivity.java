package com.rabocorp.vieiros;

import android.content.ContentResolver;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import android.util.Log;
import android.window.SplashScreenView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.WindowCompat;
import androidx.documentfile.provider.DocumentFile;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    @Nullable
    private String openedFile;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        String CHANNEL = "com.rabocorp.vieiros/opened_file";
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if(call.method.equals("getOpenedFile")){
                                result.success(this.openedFile);
                                this.openedFile = null;
                            }else{
                                result.notImplemented();
                            }
                        }
                );
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState){
        // Aligns the Flutter view vertically with the window.
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Disable the Android splash screen fade out animation to avoid
            // a flicker before the similar frame is drawn in Flutter.
            getSplashScreen()
                    .setOnExitAnimationListener(
                            (SplashScreenView splashScreenView) -> {
                                splashScreenView.remove();
                            });
        }
        super.onCreate(savedInstanceState);
        this.handleOpenFileUrl(this.getIntent());
    }

    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        this.handleOpenFileUrl(intent);
    }

    private void handleOpenFileUrl(Intent intent){
        if(intent != null && intent.getData() != null){
            ContentResolver contentResolver = getApplicationContext().getContentResolver();
            Uri uri = intent.getData();
            DocumentFile documentFile = DocumentFile.fromSingleUri(getApplicationContext(), uri);
            String name = "";
            if(documentFile != null && documentFile.getName() != null) name = documentFile.getName();
            StringBuilder text = new StringBuilder();
            try {
                InputStream inputStream = contentResolver.openInputStream(uri);
                InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                BufferedReader br = new BufferedReader(inputStreamReader);
                String line;
                while ((line = br.readLine()) != null) {
                    text.append(line);
                }
                br.close();
            } catch (Exception e) {
                Log.e(e.getClass().getCanonicalName(), e.getMessage());
            }
            this.openedFile = text.toString();
        }
    }
}
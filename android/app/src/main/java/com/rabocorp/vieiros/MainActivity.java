package com.rabocorp.vieiros;


import android.os.Build;
import android.os.Bundle;

import android.window.SplashScreenView;

import androidx.annotation.Nullable;
import androidx.core.view.WindowCompat;


import io.flutter.embedding.android.FlutterActivity;


public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState){
        // Aligns the Flutter view vertically with the window.
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Disable the Android splash screen fade out animation to avoid
            // a flicker before the similar frame is drawn in Flutter.
            getSplashScreen()
                    .setOnExitAnimationListener(
                            SplashScreenView::remove);
        }
        super.onCreate(savedInstanceState);
    }
}
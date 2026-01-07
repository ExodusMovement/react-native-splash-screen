package org.devio.rn.splashscreen;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Arguments;

/**
 * SplashScreen
 * 启动屏
 * from：http://www.devio.org
 * Author:CrazyCodeBoy
 * GitHub:https://github.com/crazycodeboy
 * Email:crazycodeboy@gmail.com
 */
public class SplashScreenModule extends ReactContextBaseJavaModule{
    public SplashScreenModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "SplashScreen";
    }

    /**
     * 打开启动屏
     */
    @ReactMethod
    public void show(@Nullable ReadableMap options) {
        SplashScreen.show(getCurrentActivity(), options != null ? options : Arguments.createMap());
    }

    /**
     * 关闭启动屏
     */
    @ReactMethod
    public void hide(@Nullable ReadableMap options) {
        SplashScreen.hide(getCurrentActivity(), options != null ? options : Arguments.createMap());
    }

    @ReactMethod
    public void showVideo(@Nullable ReadableMap options) {
        SplashScreen.showVideo(getCurrentActivity(), options != null ? options : Arguments.createMap());
    }

    @ReactMethod
    public void hideVideo() {
        SplashScreen.hideVideo(getCurrentActivity());
    }

    @ReactMethod
    public void setBackgroundColor(String color) {
        SplashScreen.setBackgroundColor(getCurrentActivity(), color);
    }

    @ReactMethod
    public void removeVideoPauseOption() {
        SplashScreen.removeVideoPauseOption(getCurrentActivity());
    }

    @ReactMethod
    public void resumeVideo() {
        SplashScreen.resumeVideo(getCurrentActivity());
    }
}

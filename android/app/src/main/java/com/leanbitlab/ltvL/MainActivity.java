/*
 * FLauncher
 * Copyright (C) 2021  Oscar Rojas
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package com.omeda.arc;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.*;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.ConnectivityManager;
import android.net.NetworkCapabilities;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.MediaStore;
import android.provider.Settings;
import android.util.Pair;
import android.media.tv.TvContract;
import android.database.Cursor;
import android.Manifest;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.FileProvider;
import androidx.annotation.RequiresApi;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.io.ByteArrayOutputStream;
import java.io.File;
import android.app.usage.NetworkStats;
import android.app.usage.NetworkStatsManager;
import android.app.AppOpsManager;
import android.os.RemoteException;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.Callable;
import java.util.concurrent.CompletionService;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorCompletionService;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class MainActivity extends FlutterActivity {
    private final String METHOD_CHANNEL = "me.efesser.flauncher/method";
    private final String APPS_EVENT_CHANNEL = "me.efesser.flauncher/event_apps";
    private final String NETWORK_EVENT_CHANNEL = "me.efesser.flauncher/event_network";
    private static final String PERMISSION_READ_TV_LISTINGS = "android.permission.READ_TV_LISTINGS";
    private static final int REQUEST_CODE_READ_TV_LISTINGS = 1001;
    private static final String COLUMN_ASPECT_RATIO = "aspect_ratio";
    private static final int WATCH_NEXT_MIN_IMAGE_WIDTH = 1920;
    private static final int WATCH_NEXT_CACHE_MIN_WIDTH = 320;
    private static final long WATCH_NEXT_CACHE_MAX_AGE_MS = 7L * 24 * 60 * 60 * 1000;

    private final ExecutorService imageExecutor = Executors.newFixedThreadPool(2);
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    private MethodChannel methodChannel;

    // singleTask: a repeated HOME press with the launcher on screen arrives here, not in onResume.
    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        if (Intent.ACTION_MAIN.equals(intent.getAction())
                && intent.hasCategory(Intent.CATEGORY_HOME)
                && methodChannel != null) {
            methodChannel.invokeMethod("homePressed", null);
        }
    }

    @Override
    protected void onDestroy() {
        imageExecutor.shutdown();
        super.onDestroy();
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        BinaryMessenger messenger = flutterEngine.getDartExecutor().getBinaryMessenger();

        methodChannel = new MethodChannel(messenger, METHOD_CHANNEL);
        methodChannel.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "getApplications" -> result.success(getApplications());
                case "getApplicationBanner" -> result.success(getApplicationBanner(call.arguments()));
                case "getApplicationIcon" -> result.success(getApplicationIcon(call.arguments()));
                case "applicationExists" -> result.success(applicationExists(call.arguments()));
                case "launchActivityFromAction" -> result.success(launchActivityFromAction(call.arguments()));
                case "launchApp" -> result.success(launchApp(call.arguments()));
                case "openSettings" -> result.success(openSettings());
                case "installApk" -> result.success(installApk(call.arguments()));
                case "getPrimaryAbi" -> result.success(Build.SUPPORTED_ABIS.length > 0 ? Build.SUPPORTED_ABIS[0] : null);
                case "requestInstallUnknownAppsPermission" -> {
                    requestInstallUnknownAppsPermission();
                    result.success(null);
                }
                case "openScreensaverSettings" -> result.success(openScreensaverSettings());
                case "openAppInfo" -> result.success(openAppInfo(call.arguments()));
                case "uninstallApp" -> result.success(uninstallApp(call.arguments()));
                case "isDefaultLauncher" -> result.success(isDefaultLauncher());
                case "checkForGetContentAvailability" -> result.success(checkForGetContentAvailability());
                case "startAmbientMode" -> result.success(startAmbientMode());
                case "getActiveNetworkInformation" -> result.success(getActiveNetworkInformation());
                case "getDailyWifiUsage" -> {
                    long usage = getDailyWifiUsage();
                    if (usage == -1) {
                        result.error("PERMISSION_DENIED", "Usage stats permission not granted", null);
                    } else {
                        result.success(usage);
                    }
                }
                case "getWeeklyWifiUsage" -> {
                    long usage = getWeeklyWifiUsage();
                    if (usage == -1) {
                        result.error("PERMISSION_DENIED", "Usage stats permission not granted", null);
                    } else {
                        result.success(usage);
                    }
                }
                case "getMonthlyWifiUsage" -> {
                    long usage = getMonthlyWifiUsage();
                    if (usage == -1) {
                        result.error("PERMISSION_DENIED", "Usage stats permission not granted", null);
                    } else {
                        result.success(usage);
                    }
                }
                case "checkUsageStatsPermission" -> result.success(checkUsageStatsPermission());
                case "requestUsageStatsPermission" -> {
                    requestUsageStatsPermission();
                    result.success(null);
                }
                case "checkWriteSettingsPermission" -> result.success(checkWriteSettingsPermission());
                case "requestWriteSettingsPermission" -> {
                    requestWriteSettingsPermission();
                    result.success(null);
                }
                case "setSystemBrightness" -> {
                    int brightness = call.argument("brightness");
                    result.success(setSystemBrightness(brightness));
                }
                case "openWifiSettings" -> result.success(openWifiSettings());
                case "getMediaStoreImages" -> result.success(getMediaStoreImages());
                case "getMediaStoreVideos" -> result.success(getMediaStoreVideos());
                case "getMediaStoreVideoThumbnail" -> {
                    Number id = call.argument("id");
                    String path = call.argument("path");
                    result.success(getMediaStoreVideoThumbnail(
                        id != null ? id.longValue() : -1, path));
                }
                case "checkMediaPermissions" -> result.success(checkMediaPermissions());
                case "areMediaPermissionsAvailable" -> result.success(areMediaPermissionsAvailable());
                case "requestMediaPermissions" -> {
                    requestMediaPermissions();
                    result.success(null);
                }
                case "checkWatchNextPermission" -> result.success(checkWatchNextPermission());
                case "requestWatchNextPermission" -> {
                    requestWatchNextPermission();
                    result.success(null);
                }
                case "getWatchNextItems" -> {
                    int limit = call.arguments() != null ? (int) call.arguments() : 10;
                    result.success(getWatchNextItems(limit));
                }
                case "launchWatchNextItem" -> {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> args = (Map<String, Object>) call.arguments();
                    if (args != null) {
                        String packageName = (String) args.get("packageName");
                        String contentId = (String) args.get("contentId");
                        String action = (String) args.get("action");
                        result.success(launchWatchNextItem(packageName, contentId, action));
                    } else {
                        result.success(false);
                    }
                }
                case "loadContentUriImage" -> {
                    String contentUri = (String) call.arguments();
                    if (contentUri != null) {
                        loadImageInBackground(result, () -> loadContentUriImage(contentUri));
                    } else {
                        result.success(new byte[0]);
                    }
                }
                case "loadWatchNextImage" -> {
                    String contentUri = (String) call.arguments();
                    if (contentUri != null) {
                        loadImageInBackground(result, () -> loadWatchNextImage(contentUri));
                    } else {
                        result.success(new byte[0]);
                    }
                }
                case "clearWatchNextImageCache" -> imageExecutor.execute(() -> {
                    deleteWatchNextCacheBefore(Long.MAX_VALUE);
                    mainHandler.post(() -> result.success(null));
                });
                default -> throw new IllegalArgumentException("Unknown method: " + call.method);
            }
        });

        new EventChannel(messenger, APPS_EVENT_CHANNEL).setStreamHandler(
                new LauncherAppsEventStreamHandler(this));

        new EventChannel(messenger, NETWORK_EVENT_CHANNEL).setStreamHandler(
                new NetworkEventStreamHandler(this));
    }

    private List<Map<String, Serializable>> getApplications() {
        ExecutorService executor = Executors.newFixedThreadPool(4);
        CompletionService<Pair<Boolean, List<ResolveInfo>>> queryIntentActivitiesCompletionService = new ExecutorCompletionService<>(
                executor);
        queryIntentActivitiesCompletionService.submit(() -> Pair.create(false, queryIntentActivities(false)));
        queryIntentActivitiesCompletionService.submit(() -> Pair.create(true, queryIntentActivities(true)));
        List<ResolveInfo> tvActivitiesInfo = null;
        List<ResolveInfo> nonTvActivitiesInfo = null;

        int completed = 0;
        while (completed < 2) {
            try {
                var activitiesInfo = queryIntentActivitiesCompletionService.take().get();

                if (!activitiesInfo.first) {
                    tvActivitiesInfo = activitiesInfo.second;
                } else {
                    nonTvActivitiesInfo = activitiesInfo.second;
                }
            } catch (InterruptedException | ExecutionException ignored) {
            } finally {
                completed += 1;
            }
        }

        CompletionService<Map<String, Serializable>> completionService = new ExecutorCompletionService<>(executor);

        List<Map<String, Serializable>> applications = new ArrayList<>(
                tvActivitiesInfo.size() + nonTvActivitiesInfo.size());

        boolean settingsPresent = false;
        int appCount = 0;
        for (ResolveInfo tvActivityInfo : tvActivitiesInfo) {
            if (!settingsPresent) {
                settingsPresent = tvActivityInfo.activityInfo.packageName.equals("com.android.tv.settings");
            }

            completionService.submit(() -> buildAppMap(tvActivityInfo.activityInfo, false, null));
            appCount += 1;
        }

        for (ResolveInfo nonTvActivityInfo : nonTvActivitiesInfo) {
            boolean nonDuplicate = true;

            if (!settingsPresent) {
                settingsPresent = nonTvActivityInfo.activityInfo.packageName.equals("com.android.settings");
            }

            for (ResolveInfo tvActivityInfo : tvActivitiesInfo) {
                if (tvActivityInfo.activityInfo.packageName.equals(nonTvActivityInfo.activityInfo.packageName)) {
                    nonDuplicate = false;
                    break;
                }
            }

            if (nonDuplicate) {
                appCount += 1;
                completionService.submit(() -> buildAppMap(nonTvActivityInfo.activityInfo, true, null));
            }
        }

        while (appCount > 0) {
            try {
                Future<Map<String, Serializable>> appMap = completionService.take();
                applications.add(appMap.get());
            } catch (InterruptedException | ExecutionException ignored) {
            } finally {
                appCount -= 1;
            }
        }

        executor.shutdown();

        if (!settingsPresent) {
            PackageManager packageManager = getPackageManager();
            Intent settingsIntent = new Intent(Settings.ACTION_SETTINGS);
            ActivityInfo activityInfo = settingsIntent.resolveActivityInfo(packageManager, 0);

            if (activityInfo != null) {
                applications.add(buildAppMap(activityInfo, false, Settings.ACTION_SETTINGS));
            }
        }

        return applications;
    }

    public Map<String, Serializable> getApplication(String packageName) {
        Map<String, Serializable> map = Map.of();
        PackageManager packageManager = getPackageManager();
        Intent intent = packageManager.getLeanbackLaunchIntentForPackage(packageName);

        if (intent == null) {
            intent = packageManager.getLaunchIntentForPackage(packageName);
        }

        if (intent != null) {
            ActivityInfo activityInfo = intent.resolveActivityInfo(getPackageManager(), 0);

            if (activityInfo != null) {
                map = buildAppMap(activityInfo, false, null);
            }
        }

        return map;
    }

    private byte[] getApplicationBanner(String packageName) {
        byte[] imageBytes = new byte[0];

        PackageManager packageManager = getPackageManager();
        try {
            ApplicationInfo info = packageManager.getApplicationInfo(packageName, 0);
            // Many TV apps (e.g. Free TV, S0undTV) declare android:banner on their leanback activity
            // only; getActivityBanner falls back to the application banner when the activity has none.
            Intent leanbackIntent = packageManager.getLeanbackLaunchIntentForPackage(packageName);
            Drawable drawable = leanbackIntent != null ? packageManager.getActivityBanner(leanbackIntent) : null;
            if (drawable == null) {
                drawable = info.loadBanner(packageManager);
            }

            if (drawable != null) {
                imageBytes = drawableToByteArray(drawable);
            }
        } catch (PackageManager.NameNotFoundException ignored) {
        }

        return imageBytes;
    }

    private byte[] getApplicationIcon(String packageName) {
        byte[] imageBytes = new byte[0];

        PackageManager packageManager = getPackageManager();
        try {
            ApplicationInfo info = packageManager.getApplicationInfo(packageName, 0);
            Drawable drawable = info.loadIcon(packageManager);

            if (drawable != null) {
                imageBytes = drawableToByteArray(drawable);
            }
        } catch (PackageManager.NameNotFoundException ignored) {
        }

        return imageBytes;
    }

    private boolean applicationExists(String packageName) {
        int flags;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            flags = PackageManager.MATCH_UNINSTALLED_PACKAGES;
        } else {
            flags = PackageManager.GET_UNINSTALLED_PACKAGES;
        }

        try {
            // Disabled packages remain installed but cannot supply launcher rows.
            return getPackageManager().getApplicationInfo(packageName, flags).enabled;
        } catch (PackageManager.NameNotFoundException ignored) {
            return false;
        }
    }

    private List<ResolveInfo> queryIntentActivities(boolean sideloaded) {
        String category;
        if (sideloaded) {
            category = Intent.CATEGORY_LAUNCHER;
        } else {
            category = Intent.CATEGORY_LEANBACK_LAUNCHER;
        }

        // NOTE: Would be nice to query the applications that match *either* of the
        // above categories
        // but from the addCategory function documentation, it says that it will "use
        // activities
        // that provide *all* the requested categories"
        Intent intent = new Intent(Intent.ACTION_MAIN)
                .addCategory(category);

        return getPackageManager()
                .queryIntentActivities(intent, 0);
    }

    private Map<String, Serializable> buildAppMap(ActivityInfo activityInfo, boolean sideloaded, String action) {
        PackageManager packageManager = getPackageManager();

        String applicationName = activityInfo.loadLabel(packageManager).toString(),
                applicationVersionName = "";
        try {
            applicationVersionName = packageManager.getPackageInfo(activityInfo.packageName, 0).versionName;
        } catch (PackageManager.NameNotFoundException ignored) {
        }

        Map<String, Serializable> appMap = new HashMap<>();
        appMap.put("name", applicationName);
        appMap.put("packageName", activityInfo.packageName);
        appMap.put("version", applicationVersionName);
        appMap.put("sideloaded", sideloaded);

        if (action != null) {
            appMap.put("action", action);
        }
        return appMap;
    }

    private boolean launchActivityFromAction(String action) {
        return tryStartActivity(new Intent(action));
    }

    private boolean launchApp(String packageName) {
        PackageManager packageManager = getPackageManager();
        Intent intent = packageManager.getLeanbackLaunchIntentForPackage(packageName);

        if (intent == null) {
            intent = packageManager.getLaunchIntentForPackage(packageName);
        }

        return tryStartActivity(intent);
    }

    private boolean openSettings() {
        return launchActivityFromAction(Settings.ACTION_SETTINGS);
    }

    private boolean installApk(String apkPath) {
        File apkFile = new File(apkPath);
        if (!apkFile.exists()) {
            return false;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                !getPackageManager().canRequestPackageInstalls()) {
            return false;
        }

        Uri apkUri = FileProvider.getUriForFile(
                this,
                getPackageName() + ".fileprovider",
                apkFile
        );

        Intent installIntent = new Intent(Intent.ACTION_VIEW)
                .setDataAndType(apkUri, "application/vnd.android.package-archive")
                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        return tryStartActivity(installIntent);
    }

    private void requestInstallUnknownAppsPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
                    .setData(Uri.parse("package:" + getPackageName()));
            tryStartActivity(intent);
        }
    }

    private boolean openAppInfo(String packageName) {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                .setData(Uri.fromParts("package", packageName, null));

        return tryStartActivity(intent);
    }

    private boolean uninstallApp(String packageName) {
        Intent intent = new Intent(Intent.ACTION_DELETE)
                .setData(Uri.fromParts("package", packageName, null));

        return tryStartActivity(intent);
    }

    private boolean checkForGetContentAvailability() {
        Intent getContentIntent = new Intent(Intent.ACTION_GET_CONTENT, null).setTypeAndNormalize("image/*");
        List<ResolveInfo> intentActivities = getPackageManager().queryIntentActivities(getContentIntent, 0);
        if (!intentActivities.isEmpty()) {
            return true;
        }
        Intent openDocIntent = new Intent(Intent.ACTION_OPEN_DOCUMENT, null).setTypeAndNormalize("image/*");
        return !getPackageManager().queryIntentActivities(openDocIntent, 0).isEmpty();
    }

    private boolean isDefaultLauncher() {
        Intent intent = new Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME);
        ResolveInfo defaultLauncher = getPackageManager().resolveActivity(intent, 0);

        if (defaultLauncher != null && defaultLauncher.activityInfo != null) {
            return defaultLauncher.activityInfo.packageName.equals(getPackageName());
        }

        return false;
    }

    private boolean startAmbientMode() {
        Intent intent = new Intent(Intent.ACTION_MAIN)
                .setClassName("com.android.systemui", "com.android.systemui.Somnambulator");

        return tryStartActivity(intent);
    }

    private Map<String, Object> getActiveNetworkInformation() {
        ConnectivityManager connectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return NetworkUtils.getNetworkInformation(this, connectivityManager.getActiveNetwork());
        } else {
            // noinspection deprecation
            return NetworkUtils.getNetworkInformation(this, connectivityManager.getActiveNetworkInfo());
        }
    }

    private boolean tryStartActivity(Intent intent) {
        boolean success = true;

        try {
            startActivity(intent);
        } catch (Exception ignored) {
            success = false;
        }

        return success;
    }

    private byte[] drawableToByteArray(Drawable drawable) {
        if (drawable.getIntrinsicWidth() <= 0 || drawable.getIntrinsicHeight() <= 0) {
            return new byte[0];
        }

        Bitmap bitmap;
        if (drawable instanceof BitmapDrawable bitmapDrawable) {
            bitmap = bitmapDrawable.getBitmap();
        } else {
            bitmap = drawableToBitmap(drawable);
        }
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
        return stream.toByteArray();
    }

    Bitmap drawableToBitmap(Drawable drawable) {
        Bitmap bitmap = Bitmap.createBitmap(
                drawable.getIntrinsicWidth(),
                drawable.getIntrinsicHeight(),
                Bitmap.Config.ARGB_8888);

        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bitmap;
    }

    private long getDailyWifiUsage() {
        if (!checkUsageStatsPermission()) {
            return -1;
        }

        NetworkStatsManager networkStatsManager = (NetworkStatsManager) getSystemService(Context.NETWORK_STATS_SERVICE);
        if (networkStatsManager == null)
            return 0;

        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0);
        calendar.set(java.util.Calendar.MINUTE, 0);
        calendar.set(java.util.Calendar.SECOND, 0);
        calendar.set(java.util.Calendar.MILLISECOND, 0);
        long startTime = calendar.getTimeInMillis();
        long endTime = System.currentTimeMillis();

        long totalBytes = 0;
        try {
            NetworkStats.Bucket bucket = networkStatsManager.querySummaryForDevice(
                    NetworkCapabilities.TRANSPORT_WIFI,
                    "",
                    startTime,
                    endTime);
            totalBytes = bucket.getRxBytes() + bucket.getTxBytes();
        } catch (RemoteException e) {
            e.printStackTrace();
        }

        return totalBytes;
    }

    private long getWeeklyWifiUsage() {
        if (!checkUsageStatsPermission()) {
            return -1;
        }

        NetworkStatsManager networkStatsManager = (NetworkStatsManager) getSystemService(Context.NETWORK_STATS_SERVICE);
        if (networkStatsManager == null)
            return 0;

        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.set(java.util.Calendar.DAY_OF_WEEK, calendar.getFirstDayOfWeek());
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0);
        calendar.set(java.util.Calendar.MINUTE, 0);
        calendar.set(java.util.Calendar.SECOND, 0);
        calendar.set(java.util.Calendar.MILLISECOND, 0);
        long startTime = calendar.getTimeInMillis();
        long endTime = System.currentTimeMillis();

        long totalBytes = 0;
        try {
            NetworkStats.Bucket bucket = networkStatsManager.querySummaryForDevice(
                    NetworkCapabilities.TRANSPORT_WIFI,
                    "",
                    startTime,
                    endTime);
            totalBytes = bucket.getRxBytes() + bucket.getTxBytes();
        } catch (RemoteException e) {
            e.printStackTrace();
        }

        return totalBytes;
    }

    private long getMonthlyWifiUsage() {
        if (!checkUsageStatsPermission()) {
            return -1;
        }

        NetworkStatsManager networkStatsManager = (NetworkStatsManager) getSystemService(Context.NETWORK_STATS_SERVICE);
        if (networkStatsManager == null)
            return 0;

        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.set(java.util.Calendar.DAY_OF_MONTH, 1);
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0);
        calendar.set(java.util.Calendar.MINUTE, 0);
        calendar.set(java.util.Calendar.SECOND, 0);
        calendar.set(java.util.Calendar.MILLISECOND, 0);
        long startTime = calendar.getTimeInMillis();
        long endTime = System.currentTimeMillis();

        long totalBytes = 0;
        try {
            NetworkStats.Bucket bucket = networkStatsManager.querySummaryForDevice(
                    NetworkCapabilities.TRANSPORT_WIFI,
                    "",
                    startTime,
                    endTime);
            totalBytes = bucket.getRxBytes() + bucket.getTxBytes();
        } catch (RemoteException e) {
            e.printStackTrace();
        }

        return totalBytes;
    }

    private boolean checkUsageStatsPermission() {
        AppOpsManager appOps = (AppOpsManager) getSystemService(Context.APP_OPS_SERVICE);
        int mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(), getPackageName());
        return mode == AppOpsManager.MODE_ALLOWED;
    }

    private void requestUsageStatsPermission() {
        Intent intent = new Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS);
        tryStartActivity(intent);
    }

    private boolean checkWriteSettingsPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return Settings.System.canWrite(this);
        }
        return true;
    }

    private void requestWriteSettingsPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS);
            intent.setData(Uri.parse("package:" + getPackageName()));
            tryStartActivity(intent);
        }
    }

    private boolean setSystemBrightness(int brightness) {
        if (checkWriteSettingsPermission()) {
            try {
                android.content.ContentResolver resolver = getContentResolver();
                // 1. Standard Android brightness
                Settings.System.putInt(resolver, Settings.System.SCREEN_BRIGHTNESS_MODE, Settings.System.SCREEN_BRIGHTNESS_MODE_MANUAL);
                Settings.System.putInt(resolver, Settings.System.SCREEN_BRIGHTNESS, brightness);
                
                // 2. Try common TV "Backlight" keys (Vendor specific)
                Settings.System.putInt(resolver, "backlight", brightness);
                Settings.System.putInt(resolver, "backlight_level", brightness);
                
                return true;
            } catch (Exception e) {
                // Ignore errors on specific keys as they may not exist
                return true;
            }
        }
        return false;
    }

    private boolean openWifiSettings() {
        // 1. Try Android Q+ WiFi panel
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            Intent panelIntent = new Intent(Settings.Panel.ACTION_WIFI);
            if (tryStartActivity(panelIntent)) {
                return true;
            }
        }

        // 2. Try standard WiFi settings
        Intent wifiIntent = new Intent(Settings.ACTION_WIFI_SETTINGS);
        if (tryStartActivity(wifiIntent)) {
            return true;
        }

        // 3. Fallback to general wireless settings
        Intent wirelessIntent = new Intent(Settings.ACTION_WIRELESS_SETTINGS);
        if (tryStartActivity(wirelessIntent)) {
            return true;
        }

        // 4. Final fallback - open main settings
        return launchActivityFromAction(Settings.ACTION_SETTINGS);
    }

    private boolean openScreensaverSettings() {
        // 1. Try Android TV specific screensaver settings (DaydreamActivity - from
        // Aerial Views)
        Intent tvIntent = new Intent(Intent.ACTION_MAIN);
        tvIntent.setClassName("com.android.tv.settings",
                "com.android.tv.settings.device.display.daydream.DaydreamActivity");
        if (tryStartActivity(tvIntent)) {
            return true;
        }

        // 2. Try standard Android screensaver/dream settings
        Intent dreamIntent = new Intent(Settings.ACTION_DREAM_SETTINGS);
        if (tryStartActivity(dreamIntent)) {
            return true;
        }

        // 3. FALLBACK: Try Display Settings (often contains screensaver on newer
        // Android TV/Google TV)
        Intent displayIntent = new Intent(Settings.ACTION_DISPLAY_SETTINGS);
        if (tryStartActivity(displayIntent)) {
            return true;
        }

        // 4. Final fallback - open main settings
        return launchActivityFromAction(Settings.ACTION_SETTINGS);
    }

    private boolean checkWatchNextPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true;
        }
        return checkSelfPermission(PERMISSION_READ_TV_LISTINGS) == PackageManager.PERMISSION_GRANTED;
    }

    private void requestWatchNextPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return;
        }
        if (checkWatchNextPermission()) {
            return;
        }
        ActivityCompat.requestPermissions(
                this,
                new String[]{PERMISSION_READ_TV_LISTINGS},
                REQUEST_CODE_READ_TV_LISTINGS);
    }

    private List<Map<String, Object>> getWatchNextItems(int limit) {
        List<Map<String, Object>> items = new ArrayList<>();

        if (!checkWatchNextPermission()) {
            android.util.Log.w("MainActivity", "READ_TV_LISTINGS permission not granted");
            return items;
        }

        try {
            String[] projection = {
                TvContract.WatchNextPrograms._ID,
                TvContract.WatchNextPrograms.COLUMN_TITLE,
                TvContract.WatchNextPrograms.COLUMN_SHORT_DESCRIPTION,
                TvContract.WatchNextPrograms.COLUMN_POSTER_ART_URI,
                TvContract.WatchNextPrograms.COLUMN_THUMBNAIL_URI,
                TvContract.WatchNextPrograms.COLUMN_PACKAGE_NAME,
                TvContract.WatchNextPrograms.COLUMN_INTERNAL_PROVIDER_ID,
                TvContract.WatchNextPrograms.COLUMN_DURATION_MILLIS,
                TvContract.WatchNextPrograms.COLUMN_LAST_ENGAGEMENT_TIME_UTC_MILLIS,
                TvContract.WatchNextPrograms.COLUMN_INTENT_URI,
                TvContract.WatchNextPrograms.COLUMN_WATCH_NEXT_TYPE
            };

            String sortOrder = TvContract.WatchNextPrograms.COLUMN_LAST_ENGAGEMENT_TIME_UTC_MILLIS + " DESC";

            try (Cursor cursor = getContentResolver().query(
                    TvContract.WatchNextPrograms.CONTENT_URI,
                    projection,
                    null,
                    null,
                    sortOrder)) {

                if (cursor != null && cursor.moveToFirst()) {
                    int count = 0;
                    int fetchLimit = Math.max(limit * 3, 150);

                    do {
                        try {
                            Map<String, Object> item = new HashMap<>();

                            int idIndex = cursor.getColumnIndex(TvContract.WatchNextPrograms._ID);
                            int titleIndex = cursor.getColumnIndex(TvContract.WatchNextPrograms.COLUMN_TITLE);
                            int descIndex = cursor.getColumnIndex(TvContract.WatchNextPrograms.COLUMN_SHORT_DESCRIPTION);
                            int posterIndex = cursor.getColumnIndex(TvContract.WatchNextPrograms.COLUMN_POSTER_ART_URI);
                            int thumbIndex = cursor.getColumnIndex(TvContract.WatchNextPrograms.COLUMN_THUMBNAIL_URI);
                            int pkgIndex = cursor.getColumnIndex(TvContract.WatchNextPrograms.COLUMN_PACKAGE_NAME);
                            int contentIdIndex = cursor.getColumnIndex(TvContract.WatchNextPrograms.COLUMN_INTERNAL_PROVIDER_ID);
                            int durationIndex = cursor.getColumnIndex(TvContract.WatchNextPrograms.COLUMN_DURATION_MILLIS);
                            int lastEngIndex = cursor.getColumnIndex(TvContract.WatchNextPrograms.COLUMN_LAST_ENGAGEMENT_TIME_UTC_MILLIS);
                            int intentUriIndex = cursor.getColumnIndex(TvContract.WatchNextPrograms.COLUMN_INTENT_URI);
                            int watchTypeIndex = cursor.getColumnIndex(TvContract.WatchNextPrograms.COLUMN_WATCH_NEXT_TYPE);
                            int aspectRatioIndex = cursor.getColumnIndex(COLUMN_ASPECT_RATIO);

                            String title = (titleIndex >= 0 && !cursor.isNull(titleIndex))
                                ? cursor.getString(titleIndex) : null;
                            if (title == null || title.isEmpty()) {
                                continue;
                            }

                            String posterUri = (posterIndex >= 0 && !cursor.isNull(posterIndex))
                                ? cursor.getString(posterIndex) : null;
                            if ((posterUri == null || posterUri.trim().isEmpty()) && thumbIndex >= 0 && !cursor.isNull(thumbIndex)) {
                                posterUri = cursor.getString(thumbIndex);
                            }

                            item.put("id", idIndex >= 0 ? cursor.getLong(idIndex) : 0);
                            item.put("title", title);
                            item.put("description", (descIndex >= 0 && !cursor.isNull(descIndex))
                                ? cursor.getString(descIndex) : null);
                            item.put("posterUri", posterUri);
                            item.put("packageName", (pkgIndex >= 0 && !cursor.isNull(pkgIndex))
                                ? cursor.getString(pkgIndex) : null);
                            item.put("contentId", (contentIdIndex >= 0 && !cursor.isNull(contentIdIndex))
                                ? cursor.getString(contentIdIndex) : null);
                            item.put("duration", (durationIndex >= 0 && !cursor.isNull(durationIndex))
                                ? cursor.getInt(durationIndex) : null);

                            item.put("intentUri", (intentUriIndex >= 0 && !cursor.isNull(intentUriIndex))
                                ? cursor.getString(intentUriIndex) : null);

                            item.put("watchNextType", (watchTypeIndex >= 0 && !cursor.isNull(watchTypeIndex))
                                ? cursor.getInt(watchTypeIndex) : 0);

                            item.put("aspectRatio", (aspectRatioIndex >= 0 && !cursor.isNull(aspectRatioIndex))
                                ? cursor.getString(aspectRatioIndex) : null);

                            if (lastEngIndex >= 0 && !cursor.isNull(lastEngIndex)) {
                                item.put("lastEngagementDate", cursor.getLong(lastEngIndex));
                            }

                            item.put("progressPercent", 0);

                            items.add(item);
                            count++;
                        } catch (Exception rowEx) {
                            android.util.Log.w("MainActivity", "Error parsing Watch Next row", rowEx);
                        }
                    } while (cursor.moveToNext() && count < fetchLimit);
                }
            }
        } catch (SecurityException e) {
            android.util.Log.w("MainActivity", "SecurityException when querying Watch Next: " + e.getMessage());
        } catch (Exception e) {
            android.util.Log.e("MainActivity", "Error querying Watch Next", e);
        }

        android.util.Log.d("MainActivity", "getWatchNextItems: total retrieved = " + items.size() + ", limit = " + limit);
        return items.subList(0, Math.min(items.size(), limit));
    }

    private boolean launchWatchNextItem(String packageName, String contentId, String action) {
        android.util.Log.d("MainActivity", "launchWatchNextItem: packageName=" + packageName + ", contentId=" + contentId + ", action=" + action);

        // Try to use the intent action/uri from arguments first
        if (action != null && !action.isEmpty()) {
            try {
                Intent intent;
                if (action.startsWith("intent://")) {
                    android.util.Log.d("MainActivity", "Parsing intent URI: " + action);
                    intent = Intent.parseUri(action, Intent.URI_INTENT_SCHEME);
                } else if (action.startsWith("content://") || action.startsWith("http://") || action.startsWith("https://")) {
                    android.util.Log.d("MainActivity", "Creating VIEW intent for URI: " + action);
                    intent = new Intent(Intent.ACTION_VIEW, Uri.parse(action));
                } else if (action.contains(":")) {
                    try {
                        android.util.Log.d("MainActivity", "Trying to parse as intent URI: " + action);
                        intent = Intent.parseUri(action, Intent.URI_INTENT_SCHEME);
                    } catch (Exception e) {
                        android.util.Log.w("MainActivity", "Failed to parse as intent URI, treating as action: " + action);
                        intent = new Intent(action);
                    }
                } else {
                    android.util.Log.d("MainActivity", "Creating intent with action: " + action);
                    intent = new Intent(action);
                }

                if (packageName != null) {
                    intent.setPackage(packageName);
                    android.util.Log.d("MainActivity", "Set package to: " + packageName);
                }
                if (contentId != null) {
                    intent.putExtra("contentId", contentId);
                    android.util.Log.d("MainActivity", "Added contentId extra: " + contentId);
                }
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                android.util.Log.d("MainActivity", "Starting activity with intent: " + intent.toUri(0));
                return tryStartActivity(intent);
            } catch (Exception e) {
                android.util.Log.e("MainActivity", "Failed to launch with action/uri: " + action, e);
            }
        }

        // Fallback to package name
        if (packageName == null) {
            android.util.Log.w("MainActivity", "No package name or action available, cannot launch");
            return false;
        }

        try {
            android.util.Log.d("MainActivity", "Falling back to package launch: " + packageName);
            PackageManager pm = getPackageManager();
            Intent intent = pm.getLeanbackLaunchIntentForPackage(packageName);
            if (intent == null) {
                intent = pm.getLaunchIntentForPackage(packageName);
            }

            if (intent != null) {
                if (contentId != null) {
                    intent.putExtra("contentId", contentId);
                }
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                return tryStartActivity(intent);
            } else {
                android.util.Log.w("MainActivity", "No launch intent found for package: " + packageName);
            }
        } catch (Exception e) {
            android.util.Log.e("MainActivity", "Error launching Watch Next item for package: " + packageName, e);
        }

        return false;
    }

    /**
     * Load image bytes from a content:// URI
     */
    private byte[] loadContentUriImage(String contentUri) {
        android.util.Log.d("MainActivity", "Loading content URI image: " + contentUri);
        try {
            android.net.Uri uri = android.net.Uri.parse(contentUri);
            android.util.Log.d("MainActivity", "Parsed URI: " + uri);

            try (java.io.InputStream inputStream = getContentResolver().openInputStream(uri)) {
                if (inputStream != null) {
                    java.io.ByteArrayOutputStream byteArrayOutputStream = new java.io.ByteArrayOutputStream();
                    byte[] buffer = new byte[8192];  // Increased buffer size
                    int length;
                    while ((length = inputStream.read(buffer)) != -1) {
                        byteArrayOutputStream.write(buffer, 0, length);
                    }
                    byte[] result = byteArrayOutputStream.toByteArray();
                    android.util.Log.d("MainActivity", "Loaded " + result.length + " bytes from content URI");
                    return result;
                } else {
                    android.util.Log.w("MainActivity", "openInputStream returned null for: " + contentUri);
                }
            }
        } catch (SecurityException e) {
            android.util.Log.w("MainActivity", "SecurityException loading content URI: " + e.getMessage());
        } catch (Exception e) {
            android.util.Log.e("MainActivity", "Error loading content URI image: " + contentUri, e);
        }
        android.util.Log.w("MainActivity", "Returning empty byte array for: " + contentUri);
        return new byte[0];
    }

    /**
     * Runs an image load off the main thread. Content providers can take seconds per image
     * (Jellyfin re-encodes every poster), which would otherwise freeze the whole launcher.
     */
    private void loadImageInBackground(MethodChannel.Result result, Callable<byte[]> loader) {
        imageExecutor.execute(() -> {
            byte[] bytes;
            try {
                bytes = loader.call();
            } catch (Throwable t) {
                android.util.Log.e("MainActivity", "Error loading image in background", t);
                bytes = new byte[0];
            }
            final byte[] reply = bytes;
            mainHandler.post(() -> result.success(reply));
        });
    }

    /**
     * Load a Watch Next image from a content:// or http(s) URI, scaled down to the screen and cached
     * on disk for a week so that later cold starts do not have to ask the provider again.
     */
    private byte[] loadWatchNextImage(String uri) {
        File cacheFile = new File(watchNextCacheDir(), sha256(uri));
        if (cacheFile.lastModified() > System.currentTimeMillis() - WATCH_NEXT_CACHE_MAX_AGE_MS) {
            byte[] cached = readFile(cacheFile);
            if (cached.length > 0) {
                return cached;
            }
        }

        byte[] original = uri.startsWith("content://") ? loadContentUriImage(uri) : downloadImage(uri);
        if (original.length == 0) {
            return original;
        }

        BitmapFactory.Options bounds = new BitmapFactory.Options();
        bounds.inJustDecodeBounds = true;
        BitmapFactory.decodeByteArray(original, 0, original.length, bounds);
        // Small images are not cached: a provider that fails may answer with a placeholder icon.
        if (bounds.outWidth < WATCH_NEXT_CACHE_MIN_WIDTH) {
            return original;
        }

        // Scale to the screen, but never below 1080p in case the UI is rendered at a lower resolution.
        int maxWidth = Math.max(getResources().getDisplayMetrics().widthPixels, WATCH_NEXT_MIN_IMAGE_WIDTH);
        byte[] scaled = scaleDownImage(original, bounds.outWidth, maxWidth);
        deleteWatchNextCacheBefore(System.currentTimeMillis() - WATCH_NEXT_CACHE_MAX_AGE_MS);
        writeFile(cacheFile, scaled);
        return scaled;
    }

    private static byte[] downloadImage(String url) {
        HttpURLConnection connection = null;
        try {
            connection = (HttpURLConnection) new URL(url).openConnection();
            connection.setConnectTimeout(10000);
            connection.setReadTimeout(10000);
            if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
                return new byte[0];
            }
            try (InputStream inputStream = connection.getInputStream()) {
                ByteArrayOutputStream stream = new ByteArrayOutputStream();
                byte[] buffer = new byte[8192];
                int length;
                while ((length = inputStream.read(buffer)) != -1) {
                    stream.write(buffer, 0, length);
                }
                return stream.toByteArray();
            }
        } catch (IOException | IllegalArgumentException e) {
            android.util.Log.w("MainActivity", "Could not download Watch Next image: " + e.getMessage());
            return new byte[0];
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    private byte[] scaleDownImage(byte[] original, int width, int maxWidth) {
        if (width <= maxWidth) {
            return original;
        }
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inSampleSize = 1;
        while (width / (options.inSampleSize * 2) >= maxWidth) {
            options.inSampleSize *= 2;
        }
        Bitmap bitmap = BitmapFactory.decodeByteArray(original, 0, original.length, options);
        if (bitmap == null) {
            return original;
        }
        if (bitmap.getWidth() > maxWidth) {
            int height = Math.round(bitmap.getHeight() * (maxWidth / (float) bitmap.getWidth()));
            Bitmap resized = Bitmap.createScaledBitmap(bitmap, maxWidth, Math.max(height, 1), true);
            if (resized != bitmap) {
                bitmap.recycle();
                bitmap = resized;
            }
        }
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        // JPEG has no alpha channel: transparent areas would turn black.
        if (bitmap.hasAlpha()) {
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
        } else {
            bitmap.compress(Bitmap.CompressFormat.JPEG, 85, stream);
        }
        bitmap.recycle();
        android.util.Log.d("MainActivity", "Scaled Watch Next image from " + original.length + " to " + stream.size() + " bytes");
        return stream.toByteArray();
    }

    private File watchNextCacheDir() {
        return new File(getCacheDir(), "watch_next");
    }

    private void deleteWatchNextCacheBefore(long time) {
        File[] files = watchNextCacheDir().listFiles();
        if (files == null) {
            return;
        }
        for (File file : files) {
            if (file.lastModified() < time) {
                file.delete();
            }
        }
    }

    private static String sha256(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                hex.append(String.format("%02x", b));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }

    private static byte[] readFile(File file) {
        if (!file.isFile()) {
            return new byte[0];
        }
        try (InputStream inputStream = new FileInputStream(file)) {
            ByteArrayOutputStream stream = new ByteArrayOutputStream((int) file.length());
            byte[] buffer = new byte[8192];
            int length;
            while ((length = inputStream.read(buffer)) != -1) {
                stream.write(buffer, 0, length);
            }
            return stream.toByteArray();
        } catch (IOException e) {
            return new byte[0];
        }
    }

    // Written to a temporary file first: the launcher is often killed for memory mid-write.
    private static void writeFile(File file, byte[] bytes) {
        File directory = file.getParentFile();
        if (directory == null || (!directory.isDirectory() && !directory.mkdirs())) {
            return;
        }
        File temporary = new File(directory, file.getName() + ".tmp");
        try (FileOutputStream outputStream = new FileOutputStream(temporary)) {
            outputStream.write(bytes);
        } catch (IOException e) {
            temporary.delete();
            return;
        }
        if (!temporary.renameTo(file)) {
            temporary.delete();
        }
    }

    private static final int MEDIA_PERMISSION_REQUEST_CODE = 9001;

    private boolean areMediaPermissionsAvailable() {
        try {
            PackageInfo info = getPackageManager().getPackageInfo(
                    getPackageName(), PackageManager.GET_PERMISSIONS);
            if (info.requestedPermissions != null) {
                for (String p : info.requestedPermissions) {
                    if (Manifest.permission.READ_MEDIA_IMAGES.equals(p) ||
                        Manifest.permission.READ_EXTERNAL_STORAGE.equals(p)) {
                        return true;
                    }
                }
            }
        } catch (Exception ignored) {
        }
        return false;
    }

    private boolean checkMediaPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return checkSelfPermission(Manifest.permission.READ_MEDIA_IMAGES) == PackageManager.PERMISSION_GRANTED
                && checkSelfPermission(Manifest.permission.READ_MEDIA_VIDEO) == PackageManager.PERMISSION_GRANTED;
        }
        return checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED;
    }

    private void requestMediaPermissions() {
        String[] permissions;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions = new String[]{
                Manifest.permission.READ_MEDIA_IMAGES,
                Manifest.permission.READ_MEDIA_VIDEO
            };
        } else {
            permissions = new String[]{Manifest.permission.READ_EXTERNAL_STORAGE};
        }
        ActivityCompat.requestPermissions(this, permissions, MEDIA_PERMISSION_REQUEST_CODE);
    }

    private List<Map<String, Object>> getMediaStoreImages() {
        List<Map<String, Object>> images = new ArrayList<>();
        String[] projection = {
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.DISPLAY_NAME,
            MediaStore.Images.Media.DATA,
            MediaStore.Images.Media.DATE_ADDED
        };
        String sortOrder = MediaStore.Images.Media.DATE_ADDED + " DESC";

        try (Cursor cursor = getContentResolver().query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection, null, null, sortOrder)) {
            if (cursor != null) {
                int idCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID);
                int nameCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME);
                int dataCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                while (cursor.moveToNext()) {
                    long id = cursor.getLong(idCol);
                    Uri contentUri = Uri.withAppendedPath(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, String.valueOf(id));
                    Map<String, Object> item = new HashMap<>();
                    item.put("id", id);
                    item.put("name", cursor.getString(nameCol));
                    item.put("path", cursor.getString(dataCol));
                    item.put("uri", contentUri.toString());
                    images.add(item);
                }
            }
        } catch (Exception ignored) {
        }
        return images;
    }

    private List<Map<String, Object>> getMediaStoreVideos() {
        List<Map<String, Object>> videos = new ArrayList<>();
        String[] projection = {
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.DISPLAY_NAME,
            MediaStore.Video.Media.DATA,
            MediaStore.Video.Media.DATE_ADDED
        };
        String sortOrder = MediaStore.Video.Media.DATE_ADDED + " DESC";

        try (Cursor cursor = getContentResolver().query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                projection, null, null, sortOrder)) {
            if (cursor != null) {
                int idCol = cursor.getColumnIndexOrThrow(MediaStore.Video.Media._ID);
                int nameCol = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME);
                int dataCol = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA);
                while (cursor.moveToNext()) {
                    long id = cursor.getLong(idCol);
                    Uri contentUri = Uri.withAppendedPath(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, String.valueOf(id));
                    Map<String, Object> item = new HashMap<>();
                    item.put("id", id);
                    item.put("name", cursor.getString(nameCol));
                    item.put("path", cursor.getString(dataCol));
                    item.put("uri", contentUri.toString());
                    videos.add(item);
                }
            }
        } catch (Exception ignored) {
        }
        return videos;
    }

    private byte[] getMediaStoreVideoThumbnail(long id, String path) {
        Bitmap bitmap = null;
        try {
            if (id >= 0 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                Uri uri = android.content.ContentUris.withAppendedId(
                    MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id);
                bitmap = getContentResolver().loadThumbnail(
                    uri, new android.util.Size(256, 256), null);
            }
        } catch (Exception ignored) {
        }

        if (bitmap == null && path != null && !path.isEmpty()) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    bitmap = android.media.ThumbnailUtils.createVideoThumbnail(
                        new File(path), new android.util.Size(256, 256), null);
                } else {
                    bitmap = android.media.ThumbnailUtils.createVideoThumbnail(
                        path, MediaStore.Images.Thumbnails.MINI_KIND);
                }
            } catch (Exception ignored) {
            }
        }

        if (bitmap == null && path != null && !path.isEmpty()) {
            android.media.MediaMetadataRetriever retriever = null;
            try {
                retriever = new android.media.MediaMetadataRetriever();
                retriever.setDataSource(path);
                bitmap = retriever.getFrameAtTime(0);
            } catch (Exception ignored) {
            } finally {
                try {
                    if (retriever != null) retriever.release();
                } catch (Exception ignored) {
                }
            }
        }

        if (bitmap == null) return null;
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 80, stream);
        bitmap.recycle();
        return stream.toByteArray();
    }

}

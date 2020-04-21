package eeui.android.aochuangRecorder.module;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.util.Log;
import android.widget.Toast;

import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.bridge.JSCallback;

import java.util.HashMap;
import java.util.Locale;

import app.eeui.framework.extend.base.WXModuleBase;
import eeui.android.aochuangRecorder.module.permission.ModuleResultListener;
import eeui.android.aochuangRecorder.module.permission.PermissionChecker;
import eeui.android.aochuangRecorder.module.recorder.Constant;
import eeui.android.aochuangRecorder.module.recorder.MediaPlayManager;
import eeui.android.aochuangRecorder.module.recorder.RecorderModule;
import eeui.android.aochuangRecorder.module.recorder.Util;

public class aochuangRecorderAppModule extends WXModuleBase {

    HashMap<String, String> mCallParams;
    JSCallback mCallCallback;

    String lang = Locale.getDefault().getLanguage();
    Boolean isChinese = lang.startsWith("zh");

    @JSMethod
    public void start(HashMap<String, String> params, final JSCallback jsCallback){
        boolean permAllow = PermissionChecker.lacksPermissions(mWXSDKInstance.getContext(), Manifest.permission.RECORD_AUDIO, Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE);

        if (permAllow) {
            HashMap<String, String> dialog = new HashMap<>();
            if (isChinese) {
                dialog.put("title", "权限申请");
                dialog.put("message", "请允许应用录制音频");
            } else {
                dialog.put("title", "Permission Request");
                dialog.put("message", "Please allow the app to record audio");
            }

            mCallParams = params;
            mCallCallback = jsCallback;

            PermissionChecker.requestPermissions((Activity) mWXSDKInstance.getContext(), dialog, new ModuleResultListener() {
                @Override
                public void onResult(Object o) {
                    if ((boolean)o == true) jsCallback.invoke(Util.getError(Constant.RECORD_AUDIO_PERMISSION_DENIED, Constant.RECORD_AUDIO_PERMISSION_DENIED_CODE));
                }
            }, Constant.RECORD_AUDIO_PERMISSION_REQUEST_CODE,  Manifest.permission.RECORD_AUDIO, Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        } else {
            realRecord(params, jsCallback);
        }
    }

    @JSMethod
    public void stop(final JSCallback jsCallback){
        RecorderModule.getInstance().stop(new eeui.android.aochuangRecorder.module.recorder.ModuleResultListener() {
            @Override
            public void onResult(Object o) {
                jsCallback.invoke(o);
            }
        });
    }

    @JSMethod
    public void finish(final JSCallback jsCallback){
        RecorderModule.getInstance().finish(new eeui.android.aochuangRecorder.module.recorder.ModuleResultListener() {
            @Override
            public void onResult(Object o) {
                jsCallback.invoke(o);
            }
        });
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == Constant.RECORD_AUDIO_PERMISSION_REQUEST_CODE) {
            if (PermissionChecker.hasAllPermissionsGranted(grantResults)) {
                realRecord(mCallParams, mCallCallback);
            } else {
                mCallCallback.invoke(Util.getError(Constant.RECORD_AUDIO_PERMISSION_DENIED, Constant.RECORD_AUDIO_PERMISSION_DENIED_CODE));
            }
        }
    }

    @JSMethod
    public void play(String path,int mode, final JSCallback jsCallback) {
        MediaPlayManager.getInstance(mWXSDKInstance.getContext()).playVoice(path,mode, new eeui.android.aochuangRecorder.module.recorder.ModuleResultListener() {
            @Override
            public void onResult(Object o) {
                jsCallback.invokeAndKeepAlive(o);
            }
        });
    }


    @JSMethod
    public void stopPlay(final JSCallback jsCallback) {
        MediaPlayManager.getInstance(mWXSDKInstance.getContext()).stop();
    }

    public void realRecord(HashMap<String, String> params, final JSCallback jsCallback){
        RecorderModule.getInstance().start(params, new eeui.android.aochuangRecorder.module.recorder.ModuleResultListener() {
            @Override
            public void onResult(Object o) {
                jsCallback.invoke(o);
            }
        });
    }
}

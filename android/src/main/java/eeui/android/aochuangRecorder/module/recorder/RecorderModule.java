package eeui.android.aochuangRecorder.module.recorder;

import android.media.MediaRecorder;
import android.util.Log;

import java.util.HashMap;

import omrecorder.AudioSource;

public class RecorderModule {
    private EAudioManager mRecorder  ;
    private boolean mIsRecording;
    private boolean mIsPausing;
    private HashMap<String, String> result = new HashMap<>();

    private static volatile RecorderModule instance = null;

    private RecorderModule(){
        mRecorder = EAudioManager.getInstance();
    }

    public static RecorderModule getInstance() {
        if (instance == null) {
            synchronized (RecorderModule.class) {
                if (instance == null) {
                    instance = new RecorderModule();
                }
            }
        }

        return instance;
    }

    public void start(HashMap<String, String> options, final ModuleResultListener listener){

        if (mIsRecording) {
            if (mIsPausing) {
                if (mRecorder != null)mRecorder.release();
                mIsPausing = false;
                listener.onResult(null);
            } else {
                listener.onResult(Util.getError(Constant.RECORDER_BUSY, Constant.RECORDER_BUSY_CODE));
            }
        } else {
            mRecorder.setOnAudioStageListener(new EAudioManager.AudioStageListener() {
                @Override
                public void wellPrepared() {

                }

                @Override
                public void volume(int volume) {
                    Log.d("charco","volume = "+volume);
                    result.put("volume",volume +"");
                    listener.onResult(result);
                }
            });
            mIsRecording = true;
            mRecorder.prepareAudio();
            listener.onResult(null);
        }
    }

    public void stop(ModuleResultListener listener) {
        if (!mIsRecording) {
            listener.onResult(Util.getError(Constant.RECORDER_NOT_STARTED, Constant.RECORDER_NOT_STARTED_CODE));
            return;
        }
        if (mIsPausing) {
            listener.onResult(null);
            return;
        }
        if (mRecorder != null) {
            mRecorder.stop();
            mIsPausing = true;
            listener.onResult(null);
        }
    }

    public void finish(ModuleResultListener listener) {
        if (!mIsRecording) {
            listener.onResult(Util.getError(Constant.RECORDER_NOT_STARTED, Constant.RECORDER_NOT_STARTED_CODE));
            return;
        }
        if (mRecorder != null) {
            mRecorder.stop();
            mIsPausing = false;
            mIsRecording = false;
            HashMap<String, String> result = new HashMap<>();
            result.put("path", mRecorder.getCurrentFilePath());
            result.put("duraction", mRecorder.getDuration() + "");
            listener.onResult(result);

        }
    }


    private AudioSource getMic(int audioBit, int channel, int frequency) {
        return new AudioSource.Smart(MediaRecorder.AudioSource.MIC, audioBit, channel, frequency);
    }
}

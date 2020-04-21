package eeui.android.aochuangRecorder.module.recorder;

import android.content.Context;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Build;
import android.util.Log;

import static android.content.Context.AUDIO_SERVICE;

/**
 * Created 2020/4/18 23:25
 * Author:charcolee
 * Version:V1.0
 * ----------------------------------------------------
 * 文件描述：
 * ----------------------------------------------------
 */
public class MediaPlayManager {

    /**
     * 单例化这个类
     */
    private static MediaPlayManager mInstance;
    private MediaPlayer mMediaPlayer;
    private AudioManager mAudioManager;

    private MediaPlayManager(Context context) {
        mMediaPlayer = new MediaPlayer();
//        mMediaPlayer.setAudioStreamType(android.media.AudioManager.STREAM_SYSTEM);
//        mMediaPlayer.setAudioStreamType(android.media.AudioManager.STREAM_VOICE_CALL);
        mMediaPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mediaPlayer, int i, int i1) {
                Log.d("MediaPlayManager","onError =  i = "+ i +"  i1 = " +i1);
                return false;
            }
        });
        mAudioManager = (AudioManager) context.getSystemService(AUDIO_SERVICE);
    }

    public static MediaPlayManager getInstance(Context context) {
        if (mInstance == null) {
            synchronized (EAudioManager.class) {
                if (mInstance == null) {
                    mInstance = new MediaPlayManager(context);
                }
            }
        }
        return mInstance;

    }

    public void playVoice(String path,int mode, final ModuleResultListener listener) {
        try {
            if (mode == 0){
                changeToSpeaker();
            }else{
                changeToReceiver();
            }

            mMediaPlayer.reset();
            mMediaPlayer.setDataSource(path);
            mMediaPlayer.prepare();
            mMediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mediaPlayer) {
                    mediaPlayer.start();
                    listener.onResult(Util.getResult("start", Constant.MEDIA_PLAY_START));
                    Log.w("MediaPlayManager", "onPrepared.");
                }
            });
            mMediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                @Override
                public void onCompletion(MediaPlayer mediaPlayer) {
                    Log.w("MediaPlayManager", "onCompletion.");
                    listener.onResult(Util.getResult("completion", Constant.MEDIA_PLAY_COMPLETION));
                    mediaPlayer.reset();
                }
            });
        }catch (Exception e) {
            e.printStackTrace();
            Log.e("MediaPlayManager", "Exception = " + e.getLocalizedMessage());
            listener.onResult(Util.getResult("Exception = " + e.getLocalizedMessage(), Constant.MEDIA_PLAY_ERROR));
        }
    }

    public void stop(){
      if (mMediaPlayer.isPlaying()){
          mMediaPlayer.stop();
      }
    }

    /**
     * 切换到外放
     */
    public void changeToSpeaker(){
        mAudioManager.setMode(AudioManager.MODE_NORMAL);
        mAudioManager.setSpeakerphoneOn(true);
    }

    /**
     * 切换到耳机模式
     */
    public void changeToHeadset(){
        mAudioManager.setSpeakerphoneOn(false);
    }

    /**
     * 切换到听筒
     */
    public void changeToReceiver(){
        mAudioManager.setSpeakerphoneOn(false);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB){
            mAudioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
        } else {
            mAudioManager.setMode(AudioManager.MODE_IN_CALL);
        }
    }

}

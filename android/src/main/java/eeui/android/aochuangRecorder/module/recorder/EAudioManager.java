package eeui.android.aochuangRecorder.module.recorder;

import android.media.MediaRecorder;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.io.File;
import java.util.UUID;

//录音核心类
public class EAudioManager {

    private MediaRecorder mRecorder;
    //文件夹位置
    private String mDirString;
    //录音文件保存路径
    private String mCurrentFilePathString;
    //是否真备好开始录音
    private boolean isPrepared;
    private Handler mHandler;
    private long start_time;

    /**
     * 单例化这个类
     */
    private static EAudioManager mInstance;

    private EAudioManager() {
        mDirString = Util.getRootFile().getAbsolutePath();
        mHandler = new Handler(Looper.getMainLooper());
    }

    public static EAudioManager getInstance() {
        if (mInstance == null) {
            synchronized (EAudioManager.class) {
                if (mInstance == null) {
                    mInstance = new EAudioManager();

                }
            }
        }
        return mInstance;

    }

    /**
     * 回调函数，准备完毕，准备好后，button才会开始显示录音
     */
    public interface AudioStageListener {
        void wellPrepared();
        void volume(int volume);
    }

    public AudioStageListener mListener;

    public void setOnAudioStageListener(AudioStageListener listener) {
        mListener = listener;
    }

    // 准备方法
    public void prepareAudio() {
        try {
            // 一开始应该是false的
            isPrepared = false;
            //创建所属文件夹
            File dir = new File(mDirString);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            String fileNameString = generalFileName();
            File file = new File(dir, fileNameString);
            //获取文件
            mCurrentFilePathString = file.getAbsolutePath();

            mRecorder = new MediaRecorder();
            // 设置输出文件
            mRecorder.setOutputFile(file.getAbsolutePath());
            // 设置meidaRecorder的音频源是麦克风
            mRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
            // 设置文件音频的输出格式为amr
            mRecorder.setOutputFormat(MediaRecorder.OutputFormat.DEFAULT);
            mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
            // 设置音频的编码格式为amr。这里采用AAC主要为了适配IOS，保证在IOS上可以正常播放。
//            mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);

            // 严格遵守google官方api给出的mediaRecorder的状态流程图
            mRecorder.prepare();

            mRecorder.start();
            start_time = System.currentTimeMillis();
            // 准备结束
            isPrepared = true;
            // 已经准备好了，可以录制了
            if (mListener != null) {
                mListener.wellPrepared();
            }
            mHandler.postDelayed(mRunnable,100);
        } catch (Exception e) {
            e.printStackTrace();
            Log.d("eeui","AudioManager prepareAudio e = "+e.getMessage());
        }

    }

    /**
     * 随机生成文件的名称
     *
     * @return
     */
    private String generalFileName() {
        return UUID.randomUUID().toString() + ".amr";
    }

    // 获得声音的level
    public int getVoiceLevel(int maxLevel) {
        // mRecorder.getMaxAmplitude()这个是音频的振幅范围，值域是1-32767
        if (isPrepared) {
            try {
                int maxAmplitude = mRecorder.getMaxAmplitude();
                Log.d("charco","maxAmplitude = "+maxAmplitude);
//                int level = maxLevel * mRecorder.getMaxAmplitude() / 8000 +1;
                // 取证+1，否则去不到7
//                Log.d("charco","level = "+level);
                if (mListener != null){
                    mListener.volume(maxAmplitude);
                }
                return maxAmplitude;
            } catch (Exception e) {
                Log.d("charco","Exception = "+e.getLocalizedMessage());
            }
        }
        if (mListener != null){
            mListener.volume(0);
        }
        return 0;
    }

    public void stop(){
        // 严格按照api流程进行
        mHandler.removeCallbacksAndMessages(null);
        if (mRecorder == null) return;
        mRecorder.stop();
    }

    // 释放资源
    public void release() {
        // 严格按照api流程进行
        mHandler.removeCallbacksAndMessages(null);
        if (mRecorder == null) return;
        /*
        * 这里处理一些特定情况下的异常。2017/04/12 by wgyscsf
         */
        try {
            //下面三个参数必须加，不加的话会奔溃，在mediarecorder.stop();
            //报错为：RuntimeException:stop failed
            mRecorder.setOnErrorListener(null);
            mRecorder.setOnInfoListener(null);
            mRecorder.setPreviewDisplay(null);
            mRecorder.stop();
        } catch (IllegalStateException e) {
            Log.i("Exception", Log.getStackTraceString(e) + "123");
        } catch (RuntimeException e) {
            Log.i("Exception", Log.getStackTraceString(e) + "123");
        } catch (Exception e) {
            Log.i("Exception", Log.getStackTraceString(e) + "123");
        }
        mRecorder.release();
//        mRecorder = null;

    }

    // 取消,因为prepare时产生了一个文件，所以cancel方法应该要删除这个文件，
    // 这是与release的方法的区别
    public void cancel() {
        release();
        if (mCurrentFilePathString != null) {
            File file = new File(mCurrentFilePathString);
            file.delete();
            mCurrentFilePathString = null;
        }

    }

    public String getCurrentFilePath() {
        return mCurrentFilePathString;
    }

    public int getDuration(){
        return (int) (System.currentTimeMillis() - start_time) / 1000 + 1;
    }

    private Runnable mRunnable = new Runnable() {
        @Override
        public void run() {
//            int getMaxAmplitude = mRecorder.getMaxAmplitude() / 32768 + 1;
//            Log.d("charco","getMaxAmplitude = "+mRecorder.getMaxAmplitude());
            getVoiceLevel(7);
            mHandler.postDelayed(this,100);
        }
    };

}

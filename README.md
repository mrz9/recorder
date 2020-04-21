# 音频录制和播放插件

## 安装

```shell script
eeui plugin install https://github.com/mrz9/recorder
```

## 卸载

```shell script
eeui plugin uninstall https://github.com/mrz9/recorder
```

## 引用

```js
const audio = app.requireModule("aochuangRecorder");
```

### start(options, callback) 开始录音

#### 参数

1.  `options` (Object)
    *   `channel` (String) (`stereo`, `mono`, default: `stereo`)

    *   `quality` (String) (`low` [8000Hz, 8bit] | `standard` [22050Hz, 16bit] | `high` [44100Hz, 16bit], default: `standard`)

2.  [`callback`] (Function)

#### 示例

```
recorder.start({
    channel: `mono`
}, () => {
    console.log('started')
})
```

* * *

### stop(callback) 暂停录音

#### 参数

1.  [`callback`] (Function)

#### 示例

```
recorder.stop()
```

```
recorder.stop(() => {
    console.log('stop')
})
```
* * *

### finish(callback) 结束录音

#### 参数

1.  [`callback`] (Function)

#### 返回

1. `result` (Object)
    *   `path` (String) 录音文件地址
    *   `duraction` (Number) 录音时长秒数

#### 示例

```
recorder.finish((ret) => {
    console.log(ret.path)
})
```

> format: 返回amr格式文件

* * *

## 播放音频

```
/**
 * @param url    音频地址
 * @param mode   声音播放源 0： 外放 1： 听筒
 * @param ret    [`callback`] (Function)
 */
audio.play(url, mode, ret=> {

})

```
#### 返回

1. `ret` (Object)
    *   `messaage` (String) 播放状态 start, completion
    *   `code` (Number) 状态码


## stopPlay(callback) 停止播放

```
audio.stopPlay()

audio.stopPlay(()=>{
    
})

```
# JKVideoRecord
视频录制美化
GPUImage是一个基于GPU图像和视频处理的开源iOS框架，
提供各种各样的图像处理滤镜，并且支持照相机和摄像机的实时滤镜；

滤镜介绍百度一下有很多，这里就不做介绍了。

开始采集视频数据 初始化预览的view等操作

fileprivate func conifgCamera() {
        //创建预览的View
        view.insertSubview(preView, at: 0)
        //设置camera方向
        camera?.outputImageOrientation = .portrait
        camera?.horizontallyMirrorFrontFacingCamera = true

        ///防止允许声音通过的情况下，避免录制第一帧黑屏闪屏
        camera?.addAudioInputsAndOutputs()

        //获取滤镜组
        beautifulFilter = getGroupFilters()

        //设置GPUImage的响应链
        camera?.addTarget(beautifulFilter)

        beautifulFilter.addTarget(preView)
        //开始采集视频
        camera?.startCapture()

    }
    
    分段视频的录制，增加暂停功能，合成时，将每一段视频的视频轨道和音频轨道合成即可合成为一个视频，下面分段合成的重要代码
    
    CSDN:http://blog.csdn.net/u011315300/article/details/78760319

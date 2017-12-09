//
//  JKPostVideoVC.swift
//
//
//  Created by ning on 2017/12/7.
//  Copyright © 2017年 sonjk. All rights reserved.
//

import UIKit
import GPUImage
import Photos
//import AVFoundation
import AVKit
class JKPostVideoVC: UIViewController{

    fileprivate lazy var camera: GPUImageVideoCamera? = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .front)
    
    fileprivate lazy var preView: GPUImageView  = {
        let preView = GPUImageView(frame: self.view.bounds)
        return preView
    }()
    
    fileprivate lazy var controlView : JKVideoControlView = {
        let control = JKVideoControlView.init(frame: self.view.bounds)
        control.delegate = self
        return control
    }()
    let saturationFilter = GPUImageSaturationFilter() // 饱和
    let bilateralFilter = GPUImageBilateralFilter() // 磨皮
    let brightnessFilter = GPUImageBrightnessFilter() // 美白
    let exposureFilter = GPUImageExposureFilter() // 曝光
    
    var beautifulFilter = GPUImageFilterGroup()
    var isRecording = false
    var isStartPauseBtnSelected = false
    
    
    // 创建写入对象
    fileprivate  var movieWriter : GPUImageMovieWriter?

    var urlArray  =  [URL]()
    
    var pathVideo = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        conifgCamera()
        view.addSubview(controlView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    //这里进行美化设置，美化效果组合
    fileprivate func getGroupFilters() -> GPUImageFilterGroup {
        //创建滤镜组
        let filterGroup = GPUImageFilterGroup()
        //创建滤镜(设置滤镜的引来关系)
        bilateralFilter.addTarget(brightnessFilter)
        brightnessFilter.addTarget(exposureFilter)
        exposureFilter.addTarget(saturationFilter)
        //设置默认值
        bilateralFilter.distanceNormalizationFactor = 5.5
        exposureFilter.exposure = 0
        brightnessFilter.brightness = 0
        saturationFilter.saturation = 1.0
        //设置滤镜起点 终点的filter
        filterGroup.initialFilters = [bilateralFilter]
        filterGroup.terminalFilter = saturationFilter
        return filterGroup
    }
    // 合成 视频 与音乐
    func margeAndExpodsVideos(_ pth:String)  {
        if urlArray.count == 0 {
            return
        }
        let mixComposition = AVMutableComposition()
        let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        var totalTim  = kCMTimeZero
        for i in 0..<urlArray.count {
            do {
                let options = [AVURLAssetPreferPreciseDurationAndTimingKey:true]
                let asset = AVURLAsset.init(url: urlArray[i], options: options)
                //视频轨道
                let assetVideoTrack = asset.tracks(withMediaType: AVMediaType.video).first
                let videoRange = CMTimeRange.init(start: kCMTimeZero, duration: asset.duration)
                try videoTrack?.insertTimeRange(videoRange, of: assetVideoTrack!, at: totalTim)
                
                
                
                //获取AVAsset 中的音频
                let assetAudioTrack = asset.tracks(withMediaType: AVMediaType.audio).first
                //因为视频比音频短，所以直接用视频的长度
                let audioRange = videoRange //CMTimeRange.init(start: kCMTimeZero, duration: asset.duration)
                try audioTrack?.insertTimeRange(audioRange, of: assetAudioTrack!, at: totalTim)
            
            
                totalTim = CMTimeAdd(totalTim, asset.duration)
            
            }catch{
                print("有错")
            }
            
            
        }
        //导出合成的视频
        let url = URL.init(fileURLWithPath: pth)
        let exporterSession = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporterSession?.outputFileType = AVFileType.mp4
        exporterSession?.outputURL = url
        exporterSession?.shouldOptimizeForNetworkUse = true
        exporterSession?.exportAsynchronously(completionHandler: {
            print("保存视频成功")
            
            self.camera?.stopCapture()
           
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pth)) {
                //保存相册核心代码
                UISaveVideoAtPathToSavedPhotosAlbum(pth, self, #selector(self.didFinishSavingWithError(path:error:contextInfo:)), nil);
            }
        })
        
        
        
    }
    @objc func didFinishSavingWithError (path pth:String ,error:Error?,contextInfo:Any?) {
        if error == nil {
            let alert = UIAlertController.init(title: "提示", message: "保存视频成功", preferredStyle: .alert)
            
            let action2 = UIAlertAction.init(title: "确定", style: .default, handler: {(action) in
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(action2)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    //获取合成视频之后的路径  我这里直接将合成后的视频 移动到系统相册
    func getVideoMargeFilePath() -> String {
        let tempath = NSTemporaryDirectory() + "/videoFolder"
        if FileManager.default.fileExists(atPath: tempath) == false {
            try! FileManager.default.createDirectory(atPath: tempath, withIntermediateDirectories: true, attributes: nil)
            
        }
        let dataFormatter =  DateFormatter()
        dataFormatter.dateFormat = "yyyyMMddHHmmss"
        let nowstr = dataFormatter.string(from: Date())
        let pth = tempath + "/\(nowstr)" + "merge.mov"
        return pth
    }
}

extension JKPostVideoVC : CYTControlViewDelegate  {
    func backBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    
    func nextStepBtnClick() {
        camera?.audioEncodingTarget = nil
        if isRecording {
            movieWriter?.finishRecording()
            camera?.removeAllTargets()
            isRecording = false
        }
        
        controlView.stopTimer()
        if isStartPauseBtnSelected {
            urlArray.append(URL.init(fileURLWithPath: pathVideo))
        }
        let pth = getVideoMargeFilePath()
        
        
        self.controlView.progressView.progress = 0.0
        self.isStartPauseBtnSelected = false
        
        margeAndExpodsVideos(pth)
    }
    
    func changeCameraBtnClick(_ bl:Bool) {
        camera?.rotateCamera()
    }
    
    func beautifulBtnClick(_ bl:Bool) {
        if bl {
            beautifulFilter.removeAllTargets()
            camera?.removeAllTargets()
            camera?.addTarget(preView)
        }else{
            camera?.removeAllTargets()
            camera?.addTarget(beautifulFilter)
            beautifulFilter.addTarget(preView)
        }
    }
    
    func startBtnBtnClick(_ bl:Bool) {
        if bl {
            isRecording = true
            isStartPauseBtnSelected = true
            pathVideo = NSHomeDirectory() + "/tmp/Movie\(urlArray.count).mov"
//            unlink(pathVideo)
            if FileManager.default.fileExists(atPath: (pathVideo)) {
                try? FileManager.default.removeItem(atPath: (pathVideo))
            }
            let url = URL.init(fileURLWithPath: pathVideo)
            movieWriter = GPUImageMovieWriter.init(movieURL: url, size: self.view.frame.size)
//            movieWriter?.isNeedBreakAudioWhiter = true
            movieWriter?.encodingLiveVideo = true
            movieWriter?.shouldPassthroughAudio = true
           
            
            // 将writer设置成滤镜的target
            beautifulFilter.addTarget(movieWriter)
            camera?.delegate = self
            camera?.audioEncodingTarget = movieWriter
            
            movieWriter?.startRecording()
            
        }else{
            isStartPauseBtnSelected = false
            camera?.audioEncodingTarget = nil
            if pathVideo.lengthOfBytes(using: String.Encoding.utf8) == 0 {
                return
            }
            if isRecording {
                isRecording = false
                movieWriter?.finishRecording()
                beautifulFilter.removeTarget(movieWriter)
                
                urlArray.append(URL.init(fileURLWithPath: pathVideo))
            }
            
        }
    }
    
    func reStarBtnClick() {
        
    }
    
    
}

extension JKPostVideoVC  : GPUImageVideoCameraDelegate {
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
       
    }
}


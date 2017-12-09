//
//  JKVideoControlView.swift
//
//
//  Created by ning on 2017/12/7.
//  Copyright © 2017年 songjk. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
let ScreenW = UIScreen.main.bounds.size.width
let ScreenH = UIScreen.main.bounds.size.height
class JKVideoControlView: UIView {
    
    weak var delegate : CYTControlViewDelegate?
    //点击下一步 即可保存到本地相册查看
    lazy var nextBtn : UIButton = {
       let btn = UIButton.init(type: .custom)
        btn.setTitle("下一步", for: .normal)
        btn.titleLabel?.textColor = UIColor.white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(nextBtnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    lazy var changeCameraBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("切换", for: .normal)
        btn.titleLabel?.textColor = UIColor.white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(nextBtnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    lazy var beautifulBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("美颜开", for: .normal)
        btn.setTitle("美颜关", for: .selected)
        btn.titleLabel?.textColor = UIColor.white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(nextBtnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    lazy var startBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("开始", for: .normal)
        btn.setTitle("暂停", for: .selected)
        btn.titleLabel?.textColor = UIColor.white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(nextBtnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    lazy var reStarBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("重开", for: .normal)
        btn.titleLabel?.textColor = UIColor.white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(nextBtnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    lazy var backBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("返回", for: .normal)
        btn.titleLabel?.textColor = UIColor.white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(nextBtnClick(btn:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var progressView : UIProgressView = {
       let pro = UIProgressView.init(progressViewStyle: .default)
        pro.trackTintColor = UIColor.clear
        pro.progressTintColor = UIColor.red
        return pro
    }()
    
    
    
    var timer : Timer?
    let totalTime  = 10.0
    var currentTime = 0.0
    let audioPlayer = AVPlayer()
    var isAudioPause = false
    var audioPath = Bundle.main.path(forResource: "123", ofType: "mp3")
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        configUI()
        
    }
    func configUI()  {
        addSubview(nextBtn)
        addSubview(changeCameraBtn)
        addSubview(beautifulBtn)
        addSubview(startBtn)
        addSubview(reStarBtn)
        addSubview(backBtn)
        addSubview(progressView)
        snapUI()
        nextBtn.isHidden = true
    }
    
    func snapUI()  {
        startBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.width.height.equalTo(80)
            make.bottom.equalTo(self.snp.bottom).offset(-40)
        }
        reStarBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo((ScreenW-80)/4.0)
            make.centerY.equalTo(startBtn)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(ScreenW-(ScreenW-80)/4.0)
            make.centerY.equalTo(startBtn)
            make.width.height.equalTo(reStarBtn)
        }
        
        changeCameraBtn.snp.makeConstraints { (make) in
            make.top.equalTo(80)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.width.equalTo(40)
            
        }
        beautifulBtn.snp.makeConstraints { (make) in
            make.top.equalTo(changeCameraBtn.snp.bottom).offset(10)
            make.size.right.equalTo(changeCameraBtn)
           
        }
        backBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(changeCameraBtn)
            make.left.equalTo(15)
            make.width.height.equalTo(40)
        }
        progressView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(10)
        }
    }
    
    @objc func nextBtnClick (btn:UIButton){
        guard let delegate = delegate else{
            return
        }
        if btn == nextBtn {
            self.pauseMusic()
            delegate.nextStepBtnClick()
            
            
        }else if btn == changeCameraBtn {
            btn.isSelected = !btn.isSelected
            delegate.changeCameraBtnClick(btn.isSelected)
        }else if btn == beautifulBtn {
            btn.isSelected = !btn.isSelected
            delegate.beautifulBtnClick(btn.isSelected)
        }else if btn == startBtn {
            
            btn.isSelected = !btn.isSelected
            delegate.startBtnBtnClick(btn.isSelected)
            startOrPause(btn.isSelected)
            
        }else if btn == reStarBtn {
            
            delegate.reStarBtnClick()
            
        }else if btn == backBtn {
            delegate.backBtnClick()
        }
    }
    
    func startOrPause(_ bl:Bool)  {
        if bl {
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .commonModes)
            
            playMusic()
            
            
        }else{
            //暂停
            stopTimer()
            pauseMusic()
            
        }
        
    }
    @objc func updateTimer(){
        currentTime += 0.05
        
        progressView.progress = Float(currentTime/totalTime)
        if currentTime >= 3.0 {//最短时间需要3s
            nextBtn.isHidden = false
        }
        if currentTime >= totalTime {
            delegate?.nextStepBtnClick()
            self.pauseMusic()
        }
    }
    
    func stopTimer()  {
        guard let timer = timer else {
            return
        }
        timer.invalidate()
    }
    //开始播放音乐
    func playMusic()  {
        if !isAudioPause {
            let path = Bundle.main.path(forResource: "123", ofType: "mp3")
            let playItem = AVPlayerItem.init(url: URL.init(fileURLWithPath: path!))
            audioPlayer.replaceCurrentItem(with: playItem)
        }
        audioPlayer.play()
        
    }
    func pauseMusic()  {
        isAudioPause = true
        audioPlayer.pause()
    }
    func stopMusic()  {
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

@objc protocol CYTControlViewDelegate {
    @objc func nextStepBtnClick()
    @objc func changeCameraBtnClick(_ bl:Bool)
    @objc func beautifulBtnClick(_ bl:Bool)
    @objc func startBtnBtnClick(_ bl:Bool)
    @objc func reStarBtnClick()
    @objc func backBtnClick()
    
}


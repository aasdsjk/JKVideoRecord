//
//  ViewController.swift
//  JKVideoRecord
//
//  Created by ning on 2017/12/9.
//  Copyright © 2017年 songjk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

   
    @IBAction func beginRecord(_ sender: Any) {
        let vc = JKPostVideoVC()
        self.present(vc, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


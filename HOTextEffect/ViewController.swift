//
//  ViewController.swift
//  HOTextEffect
//
//  Created by Holaween on 2018/10/6.
//  Copyright © 2018年 OldDaddy0. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.purple
        
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for view in view.subviews {
            view.removeFromSuperview()
        }
        let light: LightningText = LightningText()
        light.text = "帅大风大浪科技发达激发了大家封疆大吏放假啊来的看风使舵减肥连锁酒店发生快乐的疯狂了三等奖法律框架说了句翻领宽松的"
        light.showIn(self.view)
    }
}


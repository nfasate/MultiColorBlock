//
//  ViewController.swift
//  MultiColorBlock
//
//  Created by nfasate on 10/29/2017.
//  Copyright (c) 2017 nfasate. All rights reserved.
//

import UIKit
import MultiColorBlock

class ViewController: UIViewController, ColorBlockViewDelegate {
    func colorBlockDidSelect(color: UIColor) {
        colorBtn.backgroundColor = color
    }
    
    func colorBlockDidClose() {
        print("close")
    }
    
    @IBOutlet weak var colorBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func colorBtnTapped(_ sender: UIButton) {
        let view = self.view.showColorBlockView(onTap: sender, with: 100)
        view.delegate = self
        view.setCustomColor(to: .down, color: .red)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


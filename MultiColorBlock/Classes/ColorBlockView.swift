//
//  ColorBlockView.swift
//  MultiColorBlock
//
//  Created by Nilesh's MAC on 10/28/17.
//  Copyright (c) 2017 nfasate <nfasate@github.com>

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

/**
 Delegate protocol for performing action
 */
public protocol ColorBlockViewDelegate
{
    /**
     Called when user selct any color of the Blocks.
     */
    func colorBlockDidSelect(color: UIColor)
    /**
     Called when user close the multi color block.
     */
    func colorBlockDidClose()
}

public class ColorBlockView: UIView {

    /**
     Color block types
     */
    public enum BlockType {
        case up
        case right
        case down
        case left
    }
    
    //MARK:- IBOutlets variables
    /**
     XIB content view
     */
    @IBOutlet var contentView: UIView!
    @IBOutlet weak private var centerCloseBtn: UIButton!
    @IBOutlet weak private var upBlockBtn: UIButton!
    @IBOutlet weak private var downBlockBtn: UIButton!
    @IBOutlet weak private var leftBlockBtn: UIButton!
    @IBOutlet weak private var rightBlockBtn: UIButton!
    
    /**
     Delegate object of color block.
     */
    public var delegate: ColorBlockViewDelegate?
    
    //MARK:- Default Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    //MARK:- Custom Functions
    private func commonInit() {
        loadNib()
    }
    /**
     Load the nib on init method.
     */
    private func loadNib()
    {
        let bundle = Bundle(for: self.classForCoder)
        let nib = UINib(nibName: "ColorBlockView", bundle: bundle)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = self.bounds
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = self.bounds.width / 2
        contentView.layer.borderWidth = 4
        contentView.layer.borderColor = UIColor.white.cgColor
        //contentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner] //for bottom corners
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
        makeRoundedCenterBtn()
    }
    
    /**
     Making round corners to close button.
     */
    private func makeRoundedCenterBtn() {
        centerCloseBtn.backgroundColor = .white
        centerCloseBtn.layer.cornerRadius = (self.bounds.width*0.4) / 2
        centerCloseBtn.transform = CGAffineTransform(rotationAngle: .pi/4)
    }
    
    /**
     Closing the view with animation and called protocol delegate methods.
     */
    private func closeView(_ sender: UIButton!) {
        let degree:CGFloat = .pi + .pi/4
        self.transform = CGAffineTransform(rotationAngle: degree)
        
        UIView.animate(withDuration: 0.4, animations: {
            if let color = sender?.backgroundColor {
            self.setSelectedColor(color)
            }
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { (sucess) in
            self.removeFromSuperview()
        }
        
        if sender == nil {
            delegate?.colorBlockDidClose()
        }else {
            delegate?.colorBlockDidSelect(color: sender.backgroundColor!)
        }
    }
    
    /**
     Set selected color to all block.
     */
    private func setSelectedColor(_ color:UIColor) {
        upBlockBtn.backgroundColor = color
        downBlockBtn.backgroundColor = color
        rightBlockBtn.backgroundColor = color
        leftBlockBtn.backgroundColor = color
    }
    
    /**
     Setting custom color to selected block.
     */
    public func setCustomColor(to blockType: BlockType, color: UIColor)
    {
        switch blockType {
        case .up:
            upBlockBtn.backgroundColor = color
        case .down:
            downBlockBtn.backgroundColor = color
        case .right:
            rightBlockBtn.backgroundColor = color
        case .left:
            leftBlockBtn.backgroundColor = color
        }
    }
    
    //MARK:- IBAction Methods
    @IBAction private func centerCloseBtnTapped(_ sender: UIButton) {
        closeView(nil)
    }
    
    @IBAction private func upBlockBtnTapped(_ sender: UIButton) {
        closeView(sender)
    }

    @IBAction private func downBlockBtnTapped(_ sender: UIButton) {
        closeView(sender)
    }
    
    @IBAction private func rightBlockBtnTapped(_ sender: UIButton) {
        closeView(sender)
    }
    
    @IBAction private func leftBlockBtnTapped(_ sender: UIButton) {
        closeView(sender)
    }
}

//MARK:- UIView Extension
extension UIView {
    
    static var xTemp: CGFloat!
    static var yTemp: CGFloat!
    
    /**
     To Display the multi color block view with animation on tap object.
     */
    public func showColorBlockView(onTap sender: UIButton, with size:CGFloat = 100) -> ColorBlockView
    {
        let viewWidth = self.frame.width
        let viewHeight = self.frame.height
        
        var xPoint = (sender.frame.origin.x + (sender.frame.width/2)) - (size/2)
        var yPoint = (sender.frame.origin.y + (sender.frame.height/2)) - (size/2)
        
        UIView.xTemp = xPoint
        UIView.yTemp = yPoint
        
        let xTempSize = xPoint + size + 10
        let yTempSize = yPoint + size + 10
        
        if xTempSize >= viewWidth
        {
            let diff = xTempSize - viewWidth
            xPoint = xPoint - diff
        }else if (xPoint - 10) <= 0
        {
            xPoint = 10
        }
        
        
        if yTempSize >= viewHeight
        {
            let diff = yTempSize - viewHeight
            yPoint = yPoint - diff
        }else if (yPoint - 10) <= 0
        {
            yPoint = 10
        }
        
        let circularView = ColorBlockView.init(frame: CGRect(x: xPoint, y: yPoint, width: size, height: size))
        
        circularView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        circularView.backgroundColor = UIColor.clear
        circularView.layer.shadowColor = UIColor.lightGray.cgColor
        circularView.layer.shadowOffset = CGSize(width: 0, height: 0)
        circularView.layer.shadowOpacity = 1
        circularView.layer.shadowRadius = 6.0
        circularView.layer.shadowPath = UIBezierPath(roundedRect: circularView.layer.bounds, cornerRadius: circularView.bounds.width / 2).cgPath
        
        self.addSubview(circularView)
        let degree:CGFloat = .pi + .pi/4
        
        let when = DispatchTime.now() + 0.005
        DispatchQueue.main.asyncAfter(deadline: when) {
            UIView.animate(withDuration: 0.4, animations: {
                circularView.transform = CGAffineTransform(rotationAngle: degree)
            }) { (sucess) in
                
            }
        }
        
        return circularView
    }
}

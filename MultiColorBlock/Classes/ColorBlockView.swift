//
//  ColorBlockView.swift
//  DemoExample
//
//  Created by Nilesh's MAC on 10/28/17.
//  Copyright © 2017 Nilesh's MAC. All rights reserved.
//

import UIKit

/**
 Delegate protocol for performing action
 */
@objc public protocol ColorBlockViewDelegate
{
    /**
     
     */
    func colorBlockDidSelect(color: UIColor)
    @objc optional func colorBlockDidClose()
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
    var delegate: ColorBlockViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        loadNib()
    }
    /**
     Load nib on init method
     */
    private func loadNib()
    {
        Bundle.main.loadNibNamed("ColorBlockView", owner: self, options: nil)
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
            delegate?.colorBlockDidClose!()
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

extension UIView {
    func showColorBlockView(onTap sender: UIButton, with size:CGFloat = 100) -> ColorBlockView
    {
        let xPoint = sender.frame.origin.x + (sender.frame.width/2)
        let yPoint = sender.frame.origin.y + (sender.frame.height/2)
        
        let circularView = ColorBlockView.init(frame: CGRect(x: xPoint-(size/2), y: yPoint-(size/2), width: size, height: size))
        
        circularView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        circularView.backgroundColor = UIColor.clear
        circularView.layer.shadowColor = UIColor.lightGray.cgColor
        circularView.layer.shadowOffset = CGSize(width: 0, height: 0)
        circularView.layer.shadowOpacity = 1
        circularView.layer.shadowRadius = 6.0
        circularView.layer.shadowPath = UIBezierPath(roundedRect: circularView.layer.bounds, cornerRadius: circularView.bounds.width / 2).cgPath
        
        self.addSubview(circularView)
        let degree:CGFloat = .pi + .pi/4
        
        UIView.animate(withDuration: 0.4, animations: {
            circularView.transform = CGAffineTransform(rotationAngle: degree)
        }) { (sucess) in
            
        }
        return circularView
    }
}

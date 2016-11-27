//
//  ViewController.swift
//  FlickrFeed
//
//  Created by picomax on 2016. 11. 27..
//  Copyright © 2016년 picomax. All rights reserved.
//

import UIKit

let animationDuration: TimeInterval = 1

class ViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var timeslider: UISlider!
    @IBOutlet weak var timeTextField: UITextField!
    
    
    // MARK: - Properties
    let itemManager = ItemManager()
    var timer: Timer?
    var updateTime: TimeInterval = 5
    var currentImageIndex = 0
    var isStarted = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.itemManager.delegate = self
        self.itemManager.start()
        
        self.timeTextField.text = "\(Int(self.updateTime))"
        self.timeslider.value = Float(self.updateTime)
    }

    // MARK: - Events
    @IBAction func timeSliderValueChanged(_ sender: Any) {
        self.timeTextField.text = "\(Int(timeslider.value))"
        self.updateTime = TimeInterval(Int(timeslider.value))
        self.timer?.invalidate()
        
        if isStarted {
            self.setTimer()
        }
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        self.startButton.isEnabled = false
        self.showNextImage()
        self.setTimer()
        
        self.isStarted = true
    }
    
    func setTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: self.updateTime + animationDuration,
                                          target: self,
                                          selector: #selector(self.showNextImage),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    func showNextImage() {
        currentImageIndex += 1
        if currentImageIndex >= self.itemManager.count() {
            currentImageIndex = 0
        }
        
        if let imageModel = self.itemManager.getItemModel(index: currentImageIndex),
            let path = imageModel.path {
            let image = UIImage(contentsOfFile: path)
            
            UIView.transition(with: self.view, duration: animationDuration, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                self.imageView.image = image
            }, completion: nil)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: ItemManagerDelegate {
    func itemCountChanged(count: Int) {
        guard self.isStarted == false else { return }
        self.startButton.isEnabled = count > 0
    }
}

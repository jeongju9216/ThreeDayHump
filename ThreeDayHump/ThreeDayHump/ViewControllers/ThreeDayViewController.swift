//
//  ThreeDayViewController.swift
//  ThreeDayHump
//
//  Created by 유정주 on 2022/01/08.
//

import UIKit
import AVFoundation

class ThreeDayViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    
    //MARK: - Properties
    private lazy var dayViews: [UIView] = [firstView, secondView, thirdView]
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()

        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = Goal.shared.goal ?? ""
                
        updateGoalViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        updateGoalViews() //앱 밖에서 다크모드를 바꾼 경우
    }
    
    //MARK: - IBActions
    @IBAction func clickedDone(_ sender: Any) {
        AudioServicesPlaySystemSound(1519)
        
        Goal.shared.day += 1
        if Goal.shared.day > 3 {
            Goal.shared.day = 0
            resetGoalViews()
        }
        
        updateGoalViews()
    }
    
    
    //MARK: - Methods
    private func initView() {
        doneButton.layer.cornerRadius = 5
        doneButton.createShadow()
        
        resetGoalViews()
    }
    
    private func resetGoalViews() {
        for i in 0..<3 {
            dayViews[i].layer.cornerRadius = 5
            dayViews[i].layer.borderWidth = 4
            dayViews[i].layer.borderColor = UIColor.white.cgColor
            dayViews[i].layer.backgroundColor = UIColor(named: "MainColor")?.cgColor
        }
    }
    
    private func updateGoalViews() {
        dayLabel.text = Goal.shared.destination
        
        for i in 0 ..< Goal.shared.day {
            dayViews[i].backgroundColor = .white
        }
    }
}

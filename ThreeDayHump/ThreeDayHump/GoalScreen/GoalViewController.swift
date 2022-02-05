//
//  ViewController.swift
//  ThreeDayHump
//
//  Created by 유정주 on 2022/01/02.
//

import UIKit

class GoalViewController: BaseViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var goalBackgroundView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var goalTextField: UITextField!
    
    private let maxGoalLength = 15
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initViews()
        
        goalTextField.delegate = self
    }
    
    //MARK: - Overrides
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        goalTextField.endEditing(true)
    }
    
    //MARK: - IBActions
    @IBAction func clickedStartButton(_ sender: UIButton) {
        print("\(#fileID) \(#line)-line, \(#function)")
        Goal.shared.goal = goalTextField.text ?? ""
        
        UserDefaults.standard.removeObject(forKey: "clickDate")
        UserDefaults.standard.synchronize()
        
        showThreeDayViewController()
    }
    
    //MARK: - Methods
    private func initViews() {
        goalBackgroundView.layer.cornerRadius = 15

        startButton.layer.cornerRadius = 5
        startButton.createShadow()
    }
    
}

extension GoalViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        if text.count == 1 && string.isEmpty {
            startButton.isEnabled = false
        } else {
            startButton.isEnabled = true
        }
        
        // 초과되는 텍스트 제거
        let newLength = text.count + string.count - range.length
        return newLength <= (maxGoalLength + 1)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goalTextField.endEditing(true)
        return true
    }
    
}

extension UITextView {
    func centerVerticalText() {
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}

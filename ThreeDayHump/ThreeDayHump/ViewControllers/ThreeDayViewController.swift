//
//  ThreeDayViewController.swift
//  ThreeDayHump
//
//  Created by 유정주 on 2022/01/08.
//

import UIKit
import AVFoundation

class ThreeDayViewController: BaseViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - IBOutlets
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    
    //MARK: - Properties
    private lazy var dayViews: [UIView] = [firstView, secondView, thirdView]
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(onForegroundAction), name: UIApplication.willEnterForegroundNotification, object: nil)

        initView()
        
        resetGoalViews()
        updateSquares()
        
        if checkAlreadyDone() {
            setupDoneStyle()
        } else {
            setupNotDoneStyle()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //alert 상태에서 앱을 재시작했을 때 Alert
        if Goal.shared.isAlert {
            alertSuccessThreeDay()
        }
    }
    
    //MARK: - IBActions
    @IBAction func onGiveUpClicked(_ sender: UIButton) {
        alertGiveUp()
    }
    
    @IBAction func onDoneClicked(_ sender: Any) {
        var titleText: String?, messageText: String?, alertType: AlertType?
        
        if false && checkAlreadyDone() {
            titleText = "안내"
            messageText = "이미 완료 했습니다.\n내일도 화이팅!"
            alertType = .oneButton
        } else {
            let date = Date()
            Goal.shared.clickDate = date
            print(dateFormatter.string(from: date))
            
            AudioServicesPlaySystemSound(1519)
            animateSquare()
            setupDoneStyle()
            
            Goal.shared.day += 1
            dayLabel.text = Goal.shared.destination
            
            let day = Goal.shared.day
            if day % 3 == 0 {
                fillAllSquares()
                
                titleText = "안내"
                messageText = "축하합니다!\n작심삼일을 성공했어요🥳"
                alertType = .twoButton
            } else {
                fillSquares(day % 3)
                
                titleText = "안내"
                messageText = "작심 \(Goal.shared.day)일을 달성했어요."
                alertType = .oneButton
            }
        }
        
        let alertViewController = AlertViewController(titleText: titleText ?? "", messageText: messageText ?? "", alertType: alertType ?? .oneButton)
        present(alertViewController, animated: false, completion: nil)
    }
    
    //MARK: - Methods
    @objc private func onForegroundAction() {
        print("Foreground!!")
        
        if checkAlreadyDone() {
            setupDoneStyle()
        } else {
            setupNotDoneStyle()
        }
    }
    
    
    private func initView() {
        goalLabel.text = Goal.shared.goal ?? ""
        dayLabel.text = Goal.shared.destination

        doneButton.layer.cornerRadius = 5
        doneButton.createShadow()
    }
    
    private func checkAlreadyDone() -> Bool {
        guard let clickDate = UserDefaults.standard.object(forKey: "clickDate") as? Date else {
            return false
        }
        
        return Calendar.current.isDateInToday(clickDate)
    }
    
    private func setupDoneStyle() {
        UIView.animate(withDuration: 0.05, animations: { [weak self] in
            self?.doneButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        })
        
        doneButton.removeShadow()
        doneButton.backgroundColor = .none
        doneButton.titleLabel?.textColor = UIColor(named: "TabColor")
    }
    
    private func setupNotDoneStyle() {
        doneButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        doneButton.createShadow()
        doneButton.backgroundColor = UIColor(named: "TextFieldColor")
        doneButton.titleLabel?.textColor = UIColor(named: "LabelColor")
    }
    
    private func animateSquare() {
        let animateIndex = Goal.shared.day % 3
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.dayViews[animateIndex].transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.dayViews[animateIndex].transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        })
    }
    
    private func updateSquares() {
        if Goal.shared.day > 0 {
            let fillCount = Goal.shared.day % 3
            if fillCount == 0 && Goal.shared.isAlert {
                fillAllSquares()
            } else {
                fillSquares(fillCount)
            }
        }
    }
    
    private func resetGoalViews() {
        for i in 0..<3 {
            dayViews[i].layer.cornerRadius = 5
            dayViews[i].layer.borderWidth = 4
            dayViews[i].layer.borderColor = UIColor.white.cgColor
            dayViews[i].layer.backgroundColor = .none
        }
    }
    
    private func fillAllSquares() {
        for i in 0 ..< 3 {
            dayViews[i].backgroundColor = .white
        }
    }
    
    private func fillSquares(_ number: Int) {
        for i in 0 ..< number {
            dayViews[i].backgroundColor = .white
        }
    }
    
    private func alert(message: String) {
        let alert = UIAlertController(title: "안내", message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true)
    }
    
    private func alertSuccessThreeDay() {
        Goal.shared.isAlert = true
        
        let alert = UIAlertController(title: "Success", message: "축하합니다!\n작심삼일을 성공했어요🥳", preferredStyle: UIAlertController.Style.alert)
        
        let stopAction = UIAlertAction(title: "그만하기", style: UIAlertAction.Style.destructive) { [weak self] _ in
            Goal.shared.isAlert = false
            self?.resetUserDefaults()
            self?.showGoalViewController()
        }
        
        let continueAction = UIAlertAction(title: "계속하기", style: UIAlertAction.Style.default) { [weak self] _ in
            Goal.shared.isAlert = false
            self?.resetGoalViews()
        }
        
        alert.addAction(stopAction)
        alert.addAction(continueAction)

        self.present(alert, animated: true)
    }
    
    private func alertGiveUp() {
        let alert = UIAlertController(title: "포기하기", message: "작심 \(Goal.shared.day)일입니다.\n여기에서 그만 두시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        
        let stopAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel)
        
        let continueAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { [weak self] _ in
            self?.resetUserDefaults()
            self?.showGoalViewController()
        }
        
        alert.addAction(stopAction)
        alert.addAction(continueAction)

        self.present(alert, animated: true)
    }
}

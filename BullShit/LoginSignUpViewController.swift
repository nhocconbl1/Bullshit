//
//  ViewController.swift
//  AMLoginSingup
//
//  Created by amir on 10/11/16.
//  Copyright © 2016 amirs.eu. All rights reserved.
//

import UIKit
import SwiftValidator

enum AMLoginSignupViewMode {
    case login
    case signup
}

class LoginSignUpViewController: UIViewController {
    
    let validator = Validator() //Login
    let validator2 = Validator() //Signup
    let animationDuration = 0.25
    var mode:AMLoginSignupViewMode = .signup
    
    
    //MARK: - background image constraints
    @IBOutlet weak var backImageLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var backImageBottomConstraint: NSLayoutConstraint!
    
    
    //MARK: - login views and constrains
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginContentView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginWidthConstraint: NSLayoutConstraint!
    
    
    //MARK: - signup views and constrains
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var signupContentView: UIView!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signupButtonVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var signupButtonTopConstraint: NSLayoutConstraint!
    
    
    //MARK: - logo and constrains
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoButtomInSingupConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!
   
    
    @IBOutlet weak var forgotPassTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var socialsView: UIView!
    
    
    //MARK: - input views
    @IBOutlet weak var loginEmailInputView: AMInputView!
    @IBOutlet weak var loginPasswordInputView: AMInputView!
    @IBOutlet weak var signupEmailInputView: AMInputView!
    @IBOutlet weak var signupPasswordInputView: AMInputView!
    @IBOutlet weak var signupPasswordConfirmInputView: AMInputView!
    
    
    
    //MARK: - controller
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // set view to login mode
        toggleViewMode(animated: false)
        ValidatorInit()
        //add keyboard notification
         NotificationCenter.default.addObserver(self, selector: #selector(keyboarFrameChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func ValidatorInit()  {
        self.validator.registerField(loginEmailInputView.textFieldView, errorLabel: loginEmailInputView.labelView, rules: [RequiredRule(), EmailRule(message: "Invalid email")])
        self.validator.registerField(loginPasswordInputView.textFieldView, errorLabel: loginPasswordInputView.labelView, rules: [RequiredRule(), MinLengthRule.init(length: 8, message: "Minimum 8 characters"),MaxLengthRule(length:32,message:"Maximum 32 characters")])
        
        self.validator2.registerField(signupEmailInputView.textFieldView, errorLabel: signupEmailInputView.labelView, rules: [RequiredRule(), EmailRule(message: "Invalid email")])
        self.validator2.registerField(signupPasswordInputView.textFieldView, errorLabel: signupPasswordInputView.labelView, rules: [RequiredRule(), MinLengthRule.init(length: 8, message: "Minimum 8 characters"),MaxLengthRule(length:32,message:"Maximum 32 characters")])
        self.validator2.registerField(signupPasswordConfirmInputView.textFieldView, errorLabel: signupPasswordConfirmInputView.labelView, rules:[ConfirmationRule(confirmField: signupPasswordInputView.textFieldView,message:"Confirm password is incorrect")])
        
    }
    
    
    //MARK: - button actions
    @IBAction func loginButtonTouchUpInside(_ sender: AnyObject) {
   
        if mode == .signup {
             toggleViewMode(animated: true)
        
        }else{
            self.validator.validate(self)
            //TODO: login by this data
           
        }
    }
    
    @IBAction func signupButtonTouchUpInside(_ sender: AnyObject) {
   
        if mode == .login {
            toggleViewMode(animated: true)
        }else{
            self.validator2.validate(self)
            //TODO: signup by this data
           
        }
    }
    
    
    
    //MARK: - toggle view
    func toggleViewMode(animated:Bool){
    
        // toggle mode
        mode = mode == .login ? .signup:.login
        
        
        // set constraints changes
        backImageLeftConstraint.constant = mode == .login ? 0:-self.view.frame.size.width
        
        
        loginWidthConstraint.isActive = mode == .signup ? true:false
        logoCenterConstraint.constant = (mode == .login ? -1:1) * (loginWidthConstraint.multiplier * self.view.frame.size.width)/2
        loginButtonVerticalCenterConstraint.priority = mode == .login ? 300:900
        signupButtonVerticalCenterConstraint.priority = mode == .signup ? 300:900
        
        
        //animate
        self.view.endEditing(true)
        
        UIView.animate(withDuration:animated ? animationDuration:0) {
            
            //animate constraints
            self.view.layoutIfNeeded()
            
            //hide or show views
            self.loginContentView.alpha = self.mode == .login ? 1:0
            self.signupContentView.alpha = self.mode == .signup ? 1:0
            
            
            // rotate and scale login button
            let scaleLogin:CGFloat = self.mode == .login ? 1:0.4
            let rotateAngleLogin:CGFloat = self.mode == .login ? 0:CGFloat(-M_PI_2)
            
            var transformLogin = CGAffineTransform(scaleX: scaleLogin, y: scaleLogin)
            transformLogin = transformLogin.rotated(by: rotateAngleLogin)
            self.loginButton.transform = transformLogin
            
            
            // rotate and scale signup button
            let scaleSignup:CGFloat = self.mode == .signup ? 1:0.4
            let rotateAngleSignup:CGFloat = self.mode == .signup ? 0:CGFloat(-M_PI_2)
            
            var transformSignup = CGAffineTransform(scaleX: scaleSignup, y: scaleSignup)
            transformSignup = transformSignup.rotated(by: rotateAngleSignup)
            self.signupButton.transform = transformSignup
        }
        
    }
    
    
    //MARK: - keyboard
    func keyboarFrameChange(notification:NSNotification){
        
        let userInfo = notification.userInfo as! [String:AnyObject]
        
        // get top of keyboard in view
        let topOfKetboard = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue .origin.y
        
        
        // get animation curve for animate view like keyboard animation
        var animationDuration:TimeInterval = 0.25
        var animationCurve:UIViewAnimationCurve = .easeOut
        if let animDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            animationDuration = animDuration.doubleValue
        }
        
        if let animCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
            animationCurve =  UIViewAnimationCurve.init(rawValue: animCurve.intValue)!
        }
        
        
        // check keyboard is showing
        let keyboardShow = topOfKetboard != self.view.frame.size.height
        
        
        //hide logo in little devices
        let hideLogo = self.view.frame.size.height < 667
        
        // set constraints
        backImageBottomConstraint.constant = self.view.frame.size.height - topOfKetboard
        
        logoTopConstraint.constant = keyboardShow ? (hideLogo ? 0:20):50
        logoHeightConstraint.constant = keyboardShow ? (hideLogo ? 0:40):60
        logoBottomConstraint.constant = keyboardShow ? 20:32
        logoButtomInSingupConstraint.constant = keyboardShow ? 20:32
        
        forgotPassTopConstraint.constant = keyboardShow ? 30:45
        
        loginButtonTopConstraint.constant = keyboardShow ? 25:30
        signupButtonTopConstraint.constant = keyboardShow ? 23:35
        
        loginButton.alpha = keyboardShow ? 1:0.7
        signupButton.alpha = keyboardShow ? 1:0.7
        
        
        
        // animate constraints changes
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(animationCurve)
        
        self.view.layoutIfNeeded()
        
        UIView.commitAnimations()
        
    }
    
    //MARK: - hide status bar in swift3
    
    override var prefersStatusBarHidden: Bool {
        return true
    }  
}
extension LoginSignUpViewController:ValidationDelegate{
    
    func validationSuccessful() {
        // submit the form
        if mode == .login {
            self.loginEmailInputView.SetupLabel(error: false)
            self.loginPasswordInputView.SetupLabel(error: false)
             NSLog("Email:\(loginEmailInputView.textFieldView.text) Password:\(loginPasswordInputView.textFieldView.text)")
        }else{
            self.signupEmailInputView.SetupLabel(error: false)
            self.signupPasswordInputView.SetupLabel(error: false)
            self.signupPasswordConfirmInputView.SetupLabel(error: false)
             NSLog("Email:\(signupEmailInputView.textFieldView.text) Password:\(signupPasswordInputView.textFieldView.text), PasswordConfirm:\(signupPasswordConfirmInputView.textFieldView.text)")
        }
        
        
        
        
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (field, error) in errors {
           
            error.errorLabel?.textColor = UIColor.red
            error.errorLabel?.text = error.errorMessage // works if you added labels
//            error.errorLabel?.isHidden = false
        }
    }
}

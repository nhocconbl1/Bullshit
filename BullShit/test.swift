//
//  ViewController.swift
//  AMLoginSingup
//
//  Created by amir on 10/11/16.
//  Copyright © 2016 amirs.eu. All rights reserved.
//

import UIKit
import ISMessages
import Firebase
import FacebookLogin
import FacebookCore
import GoogleSignIn
enum AMLoginSignupViewMode {
    case login
    case signup
}
enum MyError: Error {
    case network
    case response
}


class LoginSignupViewController: UIViewController,UIViewControllerTransitioningDelegate,GIDSignInUIDelegate{
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    
    var ref:FIRDatabaseReference!
    
    
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
    
    @IBOutlet var EmailView: AMInputView!
    @IBOutlet var PasswordView: AMInputView!
    
    //MARK: - signup views and constrains
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var signupContentView: UIView!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signupButtonVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var signupButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var EmailSignupView: AMInputView!
    @IBOutlet var PasswordSignupView: AMInputView!
    @IBOutlet var PasswordComfirmSignUpView: AMInputView!
    //Socials button
    @IBOutlet var FbBtn: UIImageView!
    @IBOutlet var GoogleBtn: UIImageView!
    @IBOutlet var TwitterBtn: UIImageView!
    
    
    //MARK: - logo and constrains
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoButtomInSingupConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var forgotPassTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var socialsView: UIView!
    
    
    
    //MARK: - controller
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        FbBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectedFBLogin)))
        FbBtn.isUserInteractionEnabled = true
        GoogleBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectedGoogleLogin)))
        GoogleBtn.isUserInteractionEnabled = true
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // set view to login mode
        toggleViewMode(animated: false)
        
        //add keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboarFrameChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @objc fileprivate func handleSelectedGoogleLogin(){
        GIDSignIn.sharedInstance().signIn()
    }
    @objc fileprivate func handleSelectedFBLogin() {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile,.email], viewController: self, completion: {
            (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                self.showEmailAddress()
                
            }
            
        })
        
        
    }
    
    func showEmailAddress(){
        startLoading()
        let accessTocken = AccessToken.current
        
        guard  let accesTockenString = accessTocken?.authenticationToken else {
            return
        }
        print(accesTockenString)
        let credentials =  FIRFacebookAuthProvider.credential(withAccessToken: (accesTockenString))
        //        print(credentials)
        
        FIRAuth.auth()?.signIn(with: credentials, completion: {
            (user,error) in
            self.stopLoading()
            if let error = error {
                if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .errorCodeAccountExistsWithDifferentCredential:
                        ISMessages.showCardAlert(withTitle: "Invalid Email", message: "Please email exist with google " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                    case .errorCodeEmailAlreadyInUse:
                        ISMessages.showCardAlert(withTitle: "Email Already Registered", message: "Please use another email! " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                    case .errorCodeNetworkError:
                        ISMessages.showCardAlert(withTitle: "Netword Error", message: "No network connection! " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                        
                    default:
                        print("unknown error")
                        print(error)
                    }
                }
                return
            }
            do {
                User.CheckID(forUserID: user!.uid, completion: {
                    check in
                    if check == true {
                        let viewController:HomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home") as! HomeViewController
                        viewController.transitioningDelegate = self
                        self.present(viewController, animated: true, completion: nil)
                        
                    }else{
                        let u = User(id:(user?.uid)!)
                        u?.Profileurl = user?.photoURL
                        u?.email = user?.email
                        u?.username = user?.displayName
                        u?.type = .facebook
                        try? u?.save()
                        let viewController:HomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home") as! HomeViewController
                        viewController.transitioningDelegate = self
                        self.present(viewController, animated: true, completion: nil)
                        
                    }
                    
                })
                
                
                
                
            }catch let error {
                print(error)
            }
            
            
            
        })
        
        
    }
    
    //MARK: - button actions
    @IBAction func loginButtonTouchUpInside(_ sender: AnyObject) {
        
        if mode == .signup {
            toggleViewMode(animated: true)
            
        }else{
            
            let email = self.EmailView.textFieldView.text
            let password = self.PasswordView.textFieldView.text
            let finalEmail = email!.trimmingCharacters(in: CharacterSet.whitespaces)
            
            if (email?.characters.count)! < 8 || !email!.contains("@") || !email!.contains(".")  {
                
                ISMessages.showCardAlert(withTitle: "Error", message: "Email must be greater than 8 characters and not Invalid email. " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: .error, alertPosition: .top, didHide: nil)
                
            } else if (password?.characters.count)! < 8 {
                
                ISMessages.showCardAlert(withTitle: "Error", message: "Password must be greater than 8 characters. ", duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                
            } else {
                
                self.startLoading()
                do {
                    try? User.loginUser(withEmail: finalEmail, password: password!, completion: {
                        [weak weakSelf = self]   error in
                        if let error = error {
                            weakSelf?.stopLoading()
                            if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                                switch errCode {
                                case .errorCodeUserNotFound:
                                    ISMessages.showCardAlert(withTitle: "Email Not Found", message: "Please check your email!" , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                                    
                                case .errorCodeInvalidEmail:
                                    ISMessages.showCardAlert(withTitle: "Invalid Email", message: "Please check your email format!" , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                                case .errorCodeWrongPassword:
                                    ISMessages.showCardAlert(withTitle: "Wrong Password", message: "Please check your password!" , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                                case .errorCodeNetworkError:
                                    ISMessages.showCardAlert(withTitle: "Netword Error", message: "No network connection!" , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                                default:
                                    print("unknown error")
                                    print(error)
                                }
                            }
                            return
                        }else {
                            let vc:HomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home") as! HomeViewController
                            vc.transitioningDelegate = weakSelf
                            // let navController = UINavigationController(rootViewController: vc)
                            // Creating a navigation controller with VC1 at the root of the navigation stack.
                            
                            self.present(vc, animated: true, completion: nil)
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                                self.stopLoading()
                            }
                            return
                        }
                        //                        guard let user:User = user as? User else { return}
                        
                        
                        
                        
                    })
                    
                    
                    
                }catch{
                    print("error Login ")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        self.stopLoading()
                    }
                    
                }
                
                
            }
            
        }
        
        
        
    }
    
    @IBAction func signupButtonTouchUpInside(_ sender: AnyObject) {
        
        if mode == .login {
            toggleViewMode(animated: true)
        }else{
            
            let password = self.PasswordSignupView.textFieldView.text
            let confirmpass = self.PasswordComfirmSignUpView.textFieldView.text
            let email = self.EmailSignupView.textFieldView.text
            let finalEmail = email!.trimmingCharacters(in: CharacterSet.whitespaces)
            
            
            // Validate the text fields
            if (email?.characters.count)! < 8  || !email!.contains("@") || !email!.contains(".") {
                ISMessages.showCardAlert(withTitle: "Error", message: "Please enter a valid email address." , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                
                
                
            } else if (password?.characters.count)! < 8 {
                
                
                ISMessages.showCardAlert(withTitle: "Error", message: "Password must be greater than 8 characters. " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                
            } else if  ((confirmpass?.characters.count)! < 8 && confirmpass != password) {
                
                
                ISMessages.showCardAlert(withTitle: "Error", message: "Confirm Password Error " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                
                
            } else {
                
                
                self.startLoading()
                do {
                    try? User.registerUser(email: finalEmail, password:password! , completion: {
                        [weak weakSelf = self]  user,error in
                        
                        if let error = error {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                                self.stopLoading()
                            }
                            
                            if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                                switch errCode {
                                case .errorCodeInvalidEmail:
                                    ISMessages.showCardAlert(withTitle: "Invalid Email", message: "Please check your email format! " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                                case .errorCodeEmailAlreadyInUse:
                                    ISMessages.showCardAlert(withTitle: "Email Already Registered", message: "Please use another email! " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                                    
                                case .errorCodeWeakPassword:
                                    ISMessages.showCardAlert(withTitle: "Weak Password", message: "Your password is too weak! " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                                case .errorCodeNetworkError:
                                    ISMessages.showCardAlert(withTitle: "Netword Error", message: "No network connection! " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
                                default:
                                    print("unknown error")
                                    print(error)
                                }
                            }
                            return
                        }else{
                            DispatchQueue.main.async(execute: { () -> Void in
                                
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                                    weakSelf?.stopLoading()
                                }
                                
                                let viewController:SignUpNextNameViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NameSignup") as! SignUpNextNameViewController
                                viewController.user = user!
                                viewController.transitioningDelegate = weakSelf
                                self.present(viewController, animated: true, completion: nil)
                            })
                            
                        }
                        
                    })
                    
                }catch{
                    print("error register ")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(10)) {
                        self.stopLoading()
                    }
                    
                }
                
                
                
            }
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
    @IBAction func unwindToLogInScreen(_ segue:UIStoryboardSegue) {
    }
    
    
    //MARK: - hide status bar in swift3
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
}


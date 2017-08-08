//
//  ResetPasswordViewController.swift
//  ParseDemo
//
//  Created by Rumiya Murtazina on 7/31/15.
//  Copyright (c) 2015 abearablecode. All rights reserved.
//

import UIKit
import Firebase
import ISMessages


class ResetPasswordViewController: UIViewController,UITextFieldDelegate {
 

    @IBOutlet var EmailView: AMInputView!
    @IBOutlet var ResetPasswordBtn: TKTransitionSubmitButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupThemeColor()
    }

    
    @IBAction func ResetPasswordAction(_ sender: AnyObject) {
//        let view = MessageView.viewFromNib(layout: .CardView)
//        view.button?.setFAIcon(FAType.faHeart, forState: UIControlState())
        let email = EmailView.textFieldView.text
        if (email?.characters.count)! < 8 || !(email!.contains("@")){
            ISMessages.showCardAlert(withTitle: "Error", message: "Email must be greater than 8 charactor or invalid Email ", duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: .error, alertPosition: .top, didHide: nil)
            return
        }
        
        
    
        let finalEmail = email!.trimmingCharacters(in: CharacterSet.whitespaces)
          ResetPasswordBtn.startLoadingAnimation()
    
        FIRAuth.auth()?.sendPasswordReset(withEmail: finalEmail) { error in
            
           self.ResetPasswordBtn.stopLoadingAnimation()
            
            
            if error != nil  {
                
                ISMessages.showCardAlert(withTitle: "Error", message: "Your Email does't not Exist", duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
//                view.configureTheme(.error)
//                
//                // Add a drop shadow.
//                view.configureDropShadow()
//                
//                // Set message title, body, and icon. Here, we're overriding the default warning
//                // image with an emoji character.
//                let iconText = ["🤔", "😳", "🙄", "😶"].sm_random()!
//                view.configureContent(title: "Error", body: "Your Email does't not Exist", iconText: iconText)
//                
//                // Show the message.
//                SwiftMessages.show(view: view)

                
            } else {
                 ISMessages.showCardAlert(withTitle: "Success", message: "An email containing information on how to reset your password has been sent to " + finalEmail + ".", duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.success, alertPosition: .top,didHide: nil)
//                view.configureTheme(.success)
//                // Add a drop shadow.
//                view.configureDropShadow()
//                // Set message title, body, and icon. Here, we're overriding the default warning
//                // image with an emoji character.
//                let iconText = ["🤔", "😳", "🙄", "😶"].sm_random()!
//                view.configureContent(title: "Password Reset", body: "An email containing information on how to reset your password has been sent to " + finalEmail + ".", iconText: iconText)
//                
//                // Show the message.
//                SwiftMessages.show(view: view)

            
            }

        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupThemeColor(){
        //Email
        ResetPasswordBtn.layer.cornerRadius = 15.0
//        Util.applySkyscannerThemeWithIcon(EmailField)
//        EmailField.iconFont = UIFont.fontAwesomeOfSize(15)
//        EmailField.iconText = String.fontAwesomeIconWithCode("fa-envelope-o")
//        EmailField.errorColor = UIColor.red
//        self.EmailField.delegate = self
        
        
    }
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if let text = EmailField.text {
//            if  self.EmailField == textField  {
//                if(text.characters.count < 8 || !text.contains("@")) {
//                    self.EmailField.errorMessage = "Invalid email"
//                }
//                else {
//                    // The error message will only disappear when we reset it to nil or empty string
//                    self.EmailField.errorMessage = ""
//                }
//            }
//        }
//        return true
//    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TKFadeInAnimator(transitionDuration: 0.5, startingAlpha: 0.8)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override var prefersStatusBarHidden: Bool {
        return true
    }


}

//
//  SignUpNextNameViewController.swift
//  ClubW
//
//  Created by home on 11/4/16.
//  Copyright © 2016 Toupper. All rights reserved.
//

import UIKit
import  ISMessages
import MobileCoreServices
import Fusuma
class SignUpNextNameViewController: UIViewController,UINavigationControllerDelegate,UIViewControllerTransitioningDelegate,UIGestureRecognizerDelegate,FusumaDelegate {

    @IBOutlet var Username: AMInputView!
    @IBOutlet var ContinueBtn: TKTransitionSubmitButton!
    @IBOutlet var ProfilePic: UIImageView!
    
    var Profile:UIImage? = nil
    
    
    
    var user:User = User()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ContinueBtn.layer.cornerRadius = 15.0
        
        
        ProfilePic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        ProfilePic.isUserInteractionEnabled = true


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func FinishBtn_Action(_ sender: Any) {
        
        let name = Username.textFieldView.text
        
          ContinueBtn.startLoadingAnimation()
        
        // Validate the text fields
        if (name?.characters.count)! < 6 && (name?.characters.count)! > 32 {
            
            
            ISMessages.showCardAlert(withTitle: "Error", message: "User name must be greater than 6 characters and less than 32 characters. " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
            
            self.ContinueBtn.stopLoadingAnimation()

            
        }else if self.Profile == nil {
            
            ISMessages.showCardAlert(withTitle: "Error", message: "Please Pick your profile " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
            self.ContinueBtn.stopLoadingAnimation()

            
        }else {
            
            self.user.username = name
            let data: Data = UIImageJPEGRepresentation(self.Profile!, 0.2)!
            let thumbnail: Salada.File = Salada.File(name:"profile_\(self.user.id)_\(Int(Date().timeIntervalSince1970 * 1000))",data:  data)
            
            self.user.ProfileFile = thumbnail
            
            do {
               try? self.user.save()
                var userDefaults  = UserDefaults.standard.object(forKey: "userInformation") as! [String:String]
                let email =  userDefaults["email"]
                let password = userDefaults["password"]
                User.loginUser(withEmail: email!, password: password!, completion: {
                    [weak weakSelf = self]  error in
                    if error == nil {
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            weakSelf?.ContinueBtn.startFinishAnimation(1, completion: {
                                
                                let viewController:HomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home") as! HomeViewController
                                viewController.transitioningDelegate = weakSelf
                                self.present(viewController, animated: true, completion: nil)
                            })
                            
                        })
                        
                    }
                    
                    
                })
            }catch let error{
                print("Error Save Data :",error)
            }
            
           
            
        }

//            self.user.save({
//            [weak weakSelf = self] (ref,error) in
//                if error != nil {
//                    weakSelf?.ContinueBtn.stopLoadingAnimation()
//                    ISMessages.showCardAlert(withTitle: "Error", message: "Please try again " , duration: 1.0, hideOnSwipe: true, hideOnTap: true, alertType: ISAlertType.error, alertPosition: .top,didHide: nil)
//                    return
//                }
//                
//                DispatchQueue.main.async(execute: { () -> Void in
//                    weakSelf?.ContinueBtn.startFinishAnimation(1, completion: {
//                        
//                        let viewController:HomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home") as! HomeViewController
//                        viewController.transitioningDelegate = weakSelf
//                        self.present(viewController, animated: true, completion: nil)
//                    })
//                    
//                })
//                
//
//                
//            })
//        }
        
    }

    

    func handleSelectProfileImageView(){
        let fusuma = FusumaViewController()
        
        //fusumaCropImage = false
        
        fusuma.delegate = self
        fusuma.cropHeightRatio = 0.7
        //        fusuma.hasVideo = true
        
        self.present(fusuma, animated: true, completion: nil)

        
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.allowsEditing = true
//        imagePickerController.delegate = self
//        imagePickerController.mediaTypes = [kUTTypeImage as String]
//        present(imagePickerController, animated: true, completion: nil)

    }
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        switch source {
        case .camera:
            print("Image captured from Camera")
        case .library:
            print("Image selected from Camera Roll")
        default:
            print("Image selected")
        }
        
        ProfilePic.image = image
        Profile = image
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        print("video completed and output to file: \(fileURL)")
    }
    
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {
        switch source {
        case .camera:
            print("Called just after dismissed FusumaViewController using Camera")
        case .library:
            print("Called just after dismissed FusumaViewController using Camera Roll")
        default:
            print("Called just after dismissed FusumaViewController")
        }
    }
    
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func fusumaClosed() {
        print("Called when the FusumaViewController disappeared")
    }
    
    func fusumaWillClosed() {
        print("Called when the close button is pressed")
    }
    

  
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        
//                    //we selected an image
//            handleImageSelectedForInfo(info as [String : AnyObject])
//        
//        
//        dismiss(animated: true, completion: nil)
//    }
//    fileprivate func handleImageSelectedForInfo(_ info: [String: AnyObject]) {
//        var selectedImageFromPicker: UIImage?
//        
//        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
//            selectedImageFromPicker = editedImage
//        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
//            
//            selectedImageFromPicker = originalImage
//        }
//        
//        if let selectedImage = selectedImageFromPicker {
//            self.Profile = selectedImage
//            
//        }
//    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TKFadeInAnimator(transitionDuration: 0.5, startingAlpha: 0.8)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

 
  

    /*
     MARK: - Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
      */
}




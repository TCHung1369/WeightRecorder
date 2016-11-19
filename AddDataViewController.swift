//
//  AddDataViewController.swift
//  WeightRecorder
//
//  Created by Tzu_Chen on 19/10/16.
//  Copyright © 2016 Tzu-Chen. All rights reserved.
//

import UIKit
import  CoreData

class AddDataViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

   
    @IBOutlet var myScrollView: UIScrollView!
    @IBOutlet var addImage: UIImageView!
    @IBOutlet var fatRateField: UITextField!
    @IBOutlet var bmiField: UITextField!
    @IBOutlet var weightField: UITextField!
    @IBOutlet var heightField: UITextField!
    @IBOutlet var dateField: UITextField!
    
    //var weightData : WeightData!
    
    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    let dateFomatter = DateFormatter()
    let dateData = Date.init()
    var coreDataHelper : CoreDataHelper?
    
    var addImageData : UIImage?
    let imagePickerController = UIImagePickerController()
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.coreDataHelper = CoreDataHelper()
        self.dateFomatter.dateFormat = "yyyy-MM-dd"
        self.dateField.text = self.dateFomatter.string(from: dateData)
        self.imagePickerController.delegate = self
        
        print("'\(self.myScrollView.frame)")
        self.registerKeyboardNotification()
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func registerKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowUp), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func keyboardWillShowUp(aNotification:Notification){
        print("ketboard")
        let info :Dictionary = aNotification.userInfo!
        let kbSize : NSValue = info["UIKeyboardFrameBeginUserInfoKey"] as! NSValue
        let kbRect = kbSize.cgRectValue.size
        let containEdgeInset : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.height, 0.0)
        self.myScrollView.contentInset = containEdgeInset
        self.myScrollView.scrollIndicatorInsets = containEdgeInset
        //print("'\(self.myScrollView.frame)")
        
    }
    
    func keyboardWillHide(aNotification:Notification){
        print("ketboard end")
        let containEdgeInsets = UIEdgeInsets.zero
        self.myScrollView.contentInset = containEdgeInsets
        self.myScrollView.scrollIndicatorInsets = containEdgeInsets
        
    }
    @IBAction func saveData(_ sender: UIButton) {
        if addImage == nil || fatRateField.text == "" || bmiField.text == "" || weightField.text == "" || heightField.text == "" {
            let  alerController = UIAlertController(title: "注意", message: "請把所有的空格填滿歐", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "確定", style: .default, handler: nil)
            alerController.addAction(alertAction)
            self.present(alerController, animated: true, completion: nil)
        }else{
            
            let moc = self.coreDataHelper?.moc
            
            let weightData = NSEntityDescription.insertNewObject(forEntityName: "WeightRecord", into:moc! ) as! WeightData
            
            weightData.bmiData = Float(self.bmiField.text!)!
            weightData.fatRate = Float(self.fatRateField.text!)!
            weightData.height = Float(self.heightField.text!)!
            weightData.weight = Float(self.weightField.text!)!
            weightData.dateData = self.dateFomatter.date(from: self.dateField.text!)!
            if let image = self.addImage.image{
            weightData.image = UIImagePNGRepresentation(image)!
            }
            
            moc?.insert(weightData)
            //self.appDelegate.saveContext()
            
            self.coreDataHelper?.saveContext()
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        if self.dateField.isFirstResponder{
            self.dateField.resignFirstResponder()
        }

    }

    @IBAction func userChooseImage(_ sender: UIButton) {
        
        
        let alertViewController = UIAlertController(title: "注意", message: "您要選擇照相還是從相簿選呢?", preferredStyle: .alert)
        
        let alertAction1 = UIAlertAction(title: "相機", style: .default) { (alertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true{
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        }
        
        let alertAction2 = UIAlertAction(title: "相簿", style: .default) { (alertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true{
                self.imagePickerController.sourceType = .photoLibrary
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        }
        
        alertViewController.addAction(alertAction1)
        alertViewController.addAction(alertAction2)
        self.present(alertViewController, animated: true, completion: nil)
        
        
}

 
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        
        if textField.tag == 101 {
            
            print("\(self.dateField.isFirstResponder)")
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(self.dateChange), for: .valueChanged)
            textField.inputView = datePicker
            datePicker.backgroundColor = UIColor.clear
            
        }
        
    }
    
    func dateChange(_ sender: UIDatePicker){
      dateFomatter.dateFormat = "yyyy-MM-dd"
     self.dateField.text = dateFomatter.string(from: sender.date)
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func returnTomain(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension AddDataViewController{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
    print("stop shooting")
        picker.dismiss(animated: true) {
            
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            if picker.sourceType == .camera{
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            
            self.addImage.image = image

        }
        
       
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("cancel shooting")

     self.dismiss(animated: true, completion: nil)
    }

}




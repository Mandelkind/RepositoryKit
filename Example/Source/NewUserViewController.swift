//
//  NewUserViewController.swift
//  Example
//
//  Created by Luciano Polit on 19/7/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import UIKit

class NewUserViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var firstName: String {
        guard let text = firstNameTextField.text else {
            return ""
        }
        return text
    }
    
    var lastName: String {
        guard let text = lastNameTextField.text else {
            return ""
        }
        return text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.enabled = false
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = NSString(string: textField.text!).stringByReplacingCharactersInRange(range, withString: string)
        if text.characters.count != 0 {
            var tf: UITextField
            if textField == firstNameTextField {
                tf = lastNameTextField
            } else {
                tf = firstNameTextField
            }
            if tf.text?.characters.count != 0 {
                saveButton.enabled = true
            }
        } else {
            saveButton.enabled = false
        }
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        saveButton.enabled = false
        return true
    }
    
}
//
//  NewUserViewController.swift
//  Example
//
//  Created by Luciano Polit on 19/7/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import UIKit

// MARK: - Main
class NewUserViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    // MARK: - Properties
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
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Text field delegate implementation
extension NewUserViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        if text.characters.count != 0 {
            var tf: UITextField
            if textField == firstNameTextField {
                tf = lastNameTextField
            } else {
                tf = firstNameTextField
            }
            if tf.text?.characters.count != 0 {
                saveButton.isEnabled = true
            }
        } else {
            saveButton.isEnabled = false
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        saveButton.isEnabled = false
        return true
    }
    
}

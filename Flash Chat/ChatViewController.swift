//
//  ChatViewController.swift
//  Flash Chat
//
//  Created by Michael Gimara on 31/03/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //MARK: - Variables
    var user: User!
    var messages = [Message]()
 
    //MARK: - Outlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!

    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = true;
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false;
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;

        configureTableView()
        configureTextView()
        retrieveMessages()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    //MARK: - Custom Methods
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    func configureTableView() {
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: Bundle.main), forCellReuseIdentifier: "customMessageCell")
        
        messageTableView.separatorStyle = .none
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
    func configureTextView() {
        messageTextfield.delegate = self
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            UIView.animate(withDuration: 0.4) {
                self.heightConstraint.constant += keyboardHeight
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    //MARK: - TableView Delegate & DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let messageCell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as? CustomMessageCell {
            
            messageCell.senderUsername.text = messages[indexPath.row].sender
            messageCell.messageBody.text = messages[indexPath.row].messageBody
            messageCell.avatarImageView.image = UIImage(named: "egg")

            if messageCell.senderUsername.text == user.email {
                messageCell.avatarImageView.backgroundColor = UIColor.flatMint()
                messageCell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            } else {
                messageCell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
                messageCell.messageBackground.backgroundColor = UIColor.flatGray()
            }
            
            return messageCell
        }
        
        return UITableViewCell()
    }

    //MARK: - TextField Delegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        UIView.animate(withDuration: 0.4) {
//            self.heightConstraint.constant = 308
//            self.view.layoutIfNeeded()
//        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        UIView.animate(withDuration: 0.4) {
//            self.heightConstraint.constant = 50
//            self.view.layoutIfNeeded()
//        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messageTextfield.endEditing(true)

        return true
    }

    //MARK: - Send & Recieve from Firebase
    func retrieveMessages() {
        let messagesDbRef = Database.database().reference().child("messages")
        messagesDbRef.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            let messageBody = snapshotValue["messageBody"]!
            let sender = snapshotValue["sender"]!
            
            let newMessage = Message(messageBody: messageBody, sender: sender)
            self.messages.append(newMessage)

            DispatchQueue.main.async {
                self.messageTableView.reloadData()
            }
        }
    }

    //MARK: - Actions
    @IBAction func sendPressed(_ sender: AnyObject) {
        let messagesDbRef = Database.database().reference().child("messages")
        
        guard let email = user.email,
              let messageText = messageTextfield.text,
              !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messageDictionary =
        [
            "sender" : email,
            "messageBody" : messageText
        ]
        
        messagesDbRef.childByAutoId().setValue(messageDictionary) { (error, dbRef) in
            self.messageTextfield.text = ""
            self.messageTextfield.isEnabled = true
            self.sendButton.isEnabled = true
            
            if let error = error {
                let alert = UIAlertController(title: "Could not send the message", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Message sent successfully!")
            }
        }
    }

    @IBAction func logOutPressed(_ sender: AnyObject) {
        do {
            try Auth.auth().signOut()
            self.navigationController?.popToRootViewController(animated: true)
        } catch let error {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

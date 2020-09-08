//
//  ViewController.swift
//  qna
//
//  Created by Evergreen Technologies on 9/7/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var documentText: UITextView!
    
    @IBOutlet weak var questionText: UITextView!
    
    @IBOutlet weak var answerText: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setBorderforUIText(documentText)
        setBorderforUIText(questionText)
        setBorderforUIText(answerText)
        documentText.text = "The quick brown fox jumps over the lethargic dog."
        questionText.text = "who jumps over the lethargic dog?"
        
    }
    
    
    func setBorderforUIText(_ textView : UITextView!)
    {
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray.cgColor
        
        
    }

    @IBAction func findAnswerTapped(_ sender: UIButton) {
        
        print("hello world!!!!")
        
    }
    
}


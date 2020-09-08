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
    
     let bert = BERT()
    
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
        let searchText = questionText.text!
        let docText = documentText.text!
        
        answerText.text = "finding aswer. Please wait ....."
        DispatchQueue.global(qos: .userInitiated).async {
            
            let answer = self.bert.findAnswer(for: searchText, in: docText)
            
            DispatchQueue.main.async {
                
                let location = answer.startIndex.utf16Offset(in: docText)
                //let length = answer.endIndex.utf16Offset(in: docText) - location
                
                
                
                
                let start = docText.index(docText.startIndex, offsetBy: location)
                let end = docText.index(docText.endIndex, offsetBy: -1*(docText.count - answer.endIndex.utf16Offset(in: docText)))
                let range = start..<end

                let subStr = docText[range]  // play
                let finalAnswer = String(subStr)
                print(finalAnswer)
                self.answerText.text = finalAnswer
                
                
                
                
            }
            
            
            
            
            
            
            
        }
        
        
        
        
        
    }
    
}


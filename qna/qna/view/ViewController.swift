//
//  ViewController.swift
//  qna
//
//  Created by Evergreen Technologies on 9/7/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var documentText: UITextView!
    
    @IBOutlet weak var questionText: UITextView!
    
    @IBOutlet weak var answerText: UITextView!
    
    @IBOutlet weak var mic: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    let bert = BERT()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setBorderforUIText(documentText)
        setBorderforUIText(questionText)
        setBorderforUIText(answerText)
        //documentText.text = "The quick brown fox jumps over the lethargic dog."
        answerText.isHidden = true
        
        
        documentText.text = "Super Bowl 50 was an American football game to determine the champion of the National Football League (NFL) for the 2015 season. The American Football Conference (AFC) champion Denver Broncos defeated the National Football Conference (NFC) champion Carolina Panthers 24 times to earn their third Super Bowl title. The game was played on February 7, 2016, at Levi's Stadium in the San Francisco Bay Area at Santa Clara, California. As this was the 50th Super Bowl, the league emphasized the golden anniversary with various gold-themed initiatives, as well as temporarily suspending the tradition of naming each Super Bowl game with Roman numerals under which the game would have been known as Super Bowl , so that the logo could prominently feature the Arabic numerals 50."
        
        
        //questionText.text = "who jumps over the lethargic dog?"
        
        questionText.text = "Speak a question or type a question?"
        
        mic.isEnabled = false
        mic.setTitle("Start Speaking Question", for: .normal)
        
        speechRecognizer?.delegate = self
        requestSpeechAuthorization()
        
        
    }
    
    
    func requestSpeechAuthorization()
    {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            @unknown default:
                isButtonEnabled = false
                print("Unknown auth status")
            }
            
            OperationQueue.main.addOperation() {
                self.mic.isEnabled = isButtonEnabled
            }
        }
        
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
                let length = answer.endIndex.utf16Offset(in: docText) - location
                let answerRange = NSRange(location: location, length: length)
                
                
                
                let start = docText.index(docText.startIndex, offsetBy: location)
                let end = docText.index(docText.endIndex, offsetBy: -1*(docText.count - answer.endIndex.utf16Offset(in: docText)))
                let range = start..<end

                let subStr = docText[range]  // play
                let finalAnswer = String(subStr)
                print(finalAnswer)
                self.answerText.text = finalAnswer
                self.utterText(finalAnswer)
                self.highlightAnswer(answerRange: answerRange)
        
                
                
                
            }
            
            
            
            
            
            
            
        }
        
        
        
        
        
    }
    
    
    @IBAction func micPressed(_ sender: UIButton) {
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            mic.isEnabled = false
            mic.setTitle("Start Speaking Question", for: .normal)
        } else {
            startSpeechRecognition()
            mic.setTitle("Stop Speaking Question", for: .normal)
        }
        
    }
    
    
    
    
    
    func utterText(_ utterenceStr : String)
    {
          let utterance = AVSpeechUtterance(string: utterenceStr)
          utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
          let synth = AVSpeechSynthesizer()
          synth.speak(utterance)
        
        
    }
    
    
    func highlightAnswer(answerRange: NSRange)
    {
        let semiTextColor = documentText.textColor!
        let helveticaNeue17 = UIFont(name: "HelveticaNeue", size: 17)!
        let bodyFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: helveticaNeue17)
        let fullTextColor = UIColor.yellow
        let mutableAttributedText = NSMutableAttributedString(string: self.documentText.text,
        attributes: [.foregroundColor: semiTextColor,
                     .font: bodyFont])
        
        mutableAttributedText.addAttributes([.backgroundColor: fullTextColor],
        range: answerRange)
        self.documentText.attributedText = mutableAttributedText
        
        
        
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            mic.isEnabled = true
        } else {
            mic.isEnabled = false
        }
    }
    
    func startSpeechRecognition()
    {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.questionText.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.mic.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        self.questionText.text = "Say something, I'm listening!"
        
    }
    
    
}


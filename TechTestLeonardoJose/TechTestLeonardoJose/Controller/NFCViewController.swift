//
//  NFCViewController.swift
//  TechTestLeonardoJose
//
//  Created by Leonardo Jose Gunawan on 22/05/24.
//

import UIKit
import CoreNFC

class NFCViewController: UIViewController {

    @IBOutlet var NFCText: UITextView!
    
    var nfcSession: NFCNDEFReaderSession?
    var word = "None"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func ScanBtn(_ sender: Any) {
        startNFCSession()
    }
    
    func startNFCSession() {
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
    }
    
}

extension NFCViewController: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("The Session Was Invalidated: \(error.localizedDescription)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var result = ""
        for payload in messages[0].records {
            result += String.init(data: payload.payload.advanced(by: 3), encoding: .utf8) ?? "Formate Not Supported"
        }
        DispatchQueue.main.async {
            self.NFCText.text = result
        }
    }
}

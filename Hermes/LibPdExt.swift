//
//  LibPdExt.swift
//  Hermes-Swift
//
//  Created by Lance Jabr on 10/24/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

import Foundation

enum PdAudioStatusSwift : Int {
    case OK = 0, Error = -1, Changed = 1
}

extension PdFile {
    
    func sendBang(toReceiver receiver: String) {
        PdBase.sendBangToReceiver(String(self.dollarZero) + "-" + receiver)
    }
    
    func sendMessage(message: String, withArguments arguments: [AnyObject], toReceiver receiver: String) {
        PdBase.sendMessage(message, withArguments: arguments, toReceiver: String(self.dollarZero) + "-" + receiver)
    }
    
    func sendList(list: [AnyObject], toReceiver receiver: String) {
        PdBase.sendList(list, toReceiver: String(self.dollarZero) + "-" + receiver)
    }
    
    func sendSymbol(symbol: String, toReceiver receiver: String)  {
        PdBase.sendSymbol(symbol, toReceiver: String(self.dollarZero) + "-" + receiver)
    }
    
    func sendFloat(float: Float, toReceiver receiver: String)  {
        PdBase.sendFloat(float, toReceiver: String(self.dollarZero) + "-" + receiver)
        
    }
    
}
//
//  LibPdExt.swift
//  Hermes-Swift
//
//  Created by Lance Jabr on 10/24/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

import Foundation

enum PdAudioStatusSwift : Int {
    case ok = 0, error = -1, changed = 1
}

extension PdFile {
    
    func sendBang(toReceiver receiver: String) {
        PdBase.sendBang(toReceiver: String(self.dollarZero) + "-" + receiver)
    }
    
    func sendMessage(_ message: String, withArguments arguments: [Any], toReceiver receiver: String) {
        PdBase.sendMessage(message, withArguments: arguments, toReceiver: String(self.dollarZero) + "-" + receiver)
    }
    
    func sendList(_ list: [Any], toReceiver receiver: String) {
        PdBase.sendList(list, toReceiver: String(self.dollarZero) + "-" + receiver)
    }
    
    func sendSymbol(_ symbol: String, toReceiver receiver: String)  {
        PdBase.sendSymbol(symbol, toReceiver: String(self.dollarZero) + "-" + receiver)
    }
    
    func sendFloat(_ float: Float, toReceiver receiver: String)  {
        PdBase.send(float, toReceiver: String(self.dollarZero) + "-" + receiver)
        
    }
    
}

//
//  Error.swift
//  Bark
//
//  Created by Digit on 11/27/21.
//

import Foundation

enum BarkErrorType: Error {
    case uploadFailed
    case noShortCodeGiven
    case noValidFileFound
}

func translateError(errorValue: BarkErrorType) -> String {
    switch errorValue {
    case .uploadFailed:
        return "Upload failed."
    case .noShortCodeGiven:
        return "No short code found in response."
    case .noValidFileFound:
        return "Cannot use this extentsion here."
    }
}


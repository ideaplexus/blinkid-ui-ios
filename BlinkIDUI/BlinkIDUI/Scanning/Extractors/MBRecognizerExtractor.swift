//
//  MBRecognizerExtractor.swift
//  Showcase
//
//  Created by Dominik Cubelic on 30/07/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import Foundation
import MicroBlink

protocol MBFieldResult {
    func extractFieldResults() -> NSArray
    var resultTitle: String { get }
}

extension MBFieldResult {
    var resultTitle: String {
        guard let results = extractFieldResults() as? [MBField] else { return "" }
        let firstName = results.first(where: { $0.key == .firstName })?.value ?? ""
        let lastName = results.first(where: { $0.key == .lastName })?.value ?? ""
        return "\(firstName) \(lastName)"
    }
}

extension MBRecognizer: MBFieldResult {

    @objc func extractFieldResults() -> NSArray {
        print("\(self.self) doesn't override extractFieldResults method.")
        return NSArray()
    }

    func setupRecognizer() {
        if let self = self as? MBPdf417Recognizer {
            self.scanUncertain = true
        }

        if let self = self as? MBMrtdRecognizer {
            self.allowUnverifiedResults = true
        }

        if let self = self as? MBFullDocumentImage {
            self.returnFullDocumentImage = true
        }

        if let self = self as? MBSignatureImage {
            self.returnSignatureImage = true
        }

        if let self = self as? MBFaceImage {
            self.returnFaceImage = true
        }

    }

}

extension MBMrtdRecognizer {
    override func extractFieldResults() -> NSArray {
        return result.mrzResult.extractFieldResults()
    }
}

extension MBMrzResult {
    func extractFieldResults() -> NSArray {
        let fields = NSMutableArray()

        fields.add(MBField(key: MBFieldKey.issuer, value: issuer))
        fields.add(MBField(key: MBFieldKey.documentNumber, value: documentNumber))
        fields.add(MBField(key: MBFieldKey.documentCode, value: documentCode))
        fields.add(MBField(key: MBFieldKey.dateOfExpiry, value: dateOfExpiry))
        fields.add(MBField(key: MBFieldKey.primaryId, value: primaryID))
        fields.add(MBField(key: MBFieldKey.secondaryId, value: secondaryID))
        fields.add(MBField(key: MBFieldKey.dateOfBirth, value: dateOfBirth))
        fields.add(MBField(key: MBFieldKey.nationality, value: nationality))
        fields.add(MBField(key: MBFieldKey.sex, value: gender))
        fields.add(MBField(key: MBFieldKey.optional1, value: opt1))
        fields.add(MBField(key: MBFieldKey.optional2, value: opt2))
        fields.add(MBField(key: MBFieldKey.alienNumber, value: alienNumber))
        fields.add(MBField(key: MBFieldKey.applicationReceiptNumber, value: applicationReceiptNumber))
        fields.add(MBField(key: MBFieldKey.immigrantCaseNumber, value: immigrantCaseNumber))
        fields.add(MBField(key: MBFieldKey.mrzText, value: mrzText))

        return fields
    }
}

extension MBLegacyMRTDRecognizerResult {
    func extractFieldResults() -> NSArray {
        let fields = NSMutableArray()

        fields.add(MBField(key: MBFieldKey.issuer, value: issuer))
        fields.add(MBField(key: MBFieldKey.documentNumber, value: documentNumber))
        fields.add(MBField(key: MBFieldKey.documentCode, value: documentCode))
        fields.add(MBField(key: MBFieldKey.dateOfExpiry, value: dateOfExpiry?.stringDate(withRawDate: rawDateOfExpiry)))
        fields.add(MBField(key: MBFieldKey.primaryId, value: primaryId))
        fields.add(MBField(key: MBFieldKey.secondaryId, value: secondaryId))
        fields.add(MBField(key: MBFieldKey.dateOfBirth, value: dateOfBirth))
        fields.add(MBField(key: MBFieldKey.nationality, value: nationality))
        fields.add(MBField(key: MBFieldKey.sex, value: sex))
        fields.add(MBField(key: MBFieldKey.optional1, value: opt1))
        fields.add(MBField(key: MBFieldKey.optional2, value: opt2))
        fields.add(MBField(key: MBFieldKey.mrzText, value: mrzText))
        fields.add(MBField(key: MBFieldKey.mrzParsed, value: mrzParsed))
        fields.add(MBField(key: MBFieldKey.mrtdVerified, value: mrzVerified))

        return fields
    }
}
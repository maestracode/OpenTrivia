//
//  Extensions.swift
//  OpenTrivia
//
//  Created by omaestra on 05/09/2018.
//  Copyright © 2018 Oswaldo Maestra. All rights reserved.
//

import Foundation
import UIKit

/**
 Extend array to enable random shuffling
 */
extension Array {
    /**
     Randomizes the order of an array's elements
     */
    mutating func shuffle() {
        for _ in 0..<count {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}

extension String {
    /**
     Convert given HTML string into an Attributed string. This way we can read HTML format and apply it to strings.
     */
    func decodeHtml() -> NSAttributedString {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        
        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
        ]
        do {
            return try NSAttributedString(data: data, options: attributedOptions, documentAttributes: nil)
        } catch (let error) {
            print("[ERROR]: Error trying to decode HTML formatted text -> \(error)")
            return NSAttributedString()
        }
    }
}

extension NSAttributedString {
    
    public convenience init?(HTMLString html: String, attributes: [NSAttributedStringKey : Any]?) throws {
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] =
            [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
             NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue]
        
        guard let data = html.data(using: .utf8, allowLossyConversion: true) else {
            throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
        }
        
        if let attributes = attributes {
            guard let attr = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else {
                throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
            }
            
            attr.setAttributes(attributes, range: NSRange(location: 0, length: attr.length))
            self.init(attributedString: attr)
        } else {
            try? self.init(data: data, options: options, documentAttributes: nil)
        }
    }
    
    /**
     NSAttributedString extension with convenience initializer.
     Enumerates through the attributed string (HTML document) font attributes, and replaces with the provided UIFont.
     Preserves original HTML font sizes, or uses font-size from provided UIFont, @see useDocumentFontSize parameter.
     This method can simply convert HTML to NSAttributedString, without the overload of manipulating with fonts, just skip the font parameter, @see guard statement
     */
    convenience init(htmlString html: String, font: UIFont? = nil, useDocumentFontSize: Bool = true) throws {
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        let data = html.data(using: .utf8, allowLossyConversion: true)
        guard (data != nil), let fontFamily = font?.familyName, let attr = try? NSMutableAttributedString(data: data!, options: options, documentAttributes: nil) else {
            try self.init(data: data ?? Data(html.utf8), options: options, documentAttributes: nil)
            return
        }
        
        let fontSize: CGFloat? = useDocumentFontSize ? nil : font!.pointSize
        let range = NSRange(location: 0, length: attr.length)
        attr.enumerateAttribute(.font, in: range, options: .longestEffectiveRangeNotRequired) { attrib, range, _ in
            if let htmlFont = attrib as? UIFont {
                let traits = htmlFont.fontDescriptor.symbolicTraits
                var descrip = htmlFont.fontDescriptor.withFamily(fontFamily)
                
                if (traits.rawValue & UIFontDescriptorSymbolicTraits.traitBold.rawValue) != 0 {
                    if let traitBold = descrip.withSymbolicTraits(.traitBold) {
                        descrip = traitBold
                    }
                }
                
                if (traits.rawValue & UIFontDescriptorSymbolicTraits.traitItalic.rawValue) != 0 {
                    if let trailtItalic = descrip.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic) {
                        descrip = trailtItalic
                    }
                }
                
                attr.addAttribute(.font, value: UIFont(descriptor: descrip, size: fontSize ?? htmlFont.pointSize), range: range)
            }
        }
        
        self.init(attributedString: attr)
    }
}

extension UINavigationBar {
    func transparentNavigationBar() {
        self.shadowImage = UIImage()
        self.isTranslucent = true
        self.setBackgroundImage(UIImage(), for: .default)
    }
}

extension UIToolbar {
    func transparentToolbar() {
        self.setShadowImage(UIImage(), forToolbarPosition: .any)
        self.isTranslucent = true
        self.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    }
}

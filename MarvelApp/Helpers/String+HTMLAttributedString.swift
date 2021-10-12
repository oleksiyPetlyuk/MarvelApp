//
//  String+HTMLAttributedString.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 08.10.2021.
//

import Foundation
import CoreGraphics
import UIKit

extension String {
  func htmlAttributedString(size: CGFloat) -> NSAttributedString? {
    // swiftlint:disable indentation_width
    let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
              body {
                font-family: -apple-system;
                font-size: \(size)px;
              }
            </style>
          </head>
          <body>
            \(self)
          </body>
        </html>
        """
    // swiftlint:enable indentation_width

    guard let data = htmlTemplate.data(using: .utf8) else {
      return nil
    }

    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ]

    guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
      return nil
    }

    return attributedString
  }
}

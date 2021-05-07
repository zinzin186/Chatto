/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import Foundation
import UIKit
import Chatto
import CoreLocation
import AVFoundation
import Chatto
import ChattoAdditions

class MKMesssageModel: ChatItemProtocol, MessageType {
    let uid: String
    let type: String = MKMesssageModel.chatItemType
    let date: String
    var messageId: String
    var sender: SenderType {
        return user
    }
    var sentDate: Date
    var kind: MessageKind

    var user: MockUser

    static var chatItemType: ChatItemType {
        return "TimeSeparatorModel"
    }

    private init(kind: MessageKind, user: MockUser, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.uid = messageId
        self.sentDate = date
        self.date = self.sentDate.toWeekDayAndDateString()
    }
    
    convenience init(custom: Any?, user: MockUser, messageId: String, date: Date) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
    }

    convenience init(text: String, user: MockUser, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }

    convenience init(attributedText: NSAttributedString, user: MockUser, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date)
    }

    convenience init(image: UIImage, user: MockUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }

    convenience init(imageURL: URL, user: MockUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(imageURL: imageURL)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }

    convenience init(thumbnail: UIImage, user: MockUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
    }

    convenience init(emoji: String, user: MockUser, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date)
    }

    convenience init(contact: MockContactItem, user: MockUser, messageId: String, date: Date) {
        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date)
    }

    convenience init(linkItem: LinkItem, user: MockUser, messageId: String, date: Date) {
        self.init(kind: .linkPreview(linkItem), user: user, messageId: messageId, date: date)
    }
    
}

extension Date {
    // Have a time stamp formatter to avoid keep creating new ones. This improves performance
    private static let weekdayAndDateStampDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "EEEE, MMM dd yyyy" // "Monday, Mar 7 2016"
        return dateFormatter
    }()

    func toWeekDayAndDateString() -> String {
        return Date.weekdayAndDateStampDateFormatter.string(from: self)
    }
}

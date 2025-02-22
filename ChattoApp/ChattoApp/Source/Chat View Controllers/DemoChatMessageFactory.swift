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
import Chatto
import ChattoAdditions

class DemoChatMessageFactory {
    private static let demoText =
        "Lorem ipsum dolor sit amet 😇, https://github.com/badoo/Chatto consectetur adipiscing elit , sed do eiusmod tempor incididunt 07400000000 📞 ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore https://github.com/badoo/Chatto eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat 07400000000 non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

    class func makeRandomMessage(_ uid: String) -> MessageModelProtocol {
        let isIncoming: Bool = arc4random_uniform(100) % 2 == 0
        return self.makeRandomMessage(uid, isIncoming: isIncoming)
    }

    class func makeRandomMessage(_ uid: String, isIncoming: Bool) -> MessageModelProtocol {
        if arc4random_uniform(100) % 2 == 0 {
            return self.makeRandomTextMessage(uid, isIncoming: isIncoming)
        } else {
//            return self.makeCompoundMessage(isIncoming: true)
            return self.makeRandomPhotoMessage(uid, isIncoming: isIncoming)
        }
    }

    class func makeTextMessage(_ uid: String, text: String, isIncoming: Bool) -> DemoTextMessageModel {
        let messageModel = self.makeMessageModel(uid, isIncoming: isIncoming, type: TextMessageModel<MessageModel>.chatItemType)
        let textMessageModel = DemoTextMessageModel(messageModel: messageModel, text: text)
        return textMessageModel
    }

    class func makePhotoMessage(_ uid: String, image: UIImage, size: CGSize, isIncoming: Bool) -> DemoPhotoMessageModel {
        let messageModel = self.makeMessageModel(uid, isIncoming: isIncoming, type: PhotoMessageModel<MessageModel>.chatItemType)
        let photoMessageModel = DemoPhotoMessageModel(messageModel: messageModel, imageSize: size, image: image)
        return photoMessageModel
    }

    static func makeCompoundMessage(uid: String = UUID().uuidString,
                                    text: String? = nil,
                                    imageName: String? = nil,
                                    emoji: String? = nil,
                                    isIncoming: Bool) -> DemoCompoundMessageModel {
        let messageModel = self.makeMessageModel(uid,
                                                 isIncoming: isIncoming,
                                                 type: .compoundItemType)
        let text = text ?? (isIncoming ? "Hello, how are you" : "I'm good, thanks, how about yourself?")
        let imageName = imageName ?? (isIncoming ? "pic-test-1" : "pic-test-2")
        let image = UIImage(named: imageName)!
        return DemoCompoundMessageModel(text: text,
                                        image: image,
                                        showInvisibleSplitter: false,
                                        text2: nil,
                                        emoji: emoji,
                                        messageModel: messageModel)
    }

    static func makeCompoundMessage2(isIncoming: Bool,
                                     text: String? = nil,
                                     imageName: String? = nil,
                                     showInvisibleSplitter: Bool = false,
                                     text2: String? = nil) -> DemoCompoundMessageModel {
        let messageModel = self.makeMessageModel(UUID().uuidString,
                                                 isIncoming: isIncoming,
                                                 type: .compoundItemType2,
                                                 status: .success)
        return DemoCompoundMessageModel(text: text,
                                        image: imageName.flatMap(UIImage.init(named:)),
                                        showInvisibleSplitter: showInvisibleSplitter,
                                        text2: text2,
                                        emoji: nil,
                                        messageModel: messageModel)
    }

    private class func makeRandomTextMessage(_ uid: String, isIncoming: Bool) -> DemoTextMessageModel {
        let incomingText: String = isIncoming ? "incoming" : "outgoing"
        let maxText = self.demoText
        let length: Int = 10 + Int(arc4random_uniform(300))
        let text = "\(String(maxText[..<maxText.index(maxText.startIndex, offsetBy: length)]))\n\n\(incomingText)\n#\(uid)"
        return self.makeTextMessage(uid, text: text, isIncoming: isIncoming)
    }

    private class func makeRandomPhotoMessage(_ uid: String, isIncoming: Bool) -> DemoPhotoMessageModel {
        var imageSize = CGSize.zero
        switch arc4random_uniform(100) % 3 {
        case 0:
            imageSize = CGSize(width: 400, height: 300)
        case 1:
            imageSize = CGSize(width: 300, height: 400)
        default:
            imageSize = CGSize(width: 300, height: 300)
        }

        var imageName: String
        switch arc4random_uniform(100) % 3 {
        case 0:
            imageName = "pic-test-1"
        case 1:
            imageName = "pic-test-2"
        default:
            imageName = "pic-test-3"
        }
        return self.makePhotoMessage(uid, image: UIImage(named: imageName)!, size: imageSize, isIncoming: isIncoming)
    }

    private class func makeMessageModel(_ uid: String, isIncoming: Bool, type: String, status: MessageStatus? = nil) -> MessageModel {
        let senderId = isIncoming ? "1" : "2"
        let messageStatus: MessageStatus = {
            guard !isIncoming else { return .success }
            guard let status = status else { return (arc4random_uniform(100) % 3 == 0) ? .success : .failed }
            return status
        }()
        return MessageModel(
            uid: uid,
            senderId: senderId,
            type: type,
            isIncoming: isIncoming,
            date: Date(),
            status: messageStatus,
            canReply: true
        )
    }
}

extension TextMessageModel {
    static var chatItemType: ChatItemType {
        return "text"
    }
}

extension PhotoMessageModel {
    static var chatItemType: ChatItemType {
        return "photo"
    }
}

extension ChatItemType {
    static var compoundItemType = "compound"
    static var compoundItemType2 = "compound2"
}

extension DemoChatMessageFactory {

    private enum DemoMessage {
        case text(String)
        case image(String)
    }

    private static let overviewMessages: [DemoMessage] = [
        .text("Welcome to Chatto! A lightweight Swift framework to build chat apps"),
        .text("It calculates sizes in the background for smooth pagination and rotation, and it can deal with thousands of messages with a sliding data source"),
        .text("Along with Chatto there's ChattoAdditions, with bubbles and the input component"),
        .text("This is a TextMessageCollectionViewCell. It uses UITextView with data detectors so you can interact with urls: https://github.com/badoo/Chatto, phone numbers: 07400000000, dates: 3 jan 2016 and others"),
        .image("pic-test-1"),
        .image("pic-test-2"),
        .image("pic-test-3"),
        .text("Those were some PhotoMessageCollectionViewCell. With some fake data transfer"),
        .text("Both Text and Photo cells inherit from BaseMessageCollectionViewCell which adds support for a failed icon and a timestamp you can reveal by swiping from the right"),
        .text("Each message is paired with a Presenter. Each presenter is responsible to present a message by managing a corresponding UICollectionViewCell. New types of messages can be easily added by creating new types of presenters!"),
        .text("Messages have different margins and only some bubbles show a tail. This is done with a decorator that conforms to ChatItemsDecoratorProtocol"),
        .text("Failed/sending status are completly separated cells. This helps to keep cells them simpler. They are generated with the decorator as well, but other approaches are possible, like being returned by the DataSource or using more complex cells"),
        .text("More info on https://github.com/badoo/Chatto. We are waiting for your pull requests!")
    ]

    private static func messages(fromDemoMessages demoMessages: [DemoMessage]) -> [MessageModelProtocol] {
        return demoMessages.map { (demoMessage) in
            let isIncoming: Bool = arc4random_uniform(100) % 2 == 0
            switch demoMessage {
            case .text(let text):
                return DemoChatMessageFactory.makeTextMessage(NSUUID().uuidString, text: text, isIncoming: isIncoming)
            case .image(let name):
                let image = UIImage(named: name)!
                return DemoChatMessageFactory.makePhotoMessage(NSUUID().uuidString, image: image, size: image.size, isIncoming: isIncoming)
            }
        }
    }

    static func makeOverviewMessages() -> [MessageModelProtocol] {
        return self.messages(fromDemoMessages: self.overviewMessages)
    }

    static func makeMessagesForCompoundMessageExamples() -> [MessageModelProtocol] {
        return [
            self.makeCompoundMessage(isIncoming: true),
            self.makeCompoundMessage(isIncoming: false),
            self.makeCompoundMessage(isIncoming: true),
            self.makeCompoundMessage(isIncoming: false),
            self.makeCompoundMessage(isIncoming: true),
            self.makeCompoundMessage(emoji: "😍", isIncoming: true),
            self.makeCompoundMessage(isIncoming: false),
            self.makeCompoundMessage(emoji: "👍", isIncoming: false)
        ].reversed()
    }

    static func makeMessagesForCompoundMessageLayout() -> [MessageModelProtocol] {
        return [
            self.makeCompoundMessage2(
                isIncoming: true,
                text: "It's just a text content block affected by compound bubble insets. And the next message is an image content block ignoring bubble's insets."
            ),
            self.makeCompoundMessage2(
                isIncoming: false,
                imageName: "pic-test-2"
            ),
            self.makeCompoundMessage2(
                isIncoming: true,
                text: "There are both text and image content blocks in one message.",
                imageName: "pic-test-2",
                text2: "And this is how it works if the text content block goes after the image."
            ),
            self.makeCompoundMessage2(
                isIncoming: false,
                text: "There are two text content blocks in one message.",
                text2: "And it's important that content inset isn't doubled between them."
            ),
            self.makeCompoundMessage2(
                isIncoming: true,
                text: "But it's needed to be doubled,",
                showInvisibleSplitter: true,
                text2: "you can use a special invisible splitter content block between them."
            )
        ].reversed()
    }

    private static let messagesSelectionMessages: [DemoMessage] = [
        .text("Now you have an ability to select chat messages"),
        .text("Press \"Select\" to enter selection mode"),
        .text("Press \"Cancel\" to exit selection mode"),
        .text("In selection mode all interactions with bubbles are disabled"),
        .text("A message can be selected or deselected by tapping on a message cell")
    ]

    static func makeMessagesSelectionMessages() -> [MessageModelProtocol] {
        return self.messages(fromDemoMessages: self.messagesSelectionMessages)
    }
}

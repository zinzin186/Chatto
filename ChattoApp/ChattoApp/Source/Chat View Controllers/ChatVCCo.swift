//
// The MIT License (MIT)
//
// Copyright (c) 2015-present Badoo Trading Limited.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation
import MapKit
import UIKit
import Chatto
import ChattoAdditions

var now = Date()

extension DemoChatViewController: MessagesDataSource {
    public func currentSender() -> SenderType {
        return SampleData.shared.currentSender
    }
    
    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        if let item = self.chatItemCompanionCollection[indexPath.item].chatItem as? DemoTextMessageModel {
            let text = item.text
            return MockMessage(text: text, user: SampleData.shared.currentSender, messageId: UUID().uuidString, date: dateAddingRandomTime())
        }
        return MockMessage(text: "randomSentence sfsdfds dsfdsfdsfs sfđsfsdf fsdfdsfsdf fdsfdsfsd fsdfsdfsdf fsdfsdfsdf fff", user: SampleData.shared.currentSender, messageId: UUID().uuidString, date: dateAddingRandomTime())
    }
    
    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    // Rotation
    func dateAddingRandomTime() -> Date {
        let randomNumber = Int(arc4random_uniform(UInt32(10)))
        if randomNumber % 2 == 0 {
            let date = Calendar.current.date(byAdding: .hour, value: randomNumber, to: now)!
            now = date
            return date
        } else {
            let randomMinute = Int(arc4random_uniform(UInt32(59)))
            let date = Calendar.current.date(byAdding: .minute, value: randomMinute, to: now)!
            now = date
            return date
        }
    }
    
}

extension DemoChatViewController: MessageCellDelegate {
    public func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    public func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    public func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
    }
    
    public func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    public func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    public func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    public func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }

   

}

// MARK: - MessageLabelDelegate

extension DemoChatViewController: MessageLabelDelegate {
    public func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    public func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    public func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    public func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    public func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }

    public func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }

    public func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }

    public func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }
}

extension DemoChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    public func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue : .darkText
    }
    
    public func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    public func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    public func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .yellow : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    public func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    public func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
    }

    public func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
//            imageView.kf.setImage(with: imageURL)
//        } else {
//            imageView.kf.cancelDownloadTask()
//        }
    }
    
    // MARK: - Location Messages
    
   
    // MARK: - Audio Message

}

// MARK: - MessagesLayoutDelegate

extension DemoChatViewController: MessagesLayoutDelegate {
    
    public func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    public func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    public func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    public func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}

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

import UIKit

extension BaseChatViewController: ChatCollectionViewLayoutDelegate, UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chatItemCompanionCollection.count
    }

//    @objc(collectionView:cellForItemAtIndexPath:)
//    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let presenter = self.presenterForIndexPath(indexPath)
//        let cell = presenter.dequeueCell(collectionView: collectionView, indexPath: indexPath)
//        let decorationAttributes = self.decorationAttributesForIndexPath(indexPath)
//        presenter.configureCell(cell, decorationAttributes: decorationAttributes)
////        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell123", for: indexPath)
////        cell.backgroundColor = .red
////        return cell
//    }
    @objc(collectionView:cellForItemAtIndexPath:)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let presenter = self.presenterForIndexPath(indexPath)
        let cell = presenter.dequeueCell(collectionView: collectionView, indexPath: indexPath)
        let decorationAttributes = self.decorationAttributesForIndexPath(indexPath)
        presenter.configureCell(cell, decorationAttributes: decorationAttributes)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let messagesFlowLayout = collectionViewLayout as? MessagesCollectionViewFlowLayout else { return .zero }
        return messagesFlowLayout.sizeForItem(at: indexPath)
    }

//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//
//        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
//            fatalError(MessageKitError.notMessagesCollectionView)
//        }
//        guard let layoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
//            fatalError(MessageKitError.nilMessagesLayoutDelegate)
//        }
//
//        return layoutDelegate.headerViewSize(for: section, in: messagesCollectionView)
//    }

//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
//            fatalError(MessageKitError.notMessagesCollectionView)
//        }
//        guard let layoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
//            fatalError(MessageKitError.nilMessagesLayoutDelegate)
//        }
//        
//        return layoutDelegate.footerViewSize(for: section, in: messagesCollectionView)
//    }

   

    
    @objc(collectionView:didEndDisplayingCell:forItemAtIndexPath:)
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Carefull: this index path can refer to old data source after an update. Don't use it to grab items from the model
        // Instead let's use a mapping presenter <--> cell
        if let oldPresenterForCell = self.presentersByCell.object(forKey: cell) as? ChatItemPresenterProtocol {
            self.presentersByCell.removeObject(forKey: cell)
            oldPresenterForCell.cellWasHidden(cell)
        }

        if self.updatesConfig.fastUpdates {
            if let visibleCell = self.visibleCells[indexPath], visibleCell === cell {
                self.visibleCells[indexPath] = nil
            } else {
                self.visibleCells.forEach({ (indexPath, storedCell) in
                    if cell === storedCell {
                        // Inconsistency found, likely due to very fast updates
                        self.visibleCells[indexPath] = nil
                    }
                })
            }
        }
    }

    @objc(collectionView:willDisplayCell:forItemAtIndexPath:)
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Here indexPath should always referer to updated data source.

        let presenter = self.presenterForIndexPath(indexPath)
        self.presentersByCell.setObject(presenter, forKey: cell)
        if self.updatesConfig.fastUpdates {
            self.visibleCells[indexPath] = cell
        }

        if self.isAdjustingInputContainer {
            UIView.performWithoutAnimation({
                // See https://github.com/badoo/Chatto/issues/133
                presenter.cellWillBeShown(cell)
                cell.layoutIfNeeded()
            })
        } else {
            presenter.cellWillBeShown(cell)
        }
    }

    @objc(collectionView:shouldShowMenuForItemAtIndexPath:)
    open func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath?) -> Bool {
        // Note: IndexPath set optional due to https://github.com/badoo/Chatto/issues/310
        // Might be related: https://bugs.swift.org/browse/SR-2417
        guard let indexPath = indexPath else { return false }
        return self.presenterForIndexPath(indexPath).shouldShowMenu()
    }

    @objc(collectionView:canPerformAction:forItemAtIndexPath:withSender:)
    open func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath?, withSender sender: Any?) -> Bool {
        // Note: IndexPath set optional due to https://github.com/badoo/Chatto/issues/247. SR-2417 might be related
        // Might be related: https://bugs.swift.org/browse/SR-2417
        guard let indexPath = indexPath else { return false }
        return self.presenterForIndexPath(indexPath).canPerformMenuControllerAction(action)
    }

    @objc(collectionView:performAction:forItemAtIndexPath:withSender:)
    open func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        self.presenterForIndexPath(indexPath).performMenuControllerAction(action)
    }

    func presenterForIndexPath(_ indexPath: IndexPath) -> ChatItemPresenterProtocol {
        return self.presenterForIndex(indexPath.item, chatItemCompanionCollection: self.chatItemCompanionCollection)
    }

    func presenterForIndex(_ index: Int, chatItemCompanionCollection items: ChatItemCompanionCollection) -> ChatItemPresenterProtocol {
        guard index < items.count else {
            // This can happen from didEndDisplayingCell if we reloaded with less messages
            return DummyChatItemPresenter()
        }
        return items[index].presenter
    }

    public func createPresenterForChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        assert(self.presenterFactory != nil, "Presenter factory is not initialized")
        return self.presenterFactory.createChatItemPresenter(chatItem)
    }

    public func confugureCollectionViewWithPresenters() {
        assert(self.presenterFactory == nil, "Presenter factory is already initialized")
        guard let collectionView = self.collectionView else {
            assertionFailure("CollectionView is not initialized")
            return
        }
        self.presenterFactory = self.createPresenterFactory()
        self.presenterFactory.configure(withCollectionView: collectionView )
    }

    public func decorationAttributesForIndexPath(_ indexPath: IndexPath) -> ChatItemDecorationAttributesProtocol? {
        return self.chatItemCompanionCollection[indexPath.item].decorationAttributes
    }
}

//
//  RxCollectionViewSectionedAnimatedDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

public class RxCollectionViewSectionedAnimatedDataSource<S: AnimatableSectionModelType>
    : CollectionViewSectionedDataSource<S>
    , RxCollectionViewDataSourceType {
    public typealias Element = [Changeset<S>]
    public typealias ItemType = S.Item.Identity

    public var animationConfiguration: AnimationConfiguration? = nil
    
    // For some inexplicable reason, when doing animated updates first time
    // it crashes. Still need to figure out that one.
    var set = false

    public override init() {
        super.init()
    }
    
    public func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, element in
            for c in element {
                if !dataSource.set {
                    dataSource.setSections(c.finalSections)
                    collectionView.reloadData()
                    dataSource.set = true
                    return
                }
                dataSource.setSections(c.finalSections)
                collectionView.performBatchUpdates(c, animationConfiguration: self.animationConfiguration)
            }

        }.on(observedEvent)
    }
    
    override public func modelAtIndexPath(indexPath: NSIndexPath) throws -> Any {
        let model = itemAtIndexPath(indexPath)
        if let m = model as? IdentifiableValue<ItemType> {
            return m.value
        } else {
            return model
        }
    }
}
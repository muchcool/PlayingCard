//
//  CardBehavior.swift
//  PlayingCard
//
//  Created by QM H on 2020/8/7.
//  Copyright © 2020年 SCS. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    lazy var collisionBehavior: UICollisionBehavior = {//第二步添加Behavior
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        //animator.addBehavior(behavior)//移动到init里了
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false//不希望东西转动
        behavior.elasticity = 1.0//碰撞不会失去任何能量,大于时会获得能量会快起来,反之会慢下来
        behavior.resistance = 0//施加在它上面的力量,不想要任何抵抗
        //animator.addBehavior(behavior)//移动到init里了
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem){
//        let push = UIPushBehavior(items: [cardView], mode: .instantaneous)//改成item
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = CGFloat(Int(2 * CGFloat.pi).arc4random)
        push.magnitude = CGFloat(1.0) + CGFloat(Int(CGFloat(2.0)).arc4random)
        push.action = { [unowned push, weak self] in
            //push.dynamicAnimator?.removeBehavior(push)
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
        //animator.addBehavior(push)//移动到里了
    }
    
    func addItem(_ item: UIDynamicItem){
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem){
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init(){
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator){
        self.init()
        animator.addBehavior(self)
    }
}

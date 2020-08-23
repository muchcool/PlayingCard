//
//  ViewController.swift
//  PlayingCard
//
//  Created by lano on 2020/2/25.
//  Copyright © 2020 SCS. All rights reserved.

import UIKit

class ViewController: UIViewController {
    
    private var deck = PlayingCardDeck()
/*
    @IBOutlet weak var playingCardView: PlayingCardView!{
        didSet{//添加事件,当扫过牌面时
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction = [.left,.right]//添加手势,左右等
            playingCardView.addGestureRecognizer(swipe)
            //添加伸缩手势(下面target里面就不能是self了)
            let pinch = UIPinchGestureRecognizer(target: playingCardView,action:#selector(PlayingCardView.adjustFaceCardScale(byHandingGestureRecognizedBy:)))
            playingCardView.addGestureRecognizer(pinch)
        }
    }

    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {//action应该发生在sender身上,以确保在最终情况下这样做
        case .ended://不加switch这段,直接写下面翻牌这句也是可以执行的
            playingCardView.isFaceUp = !playingCardView.isFaceUp
        default:
            break
        }
    }
 
    @objc func nextCard(){
        if let card = deck.draw(){//调用deck也就是PlayingCardDeck,随机生成一张牌
            playingCardView.rank = card.rank.order
            playingCardView.suit = card.suit.rawValue
        }
    }
*/
    
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)//建动画,第一步创建Animator
    lazy var collisionBehavior: UICollisionBehavior = {//第二步添加Behavior
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(behavior)
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
       let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false//不希望东西转动
        behavior.elasticity = 1.0//碰撞不会失去任何能量,大于时会获得能量会快起来,反之会慢下来
        behavior.resistance = 0//施加在它上面的力量,不想要任何抵抗
        animator.addBehavior(behavior)
        return behavior
    }()
    
    lazy var cardBehavior = CardBehavior(in : animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        for _ in 1...10{//随机打印十张牌
//            if let card = deck.draw(){
//                print("\(card)")
//            }
//        }
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count+1)/2){
            let card = deck.draw()!
            cards += [card,card]
        }
        for cardView in cardViews{
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            //collisionBehavior.addItem(cardView)//第三步添加item
            //itemBehavior.addItem(cardView)
            cardBehavior.addItem(cardView)
        }
    }
    
    private var faceUpCardViews: [PlayingCardView]{
        //return cardViews.filter{$0.isFaceUp && !$0.isHidden}
        return cardViews.filter{$0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0.alpha == 1}
    }
    
    private var faceUpCardVeiwsMatch: Bool{
        return faceUpCardViews.count == 2 &&
            faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
            faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    var lastChosenCardView: PlayingCardView?
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer){
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView,faceUpCardViews.count < 2{
                lastChosenCardView = chosenCardView
                cardBehavior.removeItem(chosenCardView)
                UIView.transition(with: chosenCardView, duration: 0.5, options: [.transitionFlipFromLeft], animations: {chosenCardView.isFaceUp = !chosenCardView.isFaceUp},
                    completion:{finished in
                        let cardsToAnimate = self.faceUpCardViews
                        if self.faceUpCardVeiwsMatch{
                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 0, options: [], animations: {
                                    cardsToAnimate.forEach{
                                      $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                    }
                                }, completion: {postion in
                                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.75, delay: 0, options: [], animations: {
                                        cardsToAnimate.forEach{
                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                            $0.alpha = 0
                                        }
                                    },completion: {postion in
                                        cardsToAnimate.forEach{
                                            $0.isHidden = true
                                            $0.alpha = 1
                                            $0.transform = .identity
                                        }
                                    })
                                })
                        }else if cardsToAnimate.count == 2{
                            if chosenCardView == self.lastChosenCardView{
                                cardsToAnimate.forEach{cardView in
                                    UIView.transition(with: cardView, duration: 0.5, options: [.transitionFlipFromLeft], animations: {cardView.isFaceUp = false},
                                                      completion:{finished in
                                                        self.cardBehavior.addItem(cardView)
                                    })
                                }
                            }
                        }else{
                            if !chosenCardView.isFaceUp{
                                self.cardBehavior.addItem(chosenCardView)
                            }
                        }
                    })
            }
        default:
            break
        }
    }
}

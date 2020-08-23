//
//  PlayingCardDeck.swift
//  PlayingCard
//
//  Created by lano on 2020/2/25.
//  Copyright © 2020 SCS. All rights reserved.
//

import Foundation
struct PlayingCardDeck {
    private(set) var cards = [PlayingCard]()
    
    init(){//初始生成一副牌
        for suit in PlayingCard.Suit.all{
            for rank in PlayingCard.Rank.all{
                cards.append(PlayingCard(suit: suit, rank: rank))
            }
        }
    }
    
    mutating func draw() -> PlayingCard? {//随机抽一张牌
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        }else{
            return nil
        }
    }
}

//extension可以在不碰别的class代码时也能给它加var或func
extension Int{//给Int添加生成随机数的功能(属性),使得一个整数有点语法比如5.arc4random就是生成0-5的随机数
    var arc4random: Int{
        if self > 0{
            return Int(arc4random_uniform(UInt32(self)))//self就是Int自己,这写法很酷吧
        }else if self < 0 {//虽然本游戏用不到,但考虑0和负数能使所有情况都包含进去,任何用途都能使用本extension
            return -Int(arc4random_uniform(UInt32(abs(self))))//self就是Int自己,这写法很酷吧
        }else {return 0}
    }
}


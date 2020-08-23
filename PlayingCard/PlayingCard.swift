//
//  PlayingCard.swift
//  PlayingCard
//
//  Created by lano on 2020/2/25.
//  Copyright © 2020 SCS. All rights reserved.
//

import Foundation

struct PlayingCard: CustomStringConvertible{
    var description: String{return "\(rank)\(suit)"}
    
    var suit: Suit//牌型
    var rank: Rank//牌数字
    
    enum Suit: String,CustomStringConvertible {
        case spades = "♠️"
        case hearts = "♥️"
        case clubs = "♣️"
        case diamonds = "♦️"
        static var all = [Suit.spades,.hearts,.diamonds,.clubs]
        var description: String{return rawValue}
    }
    enum Rank: CustomStringConvertible{
        var description: String{
            switch self {
            case .ace: return "A"
            case .numeric(let pips): return String(pips)
            case .face(let kind): return kind
            }
        }
        
        case ace
        case face(String)
        case numeric(Int)
        
        var order: Int{
            switch self {
            case .ace: return 1
            case .numeric(let pips): return pips
            case .face(let kind) where kind == "J": return 11
            case .face(let kind) where kind == "Q": return 12
            case .face(let kind) where kind == "K": return 13
            default:return 0
            }
        }
        
        static var all: [Rank]{//2-10,JQKA,组成牌
            var allRanks = [Rank.ace]
            for pips in 2...10{
                allRanks.append(Rank.numeric(pips))
            }
            allRanks += [Rank.face("J"),.face("Q"),.face("K")]
            return allRanks
        }
    }
}

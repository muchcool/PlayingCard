//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by lano on 2020/2/25.
//  Copyright © 2020 SCS. All rights reserved.
//

import UIKit
@IBDesignable//将自定义的代码实时渲染到Interface Builder中(storyBoard，xib能实时渲染)
class PlayingCardView: UIView {
    @IBInspectable//在每个var前面加,使得storyboard右侧栏出现这个var的框,改框里数字能直接反应在图上
    var rank:Int = 13{didSet{setNeedsDisplay(); setNeedsLayout()}}//当数字改变时,能够redraw显示新的
    @IBInspectable
    var suit:String = "♥️"{didSet{setNeedsDisplay(); setNeedsLayout()}}//标记为需要重新布局
    @IBInspectable
    var isFaceUp:Bool = true{didSet{setNeedsDisplay(); setNeedsLayout()}}
    //要伸缩牌size的话
    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize{didSet{setNeedsDisplay()}}//改变牌size大小不会改变corner,所以无需重新布局
    
    //手势伸缩改变牌size
    @objc func adjustFaceCardScale(byHandingGestureRecognizedBy recognizer: UIPinchGestureRecognizer){
        switch recognizer.state {
        case .changed, .ended:
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString{
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)//iphone设定里面设大字体后本app字体也跟随
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }//设定富文本
    private var cornerString: NSAttributedString{
        return centeredAttributedString(rankString + "\n" + suit, fontSize: cornerFontSize)
    }//角上的牌字
    
    private lazy var upperLeftCornerLabel = createCornerLabel()//左上角牌字
    private lazy var lowerRightCornerLabel = createCornerLabel()//右下角牌字
    private func createCornerLabel() -> UILabel{
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureCornerLabel(_ label: UILabel){
        label.attributedText = cornerString
        label.frame.size = CGSize.zero
        label.sizeToFit()//自动变换牌字的大小
        label.isHidden = !isFaceUp//翻面就不显示牌字
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }//为了iphone设定里面设大字体后本app字体也跟随,而且是立即变化字体的话,需要这样自动布局
    
    override func layoutSubviews() {//autoLayout
        super.layoutSubviews()
        
        configureCornerLabel(upperLeftCornerLabel)
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
        
        configureCornerLabel(lowerRightCornerLabel)
        lowerRightCornerLabel.transform = CGAffineTransform.identity.translatedBy(x: lowerRightCornerLabel.frame.size.width, y: lowerRightCornerLabel.frame.size.height).rotated(by: CGFloat.pi)//右下角需要转180度
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY).offsetBy(dx: -cornerOffset, dy: -cornerOffset).offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)//右下角牌字需要重新offset一下
    }
    
    private func drawPips(){//关于点数
        let pipsPerRowForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2],[2,2,2],[2,1,2,2],[2,2,2,2],[2,2,1,2,2],[2,2,2,2,2]]
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0) })
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0) })
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize / (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()//矩形让它圆角
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFaceUp{
            if let faceCardImage = UIImage(named: rankString+suit,//老人头图案
                in: Bundle(for: self.classForCoder),compatibleWith: traitCollection){//为了InterfaceBuilder实时渲染
                //faceCardImage.draw(in: bounds.zoom(by: SizeRatio.faceCardImageSizeToBoundsSize))//固定不变大小的话这么写
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))//让老人头变大小的话,换成变量
            }else{
                drawPips()//画牌面的点图案
            }
        }else{
            if let cardBackImage = UIImage(named: "cardback",in: Bundle(for: self.classForCoder),compatibleWith: traitCollection){//为了InterfaceBuilder实时渲染)
                cardBackImage.draw(in: bounds)//牌背面图案
            }
        }
        
//        if let context = UIGraphicsGetCurrentContext(){
//            context.addArc(center: CGPoint(x:bounds.midX,y:bounds.midY), radius: 100.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
//            context.setLineWidth(5.0)
//            UIColor.green.setFill()
//            UIColor.red.setStroke()
//            context.strokePath()
//            context.fillPath()
//        }
        
//        let path = UIBezierPath()
//        path.addArc(withCenter:CGPoint(x:bounds.midX,y:bounds.midY), radius: 100.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
//        path.lineWidth = 5.0
//        UIColor.green.setFill()
//        UIColor.red.setStroke()
//        path.stroke()
//        path.fill()
    }
}
extension PlayingCardView{
    private struct SizeRatio{//各种比例(各种size取决于屏幕大小)
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085//牌字size与屏幕高度的比例
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06//牌角弧度与屏幕高度的比例
        static let cornerOffsetToCornerRadius: CGFloat = 0.33//偏移量根据弧度来
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75//牌图与屏幕大小比例
    }
    private var cornerRadius: CGFloat{//计算牌角弧度
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat{//计算角的偏移量
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat{//计算牌字size
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var rankString: String{
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}
extension CGRect{
    var leftHalf: CGRect{
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf: CGRect{
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    func inset(by size: CGSize) -> CGRect{
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect{
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale:CGFloat) -> CGRect{
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2,dy: (height - newHeight) / 2)
    }
}

extension CGPoint{
    func offsetBy(dx: CGFloat,dy: CGFloat) -> CGPoint{
        return CGPoint(x: x+dx,y: y+dy)
    }
}

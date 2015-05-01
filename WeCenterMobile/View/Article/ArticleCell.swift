//
//  ArticleCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/5/1.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleBodyLabel: UILabel!
    @IBOutlet weak var extraInformationLabel: UILabel!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    
    lazy var dateFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        articleButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
    }
    
    func update(#article: Article, updateImage: Bool) {
        articleTitleLabel.text = article.title
        articleBodyLabel.text = article.body!.wc_plainString
        let attributedString = NSMutableAttributedString(
            string: article.user!.name!,
            attributes: [
                NSForegroundColorAttributeName: UIColor.lightTextColor(),
                NSFontAttributeName: extraInformationLabel.font])
        attributedString.appendAttributedString(NSAttributedString(
            string: " \(dateFormatter.stringFromDate(article.date!))",
            attributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.4),
                NSFontAttributeName: extraInformationLabel.font]))
        extraInformationLabel.attributedText = attributedString
        if updateImage {
            userAvatarView.wc_updateWithUser(article.user)
        }
        articleButton.msr_userInfo = article
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}

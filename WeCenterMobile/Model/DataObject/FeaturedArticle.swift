//
//  FeaturedArticle.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/12.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import CoreData
import Foundation

class FeaturedArticle: FeaturedObject {

    @NSManaged var id: NSNumber
    @NSManaged var article: Article

}

//
//  HTMLNode+Swift.h
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

#import "HTMLNode.h"

typedef NS_ENUM(NSInteger, HTMLNodeType_Swift) {
    HTMLNodeType_SwiftHref = HTMLHrefNode,
    HTMLNodeType_SwiftText = HTMLTextNode,
    HTMLNodeType_SwiftUnknown = HTMLUnkownNode,
    HTMLNodeType_SwiftCode = HTMLCodeNode,
    HTMLNodeType_SwiftSpan = HTMLSpanNode,
    HTMLNodeType_SwiftP = HTMLPNode,
    HTMLNodeType_SwiftLi = HTMLLiNode,
    HTMLNodeType_SwiftUl = HTMLUlNode,
    HTMLNodeType_SwiftImg = HTMLImageNode,
    HTMLNodeType_SwiftOl = HTMLOlNode,
    HTMLNodeType_SwiftStrong = HTMLStrongNode,
    HTMLNodeType_SwiftPre = HTMLPreNode,
    HTMLNodeType_SwiftBlockQuote = HTMLBlockQuoteNode
};

@interface HTMLNode (Swift)

@property (readonly) xmlNode *nativeXMLNode;
@property (readonly) HTMLNodeType_Swift type;

@end

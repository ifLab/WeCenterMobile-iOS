//
//  HTMLNode+Swift.m
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNode+Swift.h"

@implementation HTMLNode (Swift)

- (xmlNode *)nativeXMLNode {
    return _node;
}

- (HTMLNodeType_Swift)type {
    return (HTMLNodeType_Swift)nodeType(_node);
}

@end
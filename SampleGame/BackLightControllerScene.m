//
//  GameScene.m
//  SampleGame
//
//  Created by Mohammad Zulqurnain on 25/08/2018.
//  Copyright © 2018 Mohammad Zulqurnain. All rights reserved.
//

#import "BackLightControllerScene.h"

@implementation BackLightControllerScene {

};
@synthesize vine;

NSArray* vines = nil;

- (void)didMoveToView:(SKView *)view {
    [self setUpVines];
}

 -(void) setUpVines {
    // 1 load vine data
     NSString* dataFile = [[NSBundle mainBundle] pathForResource:@"VineData.plist" ofType:nil];

     NSArray* vines = [NSArray arrayWithContentsOfFile:dataFile];
    
    // 2 add vines
     for(int i = 0; i < vines.count; i++) {
        // 3 create vine
         NSDictionary* vineData = vines[i];
         int length = (int)vineData[@"length"];
         CGPoint relAnchorPoint = CGPointFromString((NSString*)vineData[@"relAnchorPoint"]);
         CGPoint anchorPoint = CGPointMake(relAnchorPoint.x * self.size.width - 375, relAnchorPoint.y *  self.size.height + 60);
         vine = [[VineNode alloc] initWithLength:length anchorPoint:anchorPoint name:[NSString stringWithFormat:@"%d",i]];
        // 4 add to scene
         [vine addToScene:self];
    }
}

- (void)touchDownAtPoint:(CGPoint)pos {
    //[vine setPrizeWithLocation:pos];
}

- (void)touchMovedToPoint:(CGPoint)pos {
     [vine setPrizeWithLocation:pos];
}

- (void)touchUpAtPoint:(CGPoint)pos {
    [vine setPrizeToDefaultPosition];
    [vine playSoundLampTickSound];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Run 'Pulse' action from 'Actions.sks'
    //[_label runAction:[SKAction actionNamed:@"Pulse"] withKey:@"fadeInOut"];
    
    for (UITouch *t in touches) {[self touchDownAtPoint:[t locationInNode:self]];}
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *t in touches) {[self touchMovedToPoint:[t locationInNode:self]];}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}


-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end

//
//  HelloWorldScene.m
//  NoHackerbots
//
//  Created by Jake Boxer on 4/15/14.
//  Copyright Jake Boxer 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "MainGameScene.h"
#import "IntroScene.h"

// -----------------------------------------------------------------------
#pragma mark - MainGameScene
// -----------------------------------------------------------------------

@interface MainGameScene ()

typedef enum {
    GameStatePaused,
    GameStatePlaying
} GameState;

@property (nonatomic, strong) CCSprite *block;
@property (nonatomic, strong) CCSprite *door;
@property (nonatomic, assign) GameState gameState;
@property (nonatomic, strong) CCLabelTTF *gameStateLabel;
@property (nonatomic, assign) CGPoint lastTouchLocation;
@property (nonatomic, strong) CCSprite *robot;
@property (nonatomic, strong) CCLabelTTF *ruleLabel;
@property (nonatomic, strong) CCSprite *selectedBlock;

- (void)resetGame;
- (void)startRobot;
- (void)stopRobot;

@end

@implementation MainGameScene

@synthesize block;
@synthesize door;
@synthesize lastTouchLocation;
@synthesize robot;
@synthesize ruleLabel;
@synthesize selectedBlock;

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (MainGameScene *)scene {
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init {
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return nil;
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0 green:0.3f blue:0.0f alpha:1.0f]];
    [self addChild:background z:-2];

    // Create a game state label
    self.gameStateLabel = [CCLabelTTF labelWithString:@""
                                             fontName:@"Menlo-Regular"
                                             fontSize:18.0f];
    self.gameStateLabel.anchorPoint = ccp(0.0f, 1.0f);
    self.gameStateLabel.position = ccp(336.0f, 304.0f);
    [self addChild:self.gameStateLabel];

    // Create a Rules header label
    CCLabelTTF *rulesHeaderLabel = [CCLabelTTF labelWithString:@"Rules:"
                                                      fontName:@"Menlo-Bold"
                                                      fontSize:14.0f];
    rulesHeaderLabel.anchorPoint = ccp(0.0f, 1.0f);
    rulesHeaderLabel.position = ccp(336.0f, 212.0f);
    [self addChild:rulesHeaderLabel];

    // Create the label for the single existing rule
    self.ruleLabel = [CCLabelTTF labelWithString:@"1. Can go forward."
                                        fontName:@"Menlo-Bold"
                                        fontSize:14.0f];
    self.ruleLabel.anchorPoint = ccp(0.0f, 1.0f);
    self.ruleLabel.position = ccp(336.0f, 192.0f);
    [self addChild:self.ruleLabel];

    // Create a "go" button
    CCButton *goButton = [CCButton buttonWithTitle:@"[ Go ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    goButton.position = ccp(520.0f, 290.0f); // Under the back button
    [goButton setTarget:self selector:@selector(onGoClicked:)];
    [self addChild:goButton];

    // Create a "reset" button
    CCButton *resetButton = [CCButton buttonWithTitle:@"[ Reset ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    resetButton.position = ccp(505.0f, 240.0f); // Under the back button
    [resetButton setTarget:self selector:@selector(onResetClicked:)];
    [self addChild:resetButton];

    // Create the floor
    for (NSInteger row = 0; row < 10; row++) {
        CGFloat yPosition = row * 32.0f;

        for (NSInteger column = 0; column < 10; column++) {
            CGFloat xPosition = column * 32.0f;

            CCSprite *tile = [CCSprite spriteWithImageNamed:@"floor.png"];
            tile.anchorPoint = CGPointZero; // Anchor at the bottom left
            tile.position = ccp(xPosition, yPosition);
            [self addChild:tile];
        }
    }

    // Create the door
    self.door = [CCSprite spriteWithImageNamed:@"door.png"];
    self.door.anchorPoint = CGPointZero; // Anchor at the bottom left
    self.door.position = ccp(5.0f * 32.0f, 0.0f);
    [self addChild:self.door];

    // Create the block
    self.block = [CCSprite spriteWithImageNamed:@"block.png"];
    self.block.anchorPoint = CGPointZero; // Anchor at the bottom left
    [self addChild:self.block];

    // Create the robot
    self.robot = [CCSprite spriteWithImageNamed:@"robot.png"];
    self.robot.anchorPoint = CGPointZero; // Anchor at the bottom left
    [self addChild:self.robot];

    [self resetGame];

    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc {
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter {
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit {
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (GameStatePaused != self.gameState) {
        return;
    }

    CGPoint touchLocation = [touch locationInNode:self];

    if (CGRectContainsPoint(self.block.boundingBox, touchLocation)) {
        self.selectedBlock = self.block;
        self.lastTouchLocation = touchLocation;
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    if (GameStatePaused != self.gameState) {
        return;
    }

    CGPoint touchLocation = [touch locationInNode:self];

    BOOL touchInBoard = CGRectContainsPoint(CGRectMake(0.0f, 0.0f, 320.0f, 320.0f), touchLocation);

    if (self.selectedBlock != nil && touchInBoard) {
        CGFloat newX = self.selectedBlock.position.x + (touchLocation.x - self.lastTouchLocation.x);
        newX = MIN(newX, 9.0f * 32.0f);
        newX = MAX(newX, 0.0f);

        self.selectedBlock.position = ccp(newX, self.selectedBlock.position.y);
        self.lastTouchLocation = touchLocation;
    }
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (GameStatePaused != self.gameState) {
        return;
    }

    if (self.selectedBlock != nil) {
        // Snap to tile
        NSInteger tileColumn = roundf(self.block.position.x / 32.0f);
        self.block.position = ccp(tileColumn * 32.0f, self.block.position.y);
    }

    self.selectedBlock = nil;
    self.lastTouchLocation = ccp(-1.0f, -1.0f); // Sentinel value
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender {
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

- (void)onGoClicked:(id)sender {
    self.gameStateLabel.string = @"Playing";
    [self startRobot];
}

- (void)onResetClicked:(id)sender {
    [self resetGame];
}

// -----------------------------------------------------------------------
#pragma mark - Game Logic
// -----------------------------------------------------------------------

- (void)resetGame {
    // Set initial sprite states
    self.block.position = ccp(9.0f * 32.0f, 5.0f * 32.0f);
    self.robot.position = ccp(5.0f * 32.0f, 9.0f * 32.0f);

    [self stopRobot];

    self.gameStateLabel.string = @"Paused";
}

- (void)startRobot {
    // Game state updates
    self.gameState = GameStatePlaying;

    // Sprite state updates
    self.ruleLabel.color = [CCColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:1.0f];

    // Event scheduling
    [self schedule:@selector(turnBegan:) interval:1.0];
}

- (void)stopRobot {
    // Game state updates
    self.gameState = GameStatePaused;

    // Sprite state updates
    self.ruleLabel.color = [CCColor colorWithWhite:1.0f alpha:1.0f];

    // Event scheduling
    [self unschedule:@selector(turnBegan:)];
}

- (void)turnBegan:(CCTime)dt {
    // Check preconditions

    BOOL passedPreconditions = YES;

    if (CGPointEqualToPoint(self.robot.position, self.door.position)) {
        // Robot made it to the door so you lose :(
        self.gameStateLabel.string = @"DECRYPTION\nCOMPLETE\nyou lose";

        [self stopRobot];
        passedPreconditions = NO;
    }

    // Done checking preconditions. Calculate next move if they passed.

    if (passedPreconditions) {
        CGPoint nextRobotPosition = ccp(self.robot.position.x, self.robot.position.y - 32.0f);

        if (CGPointEqualToPoint(nextRobotPosition, self.block.position)) {
            // Robot bumped into the block so you win!
            self.gameStateLabel.string = @"ENOMOREMOVES\nyou win";

            [self stopRobot];
        } else {
            // Robot can keep moving
            CCActionMoveTo *moveAction = [CCActionMoveTo actionWithDuration:0.25f
                                                                   position:ccp(self.robot.position.x, self.robot.position.y - 32.0f)];
            [self.robot runAction:moveAction];
        }
    }
}

@end

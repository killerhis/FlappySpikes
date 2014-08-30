//
//  MyScene.m
//  Flappy Spikes
//
//  Created by Hicham Chourak on 29/08/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"
#import <AVFoundation/AVFoundation.h>

static NSInteger const kPipeGap = 120;
static NSInteger const kMinPipeHeight = 40;
static float const kFadeDuration = 0.5;

static const uint32_t birdCategory = 0x1 << 0;
static const uint32_t worldCategory = 0x1 << 1;
static const uint32_t pipeCategory = 0x1 << 2;
static const uint32_t scoreCategory = 0x1 << 3;

@interface GameScene () <SKPhysicsContactDelegate>

//@property (strong, nonatomic) SKAction *flapSound;
//@property (strong, nonatomic) SKAction *gameoverSound;
//@property (strong, nonatomic) SKAction *point;
@end


@implementation GameScene {
    
    SKSpriteNode *_bird;
    SKSpriteNode *_pipe1;
    SKSpriteNode *_pipe2;
    SKSpriteNode *_spikes;
    
    SKColor *_blendColor;
    
    float _scale;
    float _speed;
    float _gravity;
    float _impulse;
    float _spikesHeight;
    float _spawnTime;
    
    SKTexture *_pipeTexture1;
    SKTexture *_pipeTexture2;
    SKAction *_moveAndRemovePipes;
    
    SKNode *_moving;
    SKNode *_pipes;
    SKNode *_pipePair;
    SKNode *_startScene;
    
    BOOL _isGameOver;
    BOOL _startGameScene;
    
    SKLabelNode *_scoreLabelNode;
    NSInteger _score;
    
    SKAction *_flapSound;
    SKAction *_gameoverSound;
    SKAction *_pointSound;
}


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // init
        [self initSound];
        self.physicsWorld.contactDelegate = self;
        
        _scale = [self setDeviceScale];
        _speed = 0.005;
        _gravity = -9;
        _impulse = 12;
        _isGameOver = NO;
        _startGameScene = YES;
        _spawnTime = 1.5;
        _blendColor = [SKColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0];
        
        
        [self initSceneNodes];
        [self startScene];
        _moving.speed = 0;

    }
    return self;
}

- (void)update:(CFTimeInterval)currentTime
{
    if( _moving.speed > 0 ) {
        //_bird.zRotation = clamp( -1, 0.5, _bird.physicsBody.velocity.dy * ( _bird.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
    }
}

#pragma mark - Contact Elements

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_startGameScene) {
        _startGameScene = NO;
        [self startGame];
        [_startScene runAction:[SKAction fadeAlphaTo:0.0 duration:0.5] completion:^{
            [_startScene removeFromParent];
        }];
    }
    
    if( !_isGameOver ) {
        _bird.physicsBody.velocity = CGVectorMake(0, 0);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [_bird.physicsBody applyImpulse:CGVectorMake(0, _impulse*pow(_scale, 3))];
        } else {
            [_bird.physicsBody applyImpulse:CGVectorMake(0, _impulse)];
        }
        
        [self flapBird];
        [self runAction:_flapSound];
    }
    
    if( _isGameOver ) {
        [self resetGame];
    }
    
    
   
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if( !_isGameOver ) {
        if( ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory ) {
            // Bird has contact with score entity
            
            _score++;
            _scoreLabelNode.text = [NSString stringWithFormat:@"%d", _score];
            [self changeSceneColor];
            [self runAction:_pointSound];
        } /*else {
            
            _isGameOver = YES;
            _moving.paused = YES;
            
            [self deadBird];
            [self runAction:_gameoverSound];
        }*/
    }
}

#pragma mark - Game Elements

- (void)addScoreHud
{
    // Initialize label and create a label which holds the score
    _score = 0;
    _scoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"LVDC Common2"];
    //_scoreLabelNode.position = CGPointMake( CGRectGetMidX( self.frame ), 3 * self.frame.size.height / 4 );
    _scoreLabelNode.zPosition = -90;
    _scoreLabelNode.fontSize = 125*_scale;
    _scoreLabelNode.fontColor = [SKColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
    _scoreLabelNode.position = CGPointMake(self.size.width/2, self.size.height/2 - 35*_scale);
    _scoreLabelNode.text = [NSString stringWithFormat:@"%d", _score];
    _scoreLabelNode.alpha = 0.0;
    
    [_scoreLabelNode runAction:[SKAction fadeAlphaTo:1.0 duration:0.5]];
    
    [self addChild:_scoreLabelNode];
    //
}

- (void)initSceneNodes
{
    _moving = [SKNode node];
    [self addChild:_moving];
    
    _pipes = [SKNode node];
    [_moving addChild:_pipes];
    
    _startScene = [SKNode node];
    [self addChild:_startScene];
}

- (void)initScenePhysics
{
    self.physicsWorld.gravity = CGVectorMake( 0.0, _gravity*_scale);
    SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody = borderBody;
}

- (void)deadBird
{
    _bird.physicsBody.allowsRotation = YES;
    _bird.physicsBody.restitution = 0.1f;
    
    SKTexture* birdDeadTexture = [SKTexture textureWithImageNamed:@"bird_dead"];
    
    [_bird runAction:[SKAction setTexture:birdDeadTexture]];
    
    [_bird.physicsBody applyImpulse:CGVectorMake(40*_scale, 40*_scale)];
    
    [_bird runAction:[SKAction rotateByAngle:M_PI * 5 duration:1]];
}

- (void)addBird
{
    SKTexture* birdTexture = [SKTexture textureWithImageNamed:@"bird"];
    
    _bird = [SKSpriteNode spriteNodeWithTexture:birdTexture];
    _bird.position = CGPointMake(self.frame.size.width / 4, CGRectGetMidY(self.frame));
    
    _bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bird.size.height / 2];
    _bird.physicsBody.dynamic = YES;
    _bird.physicsBody.allowsRotation = NO;
    
    _bird.physicsBody.categoryBitMask = birdCategory;
    _bird.physicsBody.collisionBitMask = worldCategory | pipeCategory;
    _bird.physicsBody.contactTestBitMask = worldCategory | pipeCategory;
    
    [self addChild:_bird];
}

- (void)flapBird
{
    SKTexture* birdTexture = [SKTexture textureWithImageNamed:@"bird"];
    SKTexture* birdTextureFlap = [SKTexture textureWithImageNamed:@"bird_flap"];
    
    SKAction* flapAction = [SKAction animateWithTextures:@[birdTextureFlap, birdTexture] timePerFrame:0.2];
    
    [_bird runAction:flapAction];
    
}

- (void)setBackground
{
    SKSpriteNode *backgroundColor = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0] size:self.size];
    backgroundColor.position = CGPointMake(self.size.width/2, self.size.height/2);
    backgroundColor.zPosition = -101;
    backgroundColor.name = @"scene";
    [self addChild:backgroundColor];
    //_backgroundColor = [SKColor colorWithRed:223.0/255.0 green:234.0/255.0 blue:240.0/255.0 alpha:1.0];
    //self.backgroundColor = _backgroundColor;
    
    SKSpriteNode *backgroundScore = [SKSpriteNode spriteNodeWithImageNamed:@"background_score"];
    backgroundScore.position = CGPointMake(self.size.width/2, self.size.height/2);
    backgroundScore.zPosition = -100;
    [self addChild:backgroundScore];
}

- (void)addGroundSpikes
{
    SKTexture* groundSpikesTexture = [SKTexture textureWithImageNamed:@"ground_spikes"];
    
    SKAction* moveGroundSprite = [SKAction moveByX:-groundSpikesTexture.size.width-2 y:0 duration:(_speed/_scale) *(groundSpikesTexture.size.width-2)];
    SKAction* resetGroundSprite = [SKAction moveByX:groundSpikesTexture.size.width-2 y:0 duration:0];
    SKAction* moveGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite, resetGroundSprite]]];
    
    _spikesHeight = 0;
    
    for( int i = 0; i < 2 + self.frame.size.width / ( groundSpikesTexture.size.width ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:groundSpikesTexture];
        sprite.name = @"scene";
        sprite.color = _blendColor;
        sprite.colorBlendFactor = 1.0;
        
        if (self.size.height == 480.0f) {
            // 3.5 inch devices
            _spikesHeight = sprite.size.height - 50;
            sprite.position = CGPointMake(i * (sprite.size.width-2), sprite.size.height/2 - 50);
        } else if (self.size.height == 568.0f) {
            // 4 inch devices
            _spikesHeight = sprite.size.height - 25;
            sprite.position = CGPointMake(i * (sprite.size.width-2), sprite.size.height/2 - 25);
        } else {
            // iPad devices
            _spikesHeight = sprite.size.height;
            sprite.position = CGPointMake(i * (sprite.size.width-2), sprite.size.height/2);
        }
        
        [sprite runAction:moveGroundSpritesForever];
        //[self addChild:sprite];
        
        [_moving addChild:sprite];
    }
    
    [self addSpikesBody:_spikesHeight forYPosition:0];
}

- (void)addTopSpikes
{
    SKTexture* topSpikesTexture = [SKTexture textureWithImageNamed:@"ground_spikes"];
    
    SKAction* moveTopSprite = [SKAction moveByX:-topSpikesTexture.size.width-2 y:0 duration:(_speed/_scale) *(topSpikesTexture.size.width-2)];
    SKAction* resetTopSprite = [SKAction moveByX:topSpikesTexture.size.width-2 y:0 duration:0];
    SKAction* moveTopSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveTopSprite, resetTopSprite]]];
    
    float spikesHeight = 0;
    
    for( int i = 0; i < 2 + self.frame.size.width / ( topSpikesTexture.size.width ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:topSpikesTexture];
        sprite.zRotation = M_PI;
        sprite.name = @"scene";
        sprite.color = _blendColor;
        sprite.colorBlendFactor = 1.0;
        
        if (self.size.height == 480.0f) {
            // 3.5 inch devices
            spikesHeight = sprite.size.height - 50;
            sprite.position = CGPointMake(i * (sprite.size.width-2), self.size.height - (sprite.size.height/2 - 50));
        } else if (self.size.height == 568.0f) {
            // 4 inch devices
            spikesHeight = sprite.size.height - 25;
            sprite.position = CGPointMake(i * (sprite.size.width-2), self.size.height - (sprite.size.height/2 - 25));
        } else {
            // iPad devices
            spikesHeight = sprite.size.height;
            sprite.position = CGPointMake(i * (sprite.size.width-2), self.size.height - (sprite.size.height/2));
        }
        
        [sprite runAction:moveTopSpritesForever];
        //[self addChild:sprite];
        
        [_moving addChild:sprite];
    }
    
    [self addSpikesBody:spikesHeight forYPosition:self.size.height];
}

- (void)addSpikesBody:(float)height forYPosition:(float)yPosition
{
    SKNode* spikesBody = [SKNode node];
    
    spikesBody.position = CGPointMake(0, fabsf(yPosition - height/2));
    spikesBody.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width*2, height)];
    spikesBody.physicsBody.dynamic = NO;
    
    spikesBody.physicsBody.categoryBitMask = worldCategory;
    spikesBody.physicsBody.collisionBitMask = birdCategory;
    
    [self addChild:spikesBody];
}

- (void)initPipes
{
    _pipeTexture1 = [SKTexture textureWithImageNamed:@"pipe_bottom"];
    _pipeTexture2 = [SKTexture textureWithImageNamed:@"pipe_top"];
    
    CGFloat distanceToMove = self.frame.size.width + _pipeTexture1.size.width;
    SKAction* movePipes = [SKAction moveByX:-distanceToMove y:0 duration:_speed/_scale * distanceToMove];
    SKAction* removePipes = [SKAction removeFromParent];
    _moveAndRemovePipes = [SKAction sequence:@[movePipes, removePipes]];
}

-(void)spawnPipes
{
    _pipePair = [SKNode node];
    _pipePair.position = CGPointMake( self.frame.size.width + _pipeTexture1.size.width/2, 0 );
    _pipePair.zPosition = -10;
    
    float maxSpikeHeight = 2*_spikesHeight + (kPipeGap+2*kMinPipeHeight)*_scale;
    //NSLog(@"maxSpikeHeight: %f", maxSpikeHeight);
    CGFloat y = arc4random() % (NSInteger)(self.frame.size.height - maxSpikeHeight) + _spikesHeight +kMinPipeHeight*_scale;
    //NSLog(@"Height: %f", y);
    
    SKSpriteNode* pipe1 = [SKSpriteNode spriteNodeWithTexture:_pipeTexture1];
    pipe1.position = CGPointMake( 0, -pipe1.size.height/2 + y);
    pipe1.name = @"scene";
    pipe1.color = _blendColor;
    pipe1.colorBlendFactor = 1.0;
    
    pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe1.physicsBody.dynamic = NO;
    [_pipePair addChild:pipe1];
    
    SKSpriteNode* pipe2 = [SKSpriteNode spriteNodeWithTexture:_pipeTexture2];
    //pipe2.position = CGPointMake( 0, y + pipe1.size.height + kPipeGap);
    pipe2.position = CGPointMake( 0, pipe2.size.height/2 + y + kPipeGap*_scale);
    pipe2.name = @"scene";
    pipe2.color = _blendColor;
    pipe2.colorBlendFactor = 1.0;
    
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe2.size];
    pipe2.physicsBody.dynamic = NO;
    
    pipe1.physicsBody.categoryBitMask = pipeCategory;
    pipe1.physicsBody.contactTestBitMask = birdCategory;
    pipe1.physicsBody.collisionBitMask = birdCategory;
	
    pipe2.physicsBody.categoryBitMask = pipeCategory;
    pipe2.physicsBody.contactTestBitMask = birdCategory;
    pipe2.physicsBody.collisionBitMask = birdCategory;
    
    [_pipePair addChild:pipe2];
    
    // for count score
    //SKNode* contactNode = [SKNode node];
    SKSpriteNode *contactNode = [SKSpriteNode node];
    contactNode.zPosition = -100;
    contactNode.position = CGPointMake( pipe1.size.width + _bird.size.width / 2, CGRectGetMidY( self.frame ) );
    contactNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake( pipe1.size.width, self.frame.size.height )];
    contactNode.physicsBody.dynamic = NO;
    
    contactNode.physicsBody.categoryBitMask = scoreCategory;
    contactNode.physicsBody.contactTestBitMask = birdCategory;
    
    [_pipePair addChild:contactNode];
    //
    
    [_pipePair runAction:_moveAndRemovePipes];
    
    [_pipes addChild:_pipePair];
}

#pragma mark - Scenes

- (void)startScene
{
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    [self setBackground];
    
    [self addBird];
    
    [self addGroundSpikes];
    [self addTopSpikes];
    
    SKSpriteNode *title = [SKSpriteNode spriteNodeWithImageNamed:@"title.png"];
    title.position = CGPointMake(self.size.width/2, self.size.height/2 + title.size.height/2 + 35*_scale);
    
    [_startScene addChild:title];
    
    //Best Score Label
    SKLabelNode *bestScoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Opificio Neue"];
    bestScoreLabelNode.position = CGPointMake(self.size.width/2, self.size.height/2 - 140*_scale);
    bestScoreLabelNode.fontSize = 25*_scale;
    bestScoreLabelNode.fontColor = _blendColor;
    bestScoreLabelNode.text = [NSString stringWithFormat:@"Best Score: %d", 100];
    [_startScene addChild:bestScoreLabelNode];
    
    //Games Played Label
    SKLabelNode *gamesPlayedLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Opificio Neue"];
    gamesPlayedLabelNode.position = CGPointMake(self.size.width/2, self.size.height/2 - 170*_scale);
    gamesPlayedLabelNode.fontSize = 25*_scale;
    gamesPlayedLabelNode.fontColor = _blendColor;
    gamesPlayedLabelNode.text = [NSString stringWithFormat:@"Games Played: %d", 83];
    [_startScene addChild:gamesPlayedLabelNode];
}



#pragma mark - Sound

- (void)initSound
{
    _flapSound = [SKAction playSoundFileNamed:@"flap.caf" waitForCompletion:NO];
    _gameoverSound = [SKAction playSoundFileNamed:@"gameover.caf" waitForCompletion:NO];
    _pointSound = [SKAction playSoundFileNamed:@"point.caf" waitForCompletion:NO];
}

#pragma mark - Helper Methods

- (void)startGame
{
    _moving.speed = 1;
    [self initScenePhysics];
    [self initPipes];
    
    [self addScoreHud];
    
    SKAction* spawn = [SKAction performSelector:@selector(spawnPipes) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:_spawnTime];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    SKAction* spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever];
}

- (float)setDeviceScale
{
    float scale;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        scale = 2.0;
    } else {
        scale = 1.0;
    }
    
    return scale;
}

-(void)resetGame
{
    GameScene *newGameScene = [GameScene sceneWithSize:self.size];
    [self.view presentScene:newGameScene transition:[SKTransition fadeWithColor:[SKColor whiteColor] duration:0.2]];
    
}

- (void)changeSceneColor
{
    SKColor *backgroundColor;
    
    if (_score%50 == 5) {
        
        backgroundColor = [SKColor colorWithRed:229/255.0 green:242/255.0 blue:249/255.0 alpha:1.0];
        _blendColor = [SKColor colorWithRed:102/255.0 green:123/255.0 blue:132/255.0 alpha:1.0];
        
        [self setSceneColor:_blendColor withBackgroundolor:backgroundColor];
        
    }
    
    if (_score%50 == 10) {
        
        backgroundColor = [SKColor colorWithRed:249/255.0 green:237/255.0 blue:230/255.0 alpha:1.0];
        _blendColor = [SKColor colorWithRed:128/255.0 green:106/255.0 blue:98/255.0 alpha:1.0];
        
        [self setSceneColor:_blendColor withBackgroundolor:backgroundColor];
        
    }
    
    if (_score%50 == 15) {
        
        backgroundColor = [SKColor colorWithRed:236/255.0 green:246/255.0 blue:229/255.0 alpha:1.0];
        _blendColor = [SKColor colorWithRed:118/255.0 green:126/255.0 blue:103/255.0 alpha:1.0];
        
        [self setSceneColor:_blendColor withBackgroundolor:backgroundColor];
        
    }
    
    if (_score%50 == 20) {
        
        backgroundColor = [SKColor colorWithRed:236/255.0 green:234/255.0 blue:248/255.0 alpha:1.0];
        _blendColor = [SKColor colorWithRed:110/255.0 green:104/255.0 blue:128/255.0 alpha:1.0];
        
        [self setSceneColor:_blendColor withBackgroundolor:backgroundColor];
        
    }
    
    if (_score%50 == 25) {
        
        backgroundColor = [SKColor colorWithRed:116/255.0 green:116/255.0 blue:116/255.0 alpha:1.0];
        _blendColor = [SKColor whiteColor];
        
        [self setSceneColor:_blendColor withBackgroundolor:backgroundColor];
        
    }
    
    if (_score%50 == 30) {
        
        backgroundColor = [SKColor colorWithRed:8/255.0 green:121/255.0 blue:144/255.0 alpha:1.0];
        _blendColor = [SKColor colorWithRed:12/255.0 green:217/255.0 blue:255/255.0 alpha:1.0];
        
        [self setSceneColor:_blendColor withBackgroundolor:backgroundColor];
        
    }
    
    if (_score%50 == 35) {
        
        backgroundColor = [SKColor colorWithRed:25/255.0 green:117/255.0 blue:0/255.0 alpha:1.0];
        _blendColor = [SKColor colorWithRed:126/255.0 green:228/255.0 blue:0/255.0 alpha:1.0];
        
        [self setSceneColor:_blendColor withBackgroundolor:backgroundColor];
        
    }
    
    if (_score%50 == 40) {
        
        backgroundColor = [SKColor colorWithRed:0/255.0 green:29/255.0 blue:137/255.0 alpha:1.0];
        _blendColor = [SKColor colorWithRed:0/255.0 green:103/255.0 blue:255/255.0 alpha:1.0];
        
        [self setSceneColor:_blendColor withBackgroundolor:backgroundColor];
        
    }
    
    if (_score%50 == 45) {
        
        backgroundColor = [SKColor colorWithRed:146/255.0 green:16/255.0 blue:55/255.0 alpha:1.0];
        _blendColor = [SKColor colorWithRed:255/255.0 green:31/255.0 blue:100/255.0 alpha:1.0];
        
        [self setSceneColor:_blendColor withBackgroundolor:backgroundColor];
        
    }
    
    if (_score%50 == 0 && _score != 0) {
        
        backgroundColor = [SKColor colorWithRed:255/255.0 green:181/255.0 blue:41/255.0 alpha:1.0];
        _blendColor = [SKColor whiteColor];
        
        [self setSceneColor:_blendColor withBackgroundolor:backgroundColor];
        
    }
}

- (void)setSceneColor:(SKColor *)sceneColor withBackgroundolor:(SKColor *)backgroundColor
{
    _scoreLabelNode.fontColor = backgroundColor;
    
    [self enumerateChildNodesWithName:@"scene" usingBlock:^(SKNode *node, BOOL *stop) {
        [node runAction:[SKAction colorizeWithColor:backgroundColor colorBlendFactor:1.0 duration:kFadeDuration]];
    }];
    
    [_moving enumerateChildNodesWithName:@"scene" usingBlock:^(SKNode *node, BOOL *stop) {
        [node runAction:[SKAction colorizeWithColor:sceneColor colorBlendFactor:1.0 duration:kFadeDuration]];
    }];
    
    [_pipePair enumerateChildNodesWithName:@"scene" usingBlock:^(SKNode *node, BOOL *stop) {
        [node runAction:[SKAction colorizeWithColor:sceneColor colorBlendFactor:1.0 duration:kFadeDuration]];
    }];
}

@end

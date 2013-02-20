//
//  MPPicker.h
//  MusicArt
//
//  Created by 加藤 亮太 on 2013/02/20.
//
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#include "testApp.h"

@interface MPPicker : UIViewController <MPMediaPickerControllerDelegate, UITableViewDelegate, AVAudioPlayerDelegate> {
    testApp *myApp;
    IBOutlet UIBarButtonItem *showPickerButton;
    IBOutlet UIBarButtonItem *playButton;
    IBOutlet UIBarButtonItem *pauseButton;
    
    IBOutlet UISlider *slider;
    
    ofxOpenALSoundPlayer *ALplayer;
    
@public
    CGPoint location;
}

-(IBAction)showMediaPicker:(id)sender;
-(IBAction)playMediaItem:(id)sender;
-(IBAction)pauseMediaItem:(id)sender;
-(float)getLevelWithChannel:(int)ch;
- (IBAction)changePich:(id)sender;

@end
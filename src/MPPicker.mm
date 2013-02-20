//
//  MPPicker.m
//  MusicArt
//
//  Created by 加藤 亮太 on 2013/02/20.
//
//

#import "MPPicker.h"

@implementation MPPicker

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        ALplayer = NULL;
        slider.value = 0.5;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


// iPodの曲目のピッカーを表示
-(IBAction)showMediaPicker:(id)sender
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    [picker setDelegate: self];
    [picker setAllowsPickingMultipleItems: NO];
    picker.prompt = NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
    
    // pickerをModalViewに表示
    [self presentModalViewController: picker animated: YES];
    [picker release];
}



//選択した曲に対して処理を行う
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMediaItem *item = [mediaItemCollection.items lastObject];
    
    NSLog(@"export succeeded?:%@",[self exportItem:item]? @"YES": @"NO");
    
    [self dismissModalViewControllerAnimated:YES];
}

//cafファイルに変換してファイルの書き出し
- (BOOL)exportItem:(MPMediaItem *)item
{
    if(ALplayer){
        delete ALplayer;
    }
    
    ALplayer = new ofxOpenALSoundPlayer;
    
    NSError *error = nil;
    
    NSDictionary *audioSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:44100.0],AVSampleRateKey,
                                  [NSNumber numberWithInt:1],AVNumberOfChannelsKey, //チャネルを1にしておかないと音の減衰ができない
                                  [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                  [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                  [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                  [NSNumber numberWithBool:0], AVLinearPCMIsBigEndianKey,
                                  [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                  [NSData data], AVChannelLayoutKey, nil];
    
    //読み込み側のセットアップ
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset *URLAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    if (!URLAsset) return NO;
    
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:URLAsset error:&error];
    if (error) return NO;
    
    NSArray *tracks = [URLAsset tracksWithMediaType:AVMediaTypeAudio];
    if (![tracks count]) return NO;
    
    AVAssetReaderAudioMixOutput *audioMixOutput = [AVAssetReaderAudioMixOutput
                                                   assetReaderAudioMixOutputWithAudioTracks:tracks
                                                   audioSettings:audioSetting];
    
    if (![assetReader canAddOutput:audioMixOutput]) return NO;
    
    [assetReader addOutput:audioMixOutput];
    
    if (![assetReader startReading]) return NO;
    
    
    //書き込み側のセットアップ
    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    NSString *outPath = [[docDir stringByAppendingPathComponent:@"music1"]
                         stringByAppendingPathExtension:@"caf"];
    
    NSURL *outURL = [NSURL fileURLWithPath:outPath];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:outURL
                                                          fileType:AVFileTypeCoreAudioFormat
                                                             error:&error];
    //ファイルが存在している場合は削除する
    NSFileManager *manager = [NSFileManager defaultManager];
    if([manager fileExistsAtPath:outPath]){
        [manager removeItemAtPath:outPath error:&error];
    }
    
    if (error) return NO;
    
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                              outputSettings:audioSetting];
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    if (![assetWriter canAddInput:assetWriterInput]) return NO;
    
    [assetWriter addInput:assetWriterInput];
    
    if (![assetWriter startWriting]) return NO;
    
    
    
    //コピー処理
    [assetReader retain];
    [assetWriter retain];
    
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    dispatch_queue_t queue = dispatch_queue_create("assetWriterQueue", NULL);
    
    //書き込み処理
    [assetWriterInput requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
        
        NSLog(@"start");
        
        while (1){
            if ([assetWriterInput isReadyForMoreMediaData]) {
                
                CMSampleBufferRef sampleBuffer = [audioMixOutput copyNextSampleBuffer];
                
                if (sampleBuffer) {
                    [assetWriterInput appendSampleBuffer:sampleBuffer];
                    CFRelease(sampleBuffer);
                }
                else {
                    [assetWriterInput markAsFinished];
                    break;
                }
            }
        }
        
        [assetWriter finishWriting];
        [assetReader release];
        [assetWriter release];
        
        NSLog(@"finish");
        
        char *musicPath = (char *)[outPath UTF8String];
        ALplayer->unloadSound();
        
        ALplayer->loadSound(musicPath);
        
        ALplayer->play();
        
    }];
    
    dispatch_release(queue);
    
    return YES;
}

// 曲をキャンセルした時
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	[self dismissModalViewControllerAnimated:YES];
}

// 曲を再生
-(IBAction)playMediaItem:(id)sender
{
    if(ALplayer)
        ALplayer->play();
}

// 曲をポーズ
-(IBAction)pauseMediaItem:(id)sender
{
    if(ALplayer)
        ALplayer->stop();
}

// チャンネルを指定して、再生レベルを取得
-(float)getLevelWithChannel:(int)ch
{
    //    if(player.playing){
    //        [player updateMeters];
    //        float db = [player averagePowerForChannel:ch];
    //        float power = pow(10, (0.05 * db));
    //        return power;
    //    } else {
    //        return nil;
    //    }
    return nil;
}

//ピッチをスライダーで実現
- (IBAction)changePich:(id)sender {
    ALplayer->setPitch(0.5 + slider.value);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    myApp = (testApp*)ofGetAppPtr();
    //player.delegate = self;
}


- (void)viewDidUnload
{

    [slider release];
    slider = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    location = [[touches anyObject] locationInView:self.view];
    if(ALplayer){
        //NSLog(@"touchesBegan: (x, y) = (%.0f, %.0f)", location.x, location.y);
        //ALplayer->setPitch(0.5 + location.y / ofGetHeight());
        ALplayer->setLocation(location.x, 0, location.y);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    location = [[touches anyObject] locationInView:self.view];
    
    if(ALplayer){
        //NSLog(@"touchesMoved: (x, y) = (%.0f, %.0f)", location.x, location.y);
        //ALplayer->setPitch(0.5 + location.y / ofGetHeight());
        ALplayer->setLocation(location.x, 0, location.y);
    }
}

- (void)dealloc {
    [slider release];
    [super dealloc];
}
@end
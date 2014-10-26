//
//  RecordViewController.m
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-18.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasRecordViewController.h"
#import "RasMusicSelectViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import <TheAmazingAudioEngine/AEWaveImageGenerator.h>
#import <TheAmazingAudioEngine/AEToneFilter.h>
#import <TheAmazingAudioEngine/AERecorder.h>
#import <TheAmazingAudioEngine/AEPlaythroughChannel.h>

#define kRasTmpRecordFile				@"record.caf"

typedef NS_ENUM(NSUInteger, RasRecordPhase)
{
	RasRecordPhaseInit = 0,
	RasRecordPhaseRecording,
	RasRecordPhaseRecordFinish,
	RasRecordPhaseRecordPlaying,
};

@interface RasRecordViewController ()
{

}
@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) RasTrackInfo *trackInfoBg;
@property (nonatomic, strong) RasTrackInfo *trackInfoRecord;
@property (nonatomic, assign) RasRecordPhase currentPhase;
@property (nonatomic, strong) AEPlaythroughChannel *playthroughChannel;

- (void)reset;
- (void)resetAudioController;
- (AEAudioController *)audioControllerForRecord;
- (void)setPlaythroughChannel:(BOOL)bThrough audioController:(AEAudioController *)audioController;
- (NSString *)recordPath;

- (void)changePhase:(RasRecordPhase)phase;

@end

@implementation RasRecordViewController
@synthesize btnMusic = _btnMusic;
@synthesize lbMusicTitle = _lbMusicTitle;
@synthesize btnReset = _btnReset;
@synthesize btnRecord = _btnRecord;
@synthesize btnFinish = _btnFinish;
@synthesize btnPlay = _btnPlay;
@synthesize btnSave = _btnSave;
@synthesize trackEditorBg = _trackEditorBg;
@synthesize trackEditorRecord = _trackEditorRecord;
@synthesize btnPlayBg = _btnPlayBg;
@synthesize btnPlayRecord = _btnPlayRecord;
@synthesize audioController = _audioController;
@synthesize trackInfoBg = _trackInfoBg;
@synthesize trackInfoRecord = _trackInfoRecord;
@synthesize currentPhase = _currentPhase;
@synthesize playthroughChannel = _playthroughChannel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	
	self.lbMusicTitle.text = @"No background";
	[self changePhase:RasRecordPhaseInit];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (IBAction)btnMusic_Click:(id)sender
{
	RasMusicSelectViewController *selectCtrl = [[RasMusicSelectViewController alloc] initWithNibName:@"RasMusicSelectViewController" bundle:nil];
	selectCtrl.finish = ^(RasTrackInfo *ti){
		self.trackInfoBg = ti;
		[self resetAudioController];
		if (ti != nil)
		{
			AVURLAsset *assert = [ti assert];
			if (assert != nil)
			{
				self.lbMusicTitle.text = ti.name;
				
				CGSize size = self.trackEditorBg.frame.size;
				size.width *= [UIScreen mainScreen].scale;
				size.height *= [UIScreen mainScreen].scale;
				[AEWaveImageGenerator waveImageWithAssert:assert
													 size:size
													color:[UIColor redColor]
											  isHeightMax:YES
													start:^(AEWaveImageGenerator *generator){
														[SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
													}
												   finish:^(AEWaveImageGenerator *generator){
													   [SVProgressHUD dismiss];
													   NSTimeInterval duration = CMTimeGetSeconds(assert.duration);
													   [self.trackEditorBg bindWithImage:generator.waveImage duration:duration];
												   }
				 ];
				return;
			}
		}
		self.lbMusicTitle.text = @"No background";
		self.trackEditorBg.imgViewWave.image = nil;
		
//		AVPlayerItem *playerItem = [ti avPlayerItem];
//		if (playerItem == nil)
//		{
//			return;
//		}
//
////		self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:YES];
//		self.audioController = [[AEAudioController alloc] initGenericOutputWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]];
//		_audioController.preferredBufferDuration = 0.005;
//		_audioController.useMeasurementMode = YES;
//		
//		AEAvPlayerItemPlayer *player = [[AEAvPlayerItemPlayer alloc] initWithWithItem:playerItem audioController:self.audioController];
//		[player prepareWithProgress:
//		 ^(NSTimeInterval currentTime, NSTimeInterval duration){
//			 
//		 }
//							 finish:
//		 ^(){
//			 NSLog(@"%@ finish", player);
//		 }];
//		
//		player.volume = 1.0;
//		player.channelIsPlaying = YES;
//		player.channelIsMuted = NO;
//		
//		AEChannelGroupRef group = [_audioController createChannelGroup];
//		[_audioController addChannels:[NSArray arrayWithObjects:player, nil] toChannelGroup:group];
//		
//		AEWaveImageGenerator *generator = [[AEWaveImageGenerator alloc] initWithAudioController:self.audioController width:1920 height:90 duration:player.duration color:[UIColor redColor]];
//		generator.isHeightMax = YES;
//		generator.finish = ^(UIImage *image){
//			self.imgViewBgWave.image = image;
//		};
//		[_audioController addOutputReceiver:generator];
//		
////		AEToneFilter *up = [[AEToneFilter alloc] init];
////		[_audioController addFilter:up];
//		
//		NSError *error = nil;
//		[self.audioController start:&error];
//		if (error != nil)
//		{
//			NSLog(@"%@", error);
//		}
	};
	[self presentViewController:[RasUIKit navCtrlWithRootCtrl:selectCtrl] animated:YES];
}

- (IBAction)btnReset_Click:(id)sender
{
	[self reset];
	[self changePhase:RasRecordPhaseInit];
}

- (IBAction)btnRecord_Click:(id)sender
{
	[self changePhase:RasRecordPhaseRecording];
	[self resetAudioController];
	self.audioController = [self audioControllerForRecord];
	
	NSError *error = nil;
	[self.audioController start:&error];
	if (error != nil)
	{
		NSLog(@"%@", error);
	}
}

- (IBAction)btnFinish_Click:(id)sender
{
	[self changePhase:RasRecordPhaseRecordFinish];
	[self.audioController stop];
	
	NSString *path = [self recordPath];
	if ([RFStorageKit isExist:path])
	{
		RasTrackInfo *ti = [[RasTrackInfo alloc] init];
		ti.name = @"record";
		ti.path = kRasTmpRecordFile;
		ti.location = RasTrackLocationTmp;
		ti.date = [NSDate date];
		self.trackInfoRecord = ti;
		
		AVURLAsset *assert = [ti assert];
		CGSize size = self.trackEditorRecord.frame.size;
		size.width *= [UIScreen mainScreen].scale;
		size.height *= [UIScreen mainScreen].scale;
		[AEWaveImageGenerator waveImageWithAssert:assert
											 size:size
											color:[UIColor redColor]
									  isHeightMax:YES
											start:^(AEWaveImageGenerator *generator){
												[SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
											}
										   finish:^(AEWaveImageGenerator *generator){
											   [SVProgressHUD dismiss];
											   NSTimeInterval duration = CMTimeGetSeconds(assert.duration);
											   [self.trackEditorRecord bindWithImage:generator.waveImage duration:duration];
										   }];
	}
	else
	{
		[RFAlertView show:@"Record Fail"];
	}
}

- (IBAction)btnPlay_Click:(id)sender
{
	if (!_btnPlay.isSelected)
	{
		[self changePhase:RasRecordPhaseRecordPlaying];
	}
	else
	{
		[self changePhase:RasRecordPhaseRecordFinish];
	}
}

- (IBAction)btnSave_Click:(id)sender
{
	[self changePhase:RasRecordPhaseInit];
}

- (IBAction)btnPlayBg_Click:(id)sender
{

}

- (IBAction)btnPlayRecord_Click:(id)sender
{
	
}

- (void)reset
{
	[self resetAudioController];
	
	self.trackInfoBg = nil;
	[_trackEditorBg reset];
	
	self.trackInfoRecord = nil;
	[_trackEditorRecord reset];
	
	self.playthroughChannel = nil;
}

- (void)resetAudioController
{
	if (self.audioController != nil)
	{
		[self.audioController stop];
		self.audioController = nil;
	}
}

- (AEAudioController *)audioControllerForRecord
{
	NSError *error = nil;
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
	NSLog(@"%@", error);
	[[AVAudioSession sharedInstance] setActive:YES error:&error];
	NSLog(@"%@", error);
	
	AEAudioController *audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:YES];
	audioController.preferredBufferDuration = 0.005;
	audioController.useMeasurementMode = YES;
	
	AVPlayerItem *playerItem = nil;
	if (_trackInfoBg != nil)
	{
		playerItem = [_trackInfoBg avPlayerItem];
	}
	
	if (playerItem != nil)
	{
		AEAvPlayerItemPlayer *player = [[AEAvPlayerItemPlayer alloc] initWithWithItem:playerItem audioController:audioController];
		[player prepareWithProgress:
		 ^(NSTimeInterval currentTime, NSTimeInterval duration){
			 
		 }
							 finish:
		 ^(){
			 NSLog(@"%@ finish", player);
		 }];
		player.volume = 1.0;
		player.channelIsPlaying = YES;
		player.channelIsMuted = NO;
		
		AEChannelGroupRef group = [audioController createChannelGroup];
		[audioController addChannels:[NSArray arrayWithObjects:player, nil] toChannelGroup:group];
	}
	
	AERecorder *recorder = [[AERecorder alloc] initWithAudioController:audioController];
	[recorder beginRecordingToFileAtPath:[self recordPath] fileType:kAudioFileCAFType error:&error];
	if (error != nil)
	{
		NSLog(@"%@", error);
		return nil;
	}
	[audioController addInputReceiver:recorder];	// 为了输入
	[audioController addOutputReceiver:recorder];	// 为了写入
	
	if ([RFAudioKit isHeadphone])
	{
		[self setPlaythroughChannel:YES audioController:audioController];
	}
	
	return audioController;
}

- (void)setPlaythroughChannel:(BOOL)bThrough audioController:(AEAudioController *)audioController
{
	if (bThrough)
	{
		if (self.playthroughChannel == nil)
		{
			// 为了录音回放
			self.playthroughChannel = [[AEPlaythroughChannel alloc] initWithAudioController:audioController];
			[audioController addInputReceiver:_playthroughChannel];
			[audioController addChannels:@[_playthroughChannel]];
		}
	}
	else
	{
		if (self.playthroughChannel != nil)
		{
			[audioController removeChannels:@[_playthroughChannel]];
			[audioController removeInputReceiver:_playthroughChannel];
			self.playthroughChannel = nil;
		}
	}
}

- (NSString *)recordPath
{
	static NSString *s_path = nil;
	if (s_path == nil)
	{
		s_path = [RFStorageKit tmpPathWithDirectory:nil file:kRasTmpRecordFile];
	}
	return s_path;
}

- (void)changePhase:(RasRecordPhase)phase
{
	switch (phase)
	{
		case RasRecordPhaseInit:
			{
				_btnRecord.hidden = NO;
				_btnFinish.hidden = NO;
				_btnPlay.hidden = YES;
				_btnSave.hidden = YES;
				
				_btnRecord.enabled = YES;
				_btnFinish.enabled = NO;
				_btnPlay.enabled = NO;
				_btnSave.enabled = NO;
			}
			break;
		case RasRecordPhaseRecording:
			{
				_btnRecord.hidden = NO;
				_btnFinish.hidden = NO;
				_btnPlay.hidden = YES;
				_btnSave.hidden = YES;
				
				_btnRecord.enabled = NO;
				_btnFinish.enabled = YES;
				_btnPlay.enabled = NO;
				_btnSave.enabled = NO;
			}
			break;
		case RasRecordPhaseRecordFinish:
			{
				_btnRecord.hidden = YES;
				_btnFinish.hidden = YES;
				_btnPlay.hidden = NO;
				_btnSave.hidden = NO;
				
				_btnRecord.enabled = NO;
				_btnFinish.enabled = NO;
				_btnPlay.enabled = YES;
				_btnSave.enabled = YES;
				
				_btnPlay.selected = NO;
			}
			break;
		case RasRecordPhaseRecordPlaying:
			{
				_btnRecord.hidden = YES;
				_btnFinish.hidden = YES;
				_btnPlay.hidden = NO;
				_btnSave.hidden = NO;
				
				_btnRecord.enabled = NO;
				_btnFinish.enabled = NO;
				_btnPlay.enabled = YES;
				_btnSave.enabled = YES;
				
				_btnPlay.selected = YES;
			}
			break;
		default:
			break;
	}
	
	_currentPhase = phase;
}

@end

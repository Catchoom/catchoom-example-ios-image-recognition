//
//  CloudRecognitionSnapPhotoViewController.m
//  craftar-sdk-sampleapp
//
//  Created by Luis Martinell Andreu on 9/17/13.
//  Copyright (c) 2013 Catchoom. All rights reserved.
//

#import "CloudRecognitionFinderModeViewController.h"
#import <CraftARCloudImageRecognitionSDK/CraftARSDK.h>
#import <CraftARCloudImageRecognitionSDK/CraftARCloudRecognition.h>

@interface CloudRecognitionFinderModeViewController () <CraftARSDKProtocol, SearchProtocol> {
    CraftARSDK *_sdk;
    CraftARCloudRecognition *_crs;
    bool _captureStarted;
}

@end

@implementation CloudRecognitionFinderModeViewController

#pragma mark view initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup the CraftAR SDK
    _sdk = [CraftARSDK sharedCraftARSDK];
    _sdk.delegate = self;
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    // Start Video Preview for search and tracking
    [_sdk startCaptureWithView:self._preview];
    
    if (_captureStarted) {
        _crs = [CraftARCloudRecognition sharedCloudImageRecognition];
        _crs.delegate = self;
        _sdk.searchControllerDelegate = _crs.mSearchController;
        [_sdk startFinder];
    }
}

#pragma mark -


#pragma mark Finder mode implementation

- (void) didStartCapture {
    _captureStarted=YES;
    self._scanningOverlay.hidden = NO;
    [self._scanningOverlay setNeedsDisplay];
    
    _crs = [CraftARCloudRecognition sharedCloudImageRecognition];
    _crs.delegate = self;
    _sdk.searchControllerDelegate = _crs.mSearchController;
    [_sdk startFinder];
}


- (void) didGetSearchResults:(NSArray *)results {
    self._scanningOverlay.hidden = YES;
    [_sdk stopFinder];
    
    if ([results count] >= 1) {
        // Found one item, launch its content on a webView:
        CraftARSearchResult* result = [results objectAtIndex:0];
        
        CraftARItem *item = result.item;
        
        // Open URL in Webview
        UIViewController *webViewController = [[UIViewController alloc] init];
        UIWebView *uiWebView = [[UIWebView alloc] initWithFrame: self.view.frame];
        [uiWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:item.url]]];
        uiWebView.scalesPageToFit = YES;
        [webViewController.view addSubview: uiWebView];
        [self.navigationController pushViewController:webViewController animated:YES];
        self._scanningOverlay.hidden = YES;
    } else {
        self._scanningOverlay.hidden = NO;
        [self._scanningOverlay setNeedsDisplay];
        [_sdk startFinder];
    }
}


- (void) didFailSearchWithError:(NSError *)error {
    self._scanningOverlay.hidden = NO;
    [self._scanningOverlay setNeedsDisplay];
    [_sdk startFinder];
}

- (void) didValidateToken {
    // Token valid, do nothing
}

#pragma mark -


#pragma mark view lifecycle

- (void) viewWillDisappear:(BOOL)animated {
    [_sdk stopCapture];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

@end

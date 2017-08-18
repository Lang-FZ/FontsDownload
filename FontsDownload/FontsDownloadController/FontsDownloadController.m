//
//  FontsDownloadController.m
//  FontsDownload
//
//  Created by 郎凤招 on 2016/11/5.
//  Copyright © 2016年 Lang.FZ. All rights reserved.
//

#import "FontsDownloadController.h"
#import <CoreText/CoreText.h>
#import "MBProgressHUD.h"

@interface FontsDownloadController () <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate>

@property (nonatomic, strong) UITableView *fontsTable;
@property (nonatomic, strong) UILabel *fontsLabel;
@property (nonatomic, strong) NSArray *fontNames;
@property (nonatomic, copy) NSString *errorMessage;

@end

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

static NSString * const fontsDownloadIdentifer = @"fontsDownloadCell";

@implementation FontsDownloadController

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self createFontsDownloadView];
    }
    return self;
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createFontsDownloadView {
    
    NSDictionary *descriptorOptions = @{
                                        (id)kCTFontDownloadableAttribute : @YES
                                        };
    CTFontDescriptorRef descriptor = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)descriptorOptions);
    CFArrayRef fontDescriptors = CTFontDescriptorCreateMatchingFontDescriptors(descriptor, NULL);
    
    NSMutableArray *fontArr = [NSMutableArray array];
    
    for (UIFontDescriptor *fontDescriptor in (__bridge NSArray *)(fontDescriptors)) {
        [fontArr addObject:fontDescriptor.postscriptName];
    }
    _fontNames = fontArr;
    
    [self.view addSubview:self.fontsTable];
    [self.view addSubview:self.fontsLabel];
}

#pragma mark - tableView 代理 数据源

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fontNames.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:fontsDownloadIdentifer];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fontsDownloadIdentifer];
    } else {
        while ([cell.subviews lastObject] != nil) {
            [(UIView *)[cell.subviews lastObject] removeFromSuperview];
        }
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 50 - 0.5, kScreenW, 0.5)];
    separatorView.backgroundColor = [UIColor colorWithRed:172/255.0 green:185/255.0 blue:214/255.0 alpha:1];
    [cell addSubview:separatorView];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 50 - 0.5)];
    text.numberOfLines = 0;
    text.text = _fontNames[indexPath.row];
    
    [cell addSubview:text];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self asynchronouslySetFontName:_fontNames[indexPath.row]];
}

#pragma mark - 下载字体

- (void)asynchronouslySetFontName:(NSString *)fontName {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.delegate = self;
    /*
     MBProgressHUDModeDeterminate
     MBProgressHUDModeDeterminateHorizontalBar
     */
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = @"数据加载中";
    hud.contentColor = [UIColor colorWithRed:71/255.0 green:141/255.0 blue:151/255.0 alpha:1];
    hud.alpha = 0.5;
    [hud showAnimated:YES];
    
    UIFont* aFont = [UIFont fontWithName:fontName size:25.];
// If the font is already downloaded
    if (aFont && ([aFont.fontName compare:fontName] == NSOrderedSame || [aFont.familyName compare:fontName] == NSOrderedSame)) {
        
        [hud hideAnimated:YES];
        
// Go ahead and display the sample text.
        NSUInteger sampleIndex = [_fontNames indexOfObject:fontName];
        _fontsLabel.text = [NSString stringWithFormat:@"汉字测试 文字名称:\n%@",[_fontNames objectAtIndex:sampleIndex]];
        _fontsLabel.font = [UIFont fontWithName:fontName size:25.];
        
#pragma - mark 大小
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, 0., NULL);
        CFStringRef fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute);
//        NSLog(@"%@", (__bridge NSString *)(fontURL));
        
        NSString *fileStr = [NSString stringWithFormat:@"%@",(__bridge NSString *)(fontURL)];
        
        NSString *filePath = [fileStr substringWithRange:NSMakeRange(7, fileStr.length - 7)];
        
        NSLog(@"\n%@",filePath);
        
        NSLog(@"\n%@",[self fileSizeAtPath:filePath]);
        
        return;
    }
    
// Create a dictionary with the font's PostScript name.
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:fontName, kCTFontNameAttribute, nil];
    
// Create a new font descriptor reference from the attributes dictionary.
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attrs);
    
    NSMutableArray *descs = [NSMutableArray arrayWithCapacity:0];
    [descs addObject:(__bridge id)desc];
    CFRelease(desc);
    
    __block BOOL errorDuringDownload = NO;
    
// Start processing the font descriptor..
// This function returns immediately, but can potentially take long time to process.
// The progress is notified via the callback block of CTFontDescriptorProgressHandler type.
// See CTFontDescriptor.h for the list of progress states and keys for progressParameter dictionary.
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler( (__bridge CFArrayRef)descs, NULL,  ^(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {

        double progressValue = [[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingPercentage] doubleValue];
        
//        NSLog(@"\n%f\n%f\n%f",[[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingTotalDownloadedSize] doubleValue],[[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingTotalAssetSize] doubleValue],[[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingCurrentAssetSize] doubleValue]);
        
        if (state == kCTFontDescriptorMatchingDidBegin) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Show something in the text view to indicate that we are downloading
                _fontsLabel.text= [NSString stringWithFormat:@"下载中\n%@", fontName];
                _fontsLabel.font = [UIFont systemFontOfSize:25.];
            
                NSLog(@"Begin Matching");
            });
        } else if (state == kCTFontDescriptorMatchingDidFinish) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                
                [hud hideAnimated:YES];
                
// Display the sample text for the newly downloaded font
                NSUInteger sampleIndex = [_fontNames indexOfObject:fontName];
                _fontsLabel.text = [NSString stringWithFormat:@"汉字测试 文字名称:\n%@",[_fontNames objectAtIndex:sampleIndex]];
                _fontsLabel.font = [UIFont fontWithName:fontName size:17.];
                
// Log the font URL in the console
#pragma - mark 大小
                CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, 0., NULL);
                CFStringRef fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute);
//        NSLog(@"%@", (__bridge NSString *)(fontURL));
                
                NSString *fileStr = [NSString stringWithFormat:@"%@",(__bridge NSString *)(fontURL)];
                
                NSString *filePath = [fileStr substringWithRange:NSMakeRange(7, fileStr.length - 7)];
                
                NSLog(@"\n%@",filePath);
                
                NSLog(@"\n%@",[self fileSizeAtPath:filePath]);
                CFRelease(fontURL);
                CFRelease(fontRef);
                
                if (!errorDuringDownload) {
                    NSLog(@"%@ downloaded", fontName);
                }
            });
        } else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                hud.progress = 0.0;
                NSLog(@"Begin Downloading");
            });
        } else if (state == kCTFontDescriptorMatchingDidFinishDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                NSLog(@"Finish downloading");
            });
        } else if (state == kCTFontDescriptorMatchingDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                
                hud.progress = progressValue / 100.0;
                
                NSLog(@"Downloading %.0f%% complete", progressValue);
            });
        } else if (state == kCTFontDescriptorMatchingDidFailWithError) {
            
            [hud hideAnimated:YES];
            
// An error has occurred.
// Get the error message
            NSError *error = [(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingError];
            if (error != nil) {
                _errorMessage = [error description];
            } else {
                _errorMessage = @"ERROR MESSAGE IS NOT AVAILABLE!";
            }
// Set our flag
            errorDuringDownload = YES;
            
            dispatch_async( dispatch_get_main_queue(), ^ {
                NSLog(@"Download error: %@", _errorMessage);
            });
        }
        return (bool)YES;
    });
}

#pragma mark - 计算字体大小

- (NSString *)fileSizeAtPath:(NSString *)filePathStr{
    
//    NSData* data = [NSData dataWithContentsOfFile:[VoiceRecorderBaseVC getPathByFileName:_convertAmr ofType:@"amr"]];
//    NSLog(@"amrlength = %d",data.length);
//    NSString * amr = [NSString stringWithFormat:@"amrlength = %d",data.length];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *filePath = [filePathStr stringByRemovingPercentEncoding];
    
    if ([manager fileExistsAtPath:filePath]) {
        
        NSString *fileSize = [NSString string];
        
        if ([[manager attributesOfItemAtPath:filePath error:nil] fileSize] > (1000 * 1000)) {
            
            fileSize = [NSString stringWithFormat:@"%.2fM",[[manager attributesOfItemAtPath:filePath error:nil] fileSize] / (1000 * 1000.0)];
        } else if ([[manager attributesOfItemAtPath:filePath error:nil] fileSize] > 1000) {
        
            fileSize = [NSString stringWithFormat:@"%.2fK",[[manager attributesOfItemAtPath:filePath error:nil] fileSize] / 1000.0];
        } else if ([[manager attributesOfItemAtPath:filePath error:nil] fileSize] > 0) {
            
            fileSize = [NSString stringWithFormat:@"%lluB",[[manager attributesOfItemAtPath:filePath error:nil] fileSize]];
        }
        
        return fileSize;
    }
    return nil;
}
    
#pragma mark - 懒加载
    
- (UITableView *)fontsTable {
    
    if (!_fontsTable) {
        
        _fontsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, kScreenW, kScreenH - 20 - 200) style:UITableViewStylePlain];
        _fontsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _fontsTable.delegate = self;
        _fontsTable.dataSource = self;
    }
    return _fontsTable;
}
    
- (UILabel *)fontsLabel {
    
    if (!_fontsLabel) {
        
        _fontsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenH - 200, kScreenW, 200)];
        _fontsLabel.numberOfLines = 0;
        _fontsLabel.backgroundColor = [UIColor cyanColor];
    }
    return _fontsLabel;
}

@end

//
//  ViewController.m
//  common
//
//  Created by 王建 on 2016/12/2.
//  Copyright © 2016年 王建. All rights reserved.
//

#import "ViewController.h"
#import "ImagePickerController.h"
#import "JJAlert.h"
#import "DBManager.h"
#import "JJToast.h"
#import <YYWebImage.h>
#import "tableViewDelegate.h"
#define IMAGEURL @"http://img01.sogoucdn.com/app/a/100540002/610643.jpg"

@interface ViewController ()

@property (nonatomic,strong) YYAnimatedImageView *image;
@property (weak, nonatomic) IBOutlet YYAnimatedImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *labCache;

@property (strong , nonatomic)  UITableView *tableView;
@property (strong , nonatomic)  tableViewDelegate *dataSource;

@end


@implementation ViewController

- (YYAnimatedImageView *)image
{
    if (!_image) {
        _image = [[YYAnimatedImageView alloc]initWithFrame:CGRectMake(10, 300,100 , 200)];
    }
    return _image;
}
- (IBAction)clear:(id)sender {
    [self clearFile];
     self.labCache.text = [NSString stringWithFormat:@"%@",@([self readCacheSize])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.labCache.text = [NSString stringWithFormat:@"%@",@([self readCacheSize])];
    [self.view addSubview:self.image];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loadImage:(id)sender {
    
    // load from remote url
//    self.img.yy_imageURL = [NSURL URLWithString:IMAGEURL];
    
    // load from local url
//    self.img.yy_imageURL = [NSURL fileURLWithPath:@"/tmp/logo.png"];
    
    
    
//    UIImageView *imageView = [YYAnimatedImageView new];
//    self.img.yy_imageURL = [NSURL URLWithString:IMAGEURL];
    
//    [self.img yy_setImageWithURL:[NSURL URLWithString:IMAGEURL] options:YYWebImageOptionProgressive];
//    [self.img yy_setImageWithURL:[NSURL URLWithString:IMAGEURL] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation];
    
    
    
//    
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    
    // get cache capacity
    //    cache.memoryCache.totalCost;
    //    cache.memoryCache.totalCount;
    //    cache.diskCache.totalCost;
    //    cache.diskCache.totalCount;
    
    // clear cache
    [cache.memoryCache removeAllObjects];
    [cache.diskCache removeAllObjects];
    
    // clear disk cache with progress
    [cache.diskCache removeAllObjectsWithProgressBlock:^(int removedCount, int totalCount) {
        // progress
    } endBlock:^(BOOL error) {
        // end
    }];

    
    
    [self.img yy_setImageWithURL:[NSURL URLWithString:IMAGEURL]
                      placeholder:nil
                          options:YYWebImageOptionSetImageWithFadeAnimation
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                             progress = (float)receivedSize / expectedSize;
                         }
                        transform:^UIImage *(UIImage *image, NSURL *url) {
                            image = [image yy_imageByResizeToSize:CGSizeMake(1000, 1000) contentMode:UIViewContentModeScaleAspectFill];
                            return [image yy_imageByRoundCornerRadius:0];
                        }
                       completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                           if (from == YYWebImageFromDiskCache) {
                               NSLog(@"load from disk cache");
                           }
                       }];
    
    
    
    [self.image yy_setImageWithURL:[NSURL URLWithString:IMAGEURL]
                     placeholder:[[UIImage alloc]init]
                         options:YYWebImageOptionSetImageWithFadeAnimation
                        progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                            NSLog(@"%@---%@",@(expectedSize),@(receivedSize));
//                                                         progress = (float)receivedSize / expectedSize;
                        }
                       transform:^UIImage *(UIImage *image, NSURL *url) {
                           image = [image yy_imageByResizeToSize:CGSizeMake(100, 100) contentMode:UIViewContentModeScaleAspectFill];
                           return [image yy_imageByRoundCornerRadius:0];
                       }
                      completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                          if (from == YYWebImageFromDiskCache) {
                              NSLog(@"load from disk cache");
                          }
                      }];
    
    
}

- (IBAction)alt:(id)sender {
    JJAlert * alt = [[JJAlert alloc]initWithTitle:@"标题" andMessage:@"信息" style:STYLE_ACTION_SHEET];
    [alt addButton:ITEM_OK withTitle:@"确定" handler:^(JJAlertItem *item) {
        NSLog(@"点击确定");
    }];
    [alt addButton:ITEM_OTHER withTitle:@"取消" handler:^(JJAlertItem *item) {
        NSLog(@"点击取消");
    }];
    [alt show];
}
- (IBAction)photo:(id)sender {
    ImagePickerController *controller = [[ImagePickerController alloc]init];
    [controller cameraSourceType:UIImagePickerControllerSourceTypeCamera onFinishingBlock:^(UIImagePickerController *picker, NSDictionary *info, UIImage *originalImage, UIImage *editedImage) {
        NSLog(@"<%@>,<%@>,<%@>,<%@>",picker,info,originalImage,editedImage);
    } onCancelingBlock:^{
        
    }];
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}
- (IBAction)db:(id)sender {
}
- (IBAction)tios:(id)sender {
//    [JKToast showWithText:@"哦偶!打开失败喽!"];
//    [JKToast showWithText:@"哦偶!打开失败喽!" bottomOffset:100];
    [JJToast showWithText:@"哦偶!打开失败喽!" topOffset:10 duration:5];
}



//1. 获取缓存文件的大小
-( float )readCacheSize
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES) firstObject];
    return [ self folderSizeAtPath :cachePath];
}


//由于缓存文件存在沙箱中，我们可以通过NSFileManager API来实现对缓存文件大小的计算。
// 遍历文件夹获得文件夹大小，返回多少 M
- ( float ) folderSizeAtPath:( NSString *) folderPath{
    
    NSFileManager * manager = [NSFileManager defaultManager];
    if (![manager isReadableFileAtPath :folderPath])return 0 ;
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath :folderPath] objectEnumerator];
    NSString * fileName;
     NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSLog(@"%@",files);
    if (files.count == 1) {
        if ([files[0] isEqualToString:@"Snapshots"]) {
            return 0;
        }
    }
    long long folderSize = 0 ;
    while ((fileName = [childFilesEnumerator nextObject]) != nil ){
        //获取文件全路径
        NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent :fileName];
        folderSize += [ self fileSizeAtPath :fileAbsolutePath];
    }
    
    return folderSize/( 1024.0 * 1024.0);
    
}



// 计算 单个文件的大小
- ( long long ) fileSizeAtPath:( NSString *) filePath{
    NSFileManager * manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath :filePath]){
        return [[manager attributesOfItemAtPath :filePath error : nil] fileSize];
    }
    return 0;
}



//2. 清除缓存
- (void)clearFile
{
    NSString * cachePath = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES ) firstObject];
    NSArray * files = [[NSFileManager defaultManager ] subpathsAtPath :cachePath];
    //NSLog ( @"cachpath = %@" , cachePath);
    
       for ( NSString * p in files) {
        
        NSError * error = nil ;
        //获取文件全路径
        NSString * fileAbsolutePath = [cachePath stringByAppendingPathComponent :p];
        
        if ([[NSFileManager defaultManager ] fileExistsAtPath :fileAbsolutePath]) {
            [[NSFileManager defaultManager ] removeItemAtPath :fileAbsolutePath error :&error];
        }
    }
    NSError *error;
    [[NSFileManager defaultManager ] removeItemAtPath :cachePath error :&error];

    //读取缓存大小
//    float cacheSize = [self readCacheSize] *1024;
//    self.cacheSize.text = [NSString stringWithFormat:@"%.2fKB",cacheSize];
    
}

# pragma mark   --- 网络请求

- (void)net
{


}


# pragma mark   --- 懒加载方法

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self.dataSource;
        _tableView.dataSource = self.dataSource;
    }
    return _tableView;
}

- (tableViewDelegate *)dataSource
{
    return _dataSource;
}
@end

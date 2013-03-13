//
//  FlickrPhotoCache.m
//  SPoT
//
//  Created by Ryan Zulkoski on 3/6/13.
//  Copyright (c) 2013 RZGamer. All rights reserved.
//

#import "FlickrPhotoCache.h"
#import "FlickrFetcher.h"
#import "RZTools.h"

#define PHOTO_CACHE_DIR @"Photos"
#define NUM_BYTES_PER_MB pow(2.0,20)
#define MAX_CACHE_SIZE_IN_MB 3.0
#define IMAGE_URL_KEY @"imageURL"

@implementation FlickrPhotoCache

+ (UIImage *)fetchImageForPhoto:(NSDictionary *)photo
{
    // Attempt to retrieve the image from cache.
    UIImage *image = [[UIImage alloc] initWithData:[self retrieveImageDataForPhoto:photo]];
    NSLog(@"Existing Image%@Found!", image ? @" " : @" NOT ");
        
    if (!image) { // If image was not successfully retrieved from cache, download image data from flickr.        
        [RZTools enableNetworkActivityIndicator];
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:photo[IMAGE_URL_KEY]];
        [RZTools disableNetworkActivityIndicator];
        
        [self storeImageData:imageData forPhoto:photo];
        image = [[UIImage alloc] initWithData:imageData];
    }
    
    return image;
}

+ (NSData *)retrieveImageDataForPhoto:(NSDictionary *)photo
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *urls = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *imageFileURL = [self imageFileURLForPhoto:photo withBaseDirectoryURL:[urls[0] URLByAppendingPathComponent:PHOTO_CACHE_DIR]];
        
    return [NSData dataWithContentsOfURL:imageFileURL];
}

+ (void)storeImageData:(NSData *)imageData forPhoto:(NSDictionary *)photo
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *urls = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *imageFileURL = [self imageFileURLForPhoto:photo withBaseDirectoryURL:[urls[0] URLByAppendingPathComponent:PHOTO_CACHE_DIR]];
    NSString *photosPath = [[urls[0] path] stringByAppendingPathComponent:PHOTO_CACHE_DIR];
    
    float imageDataSize = ([imageData length] / NUM_BYTES_PER_MB);
    while ([self sizeOfCacheAtPath:photosPath usingFileManager:fileManager] + imageDataSize > MAX_CACHE_SIZE_IN_MB) {
        [self removeOldestCachedImageInDirAtPath:photosPath usingFileManager:fileManager];
    }
    [fileManager createDirectoryAtPath:photosPath withIntermediateDirectories:NO attributes:nil error:nil];
    [imageData writeToURL:imageFileURL atomically:YES];
}

+ (void)removeOldestCachedImageInDirAtPath:(NSString *)path
                          usingFileManager:(NSFileManager *)fileManager
{
    NSArray *cachedPhotos = [fileManager contentsOfDirectoryAtPath:path error:nil];

    int indexOfOldestPhoto = 0;
    NSDate *dateOfOldestPhoto = [NSDate date];
    for (int i = 0; i < [cachedPhotos count]; i++) {
        NSURL *urlOfCurrentPhoto = [[NSURL alloc] initFileURLWithPath:[path stringByAppendingPathComponent:cachedPhotos[i]]];
        NSDate *dateOfCurrentPhoto = [[urlOfCurrentPhoto resourceValuesForKeys:@[NSURLContentAccessDateKey] error:nil] objectForKey:NSURLContentAccessDateKey];
        
        if ([dateOfCurrentPhoto compare:dateOfOldestPhoto] == NSOrderedAscending) {
            indexOfOldestPhoto = i;
            dateOfOldestPhoto = dateOfCurrentPhoto;
        }
    }
    [fileManager removeItemAtPath:[path stringByAppendingPathComponent:cachedPhotos[indexOfOldestPhoto]] error:nil];
}

+ (float)sizeOfCacheAtPath:(NSString *)path
          usingFileManager:(NSFileManager *)fileManager
{
    float cacheSize = 0;
    for (NSString *imageFilename in [fileManager contentsOfDirectoryAtPath:path error:nil]){
        NSURL *imageFileURL = [[NSURL alloc] initFileURLWithPath:[path stringByAppendingPathComponent:imageFilename]];
        //NSURL *imageFileURL = [[urls[0] URLByAppendingPathComponent:PHOTO_CACHE_DIR] URLByAppendingPathComponent:imageFilename];
        cacheSize += [[[imageFileURL resourceValuesForKeys:@[NSURLFileSizeKey] error:nil] objectForKey:NSURLFileSizeKey] floatValue];
    }
    NSLog(@"Cache Size = %f", cacheSize / NUM_BYTES_PER_MB);
    return (cacheSize / NUM_BYTES_PER_MB);
}

+ (NSURL *)imageFileURLForPhoto:(NSDictionary *)photo
           withBaseDirectoryURL:(NSURL *)baseDirURL
{
    NSString *photoID = [photo objectForKey:FLICKR_PHOTO_ID];
    NSString *photoFormatExt = [photo objectForKey:FLICKR_PHOTO_ORIGINAL_FORMAT];
    
    return [[baseDirURL URLByAppendingPathComponent:photoID] URLByAppendingPathExtension:photoFormatExt];
}

@end

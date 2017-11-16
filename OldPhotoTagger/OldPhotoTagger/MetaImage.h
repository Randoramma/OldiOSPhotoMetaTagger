/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define STRINGKEY(_x_) ((__bridge NSString *)_x_)
#define EXIFKEY STRINGKEY(kCGImagePropertyExifDictionary)
#define GPSKEY STRINGKEY(kCGImagePropertyGPSDictionary)
#define MAKERKEY STRINGKEY(kCGImagePropertyExifMakerNote)
#define LATREFKEY STRINGKEY(kCGImagePropertyGPSLatitudeRef)
#define LATKEY STRINGKEY(kCGImagePropertyGPSLatitude)
#define LONGREFKEY STRINGKEY(kCGImagePropertyGPSLongitudeRef)
#define LONGKEY STRINGKEY(kCGImagePropertyGPSLongitude)
#define ALTITUDEKEY STRINGKEY(kCGImagePropertyGPSAltitude)
#define DESTLATREFKEY STRINGKEY(kCGImagePropertyGPSDestLatitudeRef)
#define DESTLATKEY STRINGKEY(kCGImagePropertyGPSDestLatitude)
#define DESTLONGREFKEY STRINGKEY(kCGImagePropertyGPSDestLongitudeRef)
#define DESTLONGKEY STRINGKEY(kCGImagePropertyGPSDestLongitude)
#define DIRECTIONKEY STRINGKEY(kCGImagePropertyGPSImgDirection)
#define DESTDISTANCEKEY STRINGKEY(kCGImagePropertyGPSDestDistance)
#define DESTDISTANCEREFKEY STRINGKEY(kCGImagePropertyGPSDestDistanceRef)
#define GPSTIMEKEY STRINGKEY(kCGImagePropertyGPSTimeStamp)
#define GPSDATEKEY STRINGKEY(kCGImagePropertyGPSDateStamp)


NSMutableDictionary *imagePropertiesDictionaryForFilePath(NSString *path);
NSMutableDictionary *imagePropertiesFromImage(UIImage *image);

@interface MetaImage : NSObject
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, readonly) NSMutableDictionary *properties;
@property (nonatomic, readonly) NSMutableDictionary *exif;
@property (nonatomic, readonly) NSMutableDictionary *gps;

- (BOOL) writeToPath: (NSString *) path;
- (id) objectForKeyedSubscript: (id) key;
- (void) setObject: (id) object forKeyedSubscript: (id < NSCopying >) aKey;

+ (NSArray *) imageSpecificDictionaryKeys;
+ (NSArray *) exifKeys;
+ (NSArray *) gpsKeys;

+ (instancetype) newImage: (UIImage *) image;
+ (instancetype) imageFromPath: (NSString *) path;
@end

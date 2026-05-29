#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Record : NSManagedObject

@property (nullable, nonatomic, copy) NSString *cityFrom;
@property (nullable, nonatomic, copy) NSString *cityTo;
@property (nullable, nonatomic, copy) NSString *aviaCompany;
@property (nonatomic) float price;

@end

NS_ASSUME_NONNULL_END

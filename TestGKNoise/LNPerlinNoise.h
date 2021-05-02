//
//  LNPerlinNoise.h
//  TestGKNoise
//
//  Created by Rick Mann on 2021-04-30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN





@interface LNPerlinNoise : NSObject

@property(nonatomic, assign)	double				frequency;
@property(nonatomic, assign)	NSInteger			octaveCount;
@property(nonatomic, assign)	double				lacunarity;
@property(nonatomic, assign)	double				persistence;


- (double)			getX: (double) inX
						y: (double) inY
						z: (double) inZ
						
					NS_SWIFT_NAME(get(x:y:z:));
						
@end

NS_ASSUME_NONNULL_END

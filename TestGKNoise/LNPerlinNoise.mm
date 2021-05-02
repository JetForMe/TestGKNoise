//
//  LNPerlinNoise.m
//  TestGKNoise
//
//  Created by Rick Mann on 2021-04-30.
//

#import "LNPerlinNoise.h"

#import <noise/noise.h>


using namespace noise;

@interface LNPerlinNoise()

@property (nonatomic, assign)	module::Perlin*			module;

@end



@implementation LNPerlinNoise




- (instancetype)
init
{
	self = [super init];
	if (self != nil)
	{
		self.module = new module::Perlin();
	}
	
	return self;
}

- (void)
dealloc
{
	delete self.module;
}

- (double)
getX: (double) inX
	y: (double) inY
	z: (double) inZ
{
	return self.module->GetValue(inX, inY, inZ);
}


- (double)
frequency
{
	return self.module->GetFrequency();
}

- (void)
setFrequency: (double) inVal
{
	self.module->SetFrequency(inVal);
}

- (NSInteger)
octaveCount
{
	return self.module->GetOctaveCount();
}

- (void)
setOctaveCount: (NSInteger) inVal
{
	self.module->SetOctaveCount((int) inVal);
}

- (double)
lacunarity
{
	return self.module->GetLacunarity();
}

- (void)
setLacunarity: (double) inVal
{
	self.module->SetLacunarity(inVal);
}

- (double)
persistence
{
	return self.module->GetPersistence();
}

- (void)
setPersistence: (double) inVal
{
	self.module->SetPersistence(inVal);
}

@end

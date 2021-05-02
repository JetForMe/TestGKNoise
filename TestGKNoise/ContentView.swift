//
//  ContentView.swift
//  TestGKNoise
//
//  Created by Rick Mann on 2021-04-29.
//

import SwiftUI

import CoreGraphics
import GameplayKit


let	kMaxSize						:	Int			=	1024
let	kMaxNoiseSize					:	CGFloat		=	32
let	kMaxHeight						:	CGFloat		=	1024.0
	

struct ContentView: View {
	enum
	NoiseType : CustomStringConvertible
	{
		var description: String
		{
			switch (self)
			{
				case .gameplayKit: return "GameplayKit"
				case .libnoise: return "libnoise"
			}
		}
		
		case gameplayKit
		case libnoise
	}
	
	@State	var			imageParams		:	ImageParameters		=	ImageParameters()
	@State	var			noiseType		:	NoiseType			=	.gameplayKit
			var			image			:	NSImage
											{
												get {
													let img: NSImage
													switch (self.noiseType)
													{
														case .gameplayKit: img = generateImageGK(params: self.imageParams)
														case .libnoise: img = generateImageLibNoise(params: self.imageParams)
													}
													return img
												}
											}
	
    var body: some View {
        HStack(spacing: 0)
        {
			Controls(params: self.$imageParams, noiseType: self.$noiseType)
        		.padding()
			Divider()
			Image(nsImage: self.image)
				.resizable()
				.interpolation(.none)
				.aspectRatio(contentMode: .fit)
				.frame(width: CGFloat(kMaxSize), height: CGFloat(kMaxSize))
        }
    }
    
    /**
    	Generate an image using libnoise.
    */
    
    func
    generateImageLibNoise(params inParams: ImageParameters)
    	-> NSImage
    {
    	let noise = LNPerlinNoise()
    	noise.frequency = inParams.frequency
    	noise.octaveCount = 6		//	I think this is the default for GKPerlinNoise
    	noise.lacunarity = inParams.lacunarity
    	noise.persistence = inParams.persistence
		
		let size = Int(inParams.size)
		
    	let bytesPerPixel = 2
    	let bytesPerRow =  size * bytesPerPixel
    	let totalBytes = size * bytesPerRow
    	
    	let buf = UnsafeMutablePointer<UInt16>.allocate(capacity: totalBytes)
		for y in 0 ..< size
		{
			for x in 0 ..< size
			{
				let nx = inParams.noiseSize * CGFloat(x) / CGFloat(size) + inParams.noiseOrigin.x
				let ny = inParams.noiseSize * CGFloat(y) / CGFloat(size) + inParams.noiseOrigin.y
				let nv = noise.get(x: Double(nx), y: Double(ny), z: 0.0)
				let scaled = (nv + 1.0) * 0.5 * Double(UInt16.max)
				let v = UInt16(max(0, min(scaled, Double(UInt16.max))))		//	TODO: if there are more bytes per row than width, this will fail. Need a pixelsPerRow value
				buf[y * size + x] = v
			}
		}
		
//		let bi: CGBitmapInfo = [.byteOrder16Little]
		let pixBuf = CVPixelBuffer.createFrom(buffer: buf, width: size, height: size, pixelFormatType: kCVPixelFormatType_OneComponent16, bytesPerRow: bytesPerRow, pixelBufferAttributes: [:])!
		let ii = CIImage(cvPixelBuffer: pixBuf)
		
		let ctx = CIContext()
		let image = ctx.createCGImage(ii, from: ii.extent)!
		return NSImage(cgImage: image, size: .zero)
    }
    
    /**
    	Generate an image using GKPerlinNoise.
    */
    
    func
    generateImageGK(params inParams: ImageParameters)
    	-> NSImage
    {
		let src = GKPerlinNoiseSource()
		src.frequency = inParams.frequency
		src.persistence = inParams.persistence
		src.lacunarity = inParams.lacunarity
		let noise = GKNoise(src)
//		noise.gradientColors = [ -1.0 : SKColor.blue, 1.0 : SKColor.white]		Fails
		let map = GKNoiseMap(noise,
							 size: vector_double2(x: Double(inParams.noiseSize), y: Double(inParams.noiseSize)),
							 origin: vector_double2(x: Double(inParams.noiseOrigin.x), y: Double(inParams.noiseOrigin.y)),
							 sampleCount: vector_int2(x: Int32(inParams.size), y:Int32(inParams.size)),
							 seamless: true)
		let tex = SKTexture(noiseMap: map)
		let cgimg = tex.cgImage()
		let nsimg = NSImage(cgImage: cgimg, size: NSSize(width: inParams.size, height: inParams.size))
		return nsimg
    }
}

struct Controls: View {
	@Binding	var			params			:	ImageParameters
	@Binding	var			noiseType		:	ContentView.NoiseType

    var body: some View {
		VStack(alignment: .leading)
        {
			Picker("Source:", selection: self.$noiseType) {
				Text("GameplayKit").tag(ContentView.NoiseType.gameplayKit)
				Text("libnoise").tag(ContentView.NoiseType.libnoise)
			}
			.pickerStyle(MenuPickerStyle())
        	Group
        	{
        		
				Text("Image Size: \(self.params.size, specifier: "%0.f")")
				Slider(value: self.$params.size, in: 0...CGFloat(kMaxSize))
				
				Text("Noise Size: \(self.params.noiseSize, specifier: "%0.2f")")
				Slider(value: self.$params.noiseSize, in: 0...kMaxNoiseSize)
				
				Text("Frequency: \(self.params.frequency, specifier: "%0.2f")")
				Slider(value: self.$params.frequency, in: 0...Double(5))
				
				Text("Lacunarity: \(self.params.lacunarity, specifier: "%0.2f")")
				Slider(value: self.$params.lacunarity, in: 0...Double(3))
				
				Text("Persistence: \(self.params.persistence, specifier: "%0.2f")")
				Slider(value: self.$params.persistence, in: 0...Double(5))
			}
			
			Spacer()
        }
		.frame(width: 200.0)
    }
}

struct
ImageParameters
{
	var			noiseOrigin		:	CGPoint		=	CGPoint(x: 0.0, y: 0.0)
	var			noiseSize		:	CGFloat		=	4.0
	var			size			:	CGFloat		=	64
	var			frequency		:	Double		=	1.0
	var			lacunarity		:	Double		=	0.5
	var			persistence		:	Double		=	1.3
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



extension
CVPixelBuffer
{
	static
	func
	createFrom(buffer: UnsafeMutableRawPointer,
			width: Int, height: Int,
			pixelFormatType: OSType, bytesPerRow: Int,
			pixelBufferAttributes: [String:Any]?)
		-> CVPixelBuffer?
	{
		var pb: CVPixelBuffer?
		let result = CVPixelBufferCreateWithBytes(kCFAllocatorDefault,
										Int(width), Int(height),
										kCVPixelFormatType_OneComponent16,
										buffer, bytesPerRow,
										{ (inMutableP, inP) in
											inP?.deallocate()
										}, nil, pixelBufferAttributes as CFDictionary?,
										&pb)
		if result != 0
		{
			return nil
		}
		
		return pb
	}
}

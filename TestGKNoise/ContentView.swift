//
//  ContentView.swift
//  TestGKNoise
//
//  Created by Rick Mann on 2021-04-29.
//

import SwiftUI

import GameplayKit


let	kMaxSize						:	CGFloat		=	1024.0
let	kMaxHeight						:	CGFloat		=	1024.0
	

struct ContentView: View {
	@State	var			imageParams		:	ImageParameters		=	ImageParameters()
	@State	var			image			:	NSImage?
	
    var body: some View {
        HStack(spacing: 0)
        {
			Controls(params: self.$imageParams)
        		.padding()
			Divider()
			Image(nsImage: generateImage(params: self.imageParams))
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: kMaxSize, height: kMaxSize)
        }
    }
    
    func
    generateImage(params inParams: ImageParameters)
    	-> NSImage
    {
		let src = GKPerlinNoiseSource()
		src.frequency = inParams.frequency
		src.persistence = inParams.persistence
		src.lacunarity = inParams.lacunarity
		let noise = GKNoise(src)
		noise.gradientColors = [ -1.0 : SKColor.blue, 1.0 : SKColor.white]
		let map = GKNoiseMap(noise,
							 size: vector_double2(x: inParams.noiseSize, y: inParams.noiseSize),
							 origin: vector_double2(x:0, y:0),
							 sampleCount: vector_int2(x: Int32(inParams.size), y:Int32(inParams.size)),
							 seamless: true)
		let tex = SKTexture(noiseMap: map)
		let cgimg = tex.cgImage()
		let nsimg = NSImage(cgImage: cgimg, size: NSSize(width: inParams.size, height: inParams.size))
		return nsimg
    }
}

struct Controls: View {
	@Binding	var			params		:	ImageParameters

    var body: some View {
		VStack(alignment: .leading)
        {
        	Group
        	{
				Text("Image Size: \(self.params.size, specifier: "%0.f")")
				Slider(value: self.$params.size, in: 0...kMaxSize)
				
				Text("Noise Size: \(self.params.noiseSize, specifier: "%0.2f")")
				Slider(value: self.$params.noiseSize, in: 0...Double(kMaxSize))
				
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
	var			size			:	CGFloat		=	256.0
	var			noiseSize		:	Double		=	256.0
	var			frequency		:	Double		=	1.0
	var			lacunarity		:	Double		=	0.1
	var			persistence		:	Double		=	0.1
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


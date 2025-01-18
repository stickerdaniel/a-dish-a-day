//
//  SeededRandomNumberGenerator.swift
//  calendar
//
//  Created by Daniel Sticker on 18.01.25.
//

import Foundation

// Custom RNG that uses a seed for repeatability
struct SeededRandomNumberGenerator {
    private var state: UInt64
    
    init(seed: Int) {
        self.state = UInt64(seed)
    }
    
    mutating func next() -> Double {
        // Linear congruential generator
        state = state &* 6364136223846793005 &+ 1
        
        // Normalize the value to the range [0, 1] using the full state (64-bit)
        let fraction = Double(state & 0xFFFFFFFFFFFF) / Double(0xFFFFFFFFFFFF)
        print("Generated random number: \(fraction)")
        return fraction
    }
}

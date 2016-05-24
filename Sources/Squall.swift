/*

Kai Wells, http://kaiwells.me

*/

import Foundation

/// Provides a wrapper around a Mersenne Twister implementation.
///
/// Remember to seed with some value.
///
/// CAUTION: Not thread safe, uses a global internal state.
///
public enum Squall {
    private static var generator = MersenneTwisterGenerator()
    
    /// Initialize the internal state of the generator.
    ///
    /// - parameter seed: The value used to generate the intial state. Should be chosen at random.
    public static func seed(seed: UInt32) {
        Squall.generator = MersenneTwisterGenerator(seed: seed)
    }
    
    /// Initialize the internal state of the generator.
    ///
    /// Uses the current time as the seed. Should not overflow until February 2106.
    ///
    /// Caution when spawning multiple processes within close temporal proximity.
    public static func seed() {
        let epochTime = abs(NSDate().timeIntervalSince1970)
        let seed = UInt32(epochTime)
        Squall.seed(seed)
    }
    
    /// Generates a random `UInt32`.
    ///
    /// - returns: The next `UInt32` in the sequence
    public static func random() -> UInt32 {
        return generator.next()!
    }
}

// MARK: Extended byte sequences

extension Squall {
    /// Generates a random `UInt64`.
    ///
    /// - returns: The next two `UInt32`'s in the sequence concatenated into a `UInt64`
    public static func random() -> UInt64 {
        let upper = UInt64(generator.next()!) << 32
        let lower = UInt64(generator.next()!)
        return upper + lower
    }
    
    /// Generates a random stream of bytes.
    ///
    /// - parameter length: The number of bytes of random data to return.
    ///
    /// - returns: The next `length` random bytes. Or nil if length <= 0.
    public static func randomData(length: Int) -> NSData? {
        guard length > 0 else { return nil }
        // Finding a contiguous stretch of memory much longer than this might not be possible, especially on iOS
        precondition(length < 10485760, "Buffer would exceed 10mb")
        
        let rawMemory = UnsafeMutablePointer<Void>.alloc(length)
        guard rawMemory != nil else { return nil }
        let buffer = UnsafeMutablePointer<UInt8>(rawMemory)
        
        let numChunks = length / 4
        for index in 0..<numChunks {
            let ptr = buffer + (index * 4)
            let chunk = Squall.random() as UInt32
            ptr.memory               = UInt8((chunk & 0xFF000000) >> 24)
            ptr.advancedBy(1).memory = UInt8((chunk & 0x00FF0000) >> 16)
            ptr.advancedBy(2).memory = UInt8((chunk & 0x0000FF00) >> 8)
            ptr.advancedBy(3).memory = UInt8((chunk & 0x000000FF))
        }
        
        var numExtra = length % 4
        let extraChunk = Squall.random() as UInt32
        let ptr = buffer + (numChunks * 4)
        while numExtra > 0 {
            let shift = UInt32(numExtra * 8)
            let mask: UInt32 = 0xFF << shift
            ptr.advancedBy(numExtra).memory = UInt8((extraChunk & mask) >> shift)
            numExtra -= 1
        }
        
        return NSData(
            bytesNoCopy: rawMemory,
            length: length,
            deallocator: { (ptr, length) in
                ptr.destroy(length)
                ptr.dealloc(length)
            }
        )
    }
}

// MARK: Uniform Distribution

extension Squall {
    /// Pull from a uniform distribution of random numbers. Defaults to [0, 1).
    ///
    /// - parameter lower: Lower bound of uniform distribution. Defaults to 0.
    ///
    /// - parameter upper: Upper bound of uniform distribution. Defaults to 1.
    ///
    /// - returns: A pseudo-random number from the range [lower, upper).
    public static func uniform(lower: Double = 0, _ upper: Double = 1) -> Double {
        let f = Double(Squall.random() as UInt64) / Double(UINT64_MAX)
        let d = upper - lower
        return f*d + lower
    }
    
    /// Pull from a uniform distribution of random numbers. Defaults to [0, 1).
    ///
    /// - parameter lower: Lower bound of uniform distribution. Defaults to 0.
    ///
    /// - parameter upper: Upper bound of uniform distribution. Defaults to 1.
    ///
    /// - returns: A pseudo-random number from the range [lower, upper).
    public static func uniform(lower: Float = 0, _ upper: Float = 1) -> Float {
        let f = Float(Squall.random() as UInt32) / Float(UINT32_MAX)
        let d = upper - lower
        return f*d + lower
    }
}

// MARK: Gaussian Distribution

extension Squall {
    /// Pull from a Gaussian distribution of random numbers.
    ///
    /// - parameter average: The center of the distribution. Defaults to 0.
    ///
    /// - parameter sigma: The standard deviation of the distribution. Defaults to 1.
    ///
    /// - returns: A pseudo-random number from a Gaussian distribution.
    public static func gaussian(average mu: Double = 0, sigma: Double = 1) -> Double {
        let A = Squall.uniform() as Double
        let B = Squall.uniform() as Double
        let X = sqrt(-2*log(A))*cos(2*M_PI*B)
        return X*sigma + mu
    }
    
    /// Pull from a Gaussian distribution of random numbers.
    ///
    /// - parameter average: The center of the distribution. Defaults to 0.
    ///
    /// - parameter sigma: The standard deviation of the distribution. Defaults to 1.
    ///
    /// - returns: A pseudo-random number from a Gaussian distribution.
    public static func gaussian(average mu: Float = 0, sigma: Float = 1) -> Float {
        let A = Squall.uniform() as Float
        let B = Squall.uniform() as Float
        let X = sqrt(-2*log(A))*cos(2*Float(M_PI)*B)
        return X*sigma + mu
    }
}
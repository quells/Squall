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
    internal static var generator = MersenneTwisterGenerator()

    /// Initialize the internal state of the generator.
    ///
    /// - parameter seed: The value used to generate the intial state. Should be chosen at random.
    public static func seed(_ seed: UInt32) {
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
        let f = Double(generator.next()!) / Double(generator.maxValue)
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
        let f = Float(generator.next()!) / Float(generator.maxValue)
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

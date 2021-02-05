/*

Kai Wells, http://kaiwells.me

*/

/// Multiply two `UInt32`'s and discard the overflow.
///
fileprivate func discardMultiply(_ a: UInt32, _ b: UInt32) -> UInt32 {
    let ah = UInt64(a & 0xFFFF0000) >> 16
    let al = UInt64(a & 0x0000FFFF)
    let bh = UInt64(b & 0xFFFF0000) >> 16
    let bl = UInt64(b & 0x0000FFFF)

    // Most significant bits overflow anyways, so don't bother
    // let F  = ah * bh
    let OI = ah * bl + al * bh
    let L  = al * bl

    let result = (((OI << 16) & 0xFFFFFFFF) + L) & 0xFFFFFFFF
    return UInt32(result)
}

/// Generates pseudo-random `UInt32`'s.
///
/// Uses the Mersenne Twister PRNG algorithm described [here](https://en.wikipedia.org/wiki/Mersenne_Twister).
///
final internal class MersenneTwisterGenerator: IteratorProtocol {

    internal typealias Element = UInt32

    // Magic numbers
    private let (w, n, m, r): (UInt32, Int, Int, UInt32) = (32, 624, 397, 31)
    private let a: UInt32 = 0x9908B0DF
    private let (u, d): (UInt32, UInt32) = (11, 0xFFFFFFFF)
    private let (s, b): (UInt32, UInt32) = ( 7, 0x9D2C5680)
    private let (t, c): (UInt32, UInt32) = (15, 0xEFC60000)
    private let l: UInt32 = 18
    private let f: UInt32 = 1812433253

    /// The maximum value an `UInt32` may take.
    ///
    internal let maxValue: UInt32 = 4294967295

    private var state: [UInt32]
    private var index = 0

    /// Initialize the internal state of the generator.
    ///
    /// - parameter seed: The value used to generate the intial state. Should be chosen at random.
    init(seed: UInt32 = 5489) {
        var x = [seed]
        for i in 1..<n {
            let prev = x[i-1]
            let c = discardMultiply(f, prev ^ (prev >> (w-2)))
            let (next, _) = c.addingReportingOverflow(UInt32(i))
            x.append(next)
        }
        self.state = x
    }

    /// Puts the twist in Mersenne Twister.
    ///
    private func twist() {
        for i in 0..<n {
            let x = (state[i] & 0xFFFF0000) + ((state[(i+1) % n] % UInt32(n)) & 0x0000FFFF)
            var xA = x >> 1
            if (x % 2 != 0) {
                xA = xA ^ a
            }
            state[i] = state[(i + m) % n] ^ xA
            index = 0
        }
    }

    /// Provides the next `UInt32` in the sequence.
    ///
    /// Also modifies the internal state state array, twisting if necessary.
    /// Required by the GeneratorType protocol.
    ///
    internal func next() -> UInt32? {
        if self.index > n { fatalError("Generator never seeded") }
        if self.index == n { self.twist() }

        var y = state[index]
        y = y ^ ((y >> u) & d)
        y = y ^ ((y << s) & b)
        y = y ^ ((y << t) & c)
        y = y ^ (y >> l)

        index += 1
        return y
    }
}

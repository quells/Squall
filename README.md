# Squall

A pseudo-random number generator written in Swift. Implements the Mersenne Twister (MT) algorithm as described [here](https://en.wikipedia.org/wiki/Mersenne_Twister).

## Mersenne.swift

Implementation of the MT algorithm for 32-bit integers.

## Squall.swift

Wrapper around the MT implementation that provides random values for several types:

- UInt32
- UInt64
- Float
- Double

Provides both uniform and Gaussian (normal) distributions for Float and Double.

### Thread Safety

Use `Squall` if parallel execution speed is not important. It is a global singleton with a serial queue.

```swift
let queues: [DispatchQueue] = // N DispatchQueues
for i in 0 ..< N {
	queues[i].async {
		// do stuff with Squall.random()
	}
}
```

Use `Gust` for parallel, independent PRNG. **NOTE** that a unique offset must be given given if multiple instances are created in close temporal proximity in order to preserve independence of results.

```swift
let queues: [DispatchQueue] = // N DispatchQueues
for i in 0 ..< N {
	queues[i].async {
		let g_i = Gust(offset: UInt32(i))
		// do stuff with g_i.random()
	}
}
```

## Changelog

### 1.3 - October 4, 2018

- Added OS guards around `Squall` because `DispatchQueue` is not always available on Linux systems.
- Added conformance to `RandomNumberGenerator` to `Gust` so that it can be used with the unified Swift 4.2 random methods.

### 1.2.1 - June 6, 2018

- Changed instances of `M_PI` to `Double.pi` and `Float.pi` - credit to @jmmaloney4

### 1.2 - February 19, 2017

- Changed `safeMultiply()` to `discardMultiply` to better describe what the function does.
- Added a serial queue to `Squall` for thread safety.
- Added `Gust`: a mirror of `Squall` that is not thread safe but allows parallel execution.

### 1.1 - February 14, 2017

- Updated for Swift 3.1
- Removed `Squall.randomData()` because the syntax for `UnsafeMutablePointer` changed.

### 1.0 - May 21, 2016

- Initial Release

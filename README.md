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

## Changelog

### 1.1 - February 14, 2017

- Updated for Swift 3.1
- Removed `Squall.randomData()` because the syntax for `UnsafeMutablePointer` changed.

### 1.0 - May 21, 2016

- Initial Release

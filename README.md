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
- NSData

Provides both uniform and Gaussian (normal) distributions for Float and Double.
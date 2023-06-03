module vdecimal

import math.big

// Decimal represents a fixed-point decimal.
// number = value * 10 ^ exp
pub struct Decimal {
	value &big.Integer

	exp int
}

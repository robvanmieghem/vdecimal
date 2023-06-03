module vdecimal

import math.big
import math

// Decimal represents a fixed-point decimal.
// number = value * 10 ^ exp
pub struct Decimal {
	value big.Integer

	exp int
}

// new returns a new fixed-point decimal, value * 10 ^ exp.
pub fn new(value i64, exp int) Decimal {
	return Decimal{
		value: big.integer_from_i64(value)
		exp: exp
	}
}

// decimal_from_int converts an int to Decimal.
pub fn decimal_from_int(a int) Decimal {
	return new(a, 0)
}

// int_part returns the integer component of the decimal.
pub fn (d Decimal) int_part() int {
	scaled := d.rescale(0)
	return scaled.value.int()
}

// rescale returns a rescaled version of the decimal. Returned
// decimal may be less precise if the given exponent is bigger
// than the initial exponent of the Decimal.
// NOTE: this will truncate, NOT round
//
// Example:
//
// 	d := new(12345, -4)
//	d2 := d.rescale(-1)
//	d3 := d2.rescale(-4)
//	println(d)
//	println(d2)
//	println(d3)
//
// Output:
//
//	1.2345
//	1.2
//	1.2000
//
fn (d Decimal) rescale(exp int) Decimal {
	if d.exp == exp {
		return d
	}

	diff := u32(math.abs(exp - d.exp))
	mut value := d.value

	ten_int := big.integer_from_int(10)
	exp_scale := ten_int.pow(diff)

	if exp > d.exp {
		value /= exp_scale
	} else if exp < d.exp {
		value *= exp_scale
	}

	return Decimal{
		value: value
		exp: exp
	}
}

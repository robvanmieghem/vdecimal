module vdecimal

// Arbitrary-precision fixed-point decimal numbers
import math.big
import math
import strings

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

// decimal_from_string returns a new Decimal from a string representation.
// Trailing zeroes are not trimmed.
pub fn decimal_from_string(value string) !Decimal {
	mut int_string := ''
	mut exp := 0

	// maybe replace this with strings.textscanner
	mut p_index := -1
	for i := 0; i < value.len; i++ {
		if value[i] == `.` {
			if p_index > -1 {
				return error('can\'t convert ${value} to decimal: too many .s"')
			}
			p_index = i
		}
	}

	if p_index == -1 {
		// There is no decimal point, we can just parse the original string as
		// an int
		int_string = value
	} else {
		if p_index + 1 < value.len {
			int_string = value.substr(0, p_index) + value.substr(p_index + 1, value.len)
		} else {
			int_string = value.substr(0, p_index)
		}
		exp -= value.substr(p_index + 1, value.len).len
	}
	d_value := big.integer_from_string(int_string) or {
		return error('can\'t convert ${value} to decimal')
	}
	return Decimal{
		value: d_value
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

// rescale_pair rescales two decimals to common exponential value (minimal exp of both decimals)
fn rescale_pair(d1 Decimal, d2 Decimal) (Decimal, Decimal) {
	if d1.exp == d2.exp {
		return d1, d2
	}
	base_scale := math.min(d1.exp, d2.exp)
	if base_scale != d1.exp {
		return d1.rescale(base_scale), d2
	}
	return d1, d2.rescale(base_scale)
}

// str returns the string representation of the decimal
// with the fixed point.
// Trailing zeroes in the fractional part are trimmed.
//
// Example:
//
//     d := new(-12345, -3)
//     println(d)
//
// Output:
//
//     -12.345
//
pub fn (d Decimal) str() string {
	if d.exp >= 0 {
		return d.rescale(0).value.str()
	}
	abs := d.value.abs()
	str := abs.str()

	mut int_part := ''
	mut fractional_part := ''

	if str.len > -d.exp {
		int_part = str.substr(0, str.len + d.exp)
		fractional_part = str.substr(str.len + d.exp, str.len)
	} else {
		int_part = '0'
		num_zeroes := -d.exp - str.len
		fractional_part = strings.repeat(`0`, num_zeroes) + str
	}
	// Trim trailing zeroes
	mut i := fractional_part.len - 1
	for ; i >= 0; i-- {
		if fractional_part[i] != `0` {
			break
		}
	}
	fractional_part = fractional_part.substr(0, i + 1)

	mut number := int_part
	if fractional_part.len > 0 {
		number += '.' + fractional_part
	}
	if d.value.signum < 0 {
		return '-' + number
	}
	return number
}

pub fn (decimal Decimal) + (addend Decimal) Decimal {
	rd, rd2 := rescale_pair(decimal, addend)
	result_value := rd.value + rd2.value
	return Decimal{
		value: result_value
		exp: rd.exp
	}
}

pub fn (decimal Decimal) - (subtrahend Decimal) Decimal {
	rd, rd2 := rescale_pair(decimal, subtrahend)
	result_value := rd.value - rd2.value
	return Decimal{
		value: result_value
		exp: rd.exp
	}
}

pub fn (decimal Decimal) * (multiplicand Decimal) Decimal {
	exp_i64 := i64(decimal.exp) + i64(multiplicand.exp)

	// better to panic than to give incorrect results as
	// Decimals are usually used for money
	if exp_i64 > i64(math.max_i32) || exp_i64 < i64(math.min_i32) {
		panic('exponent ${exp_i64} overflows an int32')
	}

	result_value := decimal.value * multiplicand.value
	return Decimal{
		value: result_value
		exp: int(exp_i64)
	}
}

pub fn (a Decimal) == (b Decimal) bool {
	rd_a, rd_b := rescale_pair(a, b)
	return rd_a.value == rd_b.value
}

pub fn (a Decimal) < (b Decimal) bool {
	rd_a, rd_b := rescale_pair(a, b)
	return rd_a.value < rd_b.value
}

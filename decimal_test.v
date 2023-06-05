module vdecimal

fn test_int() {
	// perfectly convertable
	i := 123
	mut d := decimal_from_int(i)
	assert i == d.int_part()
	// int_part should truncate the fractional part
	d = new(1239, -1)
	assert d.int_part() == 123
}

fn test_str() {
	// no fractional part
	mut d := new(1234, 0)
	assert '1234' == d.str()
	// with fractional part
	d = new(1234, -1)
	assert '123.4' == d.str()
	// negative and fractional part
	d = new(-1234, -1)
	assert '-123.4' == d.str()
}

fn test_decimal_from_string() ! {
	mut s := '123.4'
	mut d := decimal_from_string(s)!
	assert d.str() == s
}

fn test_decimal_from_string_multiple_points() ! {
	// multiple `.`s should return an error
	s := '123.4.5'
	mut d := decimal_from_string(s) or { return }
	return error('multiple `.`s should return an error')
}

fn test_decimal_from_string_illegal() ! {
	// should return an error
	s := '1tyu23.45'
	mut d := decimal_from_string(s) or { return }
	return error('non decimal characters should return an error')
}

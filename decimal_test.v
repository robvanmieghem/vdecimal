module vdecimal

fn test_int() {
	i := 123
	d := decimal_from_int(i)
	assert i == d.int_part()
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

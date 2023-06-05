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
	// trim trailing zeroes
	d = new(12340, -2)
	assert '123.4' == d.str()
	// no fractional part if it has only zeroes
	d = new(12340, -1)
	assert '1234' == d.str()
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

fn test_add() ! {
	test_cases := [
		['2', '3', '5'],
		['2454495034', '3451204593', '5905699627'],
		['24544.95034', '.3451204593', '24545.2954604593'],
		['.1', '.1', '0.2'],
		['.1', '-.1', '0'],
		['0', '1.001', '1.001'],
	]
	for test_case in test_cases {
		d1 := decimal_from_string(test_case[0])!
		d2 := decimal_from_string(test_case[1])!
		sum := d1 + d2
		assert test_case[2] == sum.str()
	}
}

fn test_sub() ! {
	test_cases := [
		['2', '3', '-1'],
		['12', '3', '9'],
		['-2', '9', '-11'],
		['2454495034', '3451204593', '-996709559'],
		['24544.95034', '.3451204593', '24544.6052195407'],
		['.1', '-.1', '0.2'],
		['.1', '.1', '0'],
		['0', '1.001', '-1.001'],
		['1.001', '0', '1.001'],
		['2.3', '.3', '2'],
	]
	for test_case in test_cases {
		d1 := decimal_from_string(test_case[0])!
		d2 := decimal_from_string(test_case[1])!
		result := d1 - d2
		assert test_case[2] == result.str()
	}
}

fn test_mul() ! {
	test_cases := [
		['2', '3', '6'],
		['2454495034', '3451204593', '8470964534836491162'],
		['24544.95034', '.3451204593', '8470.964534836491162'],
		['.1', '.1', '0.01'],
		['0', '1.001', '0'],
	]
	for test_case in test_cases {
		d1 := decimal_from_string(test_case[0])!
		d2 := decimal_from_string(test_case[1])!
		result := d1 * d2
		assert test_case[2] == result.str()
	}
}

fn test_equalities() {
	a := new(1234, 3)
	b := new(1234, 3)
	c := new(1234, 4)
	assert a == b
	assert a != c
}

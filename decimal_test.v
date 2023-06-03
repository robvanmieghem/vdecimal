module vdecimal

fn test_int() ? {
	i := 123
	d := decimal_from_int(i)
	assert i == d.int_part()
}

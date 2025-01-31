#include <stdint.h>

#include <rtl-sdr.h>

#include "idris_rtlsdr.h"

const void * idris_rtlsdr_open(uint32_t index, uint32_t *ret)
{
	rtlsdr_dev_t *dev;
	*ret = rtlsdr_open(&dev, index);
	return dev;
}

int idris_rtlsdr_read_refint(const int *p)
{
	return *p;
}


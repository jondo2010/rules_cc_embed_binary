#pragma once

#ifdef __cplusplus
extern "C" {
#endif

extern const unsigned char {symbol}[];
extern const unsigned char {symbol}_end[];
extern const unsigned int {symbol}_size;

#define {alias} {symbol}
#define {alias}_end {symbol}_end
#define {alias}_size {symbol}_size

#ifdef __cplusplus
}
#endif

    .section .rodata
    .global {symbol}
    .type   {symbol}, @object
    .align  4
{symbol}:
    .incbin "{src}"
{symbol}_end:
    .global {symbol}_size
    .type   {symbol}_size, @object
    .align  4
{symbol}_size:
    .int    {symbol}_end - {symbol}

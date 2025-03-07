#ifdef _WIN32
    .section .rodata,"dr"
#elif defined(__APPLE__)
    .section __TEXT,__const
#else
    .section .rodata
#endif
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

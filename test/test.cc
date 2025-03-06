#include "test/_data.h"

#include <cstdio>
#include <cstring>

const char *test_string = __TEST_STRING__;

int main() {
  // Compare directly using memcmp, which compares raw memory regions
  if (data_size == strlen(test_string) &&
      memcmp(static_cast<const void *>(data), test_string, data_size) == 0) {
    // Success
    return 0;
  }

  return 1;
}

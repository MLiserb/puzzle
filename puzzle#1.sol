// We use this to keep track of which indices [0, 63] have been filled.
uint256 bitmap = 1 << 64;
// The bitmap only reserves bits in positions [0, 63] to represent the slots
// that have been filled. Thus, 64 is a sentinel value that will always yield 1
// when retrieved via `(bitmap >> index) & 1`, and it can be used as a sensible
// default value before the next iteration of the `for` loop.
uint256 index = 64;
// We fill the puzzle randomly with 1 of [1, 8].
for (uint256 i = 1; i < 9; ) {
    // We have exhausted the seed, so stop iterating.
    if (seed == 0) break;

    // Loop through until we find an unfilled index.
    while ((bitmap >> index) & 1 == 1 && seed != 0) {
        // Retrieve 6 random bits from `seed` to determine which index to fill.
        index = seed & 0x3f;
        seed >>= 6;
    }
    // Set the bit in the bitmap to indicate that the index has been filled.
    bitmap |= 1 << index;

    // Place the number into the slot that was just filled.
    puzzle |= (i << (index << 2));
    index = 64;
    unchecked {
        ++i;
    }
}
// Check rows, columns, and subgrids for Sudoku rule violations.
for (uint256 index = 0; index < 64; index++) {
    uint256 checks = (CHECKS >> index) & 7;
    if (checks & 4 == 4) {
        if (!check(_solution, ROW_SHIFTS)) {
            return false;
        }
    }
    if (checks & 2 == 2) {
        if (!check(_solution, COL_SHIFTS)) {
            return false;
        }
    }
    if (checks & 1 == 1) {
        if (!check(_solution, SUBGRID_SHIFTS)) {
            return false;
        }
    }
}

// If all the checks pass at every index of the board, we have a valid solution!
return true;

function check(uint256 memory values, uint256[8] memory shifts) private pure returns (bool) {
    uint256[8] memory counts = new uint256[8](8);

    for (uint256 i = 0; i < 8; i++) {
        uint256 index = values >> shifts[i] & 0xf;
        counts[index] += 1;
    }

    for (uint256 i = 0; i < 8; i++) {
        if (counts[i] != 1) {
            return false;
        }
    }

    return true;
}

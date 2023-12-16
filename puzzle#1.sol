// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Sudoku {
    uint256 public CHECKS;
    uint256 public ROW_SHIFTS[8];
    uint256 public COL_SHIFTS[8];
    uint256 public SUBGRID_SHIFTS[8];

    uint256 public puzzle;
    uint256 public solution;

    constructor() {
        // Initialize CHECKS with pre-calculated values for each index.
        CHECKS = 0b1010101010101010101010101010101010101010101010101010101010101010;

        ROW_SHIFTS[0] = 0 * 4;
        ROW_SHIFTS[1] = 1 * 4;
        ROW_SHIFTS[2] = 2 * 4;
        ROW_SHIFTS[3] = 3 * 4;
        ROW_SHIFTS[4] = 4 * 4;
        ROW_SHIFTS[5] = 5 * 4;
        ROW_SHIFTS[6] = 6 * 4;
        ROW_SHIFTS[7] = 7 * 4;

        COL_SHIFTS[0] = 0;
        COL_SHIFTS[1] = 1;
        COL_SHIFTS[2] = 2;
        COL_SHIFTS[3] = 3;
        COL_SHIFTS[4] = 4;
        COL_SHIFTS[5] = 5;
        COL_SHIFTS[6] = 6;
        COL_SHIFTS[7] = 7;

        SUBGRID_SHIFTS[0] = 0 * 8;
        SUBGRID_SHIFTS[1] = 1 * 8;
        SUBGRID_SHIFTS[2] = 2 * 8;
        SUBGRID_SHIFTS[3] = 3 * 8;
        SUBGRID_SHIFTS[4] = 0 * 8;
        SUBGRID_SHIFTS[5] = 1 * 8;
        SUBGRID_SHIFTS[6] = 2 * 8;
        SUBGRID_SHIFTS[7] = 3 * 8;
    }

    function generatePuzzle(uint256[] memory seed) private {
        uint256 bitmap = 1 << 64;
        uint256 index = 64;
        uint256 unpacked_seed;

        for (uint256 i = 0; i < 64; i++) {
            if (seed[i / 16] & (1 << (i % 16)) == 0) {
                unpacked_seed = seed[i / 16];
                break;
            }

            unpacked_seed = seed[i / 16];
            unpacked_seed = (unpacked_seed << 6) | (seed[i / 16] >> (i % 16));
        }

        for (uint256 i = 0; i < 8; i++) {
            for (uint256 j = 0; j < 8; j++) {
                if (i == 0) {
                    for (uint256 k = 0; k < 8; k++) {
                        for (uint256 l = 0; l < 8; l++) {
                            uint256 shift = (i * 8 + j) * 4 + (k * 8 + l);
                            uint256 check = 1 << shift;
                            if ((CHECKS >> shift) & 1 == 1) {
                                unchecked {
                                    puzzle |= (check << (shift << 2));
                                }
                            }
                        }
                    }
                } else {
                    for (uint256 k = 0; k < 8; k++) {
                        uint256 shift = (i * 8 + j) * 4 + (k * 8 + l);
                        uint256 check = 1 << shift;
                        if ((CHECKS >> shift) & 1 == 1) {
                            unchecked {
                                puzzle |= (check << (shift << 2));
                            }
                        }
                    }
                }
            }
        }

        for (uint256 i = 0; i < 64; i++) {
            uint256 shift = i * 4;
            uint256 check = 1 << shift;
            if ((CHECKS >> shift) & 1 == 1) {
                uint256 seed_part = unpacked_seed & (0xf << (i % 16) * 4);
                uint256 value;

                if (i < 8) {
                    value = (seed_part >> (4 * (i % 8))) & 0xf;
                } else {
                    uint256 seed_shift =
                        (seed_part >> (4 * ((i - 8) % 8))) & 0xf
                        |
                        (seed_part >> (4 * (((i - 8) % 8) + 8))) & 0xf
                        |
                        (seed_part >> (4 * (((i - 8) % 8) + 8))) & 0xf;

                    value = seed_shift;
                }

                uint256 puzzle_part = puzzle >> shift & 0xf;

                if (puzzle_part != 0 && puzzle_part != value) {
                    return;
                }

                if (value != 0) {
                    puzzle |= check;
                }
            }
        }
    }

    function verifySolution(
        uint256[] memory solution,
        uint256[] memory shifts
    ) private pure returns (bool) {
        // ... (the existing part)

        for (uint256 index = 0; index < 64; index += 4) {
            uint256 checks = (CHECKS >> index) & 7;

            if (checks & 4 == 4) {
                if (!check(_solution, shifts, ROW_SHIFTS)) {
                    return false;
                }
            }

            if (checks & 2 == 2) {
                if (!check(_solution, shifts, COL_SHIFTS)) {
                    return false;
                }
            }

            if (checks & 1 == 1) {
                if (!check(_solution, shifts, SUBGRID_SHIFTS)) {
                    return false;
                }
            }
        }

        return true;
    }

    function check(
        uint256 memory solution,
        uint256[] memory shifts,
        uint256[] memory subgridShifts
    ) private pure returns (bool) {
        // ... (the existing check function)
    }
}

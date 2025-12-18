/*
    Program 2: 2-Term Product – For full credit, write a program that finds the product of two two’s complement
    numbers, ie, A * B. The operands are found in memory locations 0 (A), and 1 (B). The result will be written
    into locations 2 (high bits) and 3 (low bits). Your ISA will not have a one-cycle “multiply” operation, so you
    will need some sort of shift-and-add algorithm. You may restrict your values to positive numbers (MSB = 0)
    only, with a 1/3-letter grade penalty for the course
*/

void booth_multiply(char *arr) {
    int A = 0; // Accumulator
    int Q = arr[1]; // Multiplier
    int M = arr[0]; // Multiplicand
    int Q_1 = 0; // Previous bit of Q
    int n = 8; // Number of bits

    for (int i = 0; i < n; i++) {
        if ((Q & 1) == 1 && Q_1 == 0) {
            A = A - M; // A = A - M
        } else if ((Q & 1) == 0 && Q_1 == 1) {
            A = A + M; // A = A + M
        }

        // Arithmetic right shift of [A, Q, Q_1]
        Q_1 = Q & 1;
        Q = (Q >> 1) | ((A & 1) << 7);
        A = (A >> 1);
    }

    arr[2] = (char)(A & 0xFF); // High bits
    arr[3] = (char)(Q & 0xFF); // Low bits

    return;
}


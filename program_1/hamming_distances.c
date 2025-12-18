/*
    Program 1: Closest pair -- Write a program to find the smallest and largest Hamming distances among all pairs of
    values in an array of 16 bytes. Assume all values are 8-bit integers. The array of integers starts at location 0.
    Write the minimum distance in location 16 and the maximum distance in location 17.
*/

void hamming_distance(char *arr) {
    int min_distance = 8; // Maximum Hamming distance for 8-bit integers
    int max_distance = 0;

    for (int i = 0; i < 16; i++) {
        for (int j = i + 1; j < 16; j++) {
            char xor_result = arr[i] ^ arr[j];
            int distance = 0;

            // Count the number of set bits in xor_result
            for (int k = 0; k < 8; k++) {
                if (xor_result & (1 << k)) {
                    distance++;
                }
            }

            if (distance < min_distance) {
                min_distance = distance;
            }
            if (distance > max_distance) {
                max_distance = distance;
            }
        }
    }

    arr[16] = (char)min_distance;
    arr[17] = (char)max_distance;

    return 0;
}


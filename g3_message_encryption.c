#define N 34
const int SID = 1230010;
int data[N];
unsigned int checksum = 0;
int decrypt_ok = 0;
int xor_transform(int value, int key)
{
    return value ^ key;
}
void generate_and_encrypt(int key)
{
    unsigned int state = (unsigned int)SID;
    int i = 0;
    while (i < N)
    {
        state = 1664525u * state + 1013904223u;
        data[i] = (int)(((state >> 16) % 26u) + 65u);
        data[i] = xor_transform(data[i], key);
        i++;
    }
}
unsigned int calculate_checksum(void)
{
    unsigned int c = 0;
    int i = 0;
    while (i < N)
    {
        c = (c << 1) | (c >> 31);
        c = c + (unsigned int)data[i];
        i++;
    }
    return c;
}
int decrypt_and_verify(int key)
{
    unsigned int state = (unsigned int)SID;
    int ok = 1;
    int i = 0;
    while (i < N)
    {
        data[i] = xor_transform(data[i], key);
        state = 1664525u * state + 1013904223u;
        if (data[i] != (int)(((state >> 16) % 26u) + 65u))
            ok = 0;
        i++;
    }
    return ok;
}

int main(void)
{
    int key = SID % 256;
    if (key == 0)
        key = 0xA5;
    generate_and_encrypt(key);
    checksum = calculate_checksum();
    decrypt_ok = decrypt_and_verify(key);
    return 0;
}

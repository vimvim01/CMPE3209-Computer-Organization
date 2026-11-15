CMPE3209 G3 - Step 4g - verified user Ubuntu ELF comparison

Baseline: baseline_4g.elf is SHA-256-identical to M2 g3_O0.elf
Modified: main_v2_O0.elf, linked by student on Ubuntu with Clang/LLD 17 at -O0, RV32IM, ILP32, .text=0x10000, main entry
Program source differs in only one code edit within generate_and_encrypt(); use diff -u to reproduce.

MODEL: custom AI-assisted functional RV32IM interpreter; little endian, sp=0x7ffffff0, gp=0x10000000, no OS, main return terminates.
CACHE: 128-B total, direct-mapped, 16-B line, write-back/write-allocate; 8 lines, cache cold at start. Memory accesses include stack, globals, and array. Instruction fetch excluded from data cache.
TIMING: T1=1, T2=20 cycles; Ts=H*T1+(1-H)*(T1+T2).

VALIDATED RESULTS:
- Baseline: Ic=4741, data refs=1907, hits=1748, misses=159, H=0.916622968, Ts=2.667540640 cycles
- Modified: Ic=4401, data refs=1703, hits=1586, misses=117, H=0.931297710, Ts=2.374045802 cycles
- Full array[34] equal; checksum=23899846, decrypt_ok=1, data[0]=84.
- Hit rate +1.467474 percentage points, average data access time -11.00245% (model-based).

LIMITATION: cache data are simulator results, not measured on Ripes/hardware; official form and screenshot proof still pending. Academic AI-use declaration must accurately disclose AI assistance.

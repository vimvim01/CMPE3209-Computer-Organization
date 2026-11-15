#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$HERE/ubuntu_4g_validation"
mkdir -p "$OUT"
for p in clang-17 ld.lld-17 llvm-objdump-17; do
  command -v "$p" >/dev/null || { echo "Eksik arac: $p"; exit 1; }
done
clang-17 --version | head -n 1 | tee "$OUT/compiler.txt"
ld.lld-17 --version | tee -a "$OUT/compiler.txt"
for k in original modified; do
  case "$k" in original) SRC="$HERE/main.c";; modified) SRC="$HERE/main_v2.c";; esac
  clang-17 --target=riscv32 -march=rv32im -mabi=ilp32 -O0 -c "$SRC" -o "$OUT/$k.o"
  ld.lld-17 -m elf32lriscv -e main -Ttext=0x10000 -o "$OUT/$k.elf" "$OUT/$k.o"
  llvm-objdump-17 -d "$OUT/$k.elf" > "$OUT/${k}_objdump.txt"
  readelf -p .comment "$OUT/$k.elf" > "$OUT/${k}_compiler_comment.txt"
done
sha256sum "$OUT/original.elf" "$OUT/modified.elf" | tee "$OUT/checksums.txt"
if [[ -f "$HERE/g3_O0.elf" ]]; then
  sha256sum "$HERE/g3_O0.elf" | tee -a "$OUT/checksums.txt"
fi
(
  cd "$HERE"
  tar -czf "ubuntu_4g_validation.tar.gz" "ubuntu_4g_validation"
)
echo "OK: $HERE/ubuntu_4g_validation.tar.gz"

	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p1_m2p0"
	.file	"g3_message_encryption.c"
	.globl	xor_transform                   # -- Begin function xor_transform
	.p2align	2
	.type	xor_transform,@function
xor_transform:                          # @xor_transform
# %bb.0:
	xor	a0, a1, a0
	ret
.Lfunc_end0:
	.size	xor_transform, .Lfunc_end0-xor_transform
                                        # -- End function
	.globl	generate_and_encrypt            # -- Begin function generate_and_encrypt
	.p2align	2
	.type	generate_and_encrypt,@function
generate_and_encrypt:                   # @generate_and_encrypt
# %bb.0:
	lui	a1, %hi(data)
	addi	a1, a1, %lo(data)
	li	a2, 34
	lui	a3, 300
	addi	a3, a3, 1210
	lui	a4, 406
	addi	a4, a4, 1549
	lui	a5, 247535
	addi	a5, a5, 863
	lui	a6, 40330
	addi	a6, a6, -630
	li	a7, 26
.LBB1_1:                                # =>This Inner Loop Header: Depth=1
	mul	a3, a3, a4
	add	a3, a3, a5
	srli	t0, a3, 16
	mulhu	t1, t0, a6
	mul	t1, t1, a7
	sub	t0, t0, t1
	addi	t0, t0, 65
	xor	t0, t0, a0
	sw	t0, 0(a1)
	addi	a2, a2, -1
	addi	a1, a1, 4
	bnez	a2, .LBB1_1
# %bb.2:
	ret
.Lfunc_end1:
	.size	generate_and_encrypt, .Lfunc_end1-generate_and_encrypt
                                        # -- End function
	.globl	calculate_checksum              # -- Begin function calculate_checksum
	.p2align	2
	.type	calculate_checksum,@function
calculate_checksum:                     # @calculate_checksum
# %bb.0:
	li	a0, 0
	lui	a1, %hi(data)
	addi	a1, a1, %lo(data)
	li	a2, 34
.LBB2_1:                                # =>This Inner Loop Header: Depth=1
	lw	a3, 0(a1)
	srli	a4, a0, 31
	slli	a0, a0, 1
	or	a0, a0, a4
	add	a0, a3, a0
	addi	a2, a2, -1
	addi	a1, a1, 4
	bnez	a2, .LBB2_1
# %bb.2:
	ret
.Lfunc_end2:
	.size	calculate_checksum, .Lfunc_end2-calculate_checksum
                                        # -- End function
	.globl	decrypt_and_verify              # -- Begin function decrypt_and_verify
	.p2align	2
	.type	decrypt_and_verify,@function
decrypt_and_verify:                     # @decrypt_and_verify
# %bb.0:
	lui	a1, %hi(data)
	addi	a2, a1, %lo(data)
	li	a1, 1
	li	a3, 34
	lui	a4, 300
	addi	a4, a4, 1210
	lui	a5, 406
	addi	a5, a5, 1549
	lui	a6, 247535
	addi	a6, a6, 863
	lui	a7, 40330
	addi	a7, a7, -630
	li	t0, 26
.LBB3_1:                                # =>This Inner Loop Header: Depth=1
	lw	t1, 0(a2)
	xor	t1, t1, a0
	sw	t1, 0(a2)
	mul	a4, a4, a5
	add	a4, a4, a6
	srli	t2, a4, 16
	mulhu	t3, t2, a7
	mul	t3, t3, t0
	sub	t2, t2, t3
	addi	t2, t2, 65
	xor	t1, t1, t2
	snez	t1, t1
	addi	t1, t1, -1
	and	a1, t1, a1
	addi	a3, a3, -1
	addi	a2, a2, 4
	bnez	a3, .LBB3_1
# %bb.2:
	mv	a0, a1
	ret
.Lfunc_end3:
	.size	decrypt_and_verify, .Lfunc_end3-decrypt_and_verify
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	2
	.type	main,@function
main:                                   # @main
# %bb.0:
	lui	a0, 247535
	addi	a0, a0, 863
	lui	a1, %hi(data)
	addi	a2, a1, %lo(data)
	li	a3, 34
	lui	a1, 300
	addi	a4, a1, 1210
	lui	a1, 406
	addi	a1, a1, 1549
	lui	a5, 40330
	addi	a5, a5, -630
	li	a6, 26
.LBB4_1:                                # =>This Inner Loop Header: Depth=1
	mul	a4, a4, a1
	add	a4, a4, a0
	srli	a7, a4, 16
	mulhu	t0, a7, a5
	mul	t0, t0, a6
	sub	a7, a7, t0
	addi	a7, a7, 65
	xori	a7, a7, 186
	sw	a7, 0(a2)
	addi	a3, a3, -1
	addi	a2, a2, 4
	bnez	a3, .LBB4_1
# %bb.2:
	li	a2, 0
	lui	a3, %hi(data)
	addi	a3, a3, %lo(data)
	li	a4, 34
.LBB4_3:                                # =>This Inner Loop Header: Depth=1
	lw	a5, 0(a3)
	srli	a6, a2, 31
	slli	a2, a2, 1
	or	a2, a2, a6
	add	a2, a5, a2
	addi	a4, a4, -1
	addi	a3, a3, 4
	bnez	a4, .LBB4_3
# %bb.4:
	lui	a3, %hi(checksum)
	sw	a2, %lo(checksum)(a3)
	lui	a2, %hi(data)
	addi	a3, a2, %lo(data)
	li	a2, 1
	li	a4, 34
	lui	a5, 300
	addi	a5, a5, 1210
	lui	a6, 40330
	addi	a6, a6, -630
	li	a7, 26
.LBB4_5:                                # =>This Inner Loop Header: Depth=1
	lw	t0, 0(a3)
	xori	t0, t0, 186
	sw	t0, 0(a3)
	mul	a5, a5, a1
	add	a5, a5, a0
	srli	t1, a5, 16
	mulhu	t2, t1, a6
	mul	t2, t2, a7
	sub	t1, t1, t2
	addi	t1, t1, 65
	xor	t0, t0, t1
	snez	t0, t0
	addi	t0, t0, -1
	and	a2, t0, a2
	addi	a4, a4, -1
	addi	a3, a3, 4
	bnez	a4, .LBB4_5
# %bb.6:
	lui	a0, %hi(decrypt_ok)
	sw	a2, %lo(decrypt_ok)(a0)
	li	a0, 0
	ret
.Lfunc_end4:
	.size	main, .Lfunc_end4-main
                                        # -- End function
	.type	SID,@object                     # @SID
	.section	.rodata,"a",@progbits
	.globl	SID
	.p2align	2, 0x0
SID:
	.word	1230010                         # 0x12c4ba
	.size	SID, 4

	.type	checksum,@object                # @checksum
	.section	.sbss,"aw",@nobits
	.globl	checksum
	.p2align	2
checksum:
	.word	0                               # 0x0
	.size	checksum, 4

	.type	decrypt_ok,@object              # @decrypt_ok
	.globl	decrypt_ok
	.p2align	2
decrypt_ok:
	.word	0                               # 0x0
	.size	decrypt_ok, 4

	.type	data,@object                    # @data
	.bss
	.globl	data
	.p2align	2, 0x0
data:
	.zero	136
	.size	data, 136

	.ident	"Ubuntu clang version 17.0.6 (23ubuntu7)"
	.section	".note.GNU-stack","",@progbits
	.addrsig

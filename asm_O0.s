	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p1_m2p0"
	.file	"g3_message_encryption.c"
	.globl	xor_transform                   # -- Begin function xor_transform
	.p2align	2
	.type	xor_transform,@function
xor_transform:                          # @xor_transform
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	xor	a0, a0, a1
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
.Lfunc_end0:
	.size	xor_transform, .Lfunc_end0-xor_transform
                                        # -- End function
	.globl	generate_and_encrypt            # -- Begin function generate_and_encrypt
	.p2align	2
	.type	generate_and_encrypt,@function
generate_and_encrypt:                   # @generate_and_encrypt
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	lui	a0, 300
	addi	a0, a0, 1210
	sw	a0, -16(s0)
	li	a0, 0
	sw	a0, -20(s0)
	j	.LBB1_1
.LBB1_1:                                # =>This Inner Loop Header: Depth=1
	lw	a1, -20(s0)
	li	a0, 33
	blt	a0, a1, .LBB1_3
	j	.LBB1_2
.LBB1_2:                                #   in Loop: Header=BB1_1 Depth=1
	lw	a0, -16(s0)
	lui	a1, 406
	addi	a1, a1, 1549
	mul	a0, a0, a1
	lui	a1, 247535
	addi	a1, a1, 863
	add	a0, a0, a1
	sw	a0, -16(s0)
	lw	a0, -16(s0)
	srli	a0, a0, 16
	lui	a1, 40330
	addi	a1, a1, -630
	mulhu	a1, a0, a1
	li	a2, 26
	mul	a1, a1, a2
	sub	a0, a0, a1
	addi	a1, a0, 65
	lw	a2, -20(s0)
	lui	a0, %hi(data)
	addi	a0, a0, %lo(data)
	sw	a0, -24(s0)                     # 4-byte Folded Spill
	slli	a2, a2, 2
	add	a2, a0, a2
	sw	a1, 0(a2)
	lw	a1, -20(s0)
	slli	a1, a1, 2
	add	a0, a0, a1
	lw	a0, 0(a0)
	lw	a1, -12(s0)
	call	xor_transform
	lw	a1, -24(s0)                     # 4-byte Folded Reload
	lw	a2, -20(s0)
	slli	a2, a2, 2
	add	a1, a1, a2
	sw	a0, 0(a1)
	lw	a0, -20(s0)
	addi	a0, a0, 1
	sw	a0, -20(s0)
	j	.LBB1_1
.LBB1_3:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end1:
	.size	generate_and_encrypt, .Lfunc_end1-generate_and_encrypt
                                        # -- End function
	.globl	calculate_checksum              # -- Begin function calculate_checksum
	.p2align	2
	.type	calculate_checksum,@function
calculate_checksum:                     # @calculate_checksum
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	li	a0, 0
	sw	a0, -12(s0)
	sw	a0, -16(s0)
	j	.LBB2_1
.LBB2_1:                                # =>This Inner Loop Header: Depth=1
	lw	a1, -16(s0)
	li	a0, 33
	blt	a0, a1, .LBB2_3
	j	.LBB2_2
.LBB2_2:                                #   in Loop: Header=BB2_1 Depth=1
	lw	a0, -12(s0)
	srli	a1, a0, 31
	slli	a0, a0, 1
	or	a0, a0, a1
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	lw	a2, -16(s0)
	lui	a1, %hi(data)
	addi	a1, a1, %lo(data)
	slli	a2, a2, 2
	add	a1, a1, a2
	lw	a1, 0(a1)
	add	a0, a0, a1
	sw	a0, -12(s0)
	lw	a0, -16(s0)
	addi	a0, a0, 1
	sw	a0, -16(s0)
	j	.LBB2_1
.LBB2_3:
	lw	a0, -12(s0)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
.Lfunc_end2:
	.size	calculate_checksum, .Lfunc_end2-calculate_checksum
                                        # -- End function
	.globl	decrypt_and_verify              # -- Begin function decrypt_and_verify
	.p2align	2
	.type	decrypt_and_verify,@function
decrypt_and_verify:                     # @decrypt_and_verify
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	lui	a0, 300
	addi	a0, a0, 1210
	sw	a0, -16(s0)
	li	a0, 1
	sw	a0, -20(s0)
	li	a0, 0
	sw	a0, -24(s0)
	j	.LBB3_1
.LBB3_1:                                # =>This Inner Loop Header: Depth=1
	lw	a1, -24(s0)
	li	a0, 33
	blt	a0, a1, .LBB3_5
	j	.LBB3_2
.LBB3_2:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -24(s0)
	slli	a1, a0, 2
	lui	a0, %hi(data)
	addi	a0, a0, %lo(data)
	sw	a0, -28(s0)                     # 4-byte Folded Spill
	add	a0, a0, a1
	lw	a0, 0(a0)
	lw	a1, -12(s0)
	call	xor_transform
	mv	a1, a0
	lw	a0, -28(s0)                     # 4-byte Folded Reload
	lw	a2, -24(s0)
	slli	a2, a2, 2
	add	a2, a0, a2
	sw	a1, 0(a2)
	lw	a1, -16(s0)
	lui	a2, 406
	addi	a2, a2, 1549
	mul	a1, a1, a2
	lui	a2, 247535
	addi	a2, a2, 863
	add	a1, a1, a2
	sw	a1, -16(s0)
	lw	a1, -24(s0)
	slli	a1, a1, 2
	add	a0, a0, a1
	lw	a0, 0(a0)
	lw	a1, -16(s0)
	srli	a1, a1, 16
	lui	a2, 40330
	addi	a2, a2, -630
	mulhu	a2, a1, a2
	li	a3, 26
	mul	a2, a2, a3
	sub	a1, a1, a2
	addi	a1, a1, 65
	beq	a0, a1, .LBB3_4
	j	.LBB3_3
.LBB3_3:                                #   in Loop: Header=BB3_1 Depth=1
	li	a0, 0
	sw	a0, -20(s0)
	j	.LBB3_4
.LBB3_4:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -24(s0)
	addi	a0, a0, 1
	sw	a0, -24(s0)
	j	.LBB3_1
.LBB3_5:
	lw	a0, -20(s0)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end3:
	.size	decrypt_and_verify, .Lfunc_end3-decrypt_and_verify
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	2
	.type	main,@function
main:                                   # @main
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	li	a0, 0
	sw	a0, -12(s0)
	li	a0, 186
	sw	a0, -16(s0)
	lw	a0, -16(s0)
	bnez	a0, .LBB4_2
	j	.LBB4_1
.LBB4_1:
	li	a0, 165
	sw	a0, -16(s0)
	j	.LBB4_2
.LBB4_2:
	lw	a0, -16(s0)
	call	generate_and_encrypt
	call	calculate_checksum
	lui	a1, %hi(checksum)
	sw	a0, %lo(checksum)(a1)
	lw	a0, -16(s0)
	call	decrypt_and_verify
	lui	a1, %hi(decrypt_ok)
	sw	a0, %lo(decrypt_ok)(a1)
	li	a0, 0
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
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
	.addrsig_sym xor_transform
	.addrsig_sym generate_and_encrypt
	.addrsig_sym calculate_checksum
	.addrsig_sym decrypt_and_verify
	.addrsig_sym checksum
	.addrsig_sym decrypt_ok
	.addrsig_sym data

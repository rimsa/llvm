; Test sequences that can use RISBG with a zeroed first operand.
;
; RUN: llc < %s -mtriple=s390x-linux-gnu | FileCheck %s

; Test an extraction of bit 0 from a right-shifted value.
define i32 @f1(i32 %foo) {
; CHECK-LABEL: f1:
; CHECK: risbg %r2, %r2, 63, 191, 54
; CHECK: br %r14
  %shr = lshr i32 %foo, 10
  %and = and i32 %shr, 1
  ret i32 %and
}

; ...and again with i64.
define i64 @f2(i64 %foo) {
; CHECK-LABEL: f2:
; CHECK: risbg %r2, %r2, 63, 191, 54
; CHECK: br %r14
  %shr = lshr i64 %foo, 10
  %and = and i64 %shr, 1
  ret i64 %and
}

; Test an extraction of other bits from a right-shifted value.
define i32 @f3(i32 %foo) {
; CHECK-LABEL: f3:
; CHECK: risbg %r2, %r2, 60, 189, 42
; CHECK: br %r14
  %shr = lshr i32 %foo, 22
  %and = and i32 %shr, 12
  ret i32 %and
}

; ...and again with i64.
define i64 @f4(i64 %foo) {
; CHECK-LABEL: f4:
; CHECK: risbg %r2, %r2, 60, 189, 42
; CHECK: br %r14
  %shr = lshr i64 %foo, 22
  %and = and i64 %shr, 12
  ret i64 %and
}

; Test an extraction of most bits from a right-shifted value.
; The range should be reduced to exclude the zeroed high bits.
define i32 @f5(i32 %foo) {
; CHECK-LABEL: f5:
; CHECK: risbg %r2, %r2, 34, 188, 62
; CHECK: br %r14
  %shr = lshr i32 %foo, 2
  %and = and i32 %shr, -8
  ret i32 %and
}

; ...and again with i64.
define i64 @f6(i64 %foo) {
; CHECK-LABEL: f6:
; CHECK: risbg %r2, %r2, 2, 188, 62
; CHECK: br %r14
  %shr = lshr i64 %foo, 2
  %and = and i64 %shr, -8
  ret i64 %and
}

; Try the next value up (mask ....1111001).  The mask itself is suitable
; for RISBG, but the shift is still needed.
define i32 @f7(i32 %foo) {
; CHECK-LABEL: f7:
; CHECK: srl %r2, 2
; CHECK: risbg %r2, %r2, 63, 188, 0
; CHECK: br %r14
  %shr = lshr i32 %foo, 2
  %and = and i32 %shr, -7
  ret i32 %and
}

; ...and again with i64.
define i64 @f8(i64 %foo) {
; CHECK-LABEL: f8:
; CHECK: srlg [[REG:%r[0-5]]], %r2, 2
; CHECK: risbg %r2, [[REG]], 63, 188, 0
; CHECK: br %r14
  %shr = lshr i64 %foo, 2
  %and = and i64 %shr, -7
  ret i64 %and
}

; Test an extraction of bits from a left-shifted value.  The range should
; be reduced to exclude the zeroed low bits.
define i32 @f9(i32 %foo) {
; CHECK-LABEL: f9:
; CHECK: risbg %r2, %r2, 56, 189, 2
; CHECK: br %r14
  %shr = shl i32 %foo, 2
  %and = and i32 %shr, 255
  ret i32 %and
}

; ...and again with i64.
define i64 @f10(i64 %foo) {
; CHECK-LABEL: f10:
; CHECK: risbg %r2, %r2, 56, 189, 2
; CHECK: br %r14
  %shr = shl i64 %foo, 2
  %and = and i64 %shr, 255
  ret i64 %and
}

; Try a wrap-around mask (mask ....111100001111).  The mask itself is suitable
; for RISBG, but the shift is still needed.
define i32 @f11(i32 %foo) {
; CHECK-LABEL: f11:
; CHECK: sll %r2, 2
; CHECK: risbg %r2, %r2, 60, 183, 0
; CHECK: br %r14
  %shr = shl i32 %foo, 2
  %and = and i32 %shr, -241
  ret i32 %and
}

; ...and again with i64.
define i64 @f12(i64 %foo) {
; CHECK-LABEL: f12:
; CHECK: sllg [[REG:%r[0-5]]], %r2, 2
; CHECK: risbg %r2, [[REG]], 60, 183, 0
; CHECK: br %r14
  %shr = shl i64 %foo, 2
  %and = and i64 %shr, -241
  ret i64 %and
}

; Test an extraction from a rotated value, no mask wraparound.
; This is equivalent to the lshr case, because the bits from the
; shl are not used.
define i32 @f13(i32 %foo) {
; CHECK-LABEL: f13:
; CHECK: risbg %r2, %r2, 56, 188, 46
; CHECK: br %r14
  %parta = shl i32 %foo, 14
  %partb = lshr i32 %foo, 18
  %rotl = or i32 %parta, %partb
  %and = and i32 %rotl, 248
  ret i32 %and
}

; ...and again with i64.
define i64 @f14(i64 %foo) {
; CHECK-LABEL: f14:
; CHECK: risbg %r2, %r2, 56, 188, 14
; CHECK: br %r14
  %parta = shl i64 %foo, 14
  %partb = lshr i64 %foo, 50
  %rotl = or i64 %parta, %partb
  %and = and i64 %rotl, 248
  ret i64 %and
}

; Try a case in which only the bits from the shl are used.
define i32 @f15(i32 %foo) {
; CHECK-LABEL: f15:
; CHECK: risbg %r2, %r2, 47, 177, 14
; CHECK: br %r14
  %parta = shl i32 %foo, 14
  %partb = lshr i32 %foo, 18
  %rotl = or i32 %parta, %partb
  %and = and i32 %rotl, 114688
  ret i32 %and
}

; ...and again with i64.
define i64 @f16(i64 %foo) {
; CHECK-LABEL: f16:
; CHECK: risbg %r2, %r2, 47, 177, 14
; CHECK: br %r14
  %parta = shl i64 %foo, 14
  %partb = lshr i64 %foo, 50
  %rotl = or i64 %parta, %partb
  %and = and i64 %rotl, 114688
  ret i64 %and
}

; Test a 32-bit rotate in which both parts of the OR are needed.
; This needs a separate shift (although RISBLG would be better
; if supported).
define i32 @f17(i32 %foo) {
; CHECK-LABEL: f17:
; CHECK: rll [[REG:%r[0-5]]], %r2, 4
; CHECK: risbg %r2, [[REG]], 57, 190, 0
; CHECK: br %r14
  %parta = shl i32 %foo, 4
  %partb = lshr i32 %foo, 28
  %rotl = or i32 %parta, %partb
  %and = and i32 %rotl, 126
  ret i32 %and
}

; ...and for i64, where RISBG should do the rotate too.
define i64 @f18(i64 %foo) {
; CHECK-LABEL: f18:
; CHECK: risbg %r2, %r2, 57, 190, 4
; CHECK: br %r14
  %parta = shl i64 %foo, 4
  %partb = lshr i64 %foo, 60
  %rotl = or i64 %parta, %partb
  %and = and i64 %rotl, 126
  ret i64 %and
}

; Test an arithmetic shift right in which some of the sign bits are kept.
; The SRA is still needed.
define i32 @f19(i32 %foo) {
; CHECK-LABEL: f19:
; CHECK: sra %r2, 28
; CHECK: risbg %r2, %r2, 59, 190, 0
; CHECK: br %r14
  %shr = ashr i32 %foo, 28
  %and = and i32 %shr, 30
  ret i32 %and
}

; ...and again with i64.
define i64 @f20(i64 %foo) {
; CHECK-LABEL: f20:
; CHECK: srag [[REG:%r[0-5]]], %r2, 60
; CHECK: risbg %r2, [[REG]], 59, 190, 0
; CHECK: br %r14
  %shr = ashr i64 %foo, 60
  %and = and i64 %shr, 30
  ret i64 %and
}

; Now try an arithmetic right shift in which the sign bits aren't needed.
; Introduce a second use of %shr so that the ashr doesn't decompose to
; an lshr.
define i32 @f21(i32 %foo, i32 *%dest) {
; CHECK-LABEL: f21:
; CHECK: risbg %r2, %r2, 60, 190, 36
; CHECK: br %r14
  %shr = ashr i32 %foo, 28
  store i32 %shr, i32 *%dest
  %and = and i32 %shr, 14
  ret i32 %and
}

; ...and again with i64.
define i64 @f22(i64 %foo, i64 *%dest) {
; CHECK-LABEL: f22:
; CHECK: risbg %r2, %r2, 60, 190, 4
; CHECK: br %r14
  %shr = ashr i64 %foo, 60
  store i64 %shr, i64 *%dest
  %and = and i64 %shr, 14
  ret i64 %and
}

; Check that we use RISBG for shifted values even if the AND is a
; natural zero extension.
define i64 @f23(i64 %foo) {
; CHECK-LABEL: f23:
; CHECK: risbg %r2, %r2, 56, 191, 62
; CHECK: br %r14
  %shr = lshr i64 %foo, 2
  %and = and i64 %shr, 255
  ret i64 %and
}

; Test a case where the AND comes before a rotate.
define i32 @f24(i32 %foo) {
; CHECK-LABEL: f24:
; CHECK: risbg [[REG:%r[0-5]]], %r2, 60, 190, 0
; CHECK: rll %r2, [[REG]], 3
; CHECK: br %r14
  %and = and i32 %foo, 14
  %parta = shl i32 %and, 3
  %partb = lshr i32 %and, 29
  %rotl = or i32 %parta, %partb
  ret i32 %rotl
}

; ...and again with i64, where a single RISBG is enough.
define i64 @f25(i64 %foo) {
; CHECK-LABEL: f25:
; CHECK: risbg %r2, %r2, 57, 187, 3
; CHECK: br %r14
  %and = and i64 %foo, 14
  %parta = shl i64 %and, 3
  %partb = lshr i64 %and, 61
  %rotl = or i64 %parta, %partb
  ret i64 %rotl
}

; Test a wrap-around case in which the rotate comes after the AND.
define i32 @f26(i32 %foo) {
; CHECK-LABEL: f26:
; CHECK: risbg [[REG:%r[0-5]]], %r2, 60, 185, 0
; CHECK: rll %r2, [[REG]], 5
; CHECK: br %r14
  %and = and i32 %foo, -49
  %parta = shl i32 %and, 5
  %partb = lshr i32 %and, 27
  %rotl = or i32 %parta, %partb
  ret i32 %rotl
}

; ...and again with i64, where a single RISBG is OK.
define i64 @f27(i64 %foo) {
; CHECK-LABEL: f27:
; CHECK: risbg %r2, %r2, 55, 180, 5
; CHECK: br %r14
  %and = and i64 %foo, -49
  %parta = shl i64 %and, 5
  %partb = lshr i64 %and, 59
  %rotl = or i64 %parta, %partb
  ret i64 %rotl
}

; Test a case where the AND comes before a shift left.
define i32 @f28(i32 %foo) {
; CHECK-LABEL: f28:
; CHECK: risbg %r2, %r2, 32, 173, 17
; CHECK: br %r14
  %and = and i32 %foo, 32766
  %shl = shl i32 %and, 17
  ret i32 %shl
}

; ...and again with i64.
define i64 @f29(i64 %foo) {
; CHECK-LABEL: f29:
; CHECK: risbg %r2, %r2, 0, 141, 49
; CHECK: br %r14
  %and = and i64 %foo, 32766
  %shl = shl i64 %and, 49
  ret i64 %shl
}

; Test the next shift up from f28, in which the mask should get shortened.
define i32 @f30(i32 %foo) {
; CHECK-LABEL: f30:
; CHECK: risbg %r2, %r2, 32, 172, 18
; CHECK: br %r14
  %and = and i32 %foo, 32766
  %shl = shl i32 %and, 18
  ret i32 %shl
}

; ...and again with i64.
define i64 @f31(i64 %foo) {
; CHECK-LABEL: f31:
; CHECK: risbg %r2, %r2, 0, 140, 50
; CHECK: br %r14
  %and = and i64 %foo, 32766
  %shl = shl i64 %and, 50
  ret i64 %shl
}

; Test a wrap-around case in which the shift left comes after the AND.
; We can't use RISBG for the shift in that case.
define i32 @f32(i32 %foo) {
; CHECK-LABEL: f32:
; CHECK: sll %r2
; CHECK: br %r14
  %and = and i32 %foo, -7
  %shl = shl i32 %and, 10
  ret i32 %shl
}

; ...and again with i64.
define i64 @f33(i64 %foo) {
; CHECK-LABEL: f33:
; CHECK: sllg %r2
; CHECK: br %r14
  %and = and i64 %foo, -7
  %shl = shl i64 %and, 10
  ret i64 %shl
}

; Test a case where the AND comes before a shift right.
define i32 @f34(i32 %foo) {
; CHECK-LABEL: f34:
; CHECK: risbg %r2, %r2, 57, 191, 55
; CHECK: br %r14
  %and = and i32 %foo, 65535
  %shl = lshr i32 %and, 9
  ret i32 %shl
}

; ...and again with i64.
define i64 @f35(i64 %foo) {
; CHECK-LABEL: f35:
; CHECK: risbg %r2, %r2, 57, 191, 55
; CHECK: br %r14
  %and = and i64 %foo, 65535
  %shl = lshr i64 %and, 9
  ret i64 %shl
}

; Test a wrap-around case where the AND comes before a shift right.
; We can't use RISBG for the shift in that case.
define i32 @f36(i32 %foo) {
; CHECK-LABEL: f36:
; CHECK: srl %r2
; CHECK: br %r14
  %and = and i32 %foo, -25
  %shl = lshr i32 %and, 1
  ret i32 %shl
}

; ...and again with i64.
define i64 @f37(i64 %foo) {
; CHECK-LABEL: f37:
; CHECK: srlg %r2
; CHECK: br %r14
  %and = and i64 %foo, -25
  %shl = lshr i64 %and, 1
  ret i64 %shl
}

; Test a combination involving a large ASHR and a shift left.  We can't
; use RISBG there.
define i64 @f38(i64 %foo) {
; CHECK-LABEL: f38:
; CHECK: srag {{%r[0-5]}}
; CHECK: sllg {{%r[0-5]}}
; CHECK: br %r14
  %ashr = ashr i64 %foo, 32
  %shl = shl i64 %ashr, 5
  ret i64 %shl
}

; Try a similar thing in which no shifted sign bits are kept.
define i64 @f39(i64 %foo, i64 *%dest) {
; CHECK-LABEL: f39:
; CHECK: srag [[REG:%r[01345]]], %r2, 35
; CHECK: risbg %r2, %r2, 33, 189, 31
; CHECK: br %r14
  %ashr = ashr i64 %foo, 35
  store i64 %ashr, i64 *%dest
  %shl = shl i64 %ashr, 2
  %and = and i64 %shl, 2147483647
  ret i64 %and
}

; ...and again with the next highest shift value, where one sign bit is kept.
define i64 @f40(i64 %foo, i64 *%dest) {
; CHECK-LABEL: f40:
; CHECK: srag [[REG:%r[01345]]], %r2, 36
; CHECK: risbg %r2, [[REG]], 33, 189, 2
; CHECK: br %r14
  %ashr = ashr i64 %foo, 36
  store i64 %ashr, i64 *%dest
  %shl = shl i64 %ashr, 2
  %and = and i64 %shl, 2147483647
  ret i64 %and
}

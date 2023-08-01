#scope_export;

Vec128 :: struct(operation_type: Type) {
    low : *void; // low+high exist out here so that printing the struct has decent output
    high : *void;
    #place low;
    union {
        u8s     : [16] u8;
        u16s    : [8] u16;
        u32s    : [4] u32;
        u64s    : [2] u64;
        s8s     : [16] s8;
        s16s    : [8] s16;
        s32s    : [4] s32;
        s64s    : [2] s64;
        float32s: [4] float32;
        float64s: [4] float64;
    }
}

vec128 :: inline (data: *void, $type : Type = void) -> Vec128(type) {
    result : Vec128(type) = ---;
    memcpy(*result, data, 16);
    return result;
}

vec128 :: (str: string, offset: int) -> Vec128(u8), truncated: bool {
    assert(offset >= 0);
    if offset > str.count - 16 {
        v128 : Vec128(u8) = ---;
        zero_count := (offset - (str.count - 16));
        good_count := 16 - zero_count;
        memcpy(*v128, str.data + offset, good_count);
        memset(*v128.u8s[good_count], 0, zero_count);
        return v128, true;
    }
    else
        return vec128(str.data + offset, u8), false;
}

to_string :: (v128: *Vec128) -> string {
    result : string = ---;
    result.data = cast(*u8) v128;
    result.count = 16;
    for < i: 15 .. 0 {
        if v128.u8s[i] == 0  result.count -= 1;
        else  return result;
    }
    return "";
}

operator== :: (a: Vec128, b: Vec128) -> bool {
    return a.low == b.low && a.high == b.high;
}

// Generated:
vec128 :: (array: [16] u8) -> Vec128(u8) {
    return vec128(array.data, u8);
}

vec128 :: (value: u8) -> Vec128(u8) {
    result : Vec128(u8) = ---;
    memset(*result, cast(u8)value, 16);
    return result;
}

vec128 :: (array: [8] u16) -> Vec128(u16) {
    return vec128(array.data, u16);
}

vec128 :: (value: u16) -> Vec128(u16) {
    result : Vec128(u16) = ---;
    for * result.u16s { <<cast(*u16)it = value; }
    return result;
}

vec128 :: (array: [4] u32) -> Vec128(u32) {
    return vec128(array.data, u32);
}

vec128 :: (value: u32) -> Vec128(u32) {
    result : Vec128(u32) = ---;
    for * result.u32s { <<cast(*u32)it = value; }
    return result;
}

vec128 :: (array: [2] u64) -> Vec128(u64) {
    return vec128(array.data, u64);
}

vec128 :: (value: u64) -> Vec128(u64) {
    result : Vec128(u64) = ---;
    for * result.u64s { <<cast(*u64)it = value; }
    return result;
}

vec128 :: (array: [16] s8) -> Vec128(s8) {
    return vec128(array.data, s8);
}

vec128 :: (value: s8) -> Vec128(s8) {
    result : Vec128(s8) = ---;
    memset(*result, cast,no_check(u8)value, 16);
    return result;
}

vec128 :: (array: [8] s16) -> Vec128(s16) {
    return vec128(array.data, s16);
}

vec128 :: (value: s16) -> Vec128(s16) {
    result : Vec128(s16) = ---;
    for * result.u16s { <<cast(*s16)it = value; }
    return result;
}

vec128 :: (array: [4] s32) -> Vec128(s32) {
    return vec128(array.data, s32);
}

vec128 :: (value: s32) -> Vec128(s32) {
    result : Vec128(s32) = ---;
    for * result.u32s { <<cast(*s32)it = value; }
    return result;
}

vec128 :: (array: [2] s64) -> Vec128(s64) {
    return vec128(array.data, s64);
}

vec128 :: (value: s64) -> Vec128(s64) {
    result : Vec128(s64) = ---;
    for * result.u64s { <<cast(*s64)it = value; }
    return result;
}

vec128 :: (array: [4] float32) -> Vec128(float32) {
    return vec128(array.data, float32);
}

vec128 :: (value: float32) -> Vec128(float32) {
    result : Vec128(float32) = ---;
    for * result.u32s { <<cast(*float32)it = value; }
    return result;
}

vec128 :: (array: [2] float64) -> Vec128(float64) {
    return vec128(array.data, float64);
}

vec128 :: (value: float64) -> Vec128(float64) {
    result : Vec128(float64) = ---;
    for * result.u64s { <<cast(*float64)it = value; }
    return result;
}

SET_PS :: inline (z: float, y: float, x: float, w: float) -> [4]float {
    return float.[w, x, y, z];
}

SWIZ :: (x: int, y: int, z: int, w: int) -> Code #expand {
    //return tprint("%;", (((x) << 6) | ((y) << 4) | ((z) << 2) | (w)));
    return (((x) << 6) | ((y) << 4) | ((z) << 2) | (w));
}

swizzle :: inline (in: Vec128(float32), $x:int, $y:int, $z:int, $w:int) -> Vec128(float32) {
    // x y z w
    // z y x w
    swizzler :: (((x) << 6) | ((y) << 4) | ((z) << 2) | (w));
    in_ptr := in.float32s.data;

    out: Vec128(float32);
    out_ptr := out.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x src:, [in_ptr];
        shufps.x dst:, src, src, swizzler;
        movdqu.x [out_ptr], dst;
    }
    return out;
}

//constants
ZZZZ     :: Vec128(float32).{float32s=float.[ 0.0,  0.0,  0.0,  0.0]};
DDDD     :: Vec128(float32).{float32s=float.[ 2.0,  2.0,  2.0,  2.0]};
TTTT     :: Vec128(float32).{float32s=float.[ 3.0,  3.0,  3.0,  3.0]};
HHHH     :: Vec128(float32).{float32s=float.[ 0.5,  0.5,  0.5,  0.5]};
NZZZZ    :: Vec128(float32).{float32s=float.[-0.0,  0.0,  0.0,  0.0]};
ZUUU     :: Vec128(float32).{float32s=float.[ 0.0,  1.0,  1.0,  1.0]};
ZNUNUNU  :: Vec128(float32).{float32s=float.[ 0.0, -1.0, -1.0, -1.0]};
NDNUNUNU :: Vec128(float32).{float32s=float.[-2.0, -1.0, -1.0, -1.0]};
UZZZ     :: Vec128(float32).{float32s=float.[ 1.0,  0.0,  0.0,  0.0]};
NUZZZ    :: Vec128(float32).{float32s=float.[-1.0,  0.0,  0.0,  0.0]};
NUZZZ_I  :: Vec128(s32)    .{s32s=s32.      [  -1,    0,    0,    0]};
ZNZNZNZ  :: Vec128(float32).{float32s=float.[ 0.0, -0.0, -0.0, -0.0]};
NZNZNZNZ :: Vec128(float32).{float32s=float.[-0.0, -0.0, -0.0, -0.0]};
ZNZZZ    :: Vec128(float32).{float32s=float.[ 0.0, -0.0,  0.0,  0.0]};
UDDZ     :: Vec128(float32).{float32s=float.[ 1.0,  2.0,  2.0,  0.0]};
ZZNZZ    :: Vec128(float32).{float32s=float.[ 0.0,  0.0, -0.0,  0.0]};
DNUDZ    :: Vec128(float32).{float32s=float.[ 2.0, -1.0,  2.0,  0.0]};
NZZNZZ   :: Vec128(float32).{float32s=float.[-0.0,  0.0, -0.0,  0.0]};
DDUZ     :: Vec128(float32).{float32s=float.[ 2.0,  2.0,  1.0,  0.0]};
DDDZ     :: Vec128(float32).{float32s=float.[ 2.0,  2.0,  2.0,  0.0]};
ZZZU     :: Vec128(float32).{float32s=float.[ 0.0,  0.0,  0.0,  1.0]};
ZNDNDND  :: Vec128(float32).{float32s=float.[ 0.0, -2.0, -2.0, -2.0]};
ZDDD     :: Vec128(float32).{float32s=float.[ 0.0,  2.0,  2.0,  2.0]};
DDDU     :: Vec128(float32).{float32s=float.[ 2.0,  2.0,  2.0,  1.0]};
UDDD     :: Vec128(float32).{float32s=float.[ 1.0,  2.0,  2.0,  2.0]};
ZZZNZ    :: Vec128(float32).{float32s=float.[ 0.0,  0.0,  0.0, -0.0]};
UUUU     :: Vec128(float32).{float32s=float.[ 1.0,  1.0,  1.0,  1.0]};


// 0 1 2 3 -> 1 + 2 + 3, 0, 0, 0
hi_dp_ss :: (a: Vec128(float32), b: Vec128(float32)) -> Vec128(float32) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;
    out: Vec128(float32);
    out_ptr := out.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        // __m128 out = _mm_mul_ps(a, b);
        mulps.x vout:, va, vb;
        // // 0 1 2 3 -> 1 1 3 3
        // __m128 hi = _mm_movehdup_ps(out);
        movshdup.x hi:, vout;
        // // 0 1 2 3 + 1 1 3 3 -> (0 + 1, 1 + 1, 2 + 3, 3 + 3)
        // __m128 sum = _mm_add_ps(hi, out);
        addps.x sum:, hi, vout;
        // // unpacklo: 0 0 1 1
        // out = _mm_add_ps(sum, _mm_unpacklo_ps(out, out));
        unpcklps.x tmp1:, vout, vout;
        addps.x vout, sum, tmp1;
        // // (1 + 2 + 3, _, _, _)
        // return _mm_movehl_ps(out, out);
        movhlps vout, vout;
        movdqu.x [out_ptr], vout;
    }
    return out;
}

rcp_nr1 :: (a: Vec128(float32)) -> Vec128(float32) {
    a_ptr := a.float32s.data;
    out: Vec128(float32);
    out_ptr := out.float32s.data;
    twos_ptr := DDDD.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vtwos:, [twos_ptr];
        // __m128 xn  = _mm_rcp_ps(a);
        rcpps.x xn:, va;
        // __m128 axn = _mm_mul_ps(a, xn);
        mulps.x axn:, va, xn;
        // return _mm_mul_ps(xn, _mm_sub_ps(_mm_set1_ps(2.f), axn));
        subps.x tmp2:, vtwos, axn;
        mulps.x vout:, xn, tmp2;
        movdqu.x [out_ptr], vout;
    }
    return out;
}

rsqrt_nr1 :: (a: Vec128(float32)) -> Vec128(float32) {
    a_ptr := a.float32s.data;
    out: Vec128(float32);
    out_ptr := out.float32s.data;

    threes_ptr := TTTT.float32s.data;
    halves_ptr := HHHH.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vthrees:, [threes_ptr];
        movdqu.x vhalves:, [halves_ptr];
        movdqu.x va:, [a_ptr];
        // __m128 xn   = _mm_rsqrt_ps(a);
        rsqrtps.x xn:, va;
        // __m128 axn2 = _mm_mul_ps(xn, xn);
        mulps.x axn2:, xn, xn;
        // axn2        = _mm_mul_ps(a, axn2);
        mulps.x axn2, va, axn2;
        // __m128 xn3  = _mm_sub_ps(_mm_set1_ps(3.f), axn2);
        subps.x xn3:, vthrees, axn2;
        // return _mm_mul_ps(_mm_mul_ps(_mm_set1_ps(0.5f), xn), xn3);
        mulps.x tmp1:, vhalves, xn;
        mulps.x tmp1, tmp1, xn3;
        movdqu.x [out_ptr], tmp1;
    }
    return out;
}

sqrt_nr1 :: (a: Vec128(float32)) -> Vec128(float32) {
    a_ptr := a.float32s.data;

    out: Vec128(float32);
    out_ptr := out.float32s.data;

    threes_ptr := TTTT.float32s.data;
    halves_ptr := HHHH.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vthrees:, [threes_ptr];
        movdqu.x vhalves:, [halves_ptr];
        movdqu.x va:, [a_ptr];
        // __m128 xn   = _mm_rsqrt_ps(a);
        rsqrtps.x xn:, va;
        // __m128 axn2 = _mm_mul_ps(xn, xn);
        mulps.x axn2:, xn, xn;
        // axn2        = _mm_mul_ps(a, axn2);
        mulps.x axn2, va, axn2;
        // __m128 xn3  = _mm_sub_ps(_mm_set1_ps(3.f), axn2);
        subps.x xn3:, vthrees, axn2;
        // return _mm_mul_ps(_mm_mul_ps(_mm_set1_ps(0.5f), xn), xn3);
        mulps.x tmp1:, vhalves, xn;
        mulps.x tmp1, tmp1, xn3;
        // tmp1 is rsqrt(a)
        mulps.x tmp2:, va, tmp1;
        movdqu.x [out_ptr], tmp2;
    }
    return out;
}

hi_dp :: (a: Vec128(float32), b: Vec128(float32)) -> Vec128(float32) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;
    out: Vec128(float32);
    out_ptr := out.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        // return _mm_dp_ps(a, b, 0b11100001);
        dpps.x vout:, va, vb, 0b11100001;
        movdqu.x [out_ptr], vout;
    }
    return out;
}
hi_dp_bc :: (a: Vec128(float32), b: Vec128(float32)) -> Vec128(float32) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;
    out: Vec128(float32);
    out_ptr := out.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        // return _mm_dp_ps(a, b, 0b11101111);
        dpps.x vout:, va, vb, 0b11101111;
        movdqu.x [out_ptr], vout;
    }
    return out;
}
dp :: (a: Vec128(float32), b: Vec128(float32)) -> Vec128(float32) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;
    out: Vec128(float32);
    out_ptr := out.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        // return _mm_dp_ps(a, b, 0b11110001);
        dpps.x vout:, va, vb, 0b11110001;
        movdqu.x [out_ptr], vout;
    }
    return out;
}
dp_bc :: (a: Vec128(float32), b: Vec128(float32)) -> Vec128(float32) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;
    out: Vec128(float32);
    out_ptr := out.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        // return _mm_dp_ps(a, b, 0xff);
        dpps.x vout:, va, vb, 0xFF;
        movdqu.x [out_ptr], vout;
    }
    return out;
}

exp :: (a: Vec128(float32), b: Vec128(float32), p1_out: *Vec128(float32), p2_out: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    zeros_ptr := ZZZZ.float32s.data;

    mask :u32 = 0;
    mask_ptr := *mask;

    #asm AVX, AVX2 {
        movdqu.x vzero:, [zeros_ptr];
        movdqu.x va:, [a_ptr];
        // int mask = _mm_movemask_ps(_mm_cmpeq_ps(a, _mm_setzero_ps()));
        cmpps.x tmp:, va, vzero, 0;
        movmskps.x rmask:, tmp;
        mov [mask_ptr], rmask;
    }
    if mask == 0xf {
        // When exponentiating an ideal line, the terms past the linear
        // term in the Taylor series expansion vanishes
        p1_out.float32s.data[0] = 1; 
        p1_out.float32s.data[1] = 0; 
        p1_out.float32s.data[2] = 0; 
        p1_out.float32s.data[3] = 0; 
        p2_out.float32s.data[0] = b.float32s[0];
        p2_out.float32s.data[1] = b.float32s[1];
        p2_out.float32s.data[2] = b.float32s[2];
        p2_out.float32s.data[3] = b.float32s[3];
        return;
    }

    a2: Vec128(float32);
    a2_ptr := a2.float32s.data;
    ab: Vec128(float32);
    ab_ptr := ab.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x va, [a_ptr];
        movdqu.x vb:, [b_ptr];
        // __m128 a2 = hi_dp_bc(a, a);
        dpps.x va2:, va, va, 0b11101111;
        // __m128 ab = hi_dp_bc(a, b);
        dpps.x vab:, va, vb, 0b11101111;
        movdqu.x [a2_ptr], va2;
        movdqu.x [ab_ptr], vab;
    }
    // __m128 a2_sqrt_rcp = detail::rsqrt_nr1(a2);
    a2_sqrt_rcp := rsqrt_nr1(a2);
    a2_sqrt_rcp_ptr := a2_sqrt_rcp.float32s.data;
    a2_rcp := rcp_nr1(a2);
    a2_rcp_ptr := a2_rcp.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va, [a_ptr];
        movdqu.x vb, [b_ptr];
        movdqu.x va2, [a2_ptr];
        movdqu.x vab, [ab_ptr];
        movdqu.x va2_sqrt_rcp:, [a2_sqrt_rcp_ptr];
        movdqu.x va2_rcp_ptr:, [a2_rcp_ptr];
        // __m128 u           = _mm_mul_ps(a2, a2_sqrt_rcp);
        mulps.x u:, va2, va2_sqrt_rcp;
        // __m128 minus_v = _mm_mul_ps(ab, a2_sqrt_rcp);
        mulps.x minus_v:, vab, va2_sqrt_rcp;
        // __m128 norm_real  = _mm_mul_ps(a, a2_sqrt_rcp);
        mulps.x norm_real:, va, va2_sqrt_rcp;
        // __m128 norm_ideal = _mm_mul_ps(b, a2_sqrt_rcp);
        mulps.x norm_ideal:, vb, va2_sqrt_rcp;
        // norm_ideal = _mm_sub_ps(
        //     norm_ideal,
        //     _mm_mul_ps(
        //         a, _mm_mul_ps(ab, _mm_mul_ps(a2_sqrt_rcp, detail::rcp_nr1(a2)))));
        mulps.x tmp1:, va2_sqrt_rcp, va2_rcp_ptr;
        mulps.x tmp1, vab, tmp1;
        mulps.x tmp1, va, tmp1;
        subps.x norm_ideal, norm_ideal, tmp1;
    }

    uv: [2]float;
    uv_ptr := uv.data;
    #asm AVX, AVX2 {
        // _mm_store_ss(uv, u);
        movss [uv_ptr], u;
        // _mm_store_ss(uv + 1, minus_v);
        movss [uv_ptr+4], minus_v;
    }
    sincosu: [2]float;
    sincosu[0] = sin(uv[0]);
    sincosu[1] = cos(uv[0]);

    p1_out_ptr := p1_out.float32s.data;
    p2_out_ptr := p2_out.float32s.data;

    // __m128 sinu = _mm_set1_ps(sincosu[0]);
    sinu := vec128(float.[sincosu[0], sincosu[0], sincosu[0], sincosu[0]]);
    sinu_ptr := sinu.float32s.data;
    sinutmp1 := vec128(SET_PS(0, 0, 0, sincosu[1]));
    sinutmp1_ptr := sinutmp1.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vsinu:, [sinu_ptr];
        movdqu.x vsinu_tmp1:, [sinutmp1_ptr];
        // p1_out      = _mm_add_ps(
        //     _mm_set_ps(0.f, 0.f, 0.f, sincosu[1]), _mm_mul_ps(sinu, norm_real));
        mulps.x tmp1, vsinu, norm_real;
        addps.x vp1_out:, vsinu_tmp1, tmp1;
        movdqu.x [p1_out_ptr], vp1_out;
    }

    cosu := vec128(SET_PS(sincosu[1], sincosu[1], sincosu[1], 0));
    cosu_ptr := cosu.float32s.data;

    minus_vsinu := vec128(SET_PS(0, 0, 0, uv[1] * sincosu[0]));
    minus_vsinu_ptr := minus_vsinu.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vcosu:, [cosu_ptr];
        movdqu.x vminus_vsinu:, [minus_vsinu_ptr];
        // __m128 minus_vcosu = _mm_mul_ps(minus_v, cosu);
        mulps.x minus_vcosu:, minus_v, vcosu;
        // p2_out             = _mm_mul_ps(sinu, norm_ideal);
        mulps.x vp2_out:, vsinu, norm_ideal;
        // p2_out = _mm_add_ps(p2_out, _mm_mul_ps(minus_vcosu, norm_real));
        mulps.x tmp1, minus_vcosu, norm_real;
        addps.x vp2_out, vp2_out, tmp1;
        // p2_out = _mm_add_ps(_mm_set_ps(0.f, 0.f, 0.f, minus_vsinu), p2_out);
        addps.x vp2_out, vminus_vsinu, vp2_out;
        movdqu.x [p2_out_ptr], vp2_out;
    }
}

log :: (p1: Vec128(float32), p2: Vec128(float32), p1_out: *Vec128(float32), p2_out: *Vec128(float32)) {
    p1_ptr := p1.float32s.data;
    p2_ptr := p2.float32s.data;

    zero_ptr := ZZZZ.float32s.data;

    bv_mask_ptr := ZUUU.float32s.data;

    a: Vec128(float32);
    a_ptr := a.float32s.data;

    mask :u32 = 0;
    mask_ptr := *mask;

    #asm AVX, AVX2 {
        movdqu.x vzero:, [zero_ptr];
        movdqu.x vp1:, [p1_ptr];
        movdqu.x vbv_mask:, [bv_mask_ptr];
        // __m128 a       = _mm_mul_ps(bv_mask, p1);
        mulps.x va:, vbv_mask, vp1;
        // int mask = _mm_movemask_ps(_mm_cmpeq_ps(a, _mm_setzero_ps()));
        cmpps.x tmp:, va, vzero, 0;
        movmskps.x rmask:, tmp;
        mov [mask_ptr], rmask;
        movdqu.x [a_ptr], va;
    }


    if mask == 0xf {
        p1_out.float32s.data[0] = 0; 
        p1_out.float32s.data[1] = 0; 
        p1_out.float32s.data[2] = 0; 
        p1_out.float32s.data[3] = 0; 
        p2_out.float32s.data[0] = p2.float32s[0];
        p2_out.float32s.data[1] = p2.float32s[1];
        p2_out.float32s.data[2] = p2.float32s[2];
        p2_out.float32s.data[3] = p2.float32s[3];
        return;
    }

    b: Vec128(float32);
    b_ptr := b.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vp2:, [p2_ptr];
        // __m128 b = _mm_mul_ps(bv_mask, p2);
        mulps.x vb:, vbv_mask, vp2;
        movdqu.x [b_ptr], vb;
    }

    // __m128 a2          = hi_dp_bc(a, a);
    a2 := hi_dp_bc(a, a);
    a2_ptr := a2.float32s.data;
    // __m128 ab          = hi_dp_bc(a, b);
    ab := hi_dp_bc(a, b);
    ab_ptr := ab.float32s.data;

    // __m128 a2_sqrt_rcp = detail::rsqrt_nr1(a2);
    a2_sqrt_rcp := rsqrt_nr1(a2);
    a2_sqrt_rcp_ptr := a2_sqrt_rcp.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va2:, [a2_ptr];
        movdqu.x vab:, [ab_ptr];
        movdqu.x va2_sqrt_rcp:, [a2_sqrt_rcp_ptr];
        // __m128 s           = _mm_mul_ps(a2, a2_sqrt_rcp);
        mulps.x s:, va2, va2_sqrt_rcp;
        // __m128 minus_t     = _mm_mul_ps(ab, a2_sqrt_rcp);
        mulps.x minus_t:, vab, va2_sqrt_rcp;
    }

    p, q, s_scalar, t_scalar: float;
    p_ptr := *p;
    q_ptr := *q;
    s_scalar_ptr := *s_scalar;
    t_scalar_ptr := *t_scalar;
    #asm AVX, AVX2 {
        // _mm_store_ss(&p, p1);
        movss [p_ptr], vp1;
        // _mm_store_ss(&q, p2);
        movss [q_ptr], vp2;
        // _mm_store_ss(&s_scalar, s);
        movss [s_scalar_ptr], s;
        // _mm_store_ss(&t_scalar, minus_t);
        movss [t_scalar_ptr], minus_t;
    }
    // t_scalar *= -1.f;
    t_scalar *= -1;
    p_zero := abs(p) < 0.0000001;
    u, v: float;
    if p_zero {
        u = atan2(-q, t_scalar);
        v = -q / s_scalar;
    } else {
        u = atan2(s_scalar, p);
        v = t_scalar/p;
    }

    a2_rcp := rcp_nr1(a2);
    a2_rcp_ptr := a2_rcp.float32s.data;

    uvec := vec128(float.[u, u, u, u]);
    uvec_ptr := uvec.float32s.data;

    vvec := vec128(float.[v, v, v, v]);
    vvec_ptr := vvec.float32s.data;

    p1_out_ptr := p1_out.float32s.data;
    p2_out_ptr := p2_out.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va2_rcp_ptr:, [a2_rcp_ptr];
        movdqu.x vb, [b_ptr];
        movdqu.x vuvec:, [uvec_ptr];
        movdqu.x vvvec:, [vvec_ptr];
        // __m128 norm_real  = _mm_mul_ps(a, a2_sqrt_rcp);
        mulps.x norm_real:, va, va2_sqrt_rcp;
        // __m128 norm_ideal = _mm_mul_ps(b, a2_sqrt_rcp);
        mulps.x norm_ideal:, vb, va2_sqrt_rcp;
        // norm_ideal        = _mm_sub_ps(
        //     norm_ideal,
        //     _mm_mul_ps(
        //         a, _mm_mul_ps(ab, _mm_mul_ps(a2_sqrt_rcp, detail::rcp_nr1(a2)))));
        mulps.x tmp1:, va2_sqrt_rcp, va2_rcp_ptr;
        mulps.x tmp1, vab, tmp1;
        mulps.x tmp1, va, tmp1;
        subps.x norm_ideal, norm_ideal, tmp1;
        // p1_out      = _mm_mul_ps(uvec, norm_real);
        mulps.x vp1_out:, vuvec, norm_real;
        // p2_out      = _mm_mul_ps(uvec, norm_ideal);
        mulps.x vp2_out:, vuvec, norm_ideal;
        // p2_out      = _mm_sub_ps(p2_out, _mm_mul_ps(_mm_set1_ps(v), norm_real));
        mulps.x tmp1, vvvec, norm_real;
        subps.x vp2_out, vp2_out, tmp1;
        movdqu.x [p1_out_ptr], vp1_out;
        movdqu.x [p2_out_ptr], vp2_out;
    }
}

s0000 :: #insert #run SWIZ(0, 0, 0, 0);
s0001 :: #insert #run SWIZ(0, 0, 0, 1);
s0002 :: #insert #run SWIZ(0, 0, 0, 2);
s0020 :: #insert #run SWIZ(0, 0, 2, 0);
s0021 :: #insert #run SWIZ(0, 0, 2, 1);
s0032 :: #insert #run SWIZ(0, 0, 3, 2);
s0033 :: #insert #run SWIZ(0, 0, 3, 3);
s0003 :: #insert #run SWIZ(0, 0, 0, 3);
s0130 :: #insert #run SWIZ(0, 1, 3, 0);
s0131 :: #insert #run SWIZ(0, 1, 3, 1);
s0132 :: #insert #run SWIZ(0, 1, 3, 2);
s0202 :: #insert #run SWIZ(0, 2, 0, 2);
s0213 :: #insert #run SWIZ(0, 2, 1, 3);
s0301 :: #insert #run SWIZ(0, 3, 0, 1);
s0313 :: #insert #run SWIZ(0, 3, 1, 3);
s0321 :: #insert #run SWIZ(0, 3, 2, 1);
s0322 :: #insert #run SWIZ(0, 3, 2, 2);
s1111 :: #insert #run SWIZ(1, 1, 1, 1);
s1320 :: #insert #run SWIZ(1, 3, 2, 0);
s1321 :: #insert #run SWIZ(1, 3, 2, 1);
s1322 :: #insert #run SWIZ(1, 3, 2, 2);
s1323 :: #insert #run SWIZ(1, 3, 2, 3);
s1332 :: #insert #run SWIZ(1, 3, 3, 2);
s2130 :: #insert #run SWIZ(2, 1, 3, 0);
s2123 :: #insert #run SWIZ(2, 1, 2, 3);
s2131 :: #insert #run SWIZ(2, 1, 3, 1);
s2132 :: #insert #run SWIZ(2, 1, 3, 2);
s2133 :: #insert #run SWIZ(2, 1, 3, 3);
s2222 :: #insert #run SWIZ(2, 2, 2, 2);
s2311 :: #insert #run SWIZ(2, 3, 1, 1);
s2313 :: #insert #run SWIZ(2, 3, 1, 3);
s3121 :: #insert #run SWIZ(3, 1, 2, 1);
s3123 :: #insert #run SWIZ(3, 1, 2, 3);
s3211 :: #insert #run SWIZ(3, 2, 1, 1);
s3212 :: #insert #run SWIZ(3, 2, 1, 2);
s3213 :: #insert #run SWIZ(3, 2, 1, 3);
s3333 :: #insert #run SWIZ(3, 3, 3, 3);

// exterior_product
ext00 :: (a: Vec128(float32), b: Vec128(float32), p1_out: *Vec128(float32), p2_out: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p1_out_ptr := p1_out.float32s.data;
    p2_out_ptr := p2_out.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];

        shufps.x va1320:, va, va, s1320;
        shufps.x vb1320:, vb, vb, s1320;
        shufps.x va0000:, va, va, s0000;
        shufps.x vb0000:, vb, vb, s0000;
        // p1_out = _mm_mul_ps(a, KLN_SWIZZLE(b, 1, 3, 2, 0));
        mulps.x vp1_out:, va, vb1320;
        // p1_out = KLN_SWIZZLE(
        //     _mm_sub_ps(p1_out, _mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 0), b)),
        //     1,
        //     3,
        //     2,
        //     0);
        mulps.x tmp1:, va1320, vb;
        subps.x vp1_out, vp1_out, tmp1;
        shufps.x vp1_out_s:, vp1_out, vp1_out, s1320;

        // p2_out = _mm_mul_ps(KLN_SWIZZLE(a, 0, 0, 0, 0), b);
        mulps.x vp2_out:, va0000, vb;
        // p2_out = _mm_sub_ps(p2_out, _mm_mul_ps(a, KLN_SWIZZLE(b, 0, 0, 0, 0)));
        mulps.x tmp1, va, vb0000;
        subps.x vp2_out, vp2_out, tmp1;

        movdqu.x [p1_out_ptr], vp1_out_s;
        movdqu.x [p2_out_ptr], vp2_out;
    }
}

extPB :: (a: Vec128(float32), b: Vec128(float32), p3_out: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p3_out_ptr := p3_out.float32s.data;

    nnnz_ptr := ZNUNUNU.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vnnnz:, [nnnz_ptr];
        // p3_out = _mm_mul_ps(
        //             _mm_mul_ps(KLN_SWIZZLE(a, 0, 0, 0, 1), b),
        //              _mm_set_ps(-1.f, -1.f, -1.f, 0.f)
        // );
        shufps.x va0001:, va, va, s0001;
        mulps.x tmp1:, va0001, vb;
        mulps.x vp3_out:, tmp1, vnnnz;
        // p3_out = _mm_add_ss(p3_out, hi_dp(a, b));
        dpps.x vhidp:, va, vb, 0b11100001;
        addss vp3_out, vp3_out, vhidp;
        movdqu.x [p3_out_ptr], vp3_out;
    }
}

ext02 :: (a: Vec128(float32), b: Vec128(float32), p3_out: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p3_out_ptr := p3_out.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];

        // p3_out = _mm_mul_ps(a, KLN_SWIZZLE(b, 1, 3, 2, 0));
        shufps.x vb1320:, vb, vb, s1320;
        mulps.x vp3_out:, va, vb1320;
        // p3_out = KLN_SWIZZLE(
        //     _mm_sub_ps(p3_out, _mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 0), b)),
        //     1,
        //     3,
        //     2,
        //     0);
        shufps.x va1320:, va, va, s1320;
        mulps.x tmp1:, va1320, vb;
        subps.x vp3_out, vp3_out, tmp1;
        shufps.x vp3_out_s:, vp3_out, vp3_out, s1320;

        movdqu.x [p3_out_ptr], vp3_out_s;
    }
}

ext03_flip :: (a: Vec128(float32), b: Vec128(float32), p2: *Vec128(float32)) {
    ext03(a, b, p2);
    p2_ptr := p2.float32s.data;

    flip_ptr := NZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vflip:, [flip_ptr];
        movdqu.x vp2:, [p2_ptr];
        // p2 = _mm_xor_ps(p2, _mm_set_ss(-0.f));
        xorps.x vp2, vp2, vflip;
        movdqu.x [p2_ptr], vp2;
    }
}

ext03 :: (a: Vec128(float32), b: Vec128(float32), p2: *Vec128(float32)) {
    tmp := dp(a, b);
    p2.float32s.data[0] = tmp.float32s.data[0];
    p2.float32s.data[1] = tmp.float32s.data[1];
    p2.float32s.data[2] = tmp.float32s.data[2];
    p2.float32s.data[3] = tmp.float32s.data[3];
}

// geometric product
gp00 :: (a: Vec128(float32), b: Vec128(float32), p1_out: *Vec128(float32), p2_out: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p1_out_ptr := p1_out.float32s.data;
    p2_out_ptr := p2_out.float32s.data;

    flip_ptr := NZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu vflip:, [flip_ptr];
        // p1_out
        //     = _mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 1), KLN_SWIZZLE(b, 2, 1, 3, 1));
        shufps.x va1321:, va, va, s1321;
        shufps.x vb2131:, vb, vb, s2131;
        mulps.x vp1_out:, va1321, vb2131;
        // p1_out = _mm_sub_ps(p1_out,
        //                     _mm_xor_ps(_mm_set_ss(-0.f),
        //                                _mm_mul_ps(KLN_SWIZZLE(a, 2, 1, 3, 2),
        //                                           KLN_SWIZZLE(b, 1, 3, 2, 2))));
        shufps.x va2132:, va, va, s2132;
        shufps.x vb1322:, vb, vb, s1322;
        mulps.x tmp1:, va2132, vb1322;
        xorps.x tmp1, vflip, tmp1;
        subps.x vp1_out, vp1_out, tmp1;
        // p1_out = _mm_add_ss(
        //     p1_out,
        //     _mm_mul_ps(KLN_SWIZZLE(a, 0, 0, 0, 3), KLN_SWIZZLE(b, 0, 0, 0, 3)));
        shufps.x va0003:, va, va, s0003;
        shufps.x vb0003:, vb, vb, s0003;
        mulps.x tmp1, va0003, vb0003;
        addss vp1_out, vp1_out, tmp1;

        // p2_out = _mm_mul_ps(KLN_SWIZZLE(a, 0, 0, 0, 0), b);
        shufps.x va0000:, va, va, s0000;
        mulps.x vp2_out:, va0000, vb;
        // p2_out = _mm_sub_ps(p2_out, _mm_mul_ps(a, KLN_SWIZZLE(b, 0, 0, 0, 0)));
        shufps.x vb0000:, vb, vb, s0000;
        mulps.x tmp1, va, vb0000;
        subps.x vp2_out, vp2_out, tmp1;

        movdqu.x [p1_out_ptr], vp1_out;
        movdqu.x [p2_out_ptr], vp2_out;
    }
}

// flip == true
gp03_flip :: (a: Vec128(float32), b: Vec128(float32), p1: *Vec128(float32), p2: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p1_ptr := p1.float32s.data;
    p2_ptr := p2.float32s.data;

    flip_ptr := NZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];

        // p1 = _mm_mul_ps(a, KLN_SWIZZLE(b, 0, 0, 0, 0));
        shufps.x vb0000:, vb, vb, s0000;
        mulps.x vp1:, va, vb0000;
        // p1 = _mm_blend_ps(p1, _mm_setzero_ps(), 1);
        xorps.x zeros:, va, va;
        blendps.x vp1, vp1, zeros, 1;
        // p2 = _mm_mul_ps(KLN_SWIZZLE(a, 2, 1, 3, 0), KLN_SWIZZLE(b, 1, 3, 2, 0));
        shufps.x va2130:, va, va, s2130;
        shufps.x vb1320:, vb, vb, s1320;
        mulps.x vp2:, va2130, vb1320;
        // p2 = _mm_sub_ps(
        //     p2,
        //     _mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 0), KLN_SWIZZLE(b, 2, 1, 3, 0)));
        shufps.x va1320:, va, va, s1320;
        shufps.x vb2130:, vb, vb, s2130;
        mulps.x tmp1:, va1320, vb2130;
        subps.x vp2, vp2, tmp1;
        // __m128 tmp = dp(a, b);
        dpps.x tmp:, va, vb, 0b11110001;
        // tmp = _mm_xor_ps(tmp, _mm_set_ss(-0.f));
        movdqu.x vflip:, [flip_ptr];
        xorps.x tmp, tmp, vflip;
        // p2 = _mm_add_ps(p2, tmp);
        addps.x vp2, vp2, tmp;

        movdqu.x [p1_ptr], vp1;
        movdqu.x [p2_ptr], vp2;
    }
}

gp03 :: (a: Vec128(float32), b: Vec128(float32), p1: *Vec128(float32), p2: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p1_ptr := p1.float32s.data;
    p2_ptr := p2.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];

        // p1 = _mm_mul_ps(a, KLN_SWIZZLE(b, 0, 0, 0, 0));
        shufps.x vb0000:, vb, vb, s0000;
        mulps.x vp1:, va, vb0000;
        // p1 = _mm_blend_ps(p1, _mm_setzero_ps(), 1);
        xorps.x zeros:, va, va;
        blendps.x vp1, vp1, zeros, 1;
        // p2 = _mm_mul_ps(KLN_SWIZZLE(a, 2, 1, 3, 0), KLN_SWIZZLE(b, 1, 3, 2, 0));
        shufps.x va2130:, va, va, s2130;
        shufps.x vb1320:, vb, vb, s1320;
        mulps.x vp2:, va2130, vb1320;
        // p2 = _mm_sub_ps(
        //     p2,
        //     _mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 0), KLN_SWIZZLE(b, 2, 1, 3, 0)));
        shufps.x va1320:, va, va, s1320;
        shufps.x vb2130:, vb, vb, s2130;
        mulps.x tmp1:, va1320, vb2130;
        subps.x vp2, vp2, tmp1;
        // __m128 tmp = dp(a, b);
        dpps.x tmp2:, va, vb, 0b11110001;
        // p2         = _mm_add_ps(p2, tmp);
        addps.x vp2, vp2, tmp2;

        movdqu.x [p1_ptr], vp1;
        movdqu.x [p2_ptr], vp2;
    }
}

gp11 :: (a: Vec128(float32), b: Vec128(float32), p1_out: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p1_out_ptr := p1_out.float32s.data;

    flip_ptr := NZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];

        // p1_out = _mm_mul_ps(KLN_SWIZZLE(a, 0, 0, 0, 0), b);
        shufps.x va0000:, va, va, s0000;
        mulps.x vp1_out:, va0000, vb;
        // p1_out = _mm_sub_ps(
        //     p1_out,
        //     _mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 1), KLN_SWIZZLE(b, 2, 1, 3, 1)));
        shufps.x va1321:, va, va, s1321;
        shufps.x vb2131:, vb, vb, s2131;
        mulps.x tmp:, va1321, vb2131;
        subps.x vp1_out, vp1_out, tmp;
        // __m128 tmp1
        //     = _mm_mul_ps(KLN_SWIZZLE(a, 3, 2, 1, 2), KLN_SWIZZLE(b, 0, 0, 0, 2));
        shufps.x va3212:, va, va, s3212;
        shufps.x vb0002:, vb, vb, s0002;
        mulps.x tmp1:, va3212, vb0002;
        // __m128 tmp2
        //     = _mm_mul_ps(KLN_SWIZZLE(a, 2, 1, 3, 3), KLN_SWIZZLE(b, 1, 3, 2, 3));
        shufps.x va2133:, va, va, s2133;
        shufps.x vb1323:, vb, vb, s1323;
        mulps.x tmp2:, va2133, vb1323;
        // __m128 tmp = _mm_xor_ps(_mm_add_ps(tmp1, tmp2), _mm_set_ss(-0.f));
        addps.x tmp1, tmp1, tmp2;
        movdqu.x vflip:, [flip_ptr];
        xorps.x tmp, tmp1, vflip;
        // p1_out = _mm_add_ps(p1_out, tmp);
        addps.x vp1_out, vp1_out, tmp;

        movdqu.x [p1_out_ptr], vp1_out;
    }
}

gp33 :: (a: Vec128(float32), b: Vec128(float32), p2: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p2_ptr := p2.float32s.data;

    nnnd_ptr := NDNUNUNU.float32s.data;

    twos_ptr := DDDD.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vnnnd:, [nnnd_ptr];
        movdqu.x vtwos:, [twos_ptr];

        // __m128 tmp = _mm_mul_ps(KLN_SWIZZLE(a, 0, 0, 0, 0), b);
        shufps.x va0000:, va, va, s0000;
        mulps.x tmp:, va0000, vb;
        // tmp        = _mm_mul_ps(tmp, _mm_set_ps(-1.f, -1.f, -1.f, -2.f));
        mulps.x tmp, tmp, vnnnd;
        // tmp        = _mm_add_ps(tmp, _mm_mul_ps(a, KLN_SWIZZLE(b, 0, 0, 0, 0)));
        shufps.x vb0000:, vb, vb, s0000;
        mulps.x tmp1:, va, vb0000;
        addps.x tmp, tmp, tmp1;
        // __m128 ss = _mm_moveldup_ps(tmp);
        movsldup.x ss:, tmp;
        // ss        = _mm_movelh_ps(ss, ss);
        unpcklpd.x ss, ss, ss;
        // tmp       = _mm_mul_ps(tmp, detail::rcp_nr1(ss));
        // >>>>>>>>>>>>> inline rcp_nr1;
        rcpps.x xn:, ss;
        mulps.x axn:, ss, xn;
        subps.x tmp4:, vtwos, axn;
        mulps.x rcp:, xn, tmp4;
        // <<<<<<<<<<<<<
        mulps.x tmp, tmp, rcp;
        // p2 = _mm_blend_ps(tmp, _mm_setzero_ps(), 1);
        xorps.x zeros:, va, va;
        blendps.x vp2:, tmp, zeros, 1;

        movdqu.x [p2_ptr], vp2;
    }
}

gpDL :: (u: float, v: float, b: Vec128(float32), c: Vec128(float32), p1: *Vec128(float32), p2: *Vec128(float32)) {
    // __m128 u_vec = _mm_set1_ps(u);
    us := vec128(float.[u, u, u, u]);
    us_ptr := us.float32s.data;
    // __m128 v_vec = _mm_set1_ps(v);
    vs := vec128(float.[v, v, v, v]);
    vs_ptr := vs.float32s.data;

    b_ptr := b.float32s.data;
    c_ptr := c.float32s.data;

    p1_ptr := p1.float32s.data;
    p2_ptr := p2.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vb:, [b_ptr];
        movdqu.x vc:, [c_ptr];
        movdqu.x vus:, [us_ptr];
        movdqu.x vvs:, [vs_ptr];
        // p1           = _mm_mul_ps(u_vec, b);
        mulps.x vp1:, vus, vb;
        // p2           = _mm_mul_ps(c, u_vec);
        mulps.x vp2:, vc, vus;
        // p2           = _mm_sub_ps(p2, _mm_mul_ps(b, v_vec));
        mulps.x tmp:, vb, vvs;
        subps.x vp2, vp2, tmp;

        movdqu.x [p1_ptr], vp1;
        movdqu.x [p2_ptr], vp2;
    }
}

gpRT_flip :: (a: Vec128(float32), b: Vec128(float32), p2: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p2_ptr := p2.float32s.data;

    flip_ptr := NZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vflip:, [flip_ptr];

        // p2 = _mm_mul_ps(KLN_SWIZZLE(a, 0, 0, 0, 1), KLN_SWIZZLE(b, 3, 2, 1, 1));
        shufps.x va0001:, va, va, s0001;
        shufps.x vb3211:, vb, vb, s3211;
        mulps.x vp2:, va0001, vb3211;
        // p2 = _mm_add_ps(
        //     p2,
        //     _mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 2), KLN_SWIZZLE(b, 2, 1, 3, 2)));
        shufps.x va1322:, va, va, s1322;
        shufps.x vb2132:, vb, vb, s2132;
        mulps.x tmp:, va1322, vb2132;
        addps.x vp2, vp2, tmp;
        // p2 = _mm_sub_ps(p2,
        //                 _mm_xor_ps(_mm_set_ss(-0.f),
        //                            _mm_mul_ps(KLN_SWIZZLE(a, 2, 1, 3, 3),
        //                                       KLN_SWIZZLE(b, 1, 3, 2, 3))));
        shufps.x va2133:, va, va, s2133;
        shufps.x vb1323:, vb, vb, s1323;
        mulps.x tmp, va2133, vb1323;
        xorps.x tmp, vflip, tmp;
        subps.x vp2, vp2, tmp;

        movdqu.x [p2_ptr], vp2;
    }
}

gpRT :: (a: Vec128(float32), b: Vec128(float32), p2: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p2_ptr := p2.float32s.data;

    flip_ptr := NZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vflip:, [flip_ptr];
        // p2 = _mm_mul_ps(KLN_SWIZZLE(a, 0, 0, 0, 1), KLN_SWIZZLE(b, 3, 2, 1, 1));
        shufps.x va0001:, va, va, s0001;
        shufps.x vb3211:, vb, vb, s3211;
        mulps.x vp2:, va0001, vb3211;
        // p2 = _mm_add_ps(
        //     p2,
        //     _mm_mul_ps(KLN_SWIZZLE(a, 2, 1, 3, 2), KLN_SWIZZLE(b, 1, 3, 2, 2)));
        shufps.x va2132:, va, va, s2132;
        shufps.x vb1322:, vb, vb, s1322;
        mulps.x tmp:, va2132, vb1322;
        addps.x vp2, vp2, tmp;
        // p2 = _mm_sub_ps(p2,
        //                 _mm_xor_ps(_mm_set_ss(-0.f),
        //                            _mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 3),
        //                                       KLN_SWIZZLE(b, 2, 1, 3, 3))));
        shufps.x va1323:, va, va, s1323;
        shufps.x vb2133:, vb, vb, s2133;
        mulps.x tmp, va1323, vb2133;
        xorps.x tmp, vflip, tmp;
        subps.x vp2, vp2, tmp;

        movdqu.x [p2_ptr], vp2;
    }
}

gp12_flip :: (a: Vec128(float32), b: Vec128(float32), p2: *Vec128(float32)) {
    gpRT_flip(a, b, p2);
    p2_ptr := p2.float32s.data;

    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    flip_ptr := NZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vp2:, [p2_ptr];
        movdqu.x vflip:, [flip_ptr];
        // p2 = _mm_sub_ps(p2,
        //                 _mm_xor_ps(_mm_set_ss(-0.f),
        //                            _mm_mul_ps(a, KLN_SWIZZLE(b, 0, 0, 0, 0))));
        shufps.x vb0000:, vb, vb, s0000;
        mulps.x tmp:, va, vb0000;
        xorps.x tmp, vflip, tmp;
        subps.x vp2, vp2, tmp;

        movdqu.x [p2_ptr], vp2;
    }
}
gp12 :: (a: Vec128(float32), b: Vec128(float32), p2: *Vec128(float32)) {
    gpRT(a, b, p2);
    p2_ptr := p2.float32s.data;

    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    flip_ptr := NZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vp2:, [p2_ptr];
        movdqu.x vflip:, [flip_ptr];
        // p2 = _mm_sub_ps(p2,
        //                 _mm_xor_ps(_mm_set_ss(-0.f),
        //                            _mm_mul_ps(a, KLN_SWIZZLE(b, 0, 0, 0, 0))));
        shufps.x vb0000:, vb, vb, s0000;
        mulps.x tmp:, va, vb0000;
        xorps.x tmp, vflip, tmp;
        subps.x vp2, vp2, tmp;

        movdqu.x [p2_ptr], vp2;
    }
}

gpLL :: (l1p1: Vec128(float32), l1p2: Vec128(float32), l2p1: Vec128(float32), l2p2: Vec128(float32), out: []*Vec128(float32)) {
    // __m128 const& a = l1;
    a := l1p1.float32s.data;
    // __m128 const& d = *(&l1 + 1);
    d := l1p2.float32s.data;
    // __m128 const& b = l2;
    b := l2p1.float32s.data;
    // __m128 const& c = *(&l2 + 1);
    c := l2p2.float32s.data;

    p1_ptr := out[0].float32s.data;
    p2_ptr := out[1].float32s.data;

    flip_ptr := NZZZZ.float32s.data;

    check_var: Vec128(float32);
    check_var_ptr := check_var.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a];
        movdqu.x vb:, [b];
        movdqu.x vc:, [c];
        movdqu.x vd:, [d];
        movdqu.x vflip:, [flip_ptr];

        // p1 = _mm_mul_ps(KLN_SWIZZLE(a, 3, 1, 2, 1), KLN_SWIZZLE(b, 2, 3, 1, 1));
        shufps.x va3121:, va, va, s3121;
        shufps.x vb2311:, vb, vb, s2311;
        mulps.x vp1:, va3121, vb2311;
        // p1 = _mm_xor_ps(p1, flip);
        xorps.x vp1, vp1, vflip;
        // p1 = _mm_sub_ps(
        //     p1,
        //     _mm_mul_ps(KLN_SWIZZLE(a, 2, 3, 1, 3), KLN_SWIZZLE(b, 3, 1, 2, 3)));
        shufps.x va2313:, va, va, s2313;
        shufps.x vb3123:, vb, vb, s3123;
        mulps.x tmp1:, va2313, vb3123;
        subps.x vp1, vp1, tmp1;
        // __m128 a2 = _mm_unpackhi_ps(a, a);
        unpckhps.x a2:, va, va;
        // __m128 b2 = _mm_unpackhi_ps(b, b);
        unpckhps.x b2:, vb, vb;
        // p1        = _mm_sub_ss(p1, _mm_mul_ss(a2, b2));
        mulss tmpx2:, a2, b2;
        subss vp1, vp1, tmpx2;
        // p2 = _mm_mul_ps(KLN_SWIZZLE(a, 2, 1, 3, 1), KLN_SWIZZLE(c, 1, 3, 2, 1));
        shufps.x va2131:, va, va, s2131;
        shufps.x vc1321:, vc, vc, s1321;
        mulps.x vp2:, va2131, vc1321;
        // p2 = _mm_sub_ps(p2,
        //                 _mm_xor_ps(flip,
        //                            _mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 3),
        //                                       KLN_SWIZZLE(c, 2, 1, 3, 3))));
        shufps.x va1323:, va, va, s1323;
        shufps.x vc2133:, vc, vc, s2133;
        mulps.x tmp1, va1323, vc2133;
        xorps.x tmp2:, vflip, tmp1;
        subps.x vp2, tmp2;
        // p2 = _mm_add_ps(
        //     p2,
        //     _mm_mul_ps(KLN_SWIZZLE(b, 1, 3, 2, 1), KLN_SWIZZLE(d, 2, 1, 3, 1)));
        shufps.x vb1321:, vb, vb, s1321;
        shufps.x vd2131:, vd, vd, s2131;
        mulps.x tmp1, vb1321, vd2131;
        addps.x vp2, vp2, tmp1;
        // p2        = _mm_sub_ps(p2,
        //                 _mm_xor_ps(flip,
        //                            _mm_mul_ps(KLN_SWIZZLE(b, 2, 1, 3, 3),
        //                                       KLN_SWIZZLE(d, 1, 3, 2, 3))));
        shufps.x vb2133:, vb, vb, s2133;
        shufps.x vd1323:, vd, vd, s1323;
        mulps.x tmp1, vb2133, vd1323;
        xorps.x tmp1, vflip, tmp1;
        subps.x vp2, vp2, tmp1;
        movdqu.x [check_var_ptr], vp2;
        // __m128 c2 = _mm_unpackhi_ps(c, c);
        unpckhps.x c2:, vc, vc;
        // __m128 d2 = _mm_unpackhi_ps(d, d);
        unpckhps.x d2:, vd, vd;
        // p2        = _mm_add_ss(p2, _mm_mul_ss(a2, c2));
        mulss tmpx3:, a2, c2;
        addss vp2, vp2, tmpx3;
        // p2        = _mm_add_ss(p2, _mm_mul_ss(b2, d2));
        mulss tmpx4:, b2, d2;
        addss vp2, vp2, tmpx4;

        movdqu.x [p1_ptr], vp1;
        movdqu.x [p2_ptr], vp2;
    }
}

gpMM :: (m1p1: Vec128(float32), m1p2: Vec128(float32), m2p1: Vec128(float32), m2p2: Vec128(float32), out: []*Vec128(float32)) {
    // __m128 const& a = m1;
    a := m1p1.float32s.data;
    // __m128 const& b = *(&m1 + 1);
    b := m1p2.float32s.data;
    // __m128 const& c = m2;
    c := m2p1.float32s.data;
    // __m128 const& d = *(&m2 + 1);
    d := m2p2.float32s.data;

    p1_ptr := out[0].float32s.data;
    p2_ptr := out[1].float32s.data;

    flip_ptr := NZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a];
        movdqu.x vb:, [b];
        movdqu.x vc:, [c];
        movdqu.x vd:, [d];
        movdqu.x vflip:, [flip_ptr];
        // __m128 a_xxxx = KLN_SWIZZLE(a, 0, 0, 0, 0);
        shufps.x vaxxxx:, va, va, s0000;
        // __m128 a_zyzw = KLN_SWIZZLE(a, 3, 2, 1, 2);
        shufps.x vazyzw:, va, va, s3212;
        // __m128 a_ywyz = KLN_SWIZZLE(a, 2, 1, 3, 1);
        shufps.x vaywyz:, va, va, s2131;
        // __m128 a_wzwy = KLN_SWIZZLE(a, 1, 3, 2, 3);
        shufps.x vawzwy:, va, va, s1323;
        // __m128 c_wwyz = KLN_SWIZZLE(c, 2, 1, 3, 3);
        shufps.x vcwwyz:, vc, vc, s2133;
        // __m128 c_yzwy = KLN_SWIZZLE(c, 1, 3, 2, 1);
        shufps.x vcyzwy:, vc, vc, s1321;
        // e        = _mm_mul_ps(a_xxxx, c);
        mulps.x e:, vaxxxx, vc;
        // __m128 t = _mm_mul_ps(a_ywyz, c_yzwy);
        mulps.x t:, vaywyz, vcyzwy;
        // t = _mm_add_ps(t, _mm_mul_ps(a_zyzw, KLN_SWIZZLE(c, 0, 0, 0, 2)));
        shufps.x vc0002:, vc, vc, s0002;
        mulps.x tmp:, vazyzw, vc0002;
        addps.x t, t, tmp;
        // t = _mm_xor_ps(t, s_flip);
        xorps.x t, t, vflip;
        // e = _mm_add_ps(e, t);
        addps.x e, e, t;
        // e = _mm_sub_ps(e, _mm_mul_ps(a_wzwy, c_wwyz));
        mulps.x tmp, vawzwy, vcwwyz;
        subps.x e, e, tmp;
        // f = _mm_mul_ps(a_xxxx, d);
        mulps.x f:, vaxxxx, vd;
        // f = _mm_add_ps(f, _mm_mul_ps(b, KLN_SWIZZLE(c, 0, 0, 0, 0)));
        shufps.x vc0000:, vc, vc, s0000;
        mulps.x tmp, vb, vc0000;
        addps.x f, f, tmp;
        // f = _mm_add_ps(f, _mm_mul_ps(a_ywyz, KLN_SWIZZLE(d, 1, 3, 2, 1)));
        shufps.x vd1321:, vd, vd, s1321;
        mulps.x tmp, vaywyz, vd1321;
        addps.x f, f, tmp;
        // f = _mm_add_ps(f, _mm_mul_ps(KLN_SWIZZLE(b, 2, 1, 3, 1), c_yzwy));
        shufps.x vb2131:, vb, vb, s2131;
        mulps.x tmp, vb2131, vcyzwy;
        addps.x f, f, tmp;
        // t = _mm_mul_ps(a_zyzw, KLN_SWIZZLE(d, 0, 0, 0, 2));
        shufps.x vd0002:, vd, vd, s0002;
        mulps.x t, vazyzw, vd0002;
        // t = _mm_add_ps(t, _mm_mul_ps(a_wzwy, KLN_SWIZZLE(d, 2, 1, 3, 3)));
        shufps.x vd2133:, vd, vd, s2133;
        mulps.x tmp, vawzwy, vd2133;
        addps.x t, t, tmp;
        // t = _mm_add_ps(
        //     t,
        //     _mm_mul_ps(KLN_SWIZZLE(b, 0, 0, 0, 2), KLN_SWIZZLE(c, 3, 2, 1, 2)));
        shufps.x vb0002:, vb, vb, s0002;
        shufps.x vc3212:, vc, vc, s3212;
        mulps.x tmp, vb0002, vc3212;
        addps.x t, t, tmp;
        // t = _mm_add_ps(t, _mm_mul_ps(KLN_SWIZZLE(b, 1, 3, 2, 3), c_wwyz));
        shufps.x vb1323:, vb, vb, s1323;
        mulps.x tmp, vb1323, vcwwyz;
        addps.x t, t, tmp;
        // t = _mm_xor_ps(t, s_flip);
        xorps.x t, t, vflip;
        // f = _mm_sub_ps(f, t);
        subps.x f, f, t;

        movdqu.x [p1_ptr], e;
        movdqu.x [p2_ptr], f;
    }
}
//inner_product
dot00 :: (a: Vec128(float32), b: Vec128(float32), p1_out: *Vec128(float32)) {
    tmp := hi_dp(a, b);
    p1_out.float32s.data[0] = tmp.float32s.data[0];
    p1_out.float32s.data[1] = tmp.float32s.data[1];
    p1_out.float32s.data[2] = tmp.float32s.data[2];
    p1_out.float32s.data[3] = tmp.float32s.data[3];
}

dot03 :: (a: Vec128(float32), b: Vec128(float32), p1_out: *Vec128(float32), p2_out: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p1_out_ptr := p1_out.float32s.data;
    p2_out_ptr := p2_out.float32s.data;

    zeros_ptr := ZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x zeros:, [zeros_ptr];
        // p1_out = _mm_mul_ps(a, KLN_SWIZZLE(b, 0, 0, 0, 0));
        shufps.x vb0000:, vb, vb, s0000;
        mulps.x vp1_out:, va, vb0000;
        // p1_out = _mm_blend_ps(p1_out, _mm_setzero_ps(), 1);
        // p1 = _mm_blend_ps(p1, _mm_setzero_ps(), 1);
        blendps.x vp1_out, vp1_out, zeros, 1;
        // p2_out
        //     = KLN_SWIZZLE(_mm_sub_ps(_mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 0), b),
        //                              _mm_mul_ps(a, KLN_SWIZZLE(b, 1, 3, 2, 0))),
        //                   1,
        //                   3,
        //                   2,
        //                   0);
        shufps.x vb1320:, vb, vb, s1320;
        mulps.x tmp:, va, vb1320;
        shufps.x va1320:, va, va, s1320;
        mulps.x tmp1:, va1320, vb;
        subps.x tmp, tmp1, tmp;
        shufps.x vp2_out:, tmp, tmp, s1320;

        movdqu.x [p1_out_ptr], vp1_out;
        movdqu.x [p2_out_ptr], vp2_out;
    }
}

dot11 :: (a: Vec128(float32), b: Vec128(float32), p1_out: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p1_out_ptr := p1_out.float32s.data;

    flip_ptr := NZZZZ.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vflip:, [flip_ptr];
        // p1_out = _mm_xor_ps(_mm_set_ss(-0.f), hi_dp_ss(a, b));
        // inline hi_dp_ss
        // __m128 out = _mm_mul_ps(a, b);
        mulps.x vout:, va, vb;
        // // 0 1 2 3 -> 1 1 3 3
        // __m128 hi = _mm_movehdup_ps(out);
        movshdup.x hi:, vout;
        // // 0 1 2 3 + 1 1 3 3 -> (0 + 1, 1 + 1, 2 + 3, 3 + 3)
        // __m128 sum = _mm_add_ps(hi, out);
        addps.x sum:, hi, vout;
        // // unpacklo: 0 0 1 1
        // out = _mm_add_ps(sum, _mm_unpacklo_ps(out, out));
        unpcklps.x tmp1:, vout, vout;
        addps.x vout, sum, tmp1;
        // // (1 + 2 + 3, _, _, _)
        // return _mm_movehl_ps(out, out);
        movhlps vout, vout;
        xorps.x vp1:, vflip, vout;

        movdqu.x [p1_out_ptr], vp1;
    }
}

dot33 :: (a: Vec128(float32), b: Vec128(float32), p1_out: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p1_out_ptr := p1_out.float32s.data;

    flip_ptr := NZZZZ.float32s.data;
    nzzz_ptr := NUZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vflip:, [flip_ptr];
        movdqu.x vnzzz:, [nzzz_ptr];

        // p1_out = _mm_mul_ps(_mm_set_ss(-1.f), _mm_mul_ss(a, b));
        mulss tmp:, va, vb;
        mulps.x vp1_out:, vnzzz, tmp;

        movdqu.x [p1_out_ptr], vp1_out;
    }
}

dotPTL :: (a: Vec128(float32), b: Vec128(float32), p0: *Vec128(float32)) {
    dp := hi_dp_ss(a, b);
    dp_ptr := dp.float32s.data;

    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    p0_ptr := p0.float32s.data;

    flip2_ptr := ZNZNZNZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vdp:, [dp_ptr];
        movdqu.x vflip2:, [flip2_ptr];

        // p0        = _mm_mul_ps(KLN_SWIZZLE(a, 0, 0, 0, 0), b);
        shufps.x va0000:, va, va, s0000;
        mulps.x vp0:, va0000, vb;
        // p0        = _mm_xor_ps(p0, _mm_set_ps(-0.f, -0.f, -0.f, 0.f));
        xorps.x vp0, vp0, vflip2;
        // p1 = _mm_blend_ps(p1, _mm_setzero_ps(), 1);
        xorps.x zeros:, va, va;
        blendps.x vp0, vp0, vdp, 1;

        movdqu.x [p0_ptr], vp0;
    }
}

dotPIL_flip :: (a: Vec128(float32), c: Vec128(float32), p0: *Vec128(float32)) {
    tmp := hi_dp(a, c);
    memcpy(p0.float32s.data, tmp.float32s.data, size_of(Vec128(float32)));
}

dotPIL :: (a: Vec128(float32), c: Vec128(float32), p0: *Vec128(float32)) {
    dotPIL_flip(a, c, p0);
    p0_ptr := p0.float32s.data;

    flip_ptr := NZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vp0:, [p0_ptr];
        movdqu.x vflip:, [flip_ptr];
        xorps.x vp0, vp0, vflip;
        movdqu.x [p0_ptr], vp0;
    }
}

dotPL :: (a: Vec128(float32), b: Vec128(float32), c: Vec128(float32), p0: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;
    c_ptr := c.float32s.data;

    ac_dp_ss := hi_dp_ss(a, c);
    ac_dp_ss_ptr := ac_dp_ss.float32s.data;

    p0_ptr := p0.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vc:, [c_ptr];
        movdqu.x vacdpss:, [ac_dp_ss_ptr];

        // p0 = _mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 0), b);
        shufps.x va1320:, va, va, s1320;
        mulps.x vp0:, va1320, vb;
        // p0 = _mm_sub_ps(p0, _mm_mul_ps(a, KLN_SWIZZLE(b, 1, 3, 2, 0)));
        shufps.x vb1320:, vb, vb, s1320;
        mulps.x tmp:, va, vb1320;
        subps.x vp0, vp0, tmp;
        // p0 = _mm_sub_ss(KLN_SWIZZLE(p0, 1, 3, 2, 0), hi_dp_ss(a, c));
        shufps.x vp01320:, vp0, vp0, s1320;
        subss vp0, vp01320, vacdpss;

        movdqu.x [p0_ptr], vp0;
    }
}

dotPL_flip :: (a: Vec128(float32), b: Vec128(float32), c: Vec128(float32), p0: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;
    c_ptr := c.float32s.data;

    ac_dp_ss := hi_dp_ss(a, c);
    ac_dp_ss_ptr := ac_dp_ss.float32s.data;

    p0_ptr := p0.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vc:, [c_ptr];
        movdqu.x vacdpss:, [ac_dp_ss_ptr];

        // p0 = _mm_mul_ps(a, KLN_SWIZZLE(b, 1, 3, 2, 0));
        shufps.x vb1320:, vb, vb, s1320;
        mulps.x vp0:, va, vb1320;
        // p0 = _mm_sub_ps(p0, _mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 0), b));
        shufps.x va1320:, va, va, s1320;
        mulps.x tmp:, va1320, vb;
        subps.x vp0, vp0, tmp;
        // p0 = _mm_add_ss(KLN_SWIZZLE(p0, 1, 3, 2, 0), hi_dp_ss(a, c));
        shufps.x vp01320:, vp0, vp0, s1320;
        addss vp0, vp01320, vacdpss;

        movdqu.x [p0_ptr], vp0;
    }
}

// matrix
mat4x4_12 :: (b: Vec128(float32), c: *Vec128(float32), out: *Vec128(float32), $translate: bool=false, $normalized:bool = false) {
    b_ptr := b.float32s.data;

    buf: [4] float; 
    buf_ptr := buf.data;
    #asm AVX, AVX2 {
        movdqu.x vb:, [b_ptr];
        // _mm_storeu_ps(buf, _mm_mul_ps(b, b));
        mulps.x tmp:, vb, vb;
        movdqu.x [buf_ptr], tmp;
    }
    b0_2 := buf[0];
    b1_2 := buf[1];
    b2_2 := buf[2];
    b3_2 := buf[3];

    znzzz_ptr := ZNZZZ.float32s.data;

    uddz_ptr := UDDZ.float32s.data;

    const1 := vec128(float.[b3_2 + b2_2, 0, 0, 0]);
    const1_ptr := const1.float32s.data;

    // __m128& c0 = out[0];
    c0_ptr := out.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x vb, [b_ptr];
        movdqu.x vznzzz:, [znzzz_ptr];
        movdqu.x vuddz:, [uddz_ptr];
        movdqu.x vconst1:, [const1_ptr];

        // c0         = _mm_mul_ps(b, KLN_SWIZZLE(b, 0, 0, 2, 0));
        shufps.x vb0020:, vb, vb, s0020;
        mulps.x vc0:, vb, vb0020;
        // __m128 tmp
        //     = _mm_mul_ps(KLN_SWIZZLE(b, 0, 1, 3, 1), KLN_SWIZZLE(b, 0, 3, 0, 1));
        shufps.x vb0131:, vb, vb, s0131;
        shufps.x vb0301:, vb, vb, s0301;
        mulps.x tmp, vb0131, vb0301;
        // tmp = _mm_xor_ps(_mm_set_ps(0.f, 0.f, -0.f, 0.f), tmp);
        xorps.x tmp, vznzzz, tmp;
        // c0  = _mm_mul_ps(_mm_set_ps(0.f, 2.f, 2.f, 1.f), _mm_add_ps(c0, tmp));
        addps.x tmp, vc0, tmp;
        mulps.x vc0, vuddz, tmp;
        // c0  = _mm_sub_ps(c0, _mm_set_ss(b3_2 + b2_2));
        subps.x vc0, vc0, vconst1;
        movdqu.x [c0_ptr], vc0;
    }

    // __m128& c1 = out[1];
    c1_ptr := (out +1).float32s.data;

    zznzz_ptr := ZZNZZ.float32s.data;
    dnudz_ptr := DNUDZ.float32s.data;

    const2 := vec128(float.[0, b0_2 + b2_2, 0, 0]);
    const2_ptr := const2.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vb, [b_ptr];
        movdqu.x vzznzz:, [zznzz_ptr];
        movdqu.x vdnudz:, [dnudz_ptr];
        movdqu.x vconst2:, [const2_ptr];

        // c1         = _mm_mul_ps(b, KLN_SWIZZLE(b, 0, 3, 1, 3));
        shufps.x vb0313:, vb, vb, s0313;
        mulps.x vc1:, vb, vb0313;
        // tmp = _mm_mul_ps(KLN_SWIZZLE(b, 0, 0, 3, 2), KLN_SWIZZLE(b, 0, 1, 3, 1));
        shufps.x vb0032:, vb, vb, s0032;
        shufps.x vb0131, vb, vb, s0131;
        mulps.x tmp, vb0032, vb0131;
        // tmp = _mm_xor_ps(_mm_set_ps(0.f, -0.f, 0.f, 0.f), tmp);
        xorps.x tmp, vzznzz, tmp;
        // c1  = _mm_mul_ps(_mm_set_ps(0.f, 2.f, -1.f, 2.f), _mm_add_ps(c1, tmp));
        addps.x tmp, vc1, tmp;
        mulps.x vc1, vdnudz, tmp;
        // c1  = _mm_add_ps(c1, _mm_set_ps(0.f, 0.f, b0_2 + b2_2, 0.f));
        addps.x vc1, vc1, vconst2;
        movdqu.x [c1_ptr], vc1;
    }

    c2_ptr := (out + 2).float32s.data;

    nzznzz_ptr := NZZNZZ.float32s.data;
    dduz_ptr := DDUZ.float32s.data;

    const3 := vec128(float.[0.0, 0.0, b3_2 - b1_2, 0.0]);
    const3_ptr := const3.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vb, [b_ptr];
        movdqu.x vnzznzz:, [nzznzz_ptr];
        movdqu.x vdduz:, [dduz_ptr];
        movdqu.x vconst3:, [const3_ptr];

        // c2         = _mm_xor_ps(_mm_set_ps(0.f, -0.f, 0.f, -0.f),
        //                 _mm_mul_ps(b, KLN_SWIZZLE(b, 0, 2, 0, 2)));
        shufps.x vb0202:, vb, vb, s0202;
        mulps.x vc2:, vb, vb0202;
        xorps.x vc2, vnzznzz, vc2;
        // c2         = _mm_add_ps(
        //     c2, _mm_mul_ps(KLN_SWIZZLE(b, 0, 0, 2, 1), KLN_SWIZZLE(b, 0, 0, 3, 3)));
        shufps.x vb0021:, vb, vb, s0021;
        shufps.x vb0033:, vb, vb, s0033;
        mulps.x tmp, vb0021, vb0033;
        addps.x vc2, vc2, tmp;
        // c2 = _mm_mul_ps(c2, _mm_set_ps(0.f, 1.f, 2.f, 2.f));
        mulps.x vc2, vc2, vdduz;
        // c2 = _mm_add_ps(c2, _mm_set_ps(0.f, b3_2 - b1_2, 0.f, 0.f));
        addps.x vc2, vc2, vconst3;
        movdqu.x [c2_ptr], vc2;
    }
    
    c3_ptr := (out +3).float32s.data;
    #if translate {
        c_ptr := c.float32s.data;
        dddz_ptr := DDDZ.float32s.data;

        #asm AVX, AVX2 {
            movdqu.x vb, [b_ptr];
            movdqu.x vc:, [c_ptr];
            movdqu.x vdddz:, [dddz_ptr];

            // c3 = _mm_mul_ps(b, KLN_SWIZZLE(*c, 0, 1, 3, 1));
            shufps.x vc0131:, vc, vc, s0131;
            mulps.x vc3:, vb, vc0131;
            // c3 = _mm_add_ps(
            //     c3,
            //     _mm_mul_ps(KLN_SWIZZLE(b, 0, 0, 0, 3), KLN_SWIZZLE(*c, 0, 3, 2, 2)));
            shufps.x vb0003:, vb, vb, s0003;
            shufps.x vc0322:, vc, vc, s0322;
            mulps.x tmp, vb0003, vc0322;
            addps.x vc3, vc3, tmp;
            // c3 = _mm_add_ps(
            //     c3,
            //     _mm_mul_ps(KLN_SWIZZLE(b, 0, 3, 2, 1), KLN_SWIZZLE(*c, 0, 0, 0, 0)));
            shufps.x vb0321:, vb, vb, s0321;
            shufps.x vc0000:, vc, vc, s0000;
            mulps.x tmp, vb0321, vc0000;
            addps.x vc3, vc3, tmp;
            // tmp = _mm_mul_ps(KLN_SWIZZLE(b, 0, 1, 3, 2), KLN_SWIZZLE(*c, 0, 2, 1, 3));
            shufps.x vb0132:, vb, vb, s0132;
            shufps.x vc0213:, vc, vc, s0213;
            mulps.x tmpx3:, vb0132, vc0213;
            // c3 = _mm_mul_ps(_mm_set_ps(0.f, 2.f, 2.f, 2.f), _mm_sub_ps(tmp, c3));
            subps.x tmpx3, tmpx3, vc3;
            mulps.x vc3, vdddz, tmpx3;
            movdqu.x [c3_ptr], vc3;
        }
    }
    #if normalized {
        zzzu_ptr := ZZZU.float32s.data;
        #asm AVX, AVX2 {
            movdqu.x vc32:, [c3_ptr];
            movdqu.x vzzzu:, [zzzu_ptr];
            // c3 = _mm_blend_ps(c3, _mm_set_ps(1.f, 0.f, 0.f, 0.f), 0b1000);
            blendps.x vc32, vc32, vzzzu, 0b1000;
            movdqu.x [c3_ptr], vc32;
        }
    } else {
        const4 := vec128(SET_PS(b0_2 + b1_2 + b2_2 + b3_2, 0, 0, 0));
        const4_ptr := const4.float32s.data;

        #asm AVX, AVX2 {
            movdqu.x vc32:, [c3_ptr];
            movdqu.x vconst4:, [const4_ptr];
            // c3 = _mm_blend_ps(
            //     c3, _mm_set_ps(b0_2 + b1_2 + b2_2 + b3_2, 0.f, 0.f, 0.f), 0b1000);
            blendps.x vc32, vc32, vconst4, 0b1000;
            movdqu.x [c3_ptr], vc32;
        }
    }
}

//sandwich

sw00 :: (a: Vec128(float32), b: Vec128(float32), p0_out: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    nzzzz_ptr := NZZZZ.float32s.data;

    p0_out_ptr := p0_out.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vnzzzz:, [nzzzz_ptr];

        // __m128 a_zzwy = KLN_SWIZZLE(a, 1, 3, 2, 2);
        shufps.x a_zzwy:, va, va, s1322;
        // __m128 a_wwyz = KLN_SWIZZLE(a, 2, 1, 3, 3);
        shufps.x a_wwyz:, va, va, s2133;
        // __m128 tmp = _mm_mul_ps(a_zzwy, KLN_SWIZZLE(b, 1, 3, 2, 2));
        shufps.x vb1322:, vb, vb, s1322;
        mulps.x tmp:, a_zzwy, vb1322;
        // tmp = _mm_add_ps(tmp, _mm_mul_ps(a_wwyz, KLN_SWIZZLE(b, 2, 1, 3, 3)));
        shufps.x vb2133:, vb, vb, s2133;
        mulps.x tmp1:, a_wwyz, vb2133;
        addps.x tmp, tmp, tmp1;
        // __m128 a1 = _mm_movehdup_ps(a);
        movshdup.x a1:, va;
        // __m128 b1 = _mm_movehdup_ps(b);
        movshdup.x b1:, vb;
        // tmp       = _mm_add_ss(tmp, _mm_mul_ss(a1, b1));
        mulss tmp1, a1, b1;
        addss tmp, tmp, tmp1;
        // tmp       = _mm_mul_ps(tmp, _mm_add_ps(a, a));
        addps.x tmp1, va, va;
        mulps.x tmp, tmp, tmp1;
        // __m128 a_yyzw = KLN_SWIZZLE(a, 3, 2, 1, 1);
        shufps.x a_yyzw:, va, va, s3211;
        // __m128 tmp2 = _mm_xor_ps(_mm_mul_ps(a_yyzw, a_yyzw), _mm_set_ss(-0.f));
        mulps.x tmp1, a_yyzw, a_yyzw;
        xorps.x tmp2:, tmp1, vnzzzz;
        // tmp2        = _mm_sub_ps(tmp2, _mm_mul_ps(a_zzwy, a_zzwy));
        mulps.x tmp1, a_zzwy, a_zzwy;
        subps.x tmp2, tmp2, tmp1;
        // tmp2        = _mm_sub_ps(tmp2, _mm_mul_ps(a_wwyz, a_wwyz));
        mulps.x tmp1, a_wwyz, a_wwyz;
        subps.x tmp2, tmp2, tmp1;
        // tmp2        = _mm_mul_ps(tmp2, b);
        mulps.x tmp2, tmp2, vb;
        // p0_out = _mm_add_ps(tmp, tmp2);
        addps.x vp0_out:, tmp, tmp2;
        movdqu.x [p0_out_ptr], vp0_out;
    }
}

sw10 :: (a: Vec128(float32), b: Vec128(float32), p1: *Vec128(float32), p2: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    zddd_ptr := ZDDD.float32s.data;
    nzzzz_ptr := NZZZZ.float32s.data;

    p1_ptr := p1.float32s.data;
    p2_ptr := p2.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vzddd:, [zddd_ptr];
        movdqu.x vnzzzz:, [nzzzz_ptr];

        // __m128 a_zyzw = KLN_SWIZZLE(a, 3, 2, 1, 2);
        shufps.x a_zyzw:, va, va, s3212;
        // __m128 a_ywyz = KLN_SWIZZLE(a, 2, 1, 3, 1);
        shufps.x a_ywyz:, va, va, s2131;
        // __m128 a_wzwy = KLN_SWIZZLE(a, 1, 3, 2, 3);
        shufps.x a_wzwy:, va, va, s1323;
        // __m128 b_xzwy = KLN_SWIZZLE(b, 1, 3, 2, 0);
        shufps.x b_xzwy:, vb, vb, s1320;
        // __m128 two_zero = _mm_set_ps(2.f, 2.f, 2.f, 0.f);
        // p1              = _mm_mul_ps(a, b);
        mulps.x vp1:, va, vb;
        // p1              = _mm_add_ps(p1, _mm_mul_ps(a_wzwy, b_xzwy));
        mulps.x tmp:, a_wzwy, b_xzwy;
        addps.x vp1, vp1, tmp;
        // p1              = _mm_mul_ps(p1, _mm_mul_ps(a_ywyz, two_zero));
        mulps.x tmp, a_ywyz, vzddd;
        mulps.x vp1, vp1, tmp;
        // __m128 tmp = _mm_mul_ps(a_zyzw, a_zyzw);
        mulps.x tmp, a_zyzw, a_zyzw;
        // tmp        = _mm_add_ps(tmp, _mm_mul_ps(a_wzwy, a_wzwy));
        mulps.x tmp1:, a_wzwy, a_wzwy;
        addps.x tmp, tmp, tmp1;
        // tmp        = _mm_xor_ps(tmp, _mm_set_ss(-0.f));
        xorps.x tmp, tmp, vnzzzz;
        // tmp        = _mm_sub_ps(_mm_mul_ps(a_ywyz, a_ywyz), tmp);
        mulps.x tmp1, a_ywyz, a_ywyz;
        subps.x tmp, tmp1, tmp;
        // tmp        = _mm_mul_ps(KLN_SWIZZLE(b, 2, 1, 3, 0), tmp);
        shufps.x vb2130:, vb, vb, s2130;
        mulps.x tmp, vb2130, tmp;
        // p1 = KLN_SWIZZLE(_mm_add_ps(p1, tmp), 1, 3, 2, 0);
        addps.x tmp, vp1, tmp;
        shufps.x vp1, tmp, tmp, s1320;
        // p2 = _mm_mul_ps(a_zyzw, b_xzwy);
        mulps.x vp2:, a_zyzw, b_xzwy;
        // p2 = _mm_sub_ps(p2, _mm_mul_ps(a_wzwy, b));
        mulps.x tmp, a_wzwy, vb;
        subps.x vp2, vp2, tmp;
        // p2 = _mm_mul_ps(p2, _mm_mul_ps(KLN_SWIZZLE(a, 0, 0, 0, 0), two_zero));
        shufps.x va0000:, va, va, s0000;
        mulps.x tmp, va0000, vzddd;
        mulps.x vp2, vp2, tmp;
        // p2 = KLN_SWIZZLE(p2, 1, 3, 2, 0);
        shufps.x vp2, vp2, vp2, s1320;
        movdqu.x [p1_ptr], vp1;
        movdqu.x [p2_ptr], vp2;
    }
}

sw20 :: (a: Vec128(float32), b: Vec128(float32), p2: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    zndndnd_ptr := ZNDNDND.float32s.data;
    nzzzz_ptr := NZZZZ.float32s.data;

    p2_ptr := p2.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vzndndnd:, [zndndnd_ptr];
        movdqu.x vnzzzz:, [nzzzz_ptr];

        // __m128 a_zzwy = KLN_SWIZZLE(a, 1, 3, 2, 2);
        shufps.x a_zzwy:, va, va, s1322;
        // __m128 a_wwyz = KLN_SWIZZLE(a, 2, 1, 3, 3);
        shufps.x a_wwyz:, va, va, s2133;
        // p2 = _mm_mul_ps(a, b);
        mulps.x vp2:, va, vb;
        // p2 = _mm_add_ps(p2, _mm_mul_ps(a_zzwy, KLN_SWIZZLE(b, 1, 3, 2, 0)));
        shufps.x vb1320:, vb, vb, s1320;
        mulps.x tmp:, a_zzwy, vb1320;
        addps.x vp2, vp2, tmp;
        // p2 = _mm_mul_ps(
        //     p2, _mm_mul_ps(a_wwyz, _mm_set_ps(-2.f, -2.f, -2.f, 0.f)));
        mulps.x tmp, a_wwyz, vzndndnd;
        mulps.x vp2, vp2, tmp;
        // __m128 a_yyzw = KLN_SWIZZLE(a, 3, 2, 1, 1);
        shufps.x a_yyzw:, va, va, s3211;
        // __m128 tmp    = _mm_mul_ps(a_yyzw, a_yyzw);
        mulps.x tmp, a_yyzw, a_yyzw;
        // tmp           = _mm_xor_ps(
        //     _mm_set_ss(-0.f), _mm_add_ps(tmp, _mm_mul_ps(a_zzwy, a_zzwy)));
        mulps.x tmp1:, a_zzwy, a_zzwy;
        addps.x tmp1, tmp, tmp1;
        xorps.x tmp, vnzzzz, tmp1;
        // tmp = _mm_sub_ps(tmp, _mm_mul_ps(a_wwyz, a_wwyz));
        mulps.x tmp1, a_wwyz, a_wwyz;
        subps.x tmp, tmp, tmp1;
        // p2  = _mm_add_ps(p2, _mm_mul_ps(tmp, KLN_SWIZZLE(b, 2, 1, 3, 0)));
        shufps.x vb2130:, vb, vb, s2130;
        mulps.x tmp1, tmp, vb2130;
        addps.x vp2, vp2, tmp1;
        // p2  = KLN_SWIZZLE(p2, 1, 3, 2, 0);
        shufps.x vp2, vp2, vp2, s1320;
        movdqu.x [p2_ptr], vp2;
    }
}

sw30 :: (a: Vec128(float32), b: Vec128(float32), p3_out: *Vec128(float32)) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;

    zndndnd_ptr := ZNDNDND.float32s.data;
    nzzzz_ptr := NZZZZ.float32s.data;

    p3_out_ptr := p3_out.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vzndndnd:, [zndndnd_ptr];
        movdqu.x vnzzzz:, [nzzzz_ptr];
        // __m128 a_zwyz = KLN_SWIZZLE(a, 2, 1, 3, 2);
        shufps.x a_zwyz:, va, va, s2132;
        // __m128 a_yzwy = KLN_SWIZZLE(a, 1, 3, 2, 1);
        shufps.x a_yzwy:, va, va, s1321;
        // p3_out
        //     = _mm_mul_ps(KLN_SWIZZLE(a, 0, 0, 0, 0), KLN_SWIZZLE(b, 0, 0, 0, 0));
        shufps.x va0000:, va, va, s0000;
        shufps.x vb0000:, vb, vb, s0000;
        mulps.x vp3_out:, va0000, vb0000;
        // p3_out
        //     = _mm_add_ps(p3_out, _mm_mul_ps(a_zwyz, KLN_SWIZZLE(b, 2, 1, 3, 0)));
        shufps.x vb2130:, vb, vb, s2130;
        mulps.x tmp1:, a_zwyz, vb2130;
        addps.x vp3_out, vp3_out, tmp1;
        // p3_out
        //     = _mm_add_ps(p3_out, _mm_mul_ps(a_yzwy, KLN_SWIZZLE(b, 1, 3, 2, 0)));
        shufps.x vb1320:, vb, vb, s1320;
        mulps.x tmp1, a_yzwy, vb1320;
        addps.x vp3_out, vp3_out, tmp1;
        // p3_out = _mm_mul_ps(
        //     p3_out, _mm_mul_ps(a, _mm_set_ps(-2.f, -2.f, -2.f, 0.f)));
        mulps.x tmp1, va, vzndndnd;
        mulps.x vp3_out, vp3_out, tmp1;
        // __m128 tmp    = _mm_mul_ps(a_yzwy, a_yzwy);
        mulps.x tmp:, a_yzwy, a_yzwy;
        // tmp           = _mm_add_ps(tmp, _mm_mul_ps(a_zwyz, a_zwyz));
        mulps.x tmp1, a_zwyz, a_zwyz;
        addps.x tmp, tmp, tmp1;
        // __m128 a_wyzw = KLN_SWIZZLE(a, 3, 2, 1, 3);
        shufps.x a_wyzw:, va, va, s3213;
        // tmp           = _mm_sub_ps(
        //     tmp, _mm_xor_ps(_mm_mul_ps(a_wyzw, a_wyzw), _mm_set_ss(-0.f)));
        mulps.x tmp1, a_wyzw, a_wyzw;
        xorps.x tmp1, tmp1, vnzzzz;
        subps.x tmp, tmp, tmp1;
        // p3_out = _mm_add_ps(p3_out, _mm_mul_ps(b, tmp));
        mulps.x tmp1, vb, tmp;
        addps.x vp3_out, vp3_out, tmp1;
        //
        movdqu.x [p3_out_ptr], vp3_out;
    }
}

sw02 :: (a: Vec128(float32), b: Vec128(float32)) -> Vec128(float32) {
    a_ptr := a.float32s.data;
    tmp: = hi_dp(a, b);
    tmp_ptr := tmp.float32s.data;
    inv_b := rcp_nr1(b);
    inv_b_ptr := inv_b.float32s.data;

    out: Vec128(float32);
    out_ptr := out.float32s.data;

    const1_ptr := NUZZZ_I.s32s.data;
    // 2 / b0
    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vtmp:, [tmp_ptr];
        movdqu.x vinv_b:, [inv_b_ptr];
        movdqu.x vconst:, [const1_ptr];
        // inv_b = _mm_add_ss(inv_b, inv_b);
        addss vinv_b, vinv_b, vinv_b;
        // inv_b = _mm_and_ps(inv_b, _mm_castsi128_ps(_mm_set_epi32(0, 0, 0, -1)));
        andps.x vinv_b, vinv_b, vconst;
        // tmp   = _mm_mul_ss(tmp, inv_b);
        mulss vtmp, vtmp, vinv_b;
        // return _mm_add_ps(a, tmp);
        addps.x vout:, va, vtmp;
        movdqu.x [out_ptr], vout;
    }
    return out;
}

swL2 :: (a: Vec128(float32), d: Vec128(float32), c: Vec128(float32), out: []*Vec128(float32)) {
    a_ptr := a.float32s.data;
    c_ptr := c.float32s.data;
    d_ptr := d.float32s.data;
    p1_out := out[0].float32s.data;
    p2_out := out[1].float32s.data;
    memcpy(p1_out, a.float32s.data, size_of(Vec128(float32)));

    nzzzz_ptr := NZZZZ.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vc:, [c_ptr];
        movdqu.x vd:, [d_ptr];
        movdqu.x vnzzzz:, [nzzzz_ptr];
        // p2_out
        //     = _mm_mul_ps(KLN_SWIZZLE(a, 1, 3, 2, 0), KLN_SWIZZLE(c, 2, 1, 3, 0));
        shufps.x va1320:, va, va, s1320;
        shufps.x vc2130:, vc, vc, s2130;
        mulps.x vp2_out:, va1320, vc2130;
        // // Add and subtract the same quantity in the low component to produce a
        // // cancellation
        // p2_out = _mm_sub_ps(
        //     p2_out,
        //     _mm_mul_ps(KLN_SWIZZLE(a, 2, 1, 3, 0), KLN_SWIZZLE(c, 1, 3, 2, 0)));
        shufps.x va2130:, va, va, s2130;
        shufps.x vc1320:, vc, vc, s1320;
        mulps.x tmp:, va2130, vc1320;
        subps.x vp2_out, vp2_out, tmp;
        // p2_out = _mm_sub_ps(p2_out,
        //                     _mm_xor_ps(_mm_mul_ps(a, KLN_SWIZZLE(c, 0, 0, 0, 0)),
        //                                _mm_set_ss(-0.f)));
        shufps.x vc0000:, vc, vc, s0000;
        mulps.x tmp, va, vc0000;
        xorps.x tmp, tmp, vnzzzz;
        subps.x vp2_out, vp2_out, tmp;
        // p2_out = _mm_add_ps(p2_out, p2_out);
        addps.x vp2_out, vp2_out, vp2_out;
        // p2_out = _mm_add_ps(p2_out, d);
        addps.x vp2_out, vp2_out, vd;
        movdqu.x [p2_out], vp2_out;
    }
}

sw32 :: (a: Vec128(float32), b: Vec128(float32)) -> Vec128(float32) {
    a_ptr := a.float32s.data;
    b_ptr := b.float32s.data;
    zndndnd_ptr := ZNDNDND.float32s.data;

    out: Vec128(float32);
    out_ptr := out.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x va:, [a_ptr];
        movdqu.x vb:, [b_ptr];
        movdqu.x vzndndnd:, [zndndnd_ptr];
        // __m128 tmp = _mm_mul_ps(KLN_SWIZZLE(a, 0, 0, 0, 0), b);
        shufps.x va0000:, va, va, s0000;
        mulps.x tmp:, va0000, vb;
        // tmp        = _mm_mul_ps(_mm_set_ps(-2.f, -2.f, -2.f, 0.f), tmp);
        mulps.x tmp, vzndndnd, tmp;
        // tmp        = _mm_add_ps(a, tmp);
        addps.x tmp, va, tmp;
        movdqu.x [out_ptr], tmp;
    }
    return out;
}

swMM :: (in: *Vec128(float32), b: Vec128(float32), c: *Vec128(float32), out: *Vec128(float32), count: s32=0, $variadic:bool=false, $translate:bool=false, $inputp2:bool=false) {
    b_ptr := b.float32s.data;
    nzzzz_ptr := NZZZZ.float32s.data;
    zddd_ptr := ZDDD.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vb:, [b_ptr];
        movdqu.x vnzzzz:, [nzzzz_ptr];
        movdqu.x vzddd:, [zddd_ptr];
        // __m128 b_xwyz   = KLN_SWIZZLE(b, 2, 1, 3, 0);
        shufps.x b_xwyz:, vb, vb, s2130;
        // __m128 b_xzwy   = KLN_SWIZZLE(b, 1, 3, 2, 0);
        shufps.x b_xzwy:, vb, vb, s1320;
        // __m128 b_yxxx   = KLN_SWIZZLE(b, 0, 0, 0, 1);
        shufps.x b_yxxx:, vb, vb, s0001;
        // __m128 b_yxxx_2 = _mm_mul_ps(b_yxxx, b_yxxx);
        mulps.x b_yxxx_2:, b_yxxx, b_yxxx;
        // __m128 tmp   = _mm_mul_ps(b, b);
        mulps.x tmp:, vb, vb;
        // tmp          = _mm_add_ps(tmp, b_yxxx_2);
        addps.x tmp, tmp, b_yxxx_2;
        // __m128 b_tmp = KLN_SWIZZLE(b, 2, 1, 3, 2);
        shufps.x b_tmp:, vb, vb, s2132;
        // __m128 tmp2  = _mm_mul_ps(b_tmp, b_tmp);
        mulps.x tmp2:, b_tmp, b_tmp;
        // b_tmp        = KLN_SWIZZLE(b, 1, 3, 2, 3);
        shufps.x b_tmp, vb, vb, s1323;
        // tmp2         = _mm_add_ps(tmp2, _mm_mul_ps(b_tmp, b_tmp));
        mulps.x tmpx1:, b_tmp, b_tmp;
        addps.x tmp2, tmp2, tmpx1;
        // tmp          = _mm_sub_ps(tmp, _mm_xor_ps(tmp2, _mm_set_ss(-0.f)));
        xorps.x tmp2, tmp2, vnzzzz;
        subps.x tmp, tmp, tmp2;
        // // tmp needs to be scaled by a and set to p1_out
        // __m128 b_xxxx = KLN_SWIZZLE(b, 0, 0, 0, 0);
        shufps.x b_xxxx:, vb, vb, s0000;
        // __m128 scale  = _mm_set_ps(2.f, 2.f, 2.f, 0.f);
        // tmp2          = _mm_mul_ps(b_xxxx, b_xwyz);
        mulps.x tmp2, b_xxxx, b_xwyz;
        // tmp2          = _mm_add_ps(tmp2, _mm_mul_ps(b, b_xzwy));
        mulps.x tmpx1, vb, b_xzwy;
        addps.x tmp2, tmp2, tmpx1;
        // tmp2          = _mm_mul_ps(tmp2, scale);
        mulps.x tmp2, tmp2, vzddd;
        // // tmp2 needs to be scaled by (a0, a2, a3, a1) and added to p1_out
        // __m128 tmp3 = _mm_mul_ps(b, b_xwyz);
        mulps.x tmp3:, vb, b_xwyz;
        // tmp3        = _mm_sub_ps(tmp3, _mm_mul_ps(b_xxxx, b_xzwy));
        mulps.x tmpx1, b_xxxx, b_xzwy;
        subps.x tmp3, tmp3, tmpx1;
        // tmp3        = _mm_mul_ps(tmp3, scale);
        mulps.x tmp3, tmp3, vzddd;
    }

    #if translate {
        c_ptr := c.float32s.data;
        #asm AVX, AVX2 {
            movdqu.x vc:, [c_ptr];
            // __m128 czero  = KLN_SWIZZLE(*c, 0, 0, 0, 0);
            shufps.x czero:, vc, vc, s0000;
            // __m128 c_xzwy = KLN_SWIZZLE(*c, 1, 3, 2, 0);
            shufps.x c_xzwy:, vc, vc, s1320;
            // __m128 c_xwyz = KLN_SWIZZLE(*c, 2, 1, 3, 0);
            shufps.x c_xwyz:, vc, vc, s2130;
            // tmp4 = _mm_mul_ps(b, *c);
            mulps.x tmp4:, vb, vc;
            // tmp4 = _mm_sub_ps(
            //     tmp4, _mm_mul_ps(b_yxxx, KLN_SWIZZLE(*c, 0, 0, 0, 1)));
            shufps.x vc0001:, vc, vc, s0001;
            mulps.x tmpx1, b_yxxx, vc0001;
            subps.x tmp4, tmp4, tmpx1;
            // tmp4 = _mm_sub_ps(tmp4,
            //                   _mm_mul_ps(KLN_SWIZZLE(b, 1, 3, 3, 2),
            //                              KLN_SWIZZLE(*c, 1, 3, 3, 2)));
            shufps.x vb1332:, vb, vb, s1332;
            shufps.x vc1332:, vc, vc, s1332;
            mulps.x tmpx1, vb1332, vc1332;
            subps.x tmp4, tmp4, tmpx1;
            // tmp4 = _mm_sub_ps(tmp4,
            //                   _mm_mul_ps(KLN_SWIZZLE(b, 2, 1, 2, 3),
            //                              KLN_SWIZZLE(*c, 2, 1, 2, 3)));
            shufps.x vb2123:, vb, vb, s2123;
            shufps.x vc2123:, vc, vc, s2123;
            mulps.x tmpx1, vb2123, vc2123;
            subps.x tmp4, tmp4, tmpx1;
            // tmp4 = _mm_add_ps(tmp4, tmp4);
            addps.x tmp4, tmp4, tmp4;
            // tmp5 = _mm_mul_ps(b, c_xwyz);
            mulps.x tmp5:, vb, c_xwyz;
            // tmp5 = _mm_add_ps(tmp5, _mm_mul_ps(b_xzwy, czero));
            mulps.x tmpx1, b_xzwy, czero;
            addps.x tmp5, tmp5, tmpx1;
            // tmp5 = _mm_add_ps(tmp5, _mm_mul_ps(b_xwyz, *c));
            mulps.x tmpx1, b_xwyz, vc;
            addps.x tmp5, tmp5, tmpx1;
            // tmp5 = _mm_sub_ps(tmp5, _mm_mul_ps(b_xxxx, c_xzwy));
            mulps.x tmpx1, b_xxxx, c_xzwy;
            subps.x tmp5, tmp5, tmpx1;
            // tmp5 = _mm_mul_ps(tmp5, scale);
            mulps.x tmp5, tmp5, vzddd;
            // tmp6 = _mm_mul_ps(b, c_xzwy);
            mulps.x tmp6:, vb, c_xzwy;
            // tmp6 = _mm_add_ps(tmp6, _mm_mul_ps(b_xxxx, c_xwyz));
            mulps.x tmpx1, b_xxxx, c_xwyz;
            addps.x tmp6, tmp6, tmpx1;
            // tmp6 = _mm_add_ps(tmp6, _mm_mul_ps(b_xzwy, *c));
            mulps.x tmpx1, b_xzwy, vc;
            addps.x tmp6, tmp6, tmpx1;
            // tmp6 = _mm_sub_ps(tmp6, _mm_mul_ps(b_xwyz, czero));
            mulps.x tmpx1, b_xwyz, czero;
            subps.x tmp6, tmp6, tmpx1;
            // tmp6 = _mm_mul_ps(tmp6, scale);
            mulps.x tmp6, tmp6, vzddd;
        }
    }


    #if variadic {
        limit := count;
    } else {
        limit := 1;
    }
    #if inputp2 {
        stride := 2;
    } else {
        stride := 1;
    }

    for i: 0..limit - 1 {
        p1_in := in + (stride * i);
        p1_in_ptr := p1_in.float32s.data;
        p1_out := out + (stride * i);
        p1_out_ptr := p1_out.float32s.data;
        #asm AVX, AVX2 {
            movdqu.x vp1_in:, [p1_in_ptr];
            // __m128 p1_in_xzwy   = KLN_SWIZZLE(p1_in, 1, 3, 2, 0);
            shufps.x p1_in_xzwy:, vp1_in, vp1_in, s1320;
            // __m128 p1_in_xwyz   = KLN_SWIZZLE(p1_in, 2, 1, 3, 0);
            shufps.x p1_in_xwyz:, vp1_in, vp1_in, s2130;
            // p1_out = _mm_mul_ps(tmp, p1_in);
            mulps.x vp1_out:, tmp, vp1_in;
            // p1_out = _mm_add_ps(p1_out, _mm_mul_ps(tmp2, p1_in_xzwy));
            mulps.x tmpx1, tmp2, p1_in_xzwy;
            addps.x vp1_out, vp1_out, tmpx1;
            // p1_out = _mm_add_ps(p1_out, _mm_mul_ps(tmp3, p1_in_xwyz));
            mulps.x tmpx1, tmp3, p1_in_xwyz;
            addps.x vp1_out, vp1_out, tmpx1;
            movdqu.x [p1_out_ptr], vp1_out;
        }
        #if inputp2 || translate {
            p2_out := out + ((stride * i) + 1);
            p2_out_ptr := p2_out.float32s.data;
        }
        #if inputp2 {
            p2_in := in + ((stride * i) + 1);
            p2_in_ptr := p2_in.float32s.data;
            #asm AVX, AVX2 {
                movdqu.x vp2_in:, [p2_in_ptr];
                // p2_out              = _mm_mul_ps(tmp, p2_in);
                mulps.x vp2_out:, tmp, vp2_in;
                // p2_out              = _mm_add_ps(
                //     p2_out, _mm_mul_ps(tmp2, KLN_SWIZZLE(p2_in, 1, 3, 2, 0)));
                shufps.x vp2_in1320:, vp2_in, vp2_in, s1320;
                mulps.x tmpx1, tmp2, vp2_in1320;
                addps.x vp2_out, vp2_out, tmpx1;
                // p2_out = _mm_add_ps(
                //     p2_out, _mm_mul_ps(tmp3, KLN_SWIZZLE(p2_in, 2, 1, 3, 0)));
                shufps.x vp2_in2130:, vp2_in, vp2_in, s2130;
                mulps.x tmpx1, tmp3, vp2_in2130;
                addps.x vp2_out, vp2_out, tmpx1;
                movdqu.x [p2_out_ptr], vp2_out;
            }
        }
        #if translate {
            #asm AVX, AVX2 {
                movdqu.x vp2_out2:, [p2_out_ptr];
                // p2_out         = _mm_add_ps(p2_out, _mm_mul_ps(tmp4, p1_in));
                mulps.x tmpx1, tmp4, vp1_in;
                addps.x vp2_out2, vp2_out2, tmpx1;
                // p2_out = _mm_add_ps(p2_out, _mm_mul_ps(tmp5, p1_in_xwyz));
                mulps.x tmpx1, tmp5, p1_in_xwyz;
                addps.x vp2_out2, vp2_out2, tmpx1;
                // p2_out = _mm_add_ps(p2_out, _mm_mul_ps(tmp6, p1_in_xzwy));
                mulps.x tmpx1, tmp6, p1_in_xzwy;
                addps.x vp2_out2, vp2_out2, tmpx1;
                movdqu.x [p2_out_ptr], vp2_out2;
            }
        }
    }
}

sw012 :: (a: *Vec128(float32), b: Vec128(float32), c: *Vec128(float32), out: *Vec128(float32), count: s32=0, $variadic:bool=false, $translate:bool=false) {
    b_ptr := b.float32s.data;
    nzzzz_ptr := NZZZZ.float32s.data;
    uddd_ptr := UDDD.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vb:, [b_ptr];
        movdqu.x vnzzzz:, [nzzzz_ptr];
        movdqu.x vuddd:, [uddd_ptr];
        // __m128 b_xwyz   = KLN_SWIZZLE(b, 2, 1, 3, 0);
        shufps.x b_xwyz:, vb, vb, s2130;
        // __m128 b_xzwy   = KLN_SWIZZLE(b, 1, 3, 2, 0);
        shufps.x b_xzwy:, vb, vb, s1320;
        // __m128 b_xxxx   = KLN_SWIZZLE(b, 0, 0, 0, 0);
        shufps.x b_xxxx:, vb, vb, s0000;
        // __m128 tmp1
        //     = _mm_mul_ps(KLN_SWIZZLE(b, 0, 0, 0, 2), KLN_SWIZZLE(b, 2, 1, 3, 2));
        shufps.x vb0002:, vb, vb, s0002;
        shufps.x vb2132:, vb, vb, s2132;
        mulps.x tmp1:, vb0002, vb2132;
        // tmp1 = _mm_add_ps(
        //     tmp1,
        //     _mm_mul_ps(KLN_SWIZZLE(b, 1, 3, 2, 1), KLN_SWIZZLE(b, 3, 2, 1, 1)));
        shufps.x vb1321:, vb, vb, s1321;
        shufps.x vb3211:, vb, vb, s3211;
        mulps.x tmpx1:, vb1321, vb3211;
        addps.x tmp1, tmp1, tmpx1;
        // // Scale later with (a0, a2, a3, a1)
        // tmp1 = _mm_mul_ps(tmp1, dc_scale);
        mulps.x tmp1, tmp1, vuddd;
        // __m128 tmp2 = _mm_mul_ps(b, b_xwyz);
        mulps.x tmp2:, vb, b_xwyz;
        // tmp2 = _mm_sub_ps(tmp2,
        //                   _mm_xor_ps(_mm_set_ss(-0.f),
        //                              _mm_mul_ps(KLN_SWIZZLE(b, 0, 0, 0, 3),
        //                                         KLN_SWIZZLE(b, 1, 3, 2, 3))));
        shufps.x vb0003:, vb, vb, s0003;
        shufps.x vb1323:, vb, vb, s1323;
        mulps.x tmpx1, vb0003, vb1323;
        xorps.x tmpx1, vnzzzz, tmpx1;
        subps.x tmp2, tmp2, tmpx1;
        // // Scale later with (a0, a3, a1, a2)
        // tmp2 = _mm_mul_ps(tmp2, dc_scale);
        mulps.x tmp2, tmp2, vuddd;
        // // Alternately add and subtract to improve low component stability
        // __m128 tmp3 = _mm_mul_ps(b, b);
        mulps.x tmp3:, vb, vb;
        // tmp3        = _mm_sub_ps(tmp3, _mm_mul_ps(b_xwyz, b_xwyz));
        mulps.x tmpx1, b_xwyz, b_xwyz;
        subps.x tmp3, tmp3, tmpx1;
        // tmp3        = _mm_add_ps(tmp3, _mm_mul_ps(b_xxxx, b_xxxx));
        mulps.x tmpx1, b_xxxx, b_xxxx;
        addps.x tmp3, tmp3, tmpx1;
        // tmp3        = _mm_sub_ps(tmp3, _mm_mul_ps(b_xzwy, b_xzwy));
        mulps.x tmpx1, b_xzwy, b_xzwy;
        subps.x tmp3, tmp3, tmpx1;
    }

    tmp4_var: Vec128(float32);
    tmp4_var_ptr := tmp4_var.float32s.data;

    #if translate {
        c_ptr := c.float32s.data;

        check_var: Vec128(float32);
        check_var_ptr := check_var.float32s.data;

        #asm AVX, AVX2 {
            movdqu.x vc:, [c_ptr];
            // tmp4 = _mm_mul_ps(b_xxxx, *c);
            mulps.x tmp4:, b_xxxx, vc;
            // tmp4 = _mm_add_ps(
            //     tmp4, _mm_mul_ps(b_xzwy, KLN_SWIZZLE(*c, 2, 1, 3, 0)));
            shufps.x vc2130:, vc, vc, s2130;
            mulps.x tmpx1, b_xzwy, vc2130;
            addps.x tmp4, tmp4, tmpx1;
            // tmp4 = _mm_add_ps(tmp4, _mm_mul_ps(b, KLN_SWIZZLE(*c, 0, 0, 0, 0)));
            shufps.x vc0000:, vc, vc, s0000;
            mulps.x tmpx1, vb, vc0000;
            addps.x tmp4, tmp4, tmpx1;
            // // NOTE: The high component of tmp4 is meaningless here
            // tmp4 = _mm_sub_ps(
            //     tmp4, _mm_mul_ps(b_xwyz, KLN_SWIZZLE(*c, 1, 3, 2, 0)));
            shufps.x vc1320:, vc, vc, s1320;
            mulps.x tmpx1, b_xwyz, vc1320;
            subps.x tmp4, tmp4, tmpx1;
            movdqu.x [check_var_ptr], tmp4;
            // tmp4 = _mm_mul_ps(tmp4, dc_scale);
            mulps.x tmp4, tmp4, vuddd;
            movdqu.x [tmp4_var_ptr], tmp4;
        }
    }


    #if variadic {
        limit := count;
    } else {
        limit := 1;
    }

    for i: 0..limit - 1 {
        ai := a + i;
        ai_ptr := ai.float32s.data;
        p := out + i;
        p_ptr := p.float32s.data;

        #asm AVX, AVX2 {
            movdqu.x vai:, [ai_ptr];
            // p         = _mm_mul_ps(tmp1, KLN_SWIZZLE(a[i], 1, 3, 2, 0));
            shufps.x vai1320:, vai, vai, s1320;
            mulps.x vp:, tmp1, vai1320;
            // p = _mm_add_ps(p, _mm_mul_ps(tmp2, KLN_SWIZZLE(a[i], 2, 1, 3, 0)));
            shufps.x vai2130:, vai, vai, s2130;
            mulps.x tmpx1, tmp2, vai2130;
            addps.x vp, vp, tmpx1;
            // p = _mm_add_ps(p, _mm_mul_ps(tmp3, a[i]));
            mulps.x tmpx1, tmp3, vai;
            addps.x vp, vp, tmpx1;
        }
        #if translate {
            tmp5 := hi_dp(tmp4_var, ai.*);
            tmp5_ptr := tmp5.float32s.data;
            #asm AVX, AVX2 {
                movdqu.x vtmp5:, [tmp5_ptr];
                // p           = _mm_add_ps(p, tmp5);
                addps.x vp, vp, vtmp5;
            }
        }
        #asm AVX, AVX2 {
            movdqu.x [p_ptr], vp;
        }
    }
} 

sw312 :: (a: *Vec128(float32), b: Vec128(float32), c: *Vec128(float32), out: *Vec128(float32), count: s32=0, $variadic:bool=false, $translate:bool=false) {
    b_ptr := b.float32s.data;
    nzzzz_ptr := NZZZZ.float32s.data;
    zddd_ptr := ZDDD.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vb:, [b_ptr];
        movdqu.x vnzzzz:, [nzzzz_ptr];
        movdqu.x vzddd:, [zddd_ptr];
        // __m128 b_xxxx = KLN_SWIZZLE(b, 0, 0, 0, 0);
        shufps.x b_xxxx:, vb, vb, s0000;
        // __m128 b_xwyz = KLN_SWIZZLE(b, 2, 1, 3, 0);
        shufps.x b_xwyz:, vb, vb, s2130;
        // __m128 b_xzwy = KLN_SWIZZLE(b, 1, 3, 2, 0);
        shufps.x b_xzwy:, vb, vb, s1320;
        // __m128 tmp1 = _mm_mul_ps(b, b_xwyz);
        mulps.x tmp1:, vb, b_xwyz;
        // tmp1        = _mm_sub_ps(tmp1, _mm_mul_ps(b_xxxx, b_xzwy));
        mulps.x tmpx1:, b_xxxx, b_xzwy;
        subps.x tmp1, tmp1, tmpx1;
        // tmp1        = _mm_mul_ps(tmp1, two);
        mulps.x tmp1, tmp1, vzddd;
        // // tmp1 needs to be scaled by (_, a3, a1, a2)
        // __m128 tmp2 = _mm_mul_ps(b_xxxx, b_xwyz);
        mulps.x tmp2:, b_xxxx, b_xwyz;
        // tmp2        = _mm_add_ps(tmp2, _mm_mul_ps(b_xzwy, b));
        mulps.x tmpx1, b_xzwy, vb;
        addps.x tmp2, tmp2, tmpx1;
        // tmp2        = _mm_mul_ps(tmp2, two);
        mulps.x tmp2, tmp2, vzddd;
        // // tmp2 needs to be scaled by (_, a2, a3, a1)
        // __m128 tmp3  = _mm_mul_ps(b, b);
        mulps.x tmp3:, vb, vb;
        // __m128 b_tmp = KLN_SWIZZLE(b, 0, 0, 0, 1);
        shufps.x b_tmp:, vb, vb, s0001;
        // tmp3         = _mm_add_ps(tmp3, _mm_mul_ps(b_tmp, b_tmp));
        mulps.x tmpx1, b_tmp, b_tmp;
        addps.x tmp3, tmp3, tmpx1;
        // b_tmp        = KLN_SWIZZLE(b, 2, 1, 3, 2);
        shufps.x b_tmp, vb, vb, s2132;
        // __m128 tmp4  = _mm_mul_ps(b_tmp, b_tmp);
        mulps.x tmp4:, b_tmp, b_tmp;
        // b_tmp        = KLN_SWIZZLE(b, 1, 3, 2, 3);
        shufps.x b_tmp, vb, vb, s1323;
        // tmp4         = _mm_add_ps(tmp4, _mm_mul_ps(b_tmp, b_tmp));
        mulps.x tmpx1, b_tmp, b_tmp;
        addps.x tmp4, tmp4, tmpx1;
        // tmp3         = _mm_sub_ps(tmp3, _mm_xor_ps(tmp4, _mm_set_ss(-0.f)));
        xorps.x tmpx1, tmp4, vnzzzz;
        subps.x tmp3, tmp3, tmpx1;
        // // tmp3 needs to be scaled by (a0, a1, a2, a3)
    }

    #if translate {
        c_ptr := c.float32s.data;
        #asm AVX, AVX2 {
            movdqu.x vc:, [c_ptr];
            // tmp4 = _mm_mul_ps(b_xzwy, KLN_SWIZZLE(*c, 2, 1, 3, 0));
            shufps.x vc2130:, vc, vc, s2130;
            mulps.x tmp4, b_xzwy, vc2130;
            // tmp4 = _mm_sub_ps(tmp4, _mm_mul_ps(b_xxxx, *c));
            mulps.x tmpx1, b_xxxx, vc;
            subps.x tmp4, tmp4, tmpx1;
            // tmp4 = _mm_sub_ps(
            //     tmp4, _mm_mul_ps(b_xwyz, KLN_SWIZZLE(*c, 1, 3, 2, 0)));
            shufps.x vc1320:, vc, vc, s1320;
            mulps.x tmpx1, b_xwyz, vc1320;
            subps.x tmp4, tmp4, tmpx1;
            // tmp4 = _mm_sub_ps(tmp4, _mm_mul_ps(b, KLN_SWIZZLE(*c, 0, 0, 0, 0)));
            shufps.x vc0000:, vc, vc, s0000;
            mulps.x tmpx1, vb, vc0000;
            subps.x tmp4, tmp4, tmpx1;
            // // Mask low component and scale other components by 2
            // tmp4 = _mm_mul_ps(tmp4, two);
            mulps.x tmp4, tmp4, vzddd;
        }
    }


    #if variadic {
        limit := count;
    } else {
        limit := 1;
    }

    for i: 0..limit - 1 {
        ai := a + i;
        ai_ptr := ai.float32s.data;
        p := out + i;
        p_ptr := p.float32s.data;

        #asm AVX, AVX2 {
            movdqu.x vai:, [ai_ptr];
            // p         = _mm_mul_ps(tmp1, KLN_SWIZZLE(a[i], 2, 1, 3, 0));
            shufps.x vai2130:, vai, vai, s2130;
            mulps.x vp:, tmp1, vai2130;
            // p = _mm_add_ps(p, _mm_mul_ps(tmp2, KLN_SWIZZLE(a[i], 1, 3, 2, 0)));
            shufps.x vai1320:, vai, vai, s1320;
            mulps.x tmpx1, tmp2, vai1320;
            addps.x vp, vp, tmpx1;
            // p = _mm_add_ps(p, _mm_mul_ps(tmp3, a[i]));
            mulps.x tmpx1, tmp3, vai;
            addps.x vp, vp, tmpx1;
        }
        #if translate {
            #asm AVX, AVX2 {
                // p = _mm_add_ps(
                //     p, _mm_mul_ps(tmp4, KLN_SWIZZLE(a[i], 0, 0, 0, 0)));
                shufps.x vai0000:, vai, vai, s0000;
                mulps.x tmpx1, tmp4, vai0000;
                addps.x vp, vp, tmpx1;
            }
        }
        #asm AVX, AVX2 {
            movdqu.x [p_ptr], vp;
        }
    }
} 

swo12 :: (b: Vec128(float32), c: Vec128(float32)) -> Vec128(float32) {
    b_ptr := b.float32s.data;
    c_ptr := c.float32s.data;

    zddd_ptr := ZDDD.float32s.data;
    uzzz_ptr := UZZZ.float32s.data;

    out: Vec128(float32);
    out_ptr := out.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vb:, [b_ptr];
        movdqu.x vc:, [c_ptr];
        movdqu.x vzddd:, [zddd_ptr];
        movdqu.x vuzzz:, [uzzz_ptr];

        // __m128 tmp = _mm_mul_ps(b, KLN_SWIZZLE(c, 0, 0, 0, 0));
        shufps.x vc0000:, vc, vc, s0000;
        mulps.x tmp:, vb, vc0000;
        // tmp        = _mm_add_ps(tmp, _mm_mul_ps(KLN_SWIZZLE(b, 0, 0, 0, 0), c));
        shufps.x vb0000:, vb, vb, s0000;
        mulps.x tmpx1:, vb0000, vc;
        addps.x tmp, tmp, tmpx1;
        // tmp        = _mm_add_ps(
        //     tmp,
        //     _mm_mul_ps(KLN_SWIZZLE(b, 2, 1, 3, 0), KLN_SWIZZLE(c, 1, 3, 2, 0)));
        shufps.x vb2130:, vb, vb, s2130;
        shufps.x vc1320:, vc, vc, s1320;
        mulps.x tmpx1, vb2130, vc1320;
        addps.x tmp, tmp, tmpx1;
        // tmp = _mm_sub_ps(
        //     _mm_mul_ps(KLN_SWIZZLE(b, 1, 3, 2, 0), KLN_SWIZZLE(c, 2, 1, 3, 0)),
        //     tmp);
        shufps.x vb1320:, vb, vb, s1320;
        shufps.x vc2130:, vc, vc, s2130;
        mulps.x tmpx1, vb1320, vc2130;
        subps.x tmp, tmpx1, tmp;
        // tmp = _mm_mul_ps(tmp, _mm_set_ps(2.f, 2.f, 2.f, 0.f));
        mulps.x tmp, tmp, vzddd;
        // // b0^2 + b1^2 + b2^2 + b3^2 assumed to equal 1
        // // Set the low component to unity
        // return _mm_add_ps(tmp, _mm_set_ss(1.f));
        addps.x tmp, tmp, vuzzz;
        movdqu.x [out_ptr], tmp;
    }
    return out;
}


// functions that are used in operators
add :: inline (dst: *float, a: *float, b: *float) {
    #asm AVX, AVX2 {
        movdqu.x va:, [a];
        movdqu.x vb:, [b];
        addps.x tmp:, va, vb;
        movdqu.x [dst], tmp;
    }
}

sub :: inline (dst: *float, a: *float, b: *float) {
    #asm AVX, AVX2 {
        movdqu.x va:, [a];
        movdqu.x vb:, [b];
        subps.x tmp:, va, vb;
        movdqu.x [dst], tmp;
    }
}

xor :: inline (dst: *float, a: *float, b: *float) {
    #asm AVX, AVX2 {
        movdqu.x va:, [a];
        movdqu.x vb:, [b];
        xorps.x tmp:, va, vb;
        movdqu.x [dst], tmp;
    }
}

mul :: inline (dst: *float, a: *float, b: *float) {
    #asm AVX, AVX2 {
        movdqu.x va:, [a];
        movdqu.x vb:, [b];
        mulps.x tmp:, va, vb;
        movdqu.x [dst], tmp;
    }
}

mul :: inline (dst: *float, a: *float, b: float) {
    tmp := vec128(float.[b, b, b, b]);
    tmp_ptr := tmp.float32s.data;
    mul(dst, a, tmp_ptr);
}

div :: inline (dst: *float, a: *float, b: float) {
    tmp := rcp_nr1(vec128(float.[b, b, b, b]));
    tmp_ptr := tmp.float32s.data;
    mul(dst, a, tmp_ptr);
}
eq :: (a: *float, b: *float) -> bool {
    mask: u32 = 0;
    mask_ptr := *mask;
    #asm AVX, AVX2 {
        movdqu.x vap1:, [a];
        movdqu.x vbp1:, [b];
        cmpps.x cmp:, vap1, vbp1, 01;
        movmskps.x eq_mask:, cmp;
        mov [mask_ptr], eq_mask;
    }
    return mask == 0b1111;
}
approx_eq :: (a: *float, b: *float, epsilon: float) -> bool {
    eps := vec128(float.[epsilon, epsilon, epsilon, epsilon]);
    eps_ptr := eps.float32s.data;
    nznznznz_ptr := NZNZNZNZ.float32s.data;
    mask: u32 = 0;
    mask_ptr := *mask;
    #asm AVX, AVX2 {
        movdqu.x vap1:, [a];
        movdqu.x vbp1:, [b];
        movdqu.x veps:, [eps_ptr];
        movdqu.x vnznznznz:, [nznznznz_ptr];
        // __m128 cmp = _mm_cmplt_ps(
        //     _mm_andnot_ps(_mm_set1_ps(-0.f), _mm_sub_ps(p1_, other.p1_)), eps);
        subps.x d0:, vap1, vbp1;
        andnps.x tmpx1:, vnznznznz, d0;
        cmpps.x cmp:, tmpx1, veps, 1;
        movmskps.x eq_mask:, cmp;
        mov [mask_ptr], eq_mask;
    }
    return mask == 0b1111;
}


////////////////////////////////////////////////////////////////
Dual :: struct {
    p: float;
    q: float;
}
operator += :: (a: *Dual, b: Dual) {
    a.p += b.p;
    a.q += b.q;
}
operator -= :: (a: *Dual, b: Dual) {
    a.p -= b.p;
    a.q -= b.q;
}
operator *= :: (a: *Dual, s: float) {
    a.p *= s;
    a.q *= s;
}
operator /= :: (a: *Dual, s: float) {
    a.p /= s;
    a.q /= s;
}
operator + :: (a: Dual, b: Dual) -> Dual {
    return .{p=a.p + b.p, q=a.q + b.q};
}
operator - :: (a: Dual, b: Dual) -> Dual {
    return .{p=a.p - b.p, q=a.q - b.q};
}
operator * :: (a: Dual, s: float) -> Dual #symmetric {
    return Dual.{p=a.p * s, q=a.q * s};
}
operator / :: (a: Dual, s: float) -> Dual {
    return Dual.{p=a.p / s, q=a.q / s};
}
///////////////////////////////////////////////////////// plane
Plane :: struct {
    p0: Vec128(float32);
    make :: (a: float, b: float, c: float, d: float) -> Plane {
        out: Plane;
        out.p0 = vec128(float.[d, a, b, c]);
        return out;
    }
    make :: (a: Plane) -> Plane {
        out: Plane;
        memcpy(*out.p0, *a.p0, size_of(Vec128(float32)));
        return out;
    }
}
norm :: (a: Plane) -> float {
    tmp := sqrt_nr1(hi_dp(a.p0, a.p0));
    return tmp.float32s[0];
}
normalize :: (a: *Plane) {
    inv_norm := rsqrt_nr1(hi_dp_bc(a.p0, a.p0));
    inv_norm_ptr := inv_norm.float32s.data;
    p0_ptr := a.p0.float32s.data;

    uzzz_ptr := UZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vp0:, [p0_ptr];
        movdqu.x vinv_norm:, [inv_norm_ptr];
        movdqu.x vuzzz:, [uzzz_ptr];

        blendps.x vinv_norm, vinv_norm, vuzzz, 1;
        mulps.x vp0, vinv_norm, vp0;
        movdqu.x [p0_ptr], vp0;
    }
}
invert :: (a: *Plane) {
    inv_norm := rsqrt_nr1(hi_dp_bc(a.p0, a.p0));
    mul(a.p0.float32s.data, inv_norm.float32s.data, a.p0.float32s.data);
    mul(a.p0.float32s.data, inv_norm.float32s.data, a.p0.float32s.data);
}
normalized :: (a: Plane) -> Plane {
    out: Plane;
    memcpy(*out, *a, size_of(Plane));
    normalize(*out);
    return out;
}
inverse :: (a: Plane) -> Plane {
    out: Plane;
    memcpy(*out, *a, size_of(Plane));
    invert(*out);
    return out;
}
operator == :: (a: Plane, b: Plane) -> bool {
    ap0 := a.p0.float32s.data;
    bp0 := b.p0.float32s.data;
    mask: u32 = 0;
    mask_ptr := *mask;
    #asm AVX, AVX2 {
        movdqu.x vap0:, [ap0];
        movdqu.x vbp0:, [bp0];
        cmpps.x eq:, vap0, vbp0, 0;
        movmskps.x eq_mask:, eq;
        mov [mask_ptr], eq_mask;
    }
    return mask == 0b1111;
}
approx_eq :: (a: Plane, b: Plane, epsilon: float) -> bool {
    return approx_eq(a.p0.float32s.data, b.p0.float32s.data, epsilon);
}

reflect :: (a: Plane, p: Plane) -> Plane {
    out: Plane;
    sw00(a.p0, p.p0, *out.p0);
    return out;
}
reflect :: (a: Plane, l: Line) -> Line {
    out: Line;
    sw10(a.p0, l.p1, *out.p1, *out.p2);
    p2_tmp: Vec128(float32);
    sw20(a.p0, l.p2, *p2_tmp);
    add(out.p2.float32s.data, out.p2.float32s.data, p2_tmp.float32s.data);
    return out;
}
reflect :: (a: Plane, p: Point) -> Point {
    out: Point;
    sw30(a.p0, p.p3, *out.p3);
    return out;
}
operator += :: (a: *Plane, b: Plane) {
    add(a.p0.float32s.data, a.p0.float32s.data, b.p0.float32s.data);
}
operator -= :: (a: *Plane, b: Plane) {
    sub(a.p0.float32s.data, a.p0.float32s.data, b.p0.float32s.data);
}
operator *= :: (a: *Plane, s: float) {
    mul(a.p0.float32s.data, a.p0.float32s.data, s);
}
operator /= :: (a: *Plane, s: float) {
    div(a.p0.float32s.data, a.p0.float32s.data, s);
}
operator + :: (a: Plane, b: Plane) -> Plane {
    out: Plane;
    add(out.p0.float32s.data, a.p0.float32s.data, b.p0.float32s.data);
    return out;
}
operator - :: (a: Plane, b: Plane) -> Plane {
    out: Plane;
    sub(out.p0.float32s.data, a.p0.float32s.data, b.p0.float32s.data);
    return out;
}
operator * :: (a: Plane, s: float) -> Plane #symmetric {
    out: Plane;
    mul(out.p0.float32s.data, a.p0.float32s.data, s);
    return out;
}
operator / :: (a: Plane, s: float) -> Plane #symmetric {
    out: Plane;
    div(out.p0.float32s.data, a.p0.float32s.data, s);
    return out;
}
operator - :: (a: Plane) -> Plane {
    out: Plane;
    xor(out.p0.float32s.data, a.p0.float32s.data, ZNZNZNZ.float32s.data);
    return out;
}

///////////////////////////////////////////////////////// line
Ideal_Line :: struct {
    p2: Vec128(float32);
    make :: (a: float, b: float, c: float) -> Ideal_Line {
        out: Ideal_Line;
        out.p2 = vec128(float.[0, a, b, c]);
        return out;
    }
    make :: (in: Vec128(float32)) -> Ideal_Line {
        out: Ideal_Line;
        out.p2 = in;
        return out;
    }
}
squared_ideal_norm :: (a: *Ideal_Line) -> float {
    tmp := hi_dp(a.p2, a.p2);
    return tmp.float32s[0];
}
ideal_norm :: (a: *Ideal_Line) -> float {
    return sqrt(squared_ideal_norm(a));
}

operator += :: (a: *Ideal_Line, b: Ideal_Line) {
    add(a.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
}
operator -= :: (a: *Ideal_Line, b: Ideal_Line) {
    sub(a.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
}
operator *= :: (a: *Ideal_Line, s: float) {
    mul(a.p2.float32s.data, a.p2.float32s.data, s);
}
operator /= :: (a: *Ideal_Line, s: float) {
    div(a.p2.float32s.data, a.p2.float32s.data, s);
}

operator + :: (a: Ideal_Line, b: Ideal_Line) -> Ideal_Line {
    out: Ideal_Line;
    add(out.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
    return out;
}
operator - :: (a: Ideal_Line, b: Ideal_Line) -> Ideal_Line {
    out: Ideal_Line;
    sub(out.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
    return out;
}
operator * :: (a: Ideal_Line, s: float) -> Ideal_Line #symmetric {
    out: Ideal_Line;
    mul(out.p2.float32s.data, a.p2.float32s.data, s);
    return out;
}
operator / :: (a: Ideal_Line, s: float) -> Ideal_Line #symmetric {
    out: Ideal_Line;
    div(out.p2.float32s.data, a.p2.float32s.data, s);
    return out;
}
operator - :: (a: Ideal_Line) -> Ideal_Line {
    out: Ideal_Line;
    xor(out.p2.float32s.data, a.p2.float32s.data, NZNZNZNZ.float32s.data);
    return out;
}
operator ~ :: (a: Ideal_Line) -> Ideal_Line {
    out: Ideal_Line;
    xor(out.p2.float32s.data, a.p2.float32s.data, ZNZNZNZ.float32s.data);
    return out;
}
/////////////////////////////////////////////////////////////
Branch :: struct {
    p1: Vec128(float32);
    make :: (a: float, b: float, c: float) -> Branch {
        out: Branch;
        out.p1 = vec128(float.[0, a, b, c]);
        return out;
    }
    make :: (in: Vec128(float32)) -> Branch {
        out: Branch;
        out.p1 = in;
        return out;
    }
}
squared_norm :: (a: Branch) -> float {
    dp := hi_dp(a.p1, a.p1);
    return dp.float32s[0];
}
norm :: (a: Branch) -> float {
    return sqrt(squared_norm(a));
}
normalize :: (a: *Branch) {
    inv_norm := rsqrt_nr1(hi_dp_bc(a.p1, a.p1));
    mul(a.p1.float32s.data, a.p1.float32s.data, inv_norm.float32s.data);
}
invert :: (a: *Branch) {
    inv_norm := rsqrt_nr1(hi_dp_bc(a.p1, a.p1));
    inv_norm_ptr := inv_norm.float32s.data;
    p1_ptr := a.p1.float32s.data;
    znznznz_ptr := ZNZNZNZ.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x vp1:, [p1_ptr];
        movdqu.x vznznznz:, [znznznz_ptr];
        movdqu.x vinv_norm:, [inv_norm_ptr];
        mulps.x vp1, vp1, vinv_norm;
        mulps.x vp1, vp1, vinv_norm;
        xorps.x vp1, vznznznz, vp1;
        movdqu.x [p1_ptr], vp1;
    }
}

normalized :: (a: Branch) -> Branch {
    out: Branch;
    memcpy(*out, *a, size_of(Branch));
    normalize(*out);
    return out;
}
inverse :: (a: Branch) -> Branch {
    out: Branch;
    memcpy(*out, *a, size_of(Branch));
    invert(*out);
    return out;
}
operator += :: (a: *Branch, b: Branch) {
    add(a.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
}
operator -= :: (a: *Branch, b: Branch) {
    sub(a.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
}
operator *= :: (a: *Branch, s: float) {
    mul(a.p1.float32s.data, a.p1.float32s.data, s);
}
operator /= :: (a: *Branch, s: float) {
    div(a.p1.float32s.data, a.p1.float32s.data, s);
}

operator + :: (a: Branch, b: Branch) -> Branch {
    out: Branch;
    add(out.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
    return out;
}
operator - :: (a: Branch, b: Branch) -> Branch {
    out: Branch;
    sub(out.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
    return out;
}
operator * :: (a: Branch, s: float) -> Branch #symmetric {
    out: Branch;
    mul(out.p1.float32s.data, a.p1.float32s.data, s);
    return out;
}
operator / :: (a: Branch, s: float) -> Branch #symmetric {
    out: Branch;
    div(out.p1.float32s.data, a.p1.float32s.data, s);
    return out;
}
operator - :: (a: Branch) -> Branch {
    out: Branch;
    xor(out.p1.float32s.data, a.p1.float32s.data, NZNZNZNZ.float32s.data);
    return out;
}
operator ~ :: (a: Branch) -> Branch {
    out: Branch;
    xor(out.p1.float32s.data, a.p1.float32s.data, ZNZNZNZ.float32s.data);
    return out;
}
////////////////////////////////////////////////////////////////////////
Line :: struct {
    p1: Vec128(float32);
    p2: Vec128(float32);

    make :: (a: float, b: float, c: float, d: float, e: float, f: float) -> Line {
        out: Line;
        out.p1 = vec128(float.[0.0, d, e, f]);
        out.p2 = vec128(float.[0.0, a, b, c]);
        return out;
    }
    make :: (p1: Vec128(float32), p2: Vec128(float32)) -> Line {
        out: Line; out.p1 = p1; out.p2 = p2; return out;
    }
    make :: (o: Ideal_Line) -> Line {
        out: Line;
        out.p1 = vec128(float.[0.0, 0.0, 0.0, 0.0]);;
        out.p2 = o.p2;
        return out;
    }
    make :: (o: Branch) -> Line {
        out: Line;
        out.p1 = o.p1;
        out.p2 = vec128(float.[0.0, 0.0, 0.0, 0.0]);;
        return out;
    }
    make :: (o: Line) -> Line {
        out: Line;
        memcpy(*out.p1, *o.p1, size_of(Vec128(float32)));
        memcpy(*out.p2, *o.p2, size_of(Vec128(float32)));
        return out;
    }
}

squared_norm :: (a: Line) -> float {
    dp := hi_dp(a.p1, a.p1);
    return dp.float32s[0];
}
norm :: (a: Line) -> float {
    return sqrt(squared_norm(a));
}

normalize :: (a: *Line) {
    b2 := hi_dp_bc(a.p1, a.p1);
    s  := rsqrt_nr1(b2);
    bc := hi_dp_bc(a.p1, a.p2);
    inv_b2 := rcp_nr1(b2);

    s_ptr := s.float32s.data;
    bc_ptr := bc.float32s.data;
    inv_b2_ptr := inv_b2.float32s.data;

    p1_ptr := a.p1.float32s.data;
    p2_ptr := a.p2.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vp1:, [p1_ptr];
        movdqu.x vp2:, [p2_ptr];
        movdqu.x vs:, [s_ptr];
        movdqu.x vbc:, [bc_ptr];
        movdqu.x vinv_b2:, [inv_b2_ptr];
        // __m128 t  = _mm_mul_ps(_mm_mul_ps(bc, detail::rcp_nr1(b2)), s);
        mulps.x tmpx1:, vbc, vinv_b2;
        mulps.x t:, tmpx1, vs;
        // __m128 tmp = _mm_mul_ps(p2_, s);
        mulps.x tmp:, vp2, vs;
        // p2_        = _mm_sub_ps(tmp, _mm_mul_ps(p1_, t));
        mulps.x tmpx1, vp1, t;
        subps.x vp2, tmp, tmpx1;
        // p1_        = _mm_mul_ps(p1_, s);
        mulps.x vp1, vp1, vs;

        movdqu.x [p1_ptr], vp1;
        movdqu.x [p2_ptr], vp2;
    }
}
invert :: (a: *Line) {
    b2 := hi_dp_bc(a.p1, a.p1);
    s  := rsqrt_nr1(b2);
    bc := hi_dp_bc(a.p1, a.p2);
    inv_b2 := rcp_nr1(b2);

    s_ptr := s.float32s.data;
    bc_ptr := bc.float32s.data;
    inv_b2_ptr := inv_b2.float32s.data;
    p1_ptr := a.p1.float32s.data;
    p2_ptr := a.p2.float32s.data;
    znznznz_ptr := ZNZNZNZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vp1:, [p1_ptr];
        movdqu.x vp2:, [p2_ptr];
        movdqu.x vs:, [s_ptr];
        movdqu.x vbc:, [bc_ptr];
        movdqu.x vinv_b2:, [inv_b2_ptr];
        movdqu.x vznznznz:, [znznznz_ptr];

        // __m128 t      = _mm_mul_ps(_mm_mul_ps(bc, b2_inv), s);
        mulps.x tmpx1:, vbc, vinv_b2;
        mulps.x t:, tmpx1, vs;
        // __m128 st = _mm_mul_ps(s, t);
        mulps.x st:, vs, t;
        // st        = _mm_mul_ps(p1_, st);
        mulps.x st, vp1, st;
        // p2_       = _mm_sub_ps(_mm_mul_ps(p2_, b2_inv), _mm_add_ps(st, st));
        mulps.x tmpx1, vp2, vinv_b2;
        addps.x tmpx2:, st, st;
        subps.x vp2, tmpx1, tmpx2;
        // p2_       = _mm_xor_ps(p2_, neg);
        xorps.x vp2, vp2, vznznznz;
        // p1_ = _mm_xor_ps(_mm_mul_ps(p1_, b2_inv), neg);
        mulps.x tmpx1, vp1, vinv_b2;
        xorps.x vp1, tmpx1, vznznznz;

        movdqu.x [p1_ptr], vp1;
        movdqu.x [p2_ptr], vp2;
    }
}
normalized :: (a: Line) -> Line {
    out: Line;
    memcpy(*out, *a, size_of(Line));
    normalize(*out);
    return out;
}
inverse :: (a: Line) -> Line {
    out: Line;
    memcpy(*out, *a, size_of(Line));
    invert(*out);
    return out;
}
operator == :: (a: Line, b: Line) -> bool {
    eqp1 := eq(a.p1.float32s.data, b.p1.float32s.data);
    eqp2 := eq(a.p2.float32s.data, b.p2.float32s.data);
    return eqp1 && eqp2;
}

approx_eq :: (a: Line, b: Line, epsilon: float) -> bool {
    ap1 := approx_eq(a.p1.float32s.data, b.p1.float32s.data, epsilon);
    ap2 :=  approx_eq(a.p2.float32s.data, b.p2.float32s.data, epsilon);
    return ap1 && ap2;
    //
    // ap1 := a.p1.float32s.data; ap2 := a.p2.float32s.data;
    // bp1 := b.p1.float32s.data; bp2 := b.p2.float32s.data;
    // eps := vec128(float.[epsilon, epsilon, epsilon, epsilon]);
    // eps_ptr := eps.float32s.data;
    // nznznznz_ptr := NZNZNZNZ.float32s.data;
    // mask: u32 = 0;
    // mask_ptr := *mask;
    // #asm AVX, AVX2 {
    //     movdqu.x vap1:, [ap1];
    //     movdqu.x vap2:, [ap2];
    //     movdqu.x vbp1:, [bp1];
    //     movdqu.x vbp2:, [bp2];
    //     movdqu.x veps:, [eps_ptr];
    //     movdqu.x vnznznznz:, [nznznznz_ptr];
    //     // __m128 cmp1
    //     //     = _mm_cmplt_ps(_mm_andnot_ps(neg, _mm_sub_ps(p1_, other.p1_)), eps);
    //     subps.x dp1:, vap1, vbp1;
    //     andnps.x dp1, vnznznznz, dp1;
    //     cmpps.x cmp1:, dp1, veps, 1;
    //     // __m128 cmp2
    //     //     = _mm_cmplt_ps(_mm_andnot_ps(neg, _mm_sub_ps(p2_, other.p2_)), eps);
    //     subps.x dp2:, vap2, vbp2;
    //     andnps.x dp2, vnznznznz, dp2;
    //     cmpps.x cmp2:, dp2, veps, 1;
    //
    //     andps.x eq:, cmp1, cmp2;
    //     movmskps.x eq_mask:, eq;
    //     mov [mask_ptr], eq_mask;
    // }
    // return mask == 0xf;
}
operator += :: (a: *Line, b: Line) {
    add(a.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
    add(a.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
}
operator -= :: (a: *Line, b: Line) {
    sub(a.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
    sub(a.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
}
operator *= :: (a: *Line, s: float) {
    mul(a.p1.float32s.data, a.p1.float32s.data, s);
    mul(a.p2.float32s.data, a.p2.float32s.data, s);
}
operator /= :: (a: *Line, s: float) {
    div(a.p1.float32s.data, a.p1.float32s.data, s);
    div(a.p2.float32s.data, a.p2.float32s.data, s);
}
operator + :: (a: Line, b: Line) -> Line {
    out: Line;
    add(out.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
    add(out.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
    return out;
}
operator - :: (a: Line, b: Line) -> Line {
    out: Line;
    sub(out.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
    sub(out.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
    return out;
}
operator * :: (a: Line, s: float) -> Line #symmetric {
    out: Line;
    mul(out.p1.float32s.data, a.p1.float32s.data, s);
    mul(out.p2.float32s.data, a.p2.float32s.data, s);
    return out;
}
operator / :: (a: Line, s: float) -> Line #symmetric {
    out: Line;
    div(out.p1.float32s.data, a.p1.float32s.data, s);
    div(out.p2.float32s.data, a.p2.float32s.data, s);
    return out;
}
operator - :: (a: Line) -> Line {
    out: Line;
    xor(out.p1.float32s.data, a.p1.float32s.data, NZNZNZNZ.float32s.data);
    xor(out.p2.float32s.data, a.p2.float32s.data, NZNZNZNZ.float32s.data);
    return out;
}
operator ~ :: (a: Line) -> Line {
    out: Line;
    xor(out.p1.float32s.data, a.p1.float32s.data, ZNZNZNZ.float32s.data);
    xor(out.p2.float32s.data, a.p2.float32s.data, ZNZNZNZ.float32s.data);
    return out;
}

//////////////////////////////////////////////////////////////////////// point
Point :: struct {
    p3: Vec128(float32);
    make :: (x: float, y: float, z: float) -> Point {
        out: Point;
        out.p3 = vec128(float.[1.0, x, y, z]);
        return out;
    }
    make :: (p: Point) -> Point {
        out: Point;
        memcpy(*out.p3, *p.p3, size_of(Vec128(float32)));
        return out;
    }
}
normalize :: (a: *Point) {
    p3_ptr := a.p3.float32s.data;
    twos_ptr := DDDD.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x vtwos:, [twos_ptr];
        movdqu.x vp3:, [p3_ptr];
        shufps.x vp3_0000:, vp3, vp3, s0000;

        movdqu.x va:, vp3_0000;
        // __m128 xn  = _mm_rcp_ps(a);
        rcpps.x xn:, va;
        // __m128 axn = _mm_mul_ps(a, xn);
        mulps.x axn:, va, xn;
        // return _mm_mul_ps(xn, _mm_sub_ps(_mm_set1_ps(2.f), axn));
        subps.x tmp2:, vtwos, axn;
        mulps.x vout:, xn, tmp2;

        mulps.x vp3, vp3, vout;

        movdqu.x [p3_ptr], vp3;
    }
}

invert :: (a: *Point) {
    p3_ptr := a.p3.float32s.data;
    twos_ptr := DDDD.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x vtwos:, [twos_ptr];
        movdqu.x vp3:, [p3_ptr];
        shufps.x vp3_0000:, vp3, vp3, s0000;

        movdqu.x va:, vp3_0000;
        // __m128 xn  = _mm_rcp_ps(a);
        rcpps.x xn:, va;
        // __m128 axn = _mm_mul_ps(a, xn);
        mulps.x axn:, va, xn;
        // return _mm_mul_ps(xn, _mm_sub_ps(_mm_set1_ps(2.f), axn));
        subps.x tmp2:, vtwos, axn;
        mulps.x vout:, tmp2, axn;

        mulps.x vp3, vout, vp3;
        mulps.x vp3, vout, vp3;

        movdqu.x [p3_ptr], vp3;
    }
}
normalized :: (a: Point) -> Point {
    out: Point;
    memcpy(*out, *a, size_of(Point));
    normalize(*out);
    return out;
}
inverse :: (a: Point) -> Point {
    out: Point;
    memcpy(*out, *a, size_of(Point));
    invert(*out);
    return out;
}
operator += :: (a: *Point, b: Point) {
    add(a.p3.float32s.data, a.p3.float32s.data, b.p3.float32s.data);
}
operator -= :: (a: *Point, b: Point) {
    sub(a.p3.float32s.data, a.p3.float32s.data, b.p3.float32s.data);
}
operator *= :: (a: *Point, s: float) {
    mul(a.p3.float32s.data, a.p3.float32s.data, s);
}
operator /= :: (a: *Point, s: float) {
    div(a.p3.float32s.data, a.p3.float32s.data, s);
}

operator + :: (a: Point, b: Point) -> Point {
    out: Point;
    add(out.p3.float32s.data, a.p3.float32s.data, b.p3.float32s.data);
    return out;
}
operator - :: (a: Point, b: Point) -> Point {
    out: Point;
    sub(out.p3.float32s.data, a.p3.float32s.data, b.p3.float32s.data);
    return out;
}
operator * :: (a: Point, s: float) -> Point #symmetric {
    out: Point;
    mul(out.p3.float32s.data, a.p3.float32s.data, s);
    return out;
}
operator / :: (a: Point, s: float) -> Point #symmetric {
    out: Point;
    div(out.p3.float32s.data, a.p3.float32s.data, s);
    return out;
}
operator - :: (a: Point) -> Point {
    out: Point;
    xor(out.p3.float32s.data, a.p3.float32s.data, ZNZNZNZ.float32s.data);
    return out;
}
operator ~ :: (a: Point) -> Point {
    out: Point;
    xor(out.p3.float32s.data, a.p3.float32s.data, NZNZNZNZ.float32s.data);
    return out;
}
///////////////////////////////////////////////////////////////////////// translator
Translator :: struct {
    p2: Vec128(float32);
    make :: (delta: float, x: float, y: float, z: float) -> Translator {
        norm := sqrt(x * x + y * y + z * z);
        inv_norm := 1.0 / norm;
        half_d := -0.5 * delta;
        t: Translator;
        p2_ptr := t.p2.float32s.data;

        v1 := vec128(float.[half_d, half_d, half_d, half_d]);
        v1_ptr := v1.float32s.data;
        v2 := vec128(float.[0, x, y, z]);
        v2_ptr := v2.float32s.data;
        v3 := vec128(float.[0, inv_norm, inv_norm, inv_norm]);
        v3_ptr := v3.float32s.data;

        #asm AVX, AVX2 {
            movdqu.x vv1:, [v1_ptr];
            movdqu.x vv2:, [v2_ptr];
            movdqu.x vv3:, [v3_ptr];
            mulps.x vp2:, vv1, vv2;
            mulps.x vp2, vp2, vv3;
            movdqu.x [p2_ptr], vp2;
        }
        return t;
    }
    make :: (position: Vector3) -> Translator {
        out: Translator;
        out.p2 = vec128(float.[1.0, -0.5 * position.x, -0.5 * position.y, -0.5 * position.z]);
        return out;

        // tx := Translator.make(position.x, 1.0, 0.0, 0.0);
        // ty := Translator.make(position.y, 0.0, 1.0, 0.0);
        // tz := Translator.make(position.z, 0.0, 0.0, 1.0);
        // return tx*ty*tz;
    }
}
load_normalized :: (t: *Translator, data: *float) {
    memcpy(t.p2.float32s.data, data, size_of(float32)*4);
}
invert :: (t: *Translator) {
    xor(t.p2.float32s.data, ZNZNZNZ.float32s.data, t.p2.float32s.data);
}
inverse :: (t: *Translator) -> Translator {
    tmp: Translator;
    memcpy(*tmp, t, size_of(Translator));
    invert(*tmp);
    return tmp;
}
conjugate :: (t: Translator, p: Plane) -> Plane {
    out: Plane;

    p2_ptr := t.p2.float32s.data;
    uzzz_ptr := UZZZ.float32s.data;

    tmp: Vec128(float32);
    tmp_ptr := tmp.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x vp2:, [p2_ptr];
        movdqu.x vuzzz:, [uzzz_ptr];
        blendps.x vtmp:, vp2, vuzzz, 1;
        movdqu.x [tmp_ptr], vtmp;
    }
    out.p0 = sw02(p.p0, tmp);
    return p;
}
conjugate :: (t: Translator, l: Line) -> Line {
    out: Line;
    arr : [2]*Vec128(float32);;
    arr[0] = *out.p1;
    arr[1] = *out.p2;
    swL2(l.p1, l.p2, t.p2, arr);
    return out;
}
conjugate :: (t: Translator, p: Point) -> Point {
    out: Point;
    out.p3 = sw32(p.p3, t.p2);
    return out;
}

operator == :: (a: Translator, b: Translator) -> bool {
    return eq(a.p2.float32s.data, b.p2.float32s.data);
}

operator += :: (a: *Translator, b: Translator) {
    add(a.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
}
operator -= :: (a: *Translator, b: Translator) {
    sub(a.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
}
operator *= :: (a: *Translator, s: float) {
    mul(a.p2.float32s.data, a.p2.float32s.data, s);
}
operator /= :: (a: *Translator, s: float) {
    div(a.p2.float32s.data, a.p2.float32s.data, s);
}

operator + :: (a: Translator, b: Translator) -> Translator {
    out: Translator;
    add(out.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
    return out;
}
operator - :: (a: Translator, b: Translator) -> Translator {
    out: Translator;
    sub(out.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
    return out;
}
operator * :: (a: Translator, s: float) -> Translator #symmetric {
    out: Translator;
    mul(out.p2.float32s.data, a.p2.float32s.data, s);
    return out;
}
operator / :: (a: Translator, s: float) -> Translator #symmetric {
    out: Translator;
    div(out.p2.float32s.data, a.p2.float32s.data, s);
    return out;
}
nlerp :: (a: Translator, b: Translator, t: float) -> Translator {
    return ((1 - t) * a + t * b);
}
slerp :: (a: Translator, b: Translator, t: float) -> Translator {
    if t == 0.0 return a;
    if t == 1.0 return b;
    if a == b return a;
    return (1.0 - t) * a + t * b;
}
/////////////////////////////////////////////////////////// direction

Direction :: struct {
    p3: Vec128(float32);
    make :: (x: float, y: float, z: float) -> Direction {
        out: Direction;
        out.p3 = vec128(float.[0.0, x, y, z]);
        return out;
    }
}
normalize :: (a: *Direction) {
    p3_ptr := a.p3.float32s.data;
    tmp := rsqrt_nr1(hi_dp_bc(a.p3, a.p3));
    mul(a.p3.float32s.data, a.p3.float32s.data, tmp.float32s.data);
}
normalized :: (a: Direction) -> Direction {
    out: Direction;
    memcpy(*out, *a, size_of(Direction));
    normalize(*out);
    return out;
}
operator += :: (a: *Direction, b: Direction) {
    add(a.p3.float32s.data, a.p3.float32s.data, b.p3.float32s.data);
}
operator -= :: (a: *Direction, b: Direction) {
    sub(a.p3.float32s.data, a.p3.float32s.data, b.p3.float32s.data);
}
operator *= :: (a: *Direction, s: float) {
    mul(a.p3.float32s.data, a.p3.float32s.data, s);
}
operator /= :: (a: *Direction, s: float) {
    div(a.p3.float32s.data, a.p3.float32s.data, s);
}
operator + :: (a: Direction, b: Direction) -> Direction {
    out: Direction;
    add(out.p3.float32s.data, a.p3.float32s.data, b.p3.float32s.data);
    return out;
}
operator - :: (a: Direction, b: Direction) -> Direction {
    out: Direction;
    sub(out.p3.float32s.data, a.p3.float32s.data, b.p3.float32s.data);
    return out;
}
operator * :: (a: Direction, s: float) -> Direction #symmetric {
    out: Direction;
    mul(out.p3.float32s.data, a.p3.float32s.data, s);
    return out;
}
operator / :: (a: Direction, s: float) -> Direction #symmetric {
    out: Direction;
    div(out.p3.float32s.data, a.p3.float32s.data, s);
    return out;
}
operator - :: (a: Direction) -> Direction {
    out: Direction;
    xor(out.p3.float32s.data, a.p3.float32s.data, NZNZNZNZ.float32s.data);
    return out;
}
/////////////////////////////////////////////////////////// rotor
Euler_Angles :: struct {
    roll: float;
    pitch: float;
    yaw: float;
}

Rotor :: struct {
    p1: Vec128(float32);
    make :: (ang_rad: float, x: float, y: float, z: float) -> Rotor {
        norm := sqrt(x*x + y*y + z*z);
        inv_norm := 1.0 / norm;
        half := 0.5 * ang_rad;
        // Rely on compiler to coalesce these two assignments into a single
        // sincos call at instruction selection time
        sin_ang := sin(half);
        scale := sin_ang * inv_norm;
        out: Rotor;
        out.p1 = vec128(float.[cos(half), x, y, z]);
        vscale := vec128(float.[1.0, scale, scale, scale]);
        mul(out.p1.float32s.data, out.p1.float32s.data, vscale.float32s.data);
        return out;
    }
    make :: (q: Quaternion) -> Rotor {
        out: Rotor;
        out.p1 = vec128(float.[
            q.w, -q.x, -q.y, -q.z, 
        ]);
        normalize(*out);
        return out;
    }
    make :: (ea: Euler_Angles) -> Rotor {
        // half_yaw   := ea.yaw * 0.5;
        // half_pitch := ea.pitch * 0.5;
        // half_roll  := ea.roll * 0.5;
        // cos_y      := cos(half_yaw);
        // sin_y      := sin(half_yaw);
        // cos_p      := cos(half_pitch);
        // sin_p      := sin(half_pitch);
        // cos_r      := cos(half_roll);
        // sin_r      := sin(half_roll);
        // out: Rotor;
        // out.p1 = vec128(SET_PS(
        //     cos_r * cos_p * sin_y - sin_r * sin_p * cos_y,
        //     cos_r * sin_p * cos_y + sin_r * cos_p * sin_y,
        //     sin_r * cos_p * cos_y - cos_r * sin_p * sin_y,
        //     cos_r * cos_p * cos_y + sin_r * sin_p * sin_y, 
        // ));
        // normalize(*out);

        q_h: Quaternion;
        set_from_axis_and_angle(*q_h, 0, 1, 0, ea.yaw);
        q_p: Quaternion;
        set_from_axis_and_angle(*q_p, 1, 0, 0, ea.pitch);
        q_b: Quaternion;
        set_from_axis_and_angle(*q_b, 0, 0, 1, ea.roll);
        return Rotor.make(q_h * q_p * q_b);
    }
}

load_normalized :: (a: *Rotor, d: *float) {
    memcpy(a.p1.float32s.data, d, size_of(float32) * 4);
}

normalize :: (a: *Rotor) {
    inv_norm := rsqrt_nr1(dp_bc(a.p1, a.p1));
    mul(a.p1.float32s.data, a.p1.float32s.data, inv_norm.float32s.data);
}
invert :: (a: *Rotor) {
    inv_norm := rsqrt_nr1(hi_dp_bc(a.p1, a.p1));
    mul(a.p1.float32s.data, a.p1.float32s.data, inv_norm.float32s.data);
    mul(a.p1.float32s.data, a.p1.float32s.data, inv_norm.float32s.data);
    xor(a.p1.float32s.data, ZNZNZNZ.float32s.data, a.p1.float32s.data);
}
constrain :: (a: *Rotor) {
    p1_ptr := a.p1.float32s.data;
    nzzzz_ptr := NZZZZ.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x vp1:, [p1_ptr];
        movdqu.x vnzzzz:, [nzzzz_ptr];
        andps.x tmp1:, vp1, vnzzzz;
        shufps.x mask:, tmp1, tmp1, s0000;
        xorps.x vp1, mask, vp1;

        movdqu.x [p1_ptr], vp1;
    }
}

normalized :: (a: Rotor) -> Rotor {
    out: Rotor;
    memcpy(*out, *a, size_of(Rotor));
    normalize(*out);
    return out;
}
inverse :: (a: Rotor) -> Rotor {
    out: Rotor;
    memcpy(*out, *a, size_of(Rotor));
    invert(*out);
    return out;
}
constrained :: (a: Rotor) -> Rotor {
    out: Rotor;
    memcpy(*out, *a, size_of(Rotor));
    constrain(*out);
    return out;
}
operator == :: (a: Rotor, b: Rotor) -> bool {
    ap1 := a.p1.float32s.data;
    bp1 := b.p1.float32s.data;
    mask: u32 = 0; mask_ptr := *mask;
    #asm AVX, AVX2 {
        movdqu.x vap1:, [ap1];
        movdqu.x vbp1:, [bp1];
        cmpps.x eq:, vap1, vbp1, 0;
        movmskps.x eq_mask:, eq;
        mov [mask_ptr], eq_mask;
    }
    return mask == 0b1111;
}
approx_eq :: (a: Rotor, b: Rotor, epsilon: float) -> bool {
    return approx_eq(a.p1.float32s.data, b.p1.float32s.data, epsilon);
}

matrix3x4 :: (a: Rotor) -> Matrix4 {
    arr : [4]Vec128(float32);
    mat4x4_12(a.p1, null, arr.data, translate=false, normalized=true);
    col0 := arr[0];
    col1 := arr[1];
    col2 := arr[2];
    col3 := arr[3];

    tmp := Matrix4.{
        _11=arr[0].float32s[0], _12=arr[1].float32s[0], _13=arr[2].float32s[0], _14=arr[3].float32s[0], 
        _21=arr[0].float32s[1], _22=arr[1].float32s[1], _23=arr[2].float32s[1], _24=arr[3].float32s[1], 
        _31=arr[0].float32s[2], _32=arr[1].float32s[2], _33=arr[2].float32s[2], _34=arr[3].float32s[2], 
        _41=arr[0].float32s[3], _42=arr[1].float32s[3], _43=arr[2].float32s[3], _44=arr[3].float32s[3], 
    };
    return tmp;
}

matrix4x4 :: (a: Rotor) -> Matrix4 {
    arr : [4]Vec128(float32);
    mat4x4_12(a.p1, null, arr.data, translate=false, normalized=false);

    col0 := arr[0];
    col1 := arr[1];
    col2 := arr[2];
    col3 := arr[3];

    tmp := Matrix4.{
        _11=col0.float32s[0], _12=col1.float32s[0], _13=col2.float32s[0], _14=col3.float32s[0], 
        _21=col0.float32s[1], _22=col1.float32s[1], _23=col2.float32s[1], _24=col3.float32s[1], 
        _31=col0.float32s[2], _32=col1.float32s[2], _33=col2.float32s[2], _34=col3.float32s[2], 
        _41=col0.float32s[2], _42=col1.float32s[3], _43=col2.float32s[3], _44=col3.float32s[3], 
    };
    return tmp;
}

nlerp :: (a: Rotor, b: Rotor, t: float) -> Rotor {
    return ((1 - t) * a + t * b);
}

slerp :: (a: Rotor, b: Rotor, t: float) -> Rotor {
    if t == 0.0 return a;
    if t == 1.0 return b;
    if a == b return a;
    rotor_step := log(b * ~(a));
    // exp(log(m)) = exp(t*log(m) + (1 - t)*log(m))
    // = exp(t*(log(m))) * exp((1 - t)*log(m))
    rotor_step *= t;
    return exp(rotor_step) * a;
}

FloatInt64 :: union {
    _u64:     u64;
    _s64:     s64;
    _float64: float64;
}

signbit :: inline (x: float64) -> u64 {
    value: FloatInt64 = ---;
    value._float64 = x;
    return value._u64 & 0x8000_0000_0000_0000;
}

euler_angles :: (a: Rotor) -> Euler_Angles {
    ea: Euler_Angles;
    buf := float.[a.p1.float32s[0], a.p1.float32s[1], a.p1.float32s[2], a.p1.float32s[3]];
    test := buf[1] * buf[2] + buf[3] * buf[0];

    if (test > 0.4999) {
        ea.roll  = 2.0 * atan2(buf[1], buf[0]);
        ea.pitch = PI / 2;;
        ea.yaw   = 0.0;
        return ea;
    } else if (test < -0.4999) {
        ea.roll  = -2.0 * atan2(buf[1], buf[0]);
        ea.pitch = -PI / 2;
        ea.yaw   = 0.0;
        return ea;
    }

    buf1_2 := buf[1] * buf[1];
    buf2_2 := buf[2] * buf[2];
    buf3_2 := buf[3] * buf[3];

    ea.roll = atan2(2 * (buf[0] * buf[1] + buf[2] * buf[3]), 1 - 2 * (buf1_2 + buf2_2));

    sinp := 2 * (buf[0] * buf[2] - buf[1] * buf[3]);
    if (abs(sinp) > 1) {
        sb := signbit(cast(float64)sinp);
        ea.pitch = ifx signbit(sinp) == 1 then -PI / 2 else PI / 2;
    } else {
        ea.pitch = asin(sinp);
    }
    ea.yaw = atan2(2 * (buf[0] * buf[3] + buf[1] * buf[2]), 1 - 2 * (buf2_2 + buf3_2));
    return ea;
}

conjugate :: (r: Rotor, p: Plane) -> Plane {
    out: Plane;
    sw012(*p.p0, r.p1, null, *out.p0, count=0, variadic=false, translate=false);
    return out;
}
// TODO list of planes
conjugate :: (r: Rotor, ps: *Plane, outps: *Plane, count:s32) {
    sw012(*ps.p0, r.p1, null, *outps.p0, count=count, variadic=true, translate=false);
}
conjugate :: (r: Rotor, b: Branch) -> Branch {
    out: Branch;
    swMM(*b.p1, r.p1, null, *out.p1, count=0, variadic=false, translate=false, inputp2=false);
    return out;
}
conjugate :: (r: Rotor, l: Line) -> Line {
    out: Line;
    swMM(*l.p1, r.p1, null, *out.p1, count=0, variadic=false, translate=false, inputp2=true);
    return out;
}
conjugate :: (r: Rotor, ls: *Line, outls: *Line, count:s32) -> Line {
    out: Line;
    swMM(*ls.p1, r.p1, null, *outls.p1, count=count, variadic=true, translate=false, inputp2=true);
    return out;
}
conjugate :: (r: Rotor, p: Point) -> Point {
    out: Point;
    sw012(*p.p3, r.p1, null, *out.p3, count=0, variadic=false, translate=false);
    return out;
}
conjugate :: (r: Rotor, ps: *Point, outps: *Point, count:s32) {
    sw012(*ps.p3, r.p1, null, *outps.p3, count=count, variadic=true, translate=false);
}
conjugate :: (r: Rotor, d: Direction) -> Direction {
    out: Direction;
    sw012(*d.p3, r.p1, null, *out.p3, count=0, variadic=false, translate=false);
    return out;
}
conjugate :: (r: Rotor, ds: *Direction, outds: *Direction, count:s32) {
    sw012(*ds.p3, r.p1, null, *outds.p3, count=count, variadic=true, translate=false);
}

operator += :: (a: *Rotor, b: Rotor) {
    add(a.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
}
operator -= :: (a: *Rotor, b: Rotor) {
    sub(a.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
}
operator *= :: (a: *Rotor, s: float) {
    mul(a.p1.float32s.data, a.p1.float32s.data, s);
}
operator /= :: (a: *Rotor, s: float) {
    div(a.p1.float32s.data, a.p1.float32s.data, s);
}
operator + :: (a: Rotor, b: Rotor) -> Rotor {
    out: Rotor;
    add(out.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
    return out;
}
operator - :: (a: Rotor, b: Rotor) -> Rotor {
    out: Rotor;
    sub(out.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
    return out;
}
operator * :: (a: Rotor, s: float) -> Rotor #symmetric {
    out: Rotor;
    mul(out.p1.float32s.data, a.p1.float32s.data, s);
    return out;
}
operator / :: (a: Rotor, s: float) -> Rotor #symmetric {
    out: Rotor;
    div(out.p1.float32s.data, a.p1.float32s.data, s);
    return out;
}
operator - :: (a: Rotor) -> Rotor {
    out: Rotor;
    xor(out.p1.float32s.data, a.p1.float32s.data, NZNZNZNZ.float32s.data);
    return out;
}
operator ~ :: (a: Rotor) -> Rotor {
    out: Rotor;
    xor(out.p1.float32s.data, a.p1.float32s.data, ZNZNZNZ.float32s.data);
    return out;
}

//////////////////////////////////////////////////////////// motor
Motor :: struct {
    p1: Vec128(float32);
    p2: Vec128(float32);
    make :: (a: float, b: float, c: float, d: float, e: float, f: float, g: float, h: float) -> Motor {
        out: Motor;
        out.p1 = vec128(SET_PS(d, c, b, a));
        out.p2 = vec128(SET_PS(g, f, e, h));
        return out;
    }
    make :: (ang_rad: float, d: float, l: Line) -> Motor {
        log_m: Line;
        gpDL(-ang_rad * 0.5, d * 0.5, l.p1, l.p2, *log_m.p1, *log_m.p2);
        out: Motor;
        exp(log_m.p1, log_m.p2, *out.p1, *out.p2);
        return out;
    }
    make :: (r: Rotor) -> Motor {
        out: Motor;
        memcpy(*out.p1.float32s.data, r.p1.float32s.data, size_of(float32)*4);
        memcpy(*out.p2.float32s.data, ZZZZ.float32s.data, size_of(float32)*4);
        return out;
    }
    make :: (t: Translator) -> Motor {
        out: Motor;
        memcpy(out.p1.float32s.data, UZZZ.float32s.data, size_of(float32)*4);
        memcpy(out.p2.float32s.data, t.p2.float32s.data, size_of(float32)*4);
        return out;
    }
}
normalize :: (a: *Motor) {
    b2 := dp_bc(a.p1, a.p1);
    s  := rsqrt_nr1(b2);
    xorp1: Vec128(float32);
    xor(xorp1.float32s.data, a.p1.float32s.data, NZZZZ.float32s.data);
    bc := dp_bc(xorp1, a.p2);
    inv_b2 := rcp_nr1(b2);

    s_ptr := s.float32s.data;
    bc_ptr := bc.float32s.data;
    inv_b2_ptr := inv_b2.float32s.data;

    p1_ptr := a.p1.float32s.data;
    p2_ptr := a.p2.float32s.data;

    nzzzz_ptr := NZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vp1:, [p1_ptr];
        movdqu.x vp2:, [p2_ptr];
        movdqu.x vs:, [s_ptr];
        movdqu.x vbc:, [bc_ptr];
        movdqu.x vinv_b2:, [inv_b2_ptr];
        movdqu.x vnzzzz:, [nzzzz_ptr];
        // __m128 t  = _mm_mul_ps(_mm_mul_ps(bc, detail::rcp_nr1(b2)), s);
        mulps.x tmpx1:, vbc, vinv_b2;
        mulps.x t:, tmpx1, vs;
        // __m128 tmp = _mm_mul_ps(p2_, s);
        mulps.x tmp:, vp2, vs;
        // p2_ = _mm_sub_ps(tmp, _mm_xor_ps(_mm_mul_ps(p1_, t), _mm_set_ss(-0.f)));
        mulps.x tmpx1, vp1, t;
        xorps.x tmpx1, tmpx1, vnzzzz;
        subps.x vp2, tmp, tmpx1;
        // p1_        = _mm_mul_ps(p1_, s);
        mulps.x vp1, vp1, vs;

        movdqu.x [p1_ptr], vp1;
        movdqu.x [p2_ptr], vp2;
    }
}
invert :: (a: *Motor) {
    b2 := dp_bc(a.p1, a.p1);
    s  := rsqrt_nr1(b2);
    xorp1: Vec128(float32);
    xor(xorp1.float32s.data, a.p1.float32s.data, NZZZZ.float32s.data);
    bc := dp_bc(xorp1, a.p2);
    inv_b2 := rcp_nr1(b2);

    s_ptr := s.float32s.data;
    bc_ptr := bc.float32s.data;
    inv_b2_ptr := inv_b2.float32s.data;
    p1_ptr := a.p1.float32s.data;
    p2_ptr := a.p2.float32s.data;
    nzzzz_ptr := NZZZZ.float32s.data;
    znznznz_ptr := ZNZNZNZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vp1:, [p1_ptr];
        movdqu.x vp2:, [p2_ptr];
        movdqu.x vs:, [s_ptr];
        movdqu.x vbc:, [bc_ptr];
        movdqu.x vinv_b2:, [inv_b2_ptr];
        movdqu.x vnzzzz:, [nzzzz_ptr];
        movdqu.x vznznznz:, [znznznz_ptr];

        // __m128 t      = _mm_mul_ps(_mm_mul_ps(bc, b2_inv), s);
        mulps.x tmpx1:, vbc, vinv_b2;
        mulps.x t:, tmpx1, vs;
        // __m128 st = _mm_mul_ps(s, t);
        mulps.x st:, vs, t;
        // st        = _mm_mul_ps(p1_, st);
        mulps.x st, vp1, st;
        // p2_       = _mm_sub_ps(_mm_mul_ps(p2_, b2_inv),
        //                  _mm_xor_ps(_mm_add_ps(st, st), _mm_set_ss(-0.f)));
        addps.x tmpx1, st, st;
        xorps.x tmpx1, tmpx1, vnzzzz;
        mulps.x tmpx2:, vp2, vinv_b2;
        subps.x vp2, tmpx2, tmpx1;
        // p2_       = _mm_xor_ps(p2_, neg);
        xorps.x vp2, vp2, vznznznz;
        // p1_ = _mm_xor_ps(_mm_mul_ps(p1_, b2_inv), neg);
        mulps.x tmpx1, vp1, vinv_b2;
        xorps.x vp1, tmpx1, vznznznz;

        movdqu.x [p1_ptr], vp1;
        movdqu.x [p2_ptr], vp2;
    }
}
constrain :: (a: *Motor) {
    p1_ptr := a.p1.float32s.data;
    p2_ptr := a.p2.float32s.data;
    nzzzz_ptr := NZZZZ.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x vp1:, [p1_ptr];
        movdqu.x vp2:, [p2_ptr];
        movdqu.x vnzzzz:, [nzzzz_ptr];

        andps.x tmp1:, vp1, vnzzzz;
        shufps.x mask:, tmp1, tmp1, s0000;
        xorps.x vp1, mask, vp1;
        xorps.x vp2, mask, vp2;

        movdqu.x [p1_ptr], vp1;
        movdqu.x [p2_ptr], vp2;
    }
}
normalized :: (a: Motor) -> Motor {
    out: Motor;
    memcpy(*out, *a, size_of(Motor));
    normalize(*out);
    return out;
}
inverse :: (a: Motor) -> Motor {
    out: Motor;
    memcpy(*out, *a, size_of(Motor));
    invert(*out);
    return out;
}
constrained :: (a: Motor) -> Motor {
    out: Motor;
    memcpy(*out, *a, size_of(Motor));
    constrain(*out);
    return out;
}
operator == :: (a: Motor, b: Motor) -> bool {
    eqp1 := eq(a.p1.float32s.data, b.p1.float32s.data);
    eqp2 := eq(a.p2.float32s.data, b.p2.float32s.data);
    return eqp1 && eqp2;
}
approx_eq :: (a: Motor, b: Motor, epsilon: float) -> bool {
    ap1 := approx_eq(a.p1.float32s.data, b.p1.float32s.data, epsilon);
    ap2 :=  approx_eq(a.p2.float32s.data, b.p2.float32s.data, epsilon);
    return ap1 && ap2;
}
matrix3x4 :: (a: Motor) -> Matrix4 {
    arr : [4]Vec128(float32);
    mat4x4_12(a.p1, *a.p2, arr.data, translate=true, normalized=true);

    tmp := Matrix4.{
        _11=arr[0].float32s[0], _12=arr[1].float32s[0], _13=arr[2].float32s[0], _14=arr[3].float32s[0], 
        _21=arr[0].float32s[1], _22=arr[1].float32s[1], _23=arr[2].float32s[1], _24=arr[3].float32s[1], 
        _31=arr[0].float32s[2], _32=arr[1].float32s[2], _33=arr[2].float32s[2], _34=arr[3].float32s[2], 
        _41=arr[0].float32s[3], _42=arr[1].float32s[3], _43=arr[2].float32s[3], _44=arr[3].float32s[3], 
    };
    return tmp;
}
matrix4x4 :: (a: Motor) -> Matrix4 {
    arr : [4]Vec128(float32);
    mat4x4_12(a.p1, *a.p2, arr.data, translate=true, normalized=false);

    col0 := arr[0];
    col1 := arr[1];
    col2 := arr[2];
    col3 := arr[3];

    tmp := Matrix4.{
        _11=col0.float32s[0], _12=col1.float32s[0], _13=col2.float32s[0], _14=col3.float32s[0], 
        _21=col0.float32s[1], _22=col1.float32s[1], _23=col2.float32s[1], _24=col3.float32s[1], 
        _31=col0.float32s[2], _32=col1.float32s[2], _33=col2.float32s[2], _34=col3.float32s[2], 
        _41=col0.float32s[3], _42=col1.float32s[3], _43=col2.float32s[3], _44=col3.float32s[3], 
    };
    return tmp;
}

nlerp :: (a: Motor, b: Motor, t: float) -> Motor {
    return ((1 - t) * a + t * b);
}

slerp :: (a: Motor, b: Motor, t: float) -> Motor {
    if t == 0.0 return a;
    if t == 1.0 return b;
    if a == b return a;
    motor_step := log(b * ~(a));
    // exp(log(m)) = exp(t*log(m) + (1 - t)*log(m))
    // = exp(t*(log(m))) * exp((1 - t)*log(m))
    motor_step *= t;
    return exp(motor_step) * a;
}

apply_matrix_to_point :: (m: Matrix4, p: Vec128(float32)) -> Point {
    col0 := column(m, 0);
    col1 := column(m, 1);
    col2 := column(m, 2);
    col3 := column(m, 3);

    col0_ptr := col0.component.data;
    col1_ptr := col1.component.data;
    col2_ptr := col2.component.data;
    col3_ptr := col3.component.data;
    xyzw := p.float32s.data;
    out: Point;
    out_ptr := out.p3.float32s.data;
    #asm AVX, AVX2 {
        movdqu.x vcol0:, [col0_ptr];
        movdqu.x vcol1:, [col1_ptr];
        movdqu.x vcol2:, [col2_ptr];
        movdqu.x vcol3:, [col3_ptr];
        movdqu.x vxyzw:, [xyzw];

        // __m128 out = _mm_mul_ps(cols[0], KLN_SWIZZLE(xyzw, 0, 0, 0, 0));
        shufps.x vxyzw_0000:, vxyzw, vxyzw, s0000;
        mulps.x vout:, vcol0, vxyzw_0000;
        // vout = _mm_add_ps(vout, _mm_mul_ps(cols[1], KLN_SWIZZLE(xyzw, 1, 1, 1, 1)));
        shufps.x vxyzw_1111:, vxyzw, vxyzw, s1111;
        mulps.x tmpx1:, vcol1, vxyzw_1111;
        addps.x vout, vout, tmpx1;
        // vout = _mm_add_ps(vout, _mm_mul_ps(cols[2], KLN_SWIZZLE(xyzw, 2, 2, 2, 2)));
        shufps.x vxyzw_2222:, vxyzw, vxyzw, s2222;
        mulps.x tmpx1, vcol2, vxyzw_2222;
        addps.x vout, vout, tmpx1;
        // vout = _mm_add_ps(vout, _mm_mul_ps(cols[3], KLN_SWIZZLE(xyzw, 3, 3, 3, 3)));
        shufps.x vxyzw_3333:, vxyzw, vxyzw, s3333;
        mulps.x tmpx1, vcol3, vxyzw_3333;
        addps.x vout, vout, tmpx1;
        movdqu.x [out_ptr], vout;
    }
    return out;
}

conjugate :: (r: Motor, p: Plane) -> Plane {
    out: Plane;
    sw012(*p.p0, r.p1, *r.p2, *out.p0, count=0, variadic=false, translate=true);
    return out;
}
// TODO list of planes
conjugate :: (r: Motor, ps: *Plane, outps: *Plane, count:s32) {
    sw012(*ps.p0, r.p1, *r.p2, *outps.p0, count=count, variadic=true, translate=true);
}
conjugate :: (r: Motor, l: Line) -> Line {
    out: Line;
    swMM(*l.p1, r.p1, *r.p2, *out.p1, count=0, variadic=false, translate=true, inputp2=true);
    return out;
}
conjugate :: (r: Motor, ls: *Line, outls: *Line, count:s32) -> Line {
    out: Line;
    swMM(*ls.p1, r.p1, *r.p2, *outls.p1, count=count, variadic=true, translate=true, inputp2=true);
    return out;
}
conjugate :: (r: Motor, p: Point) -> Point {
    out: Point;
    sw312(*p.p3, r.p1, *r.p2, *out.p3, count=0, variadic=false, translate=true);
    return out;
}
conjugate :: (r: Motor, ps: *Point, outps: *Point, count:s32) -> Point {
    out: Point;
    sw312(*ps.p3, r.p1, *r.p2, *outps.p3, count=count, variadic=true, translate=true);
    return out;
}
conjugate_origin :: (r: Motor) -> Point {
    out: Point;
    out.p3 = swo12(r.p1, r.p2);
    return out;
}
conjugate :: (r: Motor, d: Direction) -> Direction {
    out: Direction;
    sw312(*d.p3, r.p1, *r.p2, *out.p3, count=0, variadic=false, translate=false);
    return out;
}
conjugate :: (r: Motor, ds: *Direction, outds: *Direction, count:s32) {
    sw312(*ds.p3, r.p1, *r.p2, *outds.p3, count=count, variadic=true, translate=false);
}
operator += :: (a: *Motor, b: Motor) {
    add(a.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
    add(a.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
}
operator -= :: (a: *Motor, b: Motor) {
    sub(a.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
    sub(a.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
}
operator *= :: (a: *Motor, s: float) {
    mul(a.p1.float32s.data, a.p1.float32s.data, s);
    mul(a.p2.float32s.data, a.p2.float32s.data, s);
}
operator /= :: (a: *Motor, s: float) {
    div(a.p1.float32s.data, a.p1.float32s.data, s);
    div(a.p2.float32s.data, a.p2.float32s.data, s);
}
operator + :: (a: Motor, b: Motor) -> Motor {
    out: Motor;
    add(out.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
    add(out.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
    return out;
}
operator - :: (a: Motor, b: Motor) -> Motor {
    out: Motor;
    sub(out.p1.float32s.data, a.p1.float32s.data, b.p1.float32s.data);
    sub(out.p2.float32s.data, a.p2.float32s.data, b.p2.float32s.data);
    return out;
}
operator * :: (a: Motor, s: float) -> Motor #symmetric {
    out: Motor;
    mul(out.p1.float32s.data, a.p1.float32s.data, s);
    mul(out.p2.float32s.data, a.p2.float32s.data, s);
    return out;
}
operator / :: (a: Motor, s: float) -> Motor #symmetric {
    out: Motor;
    div(out.p1.float32s.data, a.p1.float32s.data, s);
    div(out.p2.float32s.data, a.p2.float32s.data, s);
    return out;
}
operator - :: (a: Motor) -> Motor {
    out: Motor;
    xor(out.p1.float32s.data, a.p1.float32s.data, NZNZNZNZ.float32s.data);
    xor(out.p2.float32s.data, a.p2.float32s.data, NZNZNZNZ.float32s.data);
    return out;
}
operator ~ :: (a: Motor) -> Motor {
    out: Motor;
    xor(out.p1.float32s.data, a.p1.float32s.data, ZNZNZNZ.float32s.data);
    xor(out.p2.float32s.data, a.p2.float32s.data, ZNZNZNZ.float32s.data);
    return out;
}
//////////////////////////////////////////////////OPERATIONS exp-log
log :: (m: Motor) -> Line {
    out: Line;
    log(m.p1, m.p2, *out.p1, *out.p2);
    return out;
}
exp :: (l: Line) -> Motor {
    out: Motor;
    exp(l.p1, l.p2, *out.p1, *out.p2);
    return out;
}
log :: (t: Translator) -> Ideal_Line {
    out: Ideal_Line;
    memcpy(*out.p2.float32s.data, t.p2.float32s.data, size_of(float)*4);
    return out;
}
exp :: (il: Ideal_Line) -> Translator {
    out: Translator;
    memcpy(*out.p2.float32s.data, il.p2.float32s.data, size_of(float32)*4);
    return out;
}
log :: (r: Rotor) -> Branch {
    cos_ang := r.p1.float32s[0];
    ang := acos(cos_ang);
    ang_v := vec128(float.[ang, ang, ang, ang]);
    ang_v_ptr := ang_v.float32s.data;
    sin_ang := sin(ang);
    sin_ang_v := vec128(float.[sin_ang, sin_ang, sin_ang, sin_ang]);
    sin_ang_v_ptr := sin_ang_v.float32s.data;

    inv_sin_ang_v := rcp_nr1(sin_ang_v);
    inv_sin_ang_v_ptr := inv_sin_ang_v.float32s.data;

    rp1ptr := r.p1.float32s.data;

    out: Branch;
    p1ptr := out.p1.float32s.data;

    zzzz_ptr := ZZZZ.float32s.data;

    #asm AVX, AVX2 {
        movdqu.x vang:, [ang_v_ptr];
        movdqu.x vsin_ang:, [sin_ang_v_ptr];
        movdqu.x vinv_sin_ang:, [inv_sin_ang_v_ptr];
        movdqu.x vrp1:, [rp1ptr];
        movdqu.x vzzzz:, [zzzz_ptr];

        // out.p1_ = _mm_mul_ps(r.p1_, detail::rcp_nr1(_mm_set1_ps(sin_ang)));
        mulps.x vp1:, vrp1, vinv_sin_ang;
        // out.p1_ = _mm_mul_ps(out.p1_, _mm_set1_ps(ang));
        mulps.x vp1, vp1, vang;
        // out.p1_ = _mm_blend_ps(out.p1_, _mm_setzero_ps(), 1);
        blendps.x vp1, vp1, vzzzz, 1;

        movdqu.x [p1ptr], vp1;
    }
    return out;
}

exp :: (b: Branch) -> Rotor {
    ang := sqrt_nr1(hi_dp(b.p1, b.p1)).float32s[0];
    cos_ang := cos(ang);
    sin_ang := sin(ang) / ang;
    
    sin_angv := vec128(float.[sin_ang, sin_ang, sin_ang, sin_ang]);
    cos_angv := vec128(float.[cos_ang, 0.0, 0.0, 0.0]);

    out: Rotor;
    mul(out.p1.float32s.data, sin_angv.float32s.data, b.p1.float32s.data);
    add(out.p1.float32s.data, out.p1.float32s.data, cos_angv.float32s.data);
    return out;
}

sqrt :: (r: Rotor) -> Rotor {
    out: Rotor;
    add(out.p1.float32s.data, r.p1.float32s.data, UZZZ.float32s.data);
    normalize(*out);
    return out;
}
sqrt :: (b: Branch) -> Rotor {
    out: Rotor;
    add(out.p1.float32s.data, b.p1.float32s.data, UZZZ.float32s.data);
    normalize(*out);
    return out;
}
sqrt :: (t: Translator) -> Translator {
    out: Translator;
    memcpy(*out, *t, size_of(Translator));
    out *= 0.5;
    return out;
}
sqrt :: (m: Motor) -> Motor {
    out: Motor;
    memcpy(*out, *m, size_of(Motor));
    out.p1.float32s[0] += 1.0;
    normalize(*out);
    return out;
}
///////////////////////////////////// OPERATION GEOMETRIC
operator * :: (a: Plane, b: Plane) -> Motor {
    out: Motor;
    gp00(a.p0, b.p0, *out.p1, *out.p2);
    return out;
}

operator * :: (a: Plane, b: Point) -> Motor {
    out: Motor;
    gp03(a.p0, b.p3, *out.p1, *out.p2);
    return out;
}

operator * :: (b: Point, a: Plane) -> Motor {
    out: Motor;
    gp03_flip(a.p0, b.p3, *out.p1, *out.p2);
    return out;
}

operator * :: (a: Branch, b: Branch) -> Rotor {
    out: Rotor;
    gp11(a.p1, b.p1, *out.p1);
    return out;
}
operator * :: (a: Line, b: Line) -> Motor {
    out: Motor;
    arr: [2]*Vec128(float32);
    arr[0] = *out.p1;
    arr[1] = *out.p2;
    gpLL(a.p1, a.p2, b.p1, b.p2, arr);
    return out;
}

operator * :: (a: Point, b: Point) -> Translator {
    out: Translator;
    gp33(a.p3, b.p3, *out.p2);
    return out;
}
operator * :: (a: Rotor, b: Rotor) -> Rotor {
    out: Rotor;
    gp11(a.p1, b.p1, *out.p1);
    return out;
}
operator * :: (a: Dual, b: Line) -> Line #symmetric {
    out: Line;
    gpDL(a.p, a.q, b.p1, b.p2, *out.p1, *out.p2);
    return out;
}

operator * :: (a: Rotor, b: Translator) -> Motor {
    out: Motor;
    memcpy(*out.p1, *a.p1, size_of(Vec128(float32)));
    gpRT(a.p1, b.p2, *out.p2);
    return out;
}

operator * :: (b: Translator, a: Rotor) -> Motor {
    out: Motor;
    memcpy(*out.p1, *a.p1, size_of(Vec128(float32)));
    gpRT_flip(a.p1, b.p2, *out.p2);
    return out;
}
operator * :: (a: Translator, b: Translator) -> Translator {
    return a + b;
}
operator * :: (a: Rotor, b: Motor) -> Motor {
    out: Motor;
    gp11(a.p1, b.p1, *out.p1);
    gp12(a.p1, b.p2, *out.p2);
    return out;
}
operator * :: (b: Motor, a: Rotor) -> Motor {
    out: Motor;
    gp11(b.p1, a.p1, *out.p1);
    gp12_flip(a.p1, b.p2, *out.p2);
    return out;
}
operator * :: (a: Translator, b: Motor) -> Motor {
    out: Motor;
    memcpy(*out.p1, *b.p1, size_of(Vec128(float32)));
    gpRT_flip(b.p1, a.p2, *out.p2);
    add(out.p2.float32s.data, out.p2.float32s.data, b.p2.float32s.data);
    return out;
}

operator * :: (b: Motor, a: Translator) -> Motor {
    out: Motor;
    memcpy(*out.p1, *b.p1, size_of(Vec128(float32)));
    gpRT(b.p1, a.p2, *out.p2);
    add(out.p2.float32s.data, out.p2.float32s.data, b.p2.float32s.data);
    return out;
}

operator * :: (a: Motor, b: Motor) -> Motor {
    out: Motor;
    arr: [2]*Vec128(float32);
    arr[0] = *out.p1;
    arr[1] = *out.p2;
    gpMM(a.p1, a.p2, b.p1, b.p2, arr);
    return out;
}

operator / :: (a: Plane, b: Plane) -> Motor {
    invert(*b);
    return a * b;
}

operator / :: (a: Point, b: Point) -> Translator {
    invert(*b);
    return a * b;
}

operator / :: (a: Branch, b: Branch) -> Rotor {
    invert(*b);
    return a * b;
}

operator / :: (a: Rotor, b:Rotor) -> Rotor {
    invert(*b);
    return a * b;
}

operator / :: (a: Translator, b:Translator) -> Translator {
    invert(*b);
    return a * b;
}

operator / :: (a: Line, b: Line) -> Motor {
    invert(*b);
    return a * b;
}

operator / :: (a: Motor, b: Rotor) -> Motor {
    invert(*b);
    return a * b;
}

operator / :: (a: Motor, b: Translator) -> Motor {
    invert(*b);
    return a * b;
}

operator / :: (a: Motor, b: Motor) -> Motor {
    invert(*b);
    return a * b;
}
////////////////////////////////////////////////////// OPERATIONS INNER
operator | :: (a: Plane, b: Plane) -> float {
    s: Vec128(float32);
    dot00(a.p0, b.p0, *s);
    return s.float32s[0];
}
operator | :: (a: Plane, b: Line) -> Plane {
    out: Plane;
    dotPL(a.p0, b.p1, b.p2, *out.p0);
    return out;
}

operator | :: (b: Line, a: Plane) -> Plane {
    out: Plane;
    dotPL_flip(a.p0, b.p1, b.p2, *out.p0);
    return out;
}
operator | :: (a: Plane, b: Ideal_Line) -> Plane {
    out: Plane;
    dotPIL(a.p0, b.p2, *out.p0);
    return out;
}

operator | :: (b: Ideal_Line, a: Plane) -> Plane {
    out: Plane;
    dotPIL_flip(a.p0, b.p2, *out.p0);
    return out;
}

operator | :: (a: Plane, b: Point) -> Line {
    out: Line;
    dot03(a.p0, b.p3, *out.p1, *out.p2);
    return out;
}

operator | :: (a: Point, b: Plane) -> Line {
    return b | a;
}

operator | :: (a: Line, b: Line) -> float {
    s: Vec128(float32);
    dot11(a.p1, b.p1, *s);
    return s.float32s[0];
}

operator | :: (a: Point, b: Line) -> Plane {
    out: Plane;
    dotPTL(a.p3, b.p1, *out.p0);
    return out;
}

operator | :: (b: Line, a: Point) -> Plane {
    return a | b;
}

operator | :: (a: Point, b: Point) -> float {
    s: Vec128(float32);
    dot33(a.p3, b.p3, *s);
    return s.float32s[0];
}

///////////////////////////////////////////////////////////// OPERATOR join
operator ! :: (in: Plane) -> Point {
    return .{in.p0};
}
operator ! :: (in: Point) -> Plane {
    return .{in.p3};
}
operator ! :: (in: Line) -> Line {
    return .{in.p2, in.p1};
}
operator ! :: (in: Ideal_Line) -> Branch {
    return .{in.p2};
}
operator ! :: (in: Branch) -> Ideal_Line {
    return .{in.p1};
}
operator ! :: (in: Dual) -> Dual {
    return .{in.q, in.p};
}

operator & :: (a: Point, b: Point) -> Line {
    return !((!a) ^ (!b));
}

operator & :: (a: Point, b: Line) -> Plane {
    return !((!a) ^ (!b));
}

operator & :: (b: Line, a: Point) -> Plane {
    return a & b;
}

operator & :: (a: Point, b: Branch) -> Plane {
    return !((!a) ^ (!b));
}

operator & :: (b: Branch, a: Point) -> Plane{
    return a & b;
}

operator & :: (a: Point, b: Ideal_Line) -> Plane{
    return !((!a) ^ (!b));
}

operator & :: (b: Ideal_Line, a: Point) -> Plane{
    return a & b;
}

operator & :: (a: Plane, b: Point) -> Dual {
    return !((!a) ^ (!b));
}

operator & :: (a: Point, b: Plane) -> Dual {
    return !((!a) ^ (!b));
}
////////////////////////////////////////////////////////// OPERATOR meet
operator ^ :: (a: Plane, b: Plane) -> Line {
    out: Line;
    ext00(a.p0, b.p0, *out.p1, *out.p2);
    return out;
}

operator ^ :: (a: Plane, b: Branch) -> Point {
    out: Point;
    extPB(a.p0, b.p1, *out.p3);
    return out;
}

operator ^ :: (b: Branch, a: Plane) -> Point {
    return a ^ b;
}

operator ^ :: (a: Plane, b: Ideal_Line) -> Point {
    out: Point;
    ext02(a.p0, b.p2, *out.p3);
    return out;
}
operator ^ :: (b: Ideal_Line, a: Plane) -> Point {
    return a ^ b;
}

operator ^ :: (a: Plane, b: Line) -> Point {
    out: Point;
    extPB(a.p0, b.p1, *out.p3);
    tmp: Vec128(float32);
    ext02(a.p0, b.p2, *tmp);
    add(out.p3.float32s.data, tmp.float32s.data, out.p3.float32s.data);
    return out;
}

operator ^ :: (b: Line, a: Plane) -> Point {
    return a ^ b;
}
operator ^ :: (a: Plane, b: Point) -> Dual {
    tmp: Vec128(float32);
    ext03(a.p0, b.p3, *tmp);
    out := Dual.{p=0.0};
    out.q = tmp.float32s[0];
    return out;
}

operator ^ :: (b: Point, a: Plane) -> Dual {
    tmp: Vec128(float32);
    ext03_flip(a.p0, b.p3, *tmp);
    out := Dual.{p=0.0};
    out.q = tmp.float32s[0];
    return out;
}
operator ^ :: (a: Branch, b: Ideal_Line) -> Dual {
    dp := hi_dp_ss(a.p1, b.p2);
    return Dual.{0.0, dp.float32s[0]};
}

operator ^ :: (b: Ideal_Line, a: Branch) -> Dual {
    return a ^ b;
}

operator ^ :: (a: Line, b: Line) -> Dual {
    dp := hi_dp_ss(a.p1, b.p2);
    out: [2]float;
    out[0] = dp.float32s[0];
    dp = hi_dp_ss(b.p1, a.p2);
    out[1] = dp.float32s[0];
    return Dual.{p=0.0, q=out[0] + out[1]};
}

operator ^ :: (a: Line, b: Ideal_Line) -> Dual {
    return Branch.{a.p1} ^ b;
}

operator ^ :: (b: Ideal_Line, a: Line) -> Dual {
    return a ^ b;
}

operator ^ :: (a: Line, b: Branch) -> Dual {
    return Ideal_Line.{a.p2} ^ b;
}

operator ^ :: (b: Branch, a: Line) -> Dual {
    return a ^ b;
}

//////////////////////////////////////////////////////////// OPERATOR project
project :: (a: Point, b: Line) -> Point {
    return ((a | b) ^ (b));
}
project :: (a: Point, b: Plane) -> Point {
    return ((a | b) ^ (b));
}
project :: (a: Line, b: Plane) -> Line {
    return ((a | b) ^ (b));
}
project :: (a: Plane, b: Point) -> Plane {
    return ((a | b) | (b));
}
project :: (a: Line, b: Point) -> Line {
    return ((a | b) | (b));
}
project :: (a: Plane, b: Line) -> Plane {
    return ((a | b) | (b));
}
/////////////////////////////////////////////////////////////exrractors

scalar :: (in: $T) -> float
#modify { return (T == Dual || T == Translator || T == Rotor || T == Motor); } {
    #if T == Dual
        return in.p;
    else #if T == Translator
        return 1.0;
    else #if T == Rotor
        return in.p1.float32s[0];
    else #if T == Motor
        return in.p1.float32s[0];
}

x :: (in: $T) -> float
#modify { return (T == Direction || T == Branch || T == Point || T == Plane); } {
    #if T == Direction return in.p3.float32s[1];
    else #if T == Branch return e23(in);
    else #if T == Point return in.p3.float32s[1];
    else #if T == Plane return in.p0.float32s[1];
}
y :: (in: $T) -> float
#modify { return (T == Direction || T == Branch || T == Point || T == Plane); } {
    #if T == Direction return in.p3.float32s[2];
    else #if T == Branch return e31(in);
    else #if T == Point return in.p3.float32s[2];
    else #if T == Plane return in.p0.float32s[2];
}

z :: (in: $T) -> float
#modify { return (T == Direction || T == Branch || T == Point || T == Plane); } {
    #if T == Direction     return in.p3.float32s[3];
    else #if T == Branch   return e12(in);
    else #if T == Point   return in.p3.float32s[3];
    else #if T == Plane   return in.p0.float32s[3];
}

d :: (in: $T) -> float
#modify { return (T == Plane); } {
    return in.p0.float32s[0];
}

w :: (in: $T) -> float
#modify { return (T == Point); } {
    return in.p3.float32s[0];
}

e0 :: (in: $T) -> float
#modify { return (T == Plane); } {
    #if T == Plane return in.p0.float32s[0];
}
e1 :: (in: $T) -> float
#modify { return (T == Plane); } {
    #if T == Plane return in.p0.float32s[1];
}
e2 :: (in: $T) -> float
#modify { return (T == Plane); } {
    #if T == Plane return in.p0.float32s[2];
}
e3 :: (in: $T) -> float
#modify { return (T == Plane); } {
    #if T == Plane return in.p0.float32s[3];
}

e01 :: (in: $T) -> float
#modify { return (T == Ideal_Line || T == Line || T == Translator || T == Motor); } {
    #if T == Ideal_Line return in.p2.float32s[1];
    else #if T == Line return in.p2.float32s[1];
    else #if T == Translator return in.p2.float32s[1];
    else #if T == Motor return in.p2.float32s[1];
}
e02 :: (in: $T) -> float
#modify { return (T == Ideal_Line || T == Line || T == Translator || T == Motor); } {
    #if T == Ideal_Line return in.p2.float32s[2];
    else #if T == Line return in.p2.float32s[2];
    else #if T == Translator return in.p2.float32s[2];
    else #if T == Motor return in.p2.float32s[2];
}
e03 :: (in: $T) -> float
#modify { return (T == Ideal_Line || T == Line || T == Translator || T == Motor); } {
    #if T == Ideal_Line return in.p2.float32s[3];
    else #if T == Line return in.p2.float32s[3];
    else #if T == Translator return in.p2.float32s[3];
    else #if T == Motor return in.p2.float32s[3];
}

e10 :: (in: $T) -> float
#modify { return (T == Ideal_Line || T == Line || T == Translator || T == Motor); } {
    return -e01(in);
}

e12 :: (in: $T) -> float
#modify { return (T == Branch || T == Line || T == Rotor || T == Motor); } {
    return in.p1.float32s[3];
}

e13 :: (in: $T) -> float
#modify { return (T == Branch || T == Line || T == Rotor || T == Motor); } {
    return -e31(in);
}

e20 :: (in: $T) -> float
#modify { return (T == Ideal_Line || T == Line || T == Translator || T == Motor); } {
    return -e02(in);
}

e21 :: (in: $T) -> float
#modify { return (T == Branch || T == Line || T == Rotor || T == Motor); } {
    return -e12(in);
}

e23 :: (in: $T) -> float
#modify { return (T == Branch || T == Line || T == Rotor || T == Motor); } {
    return in.p1.float32s[1];
}

e30 :: (in: $T) -> float
#modify { return (T == Ideal_Line || T == Line || T == Translator || T == Motor); } {
    return -e03(in);
}

e31 :: (in: $T) -> float
#modify { return (T == Branch || T == Line || T == Rotor || T == Motor); } {
    return in.p1.float32s[2];
}

e32 :: (in: $T) -> float
#modify { return (T == Branch || T == Line || T == Rotor || T == Motor); } {
    return -e23(in);
}

e032 :: (in: $T) -> float
#modify { return (T == Point); } {
    return x(in);
}
e013 :: (in: $T) -> float
#modify { return (T == Point); } {
    return y(in);
}
e021 :: (in: $T) -> float
#modify { return (T == Point); } {
    return z(in);
}
e123 :: (in: $T) -> float
#modify { return (T == Point); } {
    return w(in);
}

e0123 :: (in: $T) -> float
#modify { return (T == Dual || T == Motor); } {
    #if T == Dual return in.q;
    else #if T == Motor  return in.p2.float32s[0];
}

///////////////////////////////////////////////////////////// DEBUG
print_vec128_to_builder :: (sb: *String_Builder, n: string, v: Vec128(float32)) {
    arr := v.float32s;
    print_to_builder(sb, "%", n);
    print_to_builder(sb, "[% % % %]", 
        formatFloat(arr[0], width=10), 
        formatFloat(arr[1], width=10), 
        formatFloat(arr[2], width=10), 
        formatFloat(arr[3], width=10), 
    );
}
stringify :: (in: $T) -> string {
    sb: String_Builder;
    #if T == Vec128(float32) {
        print_vec128_to_builder(*sb, "", in);
        return builder_to_string(*sb);
    } else #if T == Plane {
        print_vec128_to_builder(*sb, "p0", in.p0);
        return builder_to_string(*sb);
    } else #if T == Point {
        print_vec128_to_builder(*sb, "p3", in.p3);
        return builder_to_string(*sb);
    } else #if T == Branch {
        print_vec128_to_builder(*sb, "p1", in.p1);
        return builder_to_string(*sb);
    } else #if T == Ideal_Line {
        print_vec128_to_builder(*sb, "p2", in.p2);
        return builder_to_string(*sb);
    } else #if T == Line {
        print_vec128_to_builder(*sb, "p1", in.p1);
        print_vec128_to_builder(*sb, "p2", in.p2);
        return builder_to_string(*sb);
    } else #if T == Translator {
        print_vec128_to_builder(*sb, "p2", in.p2);
        return builder_to_string(*sb);
    } else #if T == Rotor {
        print_vec128_to_builder(*sb, "p1", in.p1);
        return builder_to_string(*sb);
    } else #if T == Motor {
        print_vec128_to_builder(*sb, "p1", in.p1);
        print_vec128_to_builder(*sb, "p2", in.p2);
        return builder_to_string(*sb);
    }
}

#import "Basic";
#import "Machine_X64";
#import "Math";

pga_tests :: () {
    CHECK_EQ :: (a: float, b: float) {
        assert(abs(a - b) <= 0.00001, "CHECK_EQ_FAIL");
    }
    CHECK_EQ :: (a: bool, b: bool) {
        assert(a == b, "CHECK_EQ_FAIL");
    }
    CHECK_EQ :: (a: Motor, b: Motor) {
        assert(a.p1.float32s[0] == b.p1.float32s[0], "CHECK_EQ_FAIL");
        assert(a.p1.float32s[1] == b.p1.float32s[1], "CHECK_EQ_FAIL");
        assert(a.p1.float32s[2] == b.p1.float32s[2], "CHECK_EQ_FAIL");
        assert(a.p1.float32s[3] == b.p1.float32s[3], "CHECK_EQ_FAIL");
        assert(a.p2.float32s[0] == b.p2.float32s[0], "CHECK_EQ_FAIL");
        assert(a.p2.float32s[1] == b.p2.float32s[1], "CHECK_EQ_FAIL");
        assert(a.p2.float32s[2] == b.p2.float32s[2], "CHECK_EQ_FAIL");
        assert(a.p2.float32s[3] == b.p2.float32s[3], "CHECK_EQ_FAIL");
    }
    print("plane^plane\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);
        p2 := Plane.make(2.0, 3.0, -1.0, -2.0);
        p12 := p1 ^ p2;
        CHECK_EQ(e01(p12), 10.0);
        CHECK_EQ(e02(p12), 16.0);
        CHECK_EQ(e03(p12), 2.0);
        CHECK_EQ(e12(p12), -1.0);
        CHECK_EQ(e31(p12), 7.0);
        CHECK_EQ(e23(p12), -11.0);
    }
    print("plane^line\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);

        // a*e01 + b*e02 + c*e03 + d*e23 + e*e31 + f*e12
        l1 := Line.make(0.0, 0.0, 1.0, 4.0, 1.0, -2.0);

        p1l1 := p1 ^ l1;
        CHECK_EQ(e021(p1l1), 8.0);
        CHECK_EQ(e013(p1l1), -5.0);
        CHECK_EQ(e032(p1l1), -14.0);
        CHECK_EQ(e123(p1l1), 0.0);
    }
    print("plane^ideal-line\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);

        // a*e01 + b*e02 + c*e03
        l1 := Ideal_Line.make(-2.0, 1.0, 4.0);

        p1l1 := p1 ^ l1;
        CHECK_EQ(e021(p1l1), 5.0);
        CHECK_EQ(e013(p1l1), -10.0);
        CHECK_EQ(e032(p1l1), 5.0);
        CHECK_EQ(e123(p1l1), 0.0);
    }
    print("plane^point\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);
        // x*e_032 + y*e_013 + z*e_021 + e_123
        p2 := Point.make(-2.0, 1.0, 4.0);

        p1p2 := p1 ^ p2;
        CHECK_EQ(scalar(p1p2), 0.0);
        CHECK_EQ(e0123(p1p2), 16.0);
    }
    print("line^plane\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);

        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        l1 := Line.make(0.0, 0.0, 1.0, 4.0, 1.0, -2.0);

        p1l1 := l1 ^ p1;
        CHECK_EQ(e021(p1l1), 8.0);
        CHECK_EQ(e013(p1l1), -5.0);
        CHECK_EQ(e032(p1l1), -14.0);
        CHECK_EQ(e123(p1l1), 0.0);
    }
    print("line^line\n");
    {
        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        l1 := Line.make(1.0, 0.0, 0.0, 3.0, 2.0, 1.0);
        l2 := Line.make(0.0, 1.0, 0.0, 4.0, 1.0, -2.0);

        l1l2 := l1 ^ l2;
        CHECK_EQ(e0123(l1l2), 6.0);
    }
    print("line^ideal-line\n");
    {
        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        l1 := Line.make(0.0, 0.0, 1.0, 3.0, 2.0, 1.0);
        // a*e01 + b*e02 + c*e03
        l2 := Ideal_Line.make(-2.0, 1.0, 4.0);

        l1l2 := l1 ^ l2;
        CHECK_EQ(e0123(l1l2), 0.0);
        CHECK_EQ(scalar(l1l2), 0.0);
    }
    print("ideal-line^plane\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);
        // a*e01 + b*e02 + c*e03
        l1 := Ideal_Line.make(-2.0, 1.0, 4.0);

        p1l1 := l1 ^ p1;
        CHECK_EQ(e021(p1l1), 5.0);
        CHECK_EQ(e013(p1l1), -10.0);
        CHECK_EQ(e032(p1l1), 5.0);
        CHECK_EQ(e123(p1l1), 0.0);
    }
    print("point^plane\n");
    {
        // x*e_032 + y*e_013 + z*e_021 + e_123
        p1 := Point.make(-2.0, 1.0, 4.0);
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p2 := Plane.make(1.0, 2.0, 3.0, 4.0);

        p1p2 := p1 ^ p2;
        CHECK_EQ(e0123(p1p2), -16.0);
    }
    //////////////////////////////////

    print("rotor-exp-log\n");
    {
        r := Rotor.make(PI * 0.5, 0.3, -3.0, 1.0);
        b := log(r);
        r2 := exp(b);

        CHECK_EQ(scalar(r2), (scalar(r)));
        CHECK_EQ(e12(r2), (e12(r)));
        CHECK_EQ(e31(r2), (e31(r)));
        CHECK_EQ(e23(r2), (e23(r)));
    }
    print("rotor-sqrt\n");
    {
        r1 := Rotor.make(PI * 0.5, 0.3, -3.0, 1.0);
        r2 := sqrt(r1);
        r3 := r2 * r2;
        CHECK_EQ(scalar(r1), (scalar(r3)));
        CHECK_EQ(e12(r1), (e12(r3)));
        CHECK_EQ(e31(r1), (e31(r3)));
        CHECK_EQ(e23(r1), (e23(r3)));
    }
    print("motor-exp-log-sqrt\n");
    {
        // Construct a motor from a translator and rotor
        r := Rotor.make(PI * 0.5, 0.3, -3.0, 1.0);
        t := Translator.make(12.0, -2.0, 0.4, 1.0);
        m1 := r * t;
        l := log(m1);
        m2 := exp(l);

        CHECK_EQ(scalar(m1), (scalar(m2)));
        CHECK_EQ(e12(m1), (e12(m2)));
        CHECK_EQ(e31(m1), (e31(m2)));
        CHECK_EQ(e23(m1), (e23(m2)));
        CHECK_EQ(e01(m1), (e01(m2)));
        CHECK_EQ(e02(m1), (e02(m2)));
        CHECK_EQ(e03(m1), (e03(m2)));
        CHECK_EQ(e0123(m1), (e0123(m2)));

        m3 := sqrt(m1) * sqrt(m1);
        CHECK_EQ(scalar(m1), (scalar(m3)));
        CHECK_EQ(e12(m1), (e12(m3)));
        CHECK_EQ(e31(m1), (e31(m3)));
        CHECK_EQ(e23(m1), (e23(m3)));
        CHECK_EQ(e01(m1), (e01(m3)));
        CHECK_EQ(e02(m1), (e02(m3)));
        CHECK_EQ(e03(m1), (e03(m3)));
        CHECK_EQ(e0123(m1), (e0123(m3)));
    }
    print("motor-slerp\n");
    {
        // Construct a motor from a translator and rotor
        r := Rotor.make(PI * 0.5, 0.3, -3.0, 1.0);
        t := Translator.make(12.0, -2.0, 0.4, 1.0);
        m1 := r * t;
        l := log(m1);
        // Divide the motor action into three equal steps
        step := l / 3;
        m_step := exp(step);
        m21 :Motor= m_step * m_step;
        m2 := m21 * m_step;
        CHECK_EQ(scalar(m1), (scalar(m2)));
        CHECK_EQ(e12(m1), (e12(m2)));
        CHECK_EQ(e31(m1), (e31(m2)));
        CHECK_EQ(e23(m1), (e23(m2)));
        CHECK_EQ(e01(m1), (e01(m2)));
        CHECK_EQ(e02(m1), (e02(m2)));
        CHECK_EQ(e03(m1), (e03(m2)));
        CHECK_EQ(e0123(m1), (e0123(m2)));
    }
    print("motor-blend\n");
    {
        r1 := Rotor.make(PI * 0.5, 0, 0, 1.0);
        t1 := Translator.make(1.0, 0.0, 0.0, 1.0);
        m1 := r1 * t1;

        r2 := Rotor.make(PI * 0.5, 0.3, -3.0, 1.0);
        t2 := Translator.make(12.0, -2.0, 0.4, 1.0);
        m2 := r2 * t2;

        motion := m2 * ~m1;
        step := log(motion) / 4.0;
        motor_step := exp(step);

        // Applying motor_step 0 times to m1 is m1.
        // Applying motor_step 4 times to m1 is m2 * ~m1;
        result := motor_step * motor_step * motor_step * motor_step * m1;
        CHECK_EQ(scalar(result), (scalar(m2)));
        CHECK_EQ(e12(result), (e12(m2)));
        CHECK_EQ(e31(result), (e31(m2)));
        CHECK_EQ(e23(result), (e23(m2)));
        CHECK_EQ(e01(result), (e01(m2)));
        CHECK_EQ(e02(result), (e02(m2)));
        CHECK_EQ(e03(result), (e03(m2)));
        CHECK_EQ(e0123(result), (e0123(m2)));
    }
    print("translator-motor-log\n");
    {
        t := Translator.make(1.0, 1.0, 2.0, 3.0);
        m := Motor.make(t);
        l := log(m);
        CHECK_EQ(e01(l), e01(m));
        CHECK_EQ(e02(l), e02(m));
        CHECK_EQ(e03(l), e03(m));
    }

    print("ideal-motor-step\n");
    {
        r1 := Rotor.make(0, 0, 0, 1.0);
        t1 := Translator.make(1.0, 0.0, 0.0, 1.0);
        m1 := r1 * t1;

        step := log(m1) / 4.0;
        motor_step := exp(step);

        // Applying motor_step 4 times should recover the translator t1
        // (embedded) in m1
        result := motor_step * motor_step * motor_step * motor_step;
        CHECK_EQ(scalar(result), (scalar(m1)));
        CHECK_EQ(e12(result), (e12(m1)));
        CHECK_EQ(e31(result), (e31(m1)));
        CHECK_EQ(e23(result), (e23(m1)));
        CHECK_EQ(e01(result), (e01(m1)));
        CHECK_EQ(e02(result), (e02(m1)));
        CHECK_EQ(e03(result), (e03(m1)));
        CHECK_EQ(e0123(result), (e0123(m1)));
    }
    print("plane*plane\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);
        p2 := Plane.make(2.0, 3.0, -1.0, -2.0);
        p12 := p1 * p2;
        CHECK_EQ(scalar(p12), 5.);
        CHECK_EQ(e12(p12), -1.);
        CHECK_EQ(e31(p12), 7.);
        CHECK_EQ(e23(p12), -11.);
        CHECK_EQ(e01(p12), 10.);
        CHECK_EQ(e02(p12), 16.);
        CHECK_EQ(e03(p12), 2.);
        CHECK_EQ(e0123(p12), 0.);

        dp1p2 := p1 / p2;
        sp1p2 := sqrt(dp1p2);
        p3 := conjugate(sp1p2, p2);
        CHECK_EQ(approx_eq(p3, p1, 0.001), true);

        normalize(*p1);
        m := p1 * p1;
        CHECK_EQ(scalar(m), (1.0));
    }
    print("plane/plane\n");
    {
        p1 := Plane.make(1.0, 2., 3., 4.);
        m := p1 / p1;
        CHECK_EQ(scalar(m), (1.));
        CHECK_EQ(e12(m), 0.);
        CHECK_EQ(e31(m), 0.);
        CHECK_EQ(e23(m), 0.);
        CHECK_EQ(e01(m), 0.);
        CHECK_EQ(e02(m), 0.);
        CHECK_EQ(e03(m), 0.);
        CHECK_EQ(e0123(m), 0.);
    }

    print("plane*point\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);
        // x*e_032 + y*e_013 + z*e_021 + e_123
        p2 := Point.make(-2.0, 1.0, 4.0);

        p1p2 := p1 * p2;
        CHECK_EQ(scalar(p1p2), 0.0);
        CHECK_EQ(e01(p1p2), -5.0);
        CHECK_EQ(e02(p1p2), 10.0);
        CHECK_EQ(e03(p1p2), -5.0);
        CHECK_EQ(e12(p1p2), 3.0);
        CHECK_EQ(e31(p1p2), 2.0);
        CHECK_EQ(e23(p1p2), 1.0);
        CHECK_EQ(e0123(p1p2), 16.0);
    }
    print("line-normalization\n");
    {
        l := Line.make(1.0, 2.0, 3.0, 3.0, 2.0, 1.0);
        normalize(*l);
        m := l * ~l;
        CHECK_EQ(scalar(m), (1.0));
        CHECK_EQ(e23(m), (0.0));
        CHECK_EQ(e31(m), (0.0));
        CHECK_EQ(e12(m), (0.0));
        CHECK_EQ(e01(m), (0.0));
        CHECK_EQ(e02(m), (0.0));
        CHECK_EQ(e03(m), (0.0));
        CHECK_EQ(e0123(m), (0.0));
    }
    print("branch*branch\n");
    {
        b1 := Branch.make(2.0, 1.0, 3.0);
        b2 := Branch.make(1.0, -2.0, -3.0);
        r := b2 * b1;
        CHECK_EQ(scalar(r), 9.0);
        CHECK_EQ(e23(r), 3.0);
        CHECK_EQ(e31(r), 9.0);
        CHECK_EQ(e12(r), -5.0);

        normalize(*b1);
        normalize(*b2);

        x1 := b2 * b1;
        sqx1 := sqrt(b2 * b1);
        conjsx1 := conjugate(sqx1, b1);
        b3 := ~conjsx1;
        CHECK_EQ(x(b3), x(b2));
        CHECK_EQ(y(b3), y(b2));
        CHECK_EQ(z(b3), z(b2));
    }
    print("branch/branch\n");
    {
        b := Branch.make(2.0, 1.0, 3.0);
        r := b / b;
        CHECK_EQ(scalar(r), (1.0));
        CHECK_EQ(e23(r), 0.0);
        CHECK_EQ(e31(r), 0.0);
        CHECK_EQ(e12(r), 0.0);
    }
    print("line*line\n");
    {
        // a*e01 + b*e02 + c*e03 + d*e23 + e*e31 + f*e12
        l1 := Line.make(1.0, 0.0, 0.0, 3.0, 2.0, 1.0);
        l2 := Line.make(0.0, 1.0, 0.0, 4.0, 1.0, -2.0);

        l1l2 := l1 * l2;
        CHECK_EQ(scalar(l1l2), -12.0);
        CHECK_EQ(e12(l1l2), 5.0);
        CHECK_EQ(e31(l1l2), -10.0);
        CHECK_EQ(e23(l1l2), 5.0);
        CHECK_EQ(e01(l1l2), 1.0);
        CHECK_EQ(e02(l1l2), -2.0);
        CHECK_EQ(e03(l1l2), -4.0);
        CHECK_EQ(e0123(l1l2), 6.0);

        normalize(*l1);
        normalize(*l2);
        l1l2 = l1 * l2;
        sl1l2 := sqrt(l1l2);
        l3 := conjugate(sl1l2, l2);
        CHECK_EQ(approx_eq(l3, -l1, 0.001), true);
    }
    print("line/line\n");
    {
        l := Line.make(1.0, -2.0, 2.0, -3.0, 3.0, -4.0);
        m := l / l;
        CHECK_EQ(scalar(m), (1.0));
        CHECK_EQ(e12(m), 0.0);
        CHECK_EQ(e31(m), 0.0);
        CHECK_EQ(e23(m), 0.0);
        CHECK_EQ(e01(m), (0.0));
        CHECK_EQ(e02(m), (0.0));
        CHECK_EQ(e03(m), (0.0));
        CHECK_EQ(e0123(m), (0.0));
    }
    print("point*plane\n");
    {
        // x*e_032 + y*e_013 + z*e_021 + e_123
        p1 := Point.make(-2.0, 1.0, 4.0);
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p2 := Plane.make(1.0, 2.0, 3.0, 4.0);

        p1p2 := p1 * p2;
        CHECK_EQ(scalar(p1p2), 0.0);
        CHECK_EQ(e01(p1p2), -5.0);
        CHECK_EQ(e02(p1p2), 10.0);
        CHECK_EQ(e03(p1p2), -5.0);
        CHECK_EQ(e12(p1p2), 3.0);
        CHECK_EQ(e31(p1p2), 2.0);
        CHECK_EQ(e23(p1p2), 1.0);
        CHECK_EQ(e0123(p1p2), -16.0);
    }
    print("point*point\n");
    {
        // x*e_032 + y*e_013 + z*e_021 + e_123
        p1 := Point.make(1.0, 2.0, 3.0);
        p2 := Point.make(-2.0, 1.0, 4.0);

        p1p2 := p1 * p2;
        CHECK_EQ(e01(p1p2), (-3.0));
        CHECK_EQ(e02(p1p2), (-1.0));
        CHECK_EQ(e03(p1p2), (1.0));

        p3 := conjugate(sqrt(p1p2), p2);
        CHECK_EQ(x(p3), (1.0));
        CHECK_EQ(y(p3), (2.0));
        CHECK_EQ(z(p3), (3.0));
    }

    print("point/point\n");
    {
        p1 := Point.make(1.0, 2.0, 3.0);
        t := p1 / p1;
        CHECK_EQ(e01(t), 0.0);
        CHECK_EQ(e02(t), 0.0);
        CHECK_EQ(e03(t), 0.0);
    }
    print("translator/translator\n");
    {
        t1 := Translator.make(3.0, 1.0, -2.0, 3.0);
        t2 := t1 / t1;
        CHECK_EQ(e01(t2), 0.0);
        CHECK_EQ(e02(t2), 0.0);
        CHECK_EQ(e03(t2), 0.0);
    }

    print("rotor*translator\n");
    {
        r: Rotor;
        r.p1 = vec128(SET_PS(1.0, 0, 0, 1.0));
        t: Translator;
        t.p2 = vec128(SET_PS(1.0, 0, 0, 0.0));
        m := r * t;
        CHECK_EQ(scalar(m), 1.0);
        CHECK_EQ(e01(m), 0.0);
        CHECK_EQ(e02(m), 0.0);
        CHECK_EQ(e03(m), 1.0);
        CHECK_EQ(e23(m), 0.0);
        CHECK_EQ(e31(m), 0.0);
        CHECK_EQ(e12(m), 1.0);
        CHECK_EQ(e0123(m), 1.0);
    }
    print("translator*rotor\n");
    {
        r: Rotor;
        r.p1 = vec128(SET_PS(1.0, 0, 0, 1.0));
        t: Translator;
        t.p2 = vec128(SET_PS(1.0, 0, 0, 0.0));
        m := t * r;
        CHECK_EQ(scalar(m), 1.0);
        CHECK_EQ(e01(m), 0.0);
        CHECK_EQ(e02(m), 0.0);
        CHECK_EQ(e03(m), 1.0);
        CHECK_EQ(e23(m), 0.0);
        CHECK_EQ(e31(m), 0.0);
        CHECK_EQ(e12(m), 1.0);
        CHECK_EQ(e0123(m), 1.0);
    }

    print("motor*rotor\n");
    {
        r1: Rotor;
        r1.p1 = vec128(SET_PS(1.0, 2.0, 3.0, 4.0));
        t: Translator;
        t.p2 = vec128(SET_PS(3.0, -2.0, 1.0, -3.0));
        r2: Rotor;
        r2.p1 = vec128(SET_PS(-4.0, 2.0, -3.0, 1.0));
        m1 := (t * r1) * r2;
        m2 := t * (r1 * r2);
        CHECK_EQ(m1, m2);
    }

    print("rotor*motor\n");
    {
        r1: Rotor;
        r1.p1 = vec128(SET_PS(1.0, 2.0, 3.0, 4.0));
        t: Translator;
        t.p2 = vec128(SET_PS(3.0, -2.0, 1.0, -3.0));
        r2: Rotor;
        r2.p1   = vec128(SET_PS(-4.0, 2.0, -3.0, 1.0));
        m1 := r2 * (r1 * t);
        m2 := (r2 * r1) * t;
        CHECK_EQ(m1, m2);
    }

    print("motor*translator\n");
    {
        r: Rotor;
        r.p1 = vec128(SET_PS(1.0, 2.0, 3.0, 4.0));
        t1: Translator;
        t1.p2 = vec128(SET_PS(3.0, -2.0, 1.0, -3.0));
        t2: Translator;
        t2.p2   = vec128(SET_PS(-4.0, 2.0, -3.0, 1.0));
        m1 := (r * t1) * t2;
        m2 := r * (t1 * t2);
        CHECK_EQ(m1, m2);
    }
    print("translator*motor\n");
    {
        r: Rotor;
        r.p1 = vec128(SET_PS(1.0, 2.0, 3.0, 4.0));
        t1: Translator;
        t1.p2 = vec128(SET_PS(3.0, -2.0, 1.0, -3.0));
        t2: Translator;
        t2.p2   = vec128(SET_PS(-4.0, 2.0, -3.0, 1.0));
        m1 := t2 * (r * t1);
        m2 := (t2 * r) * t1;
        CHECK_EQ(m1, m2);
    }

    print("motor*motor\n");
    {
        m1 := Motor.make(2, 3, 4, 5, 6, 7, 8, 9);
        m2 := Motor.make(6, 7, 8, 9, 10, 11, 12, 13);
        m3 := m1 * m2;
        CHECK_EQ(scalar(m3), -86.0);
        CHECK_EQ(e23(m3), 36.0);
        CHECK_EQ(e31(m3), 32.0);
        CHECK_EQ(e12(m3), 52.0);
        CHECK_EQ(e01(m3), -38.0);
        CHECK_EQ(e02(m3), -76.0);
        CHECK_EQ(e03(m3), -66.0);
        CHECK_EQ(e0123(m3), 384.0);
    }

    print("motor/motor\n");
    {
        m1 := Motor.make(2, 3, 4, 5, 6, 7, 8, 9);
        m2 := m1 / m1;
        CHECK_EQ(scalar(m2), (1.0));
        CHECK_EQ(e23(m2), 0.0);
        CHECK_EQ(e31(m2), 0.0);
        CHECK_EQ(e12(m2), 0.0);
        CHECK_EQ(e01(m2), 0.0);
        CHECK_EQ(e02(m2), (0.0));
        CHECK_EQ(e03(m2), (0.0));
        CHECK_EQ(e0123(m2), (0.0));
    }
    print("plane|plane\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);
        p2 := Plane.make(2.0, 3.0, -1.0, -2.0);
        p12 := p1 | p2;
        CHECK_EQ(p12, 5.0);
    }
    print("plane|line\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);

        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        l1 := Line.make(0.0, 0.0, 1.0, 4.0, 1.0, -2.0);

        p1l1 :Plane = p1 | l1;
        CHECK_EQ(e0(p1l1), -3.0);
        CHECK_EQ(e1(p1l1), 7.0);
        CHECK_EQ(e2(p1l1), -14.0);
        CHECK_EQ(e3(p1l1), 7.0);
    }
    print("plane|ideal-line\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);

        // a*e01 + b*e02 + c*e03
        l1 := Ideal_Line.make(-2.0, 1.0, 4.0);

        p1l1 :Plane = p1 | l1;
        CHECK_EQ(e0(p1l1), -12.0);
    }
    print("plane|point\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);
        // x*e_032 + y*e_013 + z*e_021 + e_123
        p2 := Point.make(-2.0, 1.0, 4.0);

        p1p2 :Line = p1 | p2;
        CHECK_EQ(e01(p1p2), -5.0);
        CHECK_EQ(e02(p1p2), 10.0);
        CHECK_EQ(e03(p1p2), -5.0);
        CHECK_EQ(e12(p1p2), 3.0);
        CHECK_EQ(e31(p1p2), 2.0);
        CHECK_EQ(e23(p1p2), 1.0);
    }

    print("line|plane\n");
    {
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p1 := Plane.make(1.0, 2.0, 3.0, 4.0);

        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        l1 := Line.make(0.0, 0.0, 1.0, 4.0, 1.0, -2.0);

        p1l1 :Plane = l1 | p1;
        CHECK_EQ(e0(p1l1), 3.0);
        CHECK_EQ(e1(p1l1), -7.0);
        CHECK_EQ(e2(p1l1), 14.0);
        CHECK_EQ(e3(p1l1), -7.0);
    }
    print("line|line\n");
    {
        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        l1 := Line.make(1.0, 0.0, 0.0, 3.0, 2.0, 1.0);
        l2 := Line.make(0.0, 1.0, 0.0, 4.0, 1.0, -2.0);

        l1l2 := l1 | l2;
        CHECK_EQ(l1l2, -12);
    }

    print("line|point\n");
    {
        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        l1 := Line.make(0.0, 0.0, 1.0, 3.0, 2.0, 1.0);
        // x*e_032 + y*e_013 + z*e_021 + e_123
        p2 := Point.make(-2.0, 1.0, 4.0);

        l1p2 :Plane = l1 | p2;
        CHECK_EQ(e0(l1p2), 0.0);
        CHECK_EQ(e1(l1p2), -3.0);
        CHECK_EQ(e2(l1p2), -2.0);
        CHECK_EQ(e3(l1p2), -1.0);
    }
    print("point|plane\n");
    {
        // x*e_032 + y*e_013 + z*e_021 + e_123
        p1 := Point.make(-2.0, 1.0, 4.0);
        // d*e_0 + a*e_1 + b*e_2 + c*e_3
        p2 := Plane.make(1.0, 2.0, 3.0, 4.0);

        p1p2 :Line = p1 | p2;
        CHECK_EQ(e01(p1p2), -5.0);
        CHECK_EQ(e02(p1p2), 10.0);
        CHECK_EQ(e03(p1p2), -5.0);
        CHECK_EQ(e12(p1p2), 3.0);
        CHECK_EQ(e31(p1p2), 2.0);
        CHECK_EQ(e23(p1p2), 1.0);
    }

    print("point|line\n");
    {
        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        l1 := Line.make(0.0, 0.0, 1.0, 3.0, 2.0, 1.0);
        // x*e_032 + y*e_013 + z*e_021 + e_123
        p2 := Point.make(-2.0, 1.0, 4.0);

        l1p2 :Plane = p2 | l1;
        CHECK_EQ(e0(l1p2), 0.0);
        CHECK_EQ(e1(l1p2), -3.0);
        CHECK_EQ(e2(l1p2), -2.0);
        CHECK_EQ(e3(l1p2), -1.0);
    }
    print("point|point\n");
    {
        // x*e_032 + y*e_013 + z*e_021 + e_123
        p1 := Point.make(1.0, 2.0, 3.0);
        p2 := Point.make(-2.0, 1.0, 4.0);

        p1p2 := p1 | p2;
        CHECK_EQ(p1p2, -1.0);
    }

    print("project point to line\n");
    {
        p1 := Point.make(2.0, 2.0, 0.0);
        p2 := Point.make(0.0, 0.0, 0.0);
        p3 := Point.make(1.0, 0.0, 0.0);
        l:Line = p2 & p3;
        pl: Plane = l | p1;
        np: Point = pl ^ l;
        p4 := Point.make(np);
        normalize(*p4);

        CHECK_EQ(e123(p4), (1.0));
        CHECK_EQ(x(p4), (2.0));
        CHECK_EQ(y(p4), (0.0));
        CHECK_EQ(z(p4), (0.0));
    }
    print("measure-point-to-point\n");
    {
        p1 := Point.make(1.0, 0, 0);
        p2 := Point.make(0.0, 1.0, 0);
        l :Line= p1 & p2;
        // Produce the squared distance between p1 and p2
        CHECK_EQ(squared_norm(l), 2.0);
    }
    print("measure-point-to-plane\n");
    {
        //    Plane p2
        //    /
        //   / \ line perpendicular to
        //  /   \ p2 through p1
        // 0------x--------->
        //        p1

        // (2, 0, 0)
        p1 := Point.make(2.0, 0.0, 0.0);
        // Plane x - y = 0
        p2 := Plane.make(1.0, -1.0, 0.0, 0.0);
        normalize(*p2);
        // Distance from point p1 to plane p2
        root_two := (sqrt(2.0));
        CHECK_EQ(abs(scalar(p1 & p2)), root_two);
        CHECK_EQ(abs(e0123(p1 ^ p2)), root_two);
    }
    print("measure-point-to-line\n");
    {
        l := Line.make(0, 1, 0, 1, 0, 0);
        p := Point.make(0, 1, 2);
        lp :Plane= l & p;
        distance :float = norm(Plane.make(lp));
        CHECK_EQ(distance, (sqrt(2.0)));
    }

    print("euler-angles\n");
    {
        // Make 3 rotors about the x, y, and z-axes.
        rx := Rotor.make(1.0, 1.0, 0.0, 0.0);
        ry := Rotor.make(1.0, 0.0, 1.0, 0.0);
        rz := Rotor.make(1.0, 0.0, 0.0, 1.0);

        r :Rotor= rx * ry * rz;
        ea := euler_angles(r);
        CHECK_EQ(ea.roll, (1.0));
        CHECK_EQ(ea.pitch, (1.0));
        CHECK_EQ(ea.yaw, (1.0));

        r2 := Rotor.make(ea);

        for i: 0..3 {
            CHECK_EQ(r.p1.float32s[i], r2.p1.float32s[i]);
        }
    }
    print("euler-angles-precision\n");
    {
        ea1 := Euler_Angles.{PI * 0.2, PI * 0.2, 0.0};
        r1 := Rotor.make(ea1);
        ea2 := euler_angles(r1);

        CHECK_EQ(ea1.roll, (ea2.roll));
        CHECK_EQ(ea1.pitch, (ea2.pitch));
        CHECK_EQ(ea1.yaw, (ea2.yaw));
    }
    print("+z line\n");
    {
        p1 := Point.make(0.0, 0.0, 0.0);
        p2 := Point.make(0.0, 0.0, 1.0);
        p12 :Line= p1 & p2;
        CHECK_EQ(e12(p12), 1.0);
    }
    print("+y line\n");
    {
        p1 := Point.make(0.0, -1.0, 0.0);
        p2 := Point.make(0.0, 0.0, 0.0);
        p12 :Line= p1 & p2;
        CHECK_EQ(e31(p12), 1.0);
    }

    print("+x line\n");
    {
        p1 := Point.make(-2.0, 0.0, 0.0);
        p2 := Point.make(-1.0, 0.0, 0.0);
        p12 :Line= p1 & p2;
        CHECK_EQ(e23(p12), 1.0);
    }
    print("plane-construction\n");
    {
        p1 := Point.make(1.0, 3.0, 2.0);
        p2 := Point.make(-1.0, 5.0, 2.0);
        p3 := Point.make(2.0, -1.0, -4.0);

        p123 := Plane.make(p1 & p2 & p3);

        // Check that all 3 points lie on the plane
        CHECK_EQ(e1(p123) + e2(p123) * 3.0 + e3(p123) * 2.0 + e0(p123), 0.0);
        CHECK_EQ(-e1(p123) + e2(p123) * 5.0 + e3(p123) * 2.0 + e0(p123), 0.0);
        CHECK_EQ(e1(p123) * 2.0 - e2(p123) - e3(p123) * 4.0 + e0(p123), 0.0);
    }
    print("simd-sandwich\n");
    {
        a := vec128(SET_PS(4.0, 3.0, 2.0, 1.0));
        b := vec128(SET_PS(-1.0, -2.0, -3.0, -4.0));
        ab := sw02(a, b);

        CHECK_EQ(ab.float32s[0], 9.0);
        CHECK_EQ(ab.float32s[1], 2.0);
        CHECK_EQ(ab.float32s[2], 3.0);
        CHECK_EQ(ab.float32s[3], 4.0);
    }
    print("reflect-plane\n");
    {
        p1 := Plane.make(3.0, 2.0, 1.0, -1.0);
        p2 := Plane.make(1.0, 2.0, -1.0, -3.0);
        p3 :Plane= reflect(p1, p2);

        CHECK_EQ(e0(p3), 30.0);
        CHECK_EQ(e1(p3), 22.0);
        CHECK_EQ(e2(p3), -4.0);
        CHECK_EQ(e3(p3), 26.0);
    }
    print("reflect-line\n");
    {
        p := Plane.make(3.0, 2.0, 1.0, -1.0);
        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        l1 := Line.make(1.0, -2.0, 3.0, 6.0, 5.0, -4.0);
        l2:Line= reflect(p, l1);
        CHECK_EQ(e01(l2), 28.0);
        CHECK_EQ(e02(l2), -72.0);
        CHECK_EQ(e03(l2), 32.0);
        CHECK_EQ(e12(l2), 104.0);
        CHECK_EQ(e31(l2), 26.0);
        CHECK_EQ(e23(l2), 60.0);
    }
    print("reflect-point\n");
    {
        p1 := Plane.make(3.0, 2.0, 1.0, -1.0);
        p2 := Point.make(4.0, -2.0, -1.0);
        p3 :Point= reflect(p1, p2);
        CHECK_EQ(e021(p3), -26.0);
        CHECK_EQ(e013(p3), -52.0);
        CHECK_EQ(e032(p3), 20.0);
        CHECK_EQ(e123(p3), 14.0);
    }
    print("rotor-line\n");
    {
        // Make an unnormalized rotor to verify correctness
        data := float.[1.0, 4.0, -3.0, 2.0];
        r: Rotor;
        load_normalized(*r, data.data);
        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        l1 := Line.make(-1.0, 2.0, -3.0, -6.0, 5.0, 4.0);
        tmpl := conjugate(r, l1);
        l2 := Line.make(tmpl);
        CHECK_EQ(e01(l2), -110.0);
        CHECK_EQ(e02(l2), 20.0);
        CHECK_EQ(e03(l2), 10.0);
        CHECK_EQ(e12(l2), -240.0);
        CHECK_EQ(e31(l2), 102.0);
        CHECK_EQ(e23(l2), -36.0);
    }
    print("rotor-point\n");
    {
        r := Rotor.make(PI * 0.5, 0, 0, 1.0);
        p1 := Point.make(1, 0, 0);
        p2 :Point= conjugate(r, p1);
        CHECK_EQ(x(p2), 0.0);
        CHECK_EQ(y(p2), (-1.0));
        CHECK_EQ(z(p2), 0.0);
    }
    print("translator-point\n");
    {
        t := Translator.make(1.0, 0.0, 0.0, 1.0);
        p1 := Point.make(1, 0, 0);
        p2 :Point= conjugate(t, p1);
        CHECK_EQ(x(p2), 1.0);
        CHECK_EQ(y(p2), 0.0);
        CHECK_EQ(z(p2), 1.0);
    }
    print("translator-line\n");
    {
        data := float.[0.0, -5.0, -2.0, 2.0];
        t: Translator;
        load_normalized(*t, data.data);
        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        l1 := Line.make(-1.0, 2.0, -3.0, -6.0, 5.0, 4.0);
        tmpl := conjugate(t, l1);
        l2 := Line.make(tmpl);
        CHECK_EQ(e01(l2), 35.0);
        CHECK_EQ(e02(l2), -14.0);
        CHECK_EQ(e03(l2), 71.0);
        CHECK_EQ(e12(l2), 4.0);
        CHECK_EQ(e31(l2), 5.0);
        CHECK_EQ(e23(l2), -6.0);
    }
    print("construct-motor\n");
    {
        r := Rotor.make(PI * 0.5, 0, 0, 1.0);
        t := Translator.make(1.0, 0.0, 0.0, 1.0);
        m :Motor= r * t;
        p1 := Point.make(1, 0, 0);
        p2 :Point= conjugate(m, p1);
        CHECK_EQ(x(p2), 0.0);
        CHECK_EQ(y(p2), (-1.0));
        CHECK_EQ(z(p2), (1.0));

        // Rotation and translation about the same axis commutes
        m  = t * r;
        p2 = conjugate(m, p1);
        CHECK_EQ(x(p2), 0.0);
        CHECK_EQ(y(p2), (-1.0));
        CHECK_EQ(z(p2), (1.0));

        l :Line= log(m);
        CHECK_EQ(e23(l), 0.0);
        CHECK_EQ(e12(l), 0.7854);
        CHECK_EQ(e31(l), 0.0);
        CHECK_EQ(e01(l), 0.0);
        CHECK_EQ(e02(l), 0.0);
        CHECK_EQ(e03(l), (-0.5));
    }
    print("construct-motor-via-screw-axis\n");
    {
        m := Motor.make(PI * 0.5, 1.0, Line.make(0.0, 0.0, 0.0, 0.0, 0.0, 1.0));
        p1 := Point.make(1, 0, 0);
        p2 :Point= conjugate(m, p1);
        CHECK_EQ(x(p2), (0.0));
        CHECK_EQ(y(p2), (1.0));
        CHECK_EQ(z(p2), (1.0));
    }

    print("motor-plane\n");
    {
        m := Motor.make(1.0, 4.0, 3.0, 2.0, 5.0, 6.0, 7.0, 8.0);
        p1 := Plane.make(3.0, 2.0, 1.0, -1.0);
        p2 :Plane= conjugate(m, p1);
        CHECK_EQ(x(p2), 78.0);
        CHECK_EQ(y(p2), 60.0);
        CHECK_EQ(z(p2), 54.0);
        CHECK_EQ(d(p2), 358.0);
    }
    print("motor-plane-variadic\n");
    {
        m := Motor.make(1.0, 4.0, 3.0, 2.0, 5.0, 6.0, 7.0, 8.0);
        ps := Plane.[
            Plane.make(3.0, 2.0, 1.0, -1.0), 
            Plane.make(3.0, 2.0, 1.0, -1.0), 
        ];
        ps2: [2]Plane;
        conjugate(m, ps.data, ps2.data, 2);

        for i: 0..1 {
            CHECK_EQ(x(ps2[i]), 78.0);
            CHECK_EQ(y(ps2[i]), 60.0);
            CHECK_EQ(z(ps2[i]), 54.0);
            CHECK_EQ(d(ps2[i]), 358.0);
        }
    }
    print("motor-point\n");
    {
        m := Motor.make(1.0, 4.0, 3.0, 2.0, 5.0, 6.0, 7.0, 8.0);
        p1 := Point.make(-1.0, 1.0, 2.0);
        p2 :Point= conjugate(m, p1);
        CHECK_EQ(x(p2), -12.0);
        CHECK_EQ(y(p2), -86.0);
        CHECK_EQ(z(p2), -86.0);
        CHECK_EQ(w(p2), 30.0);
    }
    print("motor-point-variadic\n");
    {
        m := Motor.make(1.0, 4.0, 3.0, 2.0, 5.0, 6.0, 7.0, 8.0);
        ps := Point.[
            Point.make(-1.0, 1.0, 2.0), 
            Point.make(-1.0, 1.0, 2.0), 
        ];
        ps2: [2]Point;
        conjugate(m, ps.data, ps2.data, 2);
        for i: 0..1 {
            CHECK_EQ(x(ps2[i]), -12.0);
            CHECK_EQ(y(ps2[i]), -86.0);
            CHECK_EQ(z(ps2[i]), -86.0);
            CHECK_EQ(w(ps2[i]), 30.0);
        }
    }
    print("motor-line\n");
    {
        m := Motor.make(2.0, 4.0, 3.0, -1.0, -5.0, -2.0, 2.0, -3.0);
        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        l1 := Line.make(-1.0, 2.0, -3.0, -6.0, 5.0, 4.0);
        tmpl := conjugate(m, l1);
        l2 := Line.make(tmpl);
        CHECK_EQ(e01(l2), 6.0);
        CHECK_EQ(e02(l2), 522.0);
        CHECK_EQ(e03(l2), 96.0);
        CHECK_EQ(e12(l2), -214.0);
        CHECK_EQ(e31(l2), -148.0);
        CHECK_EQ(e23(l2), -40.0);
    }
    print("motor-line-variadic\n");
    {
        m := Motor.make(2.0, 4.0, 3.0, -1.0, -5.0, -2.0, 2.0, -3.0);
        // a*e01 + b*e01 + c*e02 + d*e23 + e*e31 + f*e12
        ls := Line.[
            Line.make(-1.0, 2.0, -3.0, -6.0, 5.0, 4.0),
            Line.make(-1.0, 2.0, -3.0, -6.0, 5.0, 4.0), 
        ];
        ls2: [2]Line;
        conjugate(m, ls.data, ls2.data, 2);


        for i: 0..1 {
            CHECK_EQ(e01(ls2[i]), 6.0);
            CHECK_EQ(e02(ls2[i]), 522.0);
            CHECK_EQ(e03(ls2[i]), 96.0);
            CHECK_EQ(e12(ls2[i]), -214.0);
            CHECK_EQ(e31(ls2[i]), -148.0);
            CHECK_EQ(e23(ls2[i]), -40.0);
        }
    }
    print("motor-origin\n");
    {
        r := Rotor.make(PI * 0.5, 0, 0, 1.0);
        t := Translator.make(1.0, 0.0, 0.0, 1.0);
        m :Motor= r * t;
        p :Point= conjugate_origin(m);
        CHECK_EQ(x(p), 0.0);
        CHECK_EQ(y(p), 0.0);
        CHECK_EQ(z(p), (1.0));
    }

    print("motor-to-matrix\n");
    {
        m := Motor.make(1.0, 4.0, 3.0, 2.0, 5.0, 6.0, 7.0, 8.0);
        p1    := vec128(float.[-1.0, 1.0, 2.0, 1.0]);
        m_mat := matrix4x4(m);
        p2:Point = apply_matrix_to_point(m_mat, p1);
        CHECK_EQ(p2.p3.float32s[0], -12.0);
        CHECK_EQ(p2.p3.float32s[1], -86.0);
        CHECK_EQ(p2.p3.float32s[2], -86.0);
        CHECK_EQ(p2.p3.float32s[3], 30.0);
    }
    print("motor-to-matrix-3x4\n");
    {
        m := Motor.make(1.0, 4.0, 3.0, 2.0, 5.0, 6.0, 7.0, 8.0);
        normalize(*m);
        p1    := vec128(SET_PS(1.0, 2.0, 1.0, -1.0));
        m_mat := matrix3x4(m);
        p2    :Point= apply_matrix_to_point(m_mat, p1);

        CHECK_EQ(p2.p3.float32s[0], (-12.0 / 30.0));
        CHECK_EQ(p2.p3.float32s[1], (-86.0 / 30.0));
        CHECK_EQ(p2.p3.float32s[2], (-86.0 / 30.0));
        CHECK_EQ(p2.p3.float32s[3], 1.0);
    }
    print("normalize-motor\n");
    {
        m := Motor.make(1.0, 4.0, 3.0, 2.0, 5.0, 6.0, 7.0, 8.0);
        normalize(*m);
        norm:Motor= m * ~m;
        CHECK_EQ(scalar(norm), (1.0));
        CHECK_EQ(e0123(norm), (0.0));
    }

    print("motor-sqrt\n");
    {
        lm := Line.make(3.0, 1.0, 2.0, 4.0, -2.0, 1.0);
        nlm := normalized(lm);
        m := Motor.make(PI * 0.5, 3.0, nlm);
        m2 :Motor= sqrt(m);
        m2       = m2 * m2;
        CHECK_EQ(scalar(m), (scalar(m2)));
        CHECK_EQ(e01(m), (e01(m2)));
        CHECK_EQ(e02(m), (e02(m2)));
        CHECK_EQ(e03(m), (e03(m2)));
        CHECK_EQ(e23(m), (e23(m2)));
        CHECK_EQ(e31(m), (e31(m2)));
        CHECK_EQ(e12(m), (e12(m2)));
        CHECK_EQ(e0123(m), (e0123(m2)));
    }
    print("rotor-sqrt\n");
    {
        r := Rotor.make(PI * 0.5, 1, 2, 3);
        r2 :Rotor= sqrt(r);
        r2       = r2 * r2;
        CHECK_EQ(scalar(r2), (scalar(r)));
        CHECK_EQ(e23(r2), (e23(r)));
        CHECK_EQ(e31(r2), (e31(r)));
        CHECK_EQ(e12(r2), (e12(r)));
    }

    print("normalize-rotor\n");
    {
        r: Rotor;
        r.p1 = vec128(SET_PS(4.0, -3.0, 3.0, 28.0));
        normalize(*r);
        norm :Rotor= r * ~r;
        CHECK_EQ(scalar(norm), (1.0));
        CHECK_EQ(e12(norm), (0.0));
        CHECK_EQ(e31(norm), (0.0));
        CHECK_EQ(e23(norm), (0.0));
    }
}

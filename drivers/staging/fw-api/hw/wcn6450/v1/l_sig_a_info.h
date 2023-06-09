
/*
 * Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software for
 * any purpose with or without fee is hereby granted, provided that the
 * above copyright notice and this permission notice appear in all
 * copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
 * WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
 * DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
 * PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */



#ifndef _L_SIG_A_INFO_H_
#define _L_SIG_A_INFO_H_
#if !defined(__ASSEMBLER__)
#endif

#define NUM_OF_DWORDS_L_SIG_A_INFO 1

struct l_sig_a_info {
             uint32_t rate                            :  4,
                      lsig_reserved                   :  1,
                      length                          : 12,
                      parity                          :  1,
                      tail                            :  6,
                      pkt_type                        :  4,
                      captured_implicit_sounding      :  1,
                      reserved                        :  3;
};

#define L_SIG_A_INFO_0_RATE_OFFSET                                   0x00000000
#define L_SIG_A_INFO_0_RATE_LSB                                      0
#define L_SIG_A_INFO_0_RATE_MASK                                     0x0000000f

#define L_SIG_A_INFO_0_LSIG_RESERVED_OFFSET                          0x00000000
#define L_SIG_A_INFO_0_LSIG_RESERVED_LSB                             4
#define L_SIG_A_INFO_0_LSIG_RESERVED_MASK                            0x00000010

#define L_SIG_A_INFO_0_LENGTH_OFFSET                                 0x00000000
#define L_SIG_A_INFO_0_LENGTH_LSB                                    5
#define L_SIG_A_INFO_0_LENGTH_MASK                                   0x0001ffe0

#define L_SIG_A_INFO_0_PARITY_OFFSET                                 0x00000000
#define L_SIG_A_INFO_0_PARITY_LSB                                    17
#define L_SIG_A_INFO_0_PARITY_MASK                                   0x00020000

#define L_SIG_A_INFO_0_TAIL_OFFSET                                   0x00000000
#define L_SIG_A_INFO_0_TAIL_LSB                                      18
#define L_SIG_A_INFO_0_TAIL_MASK                                     0x00fc0000

#define L_SIG_A_INFO_0_PKT_TYPE_OFFSET                               0x00000000
#define L_SIG_A_INFO_0_PKT_TYPE_LSB                                  24
#define L_SIG_A_INFO_0_PKT_TYPE_MASK                                 0x0f000000

#define L_SIG_A_INFO_0_CAPTURED_IMPLICIT_SOUNDING_OFFSET             0x00000000
#define L_SIG_A_INFO_0_CAPTURED_IMPLICIT_SOUNDING_LSB                28
#define L_SIG_A_INFO_0_CAPTURED_IMPLICIT_SOUNDING_MASK               0x10000000

#define L_SIG_A_INFO_0_RESERVED_OFFSET                               0x00000000
#define L_SIG_A_INFO_0_RESERVED_LSB                                  29
#define L_SIG_A_INFO_0_RESERVED_MASK                                 0xe0000000

#endif

#include <features.h>
#include <sys/syscall.h>
#define _ERRNO_H    1
#include <bits/errno.h>

#ifdef __NR_clone

.text
.global clone
.type clone,@function
.align 4

clone:
    be      r1, r0, 1f
    be      r2, r0, 1f

    #addi    sp, sp, -8
    #sw      (sp+4), r11
    #sw      (sp+8), r12

    /* save fn and arg */
    #mv      r11, r1
    #mv      r12, r4
    addi    r2, r2, -12
    sw      (r2+8), r4
    sw      (r2+4), r1

    mvi     r8, __NR_clone
    scall

    bg      r0, r1, 0f

    be      r1, r0, __thread_start

    #lw      r11, (sp+4)
    #lw      r12, (sp+8)
    #addi    sp, sp, 8
    ret

__thread_start:
    mvi     fp, 0
    #mv      r1, r11
    #mv      r2, r12
    lw      r1, (sp+8)
    lw      r2, (sp+4)
    call    r2

    calli HIDDEN_JUMPTARGET(_exit)

    /* Stop the unstoppable.  */
9:
    bi      9b

1:
    #mvi     r3, -EINVAL
0:
    #calli   __errno_location
    #sw      (r1+0), r3
    mvi     r1, -1
    ret

#endif /* __NR_clone */

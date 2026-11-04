.file "sleep.s"

.section .rodata
data_usage_message: .asciz "Usage: sleep NUMBER\nPause for NUMBER seconds\n"
data_usage_message_len: .word 45
dt_invalid_num_arg_message: .asciz "Invalid <NUMBER> argument\n"
dt_invalid_num_arg_message_len: .word 26
dt_sleep_log_1: .asciz "Sleeping for "
dt_sleep_log_1_len: .word 13
dt_sleep_log_2: .asciz " seconds\n"
dt_sleep_log_2_len: .word 9

.set SYS_WRITE, 64
.set SYS_EXIT, 93
.set SYS_NANOSLEEP, 101
.set STDIN, 0
.set STDOUT, 1
.set STDERR, 2

.set EXIT_SUCCESS, 0
.set EXIT_INVALID_USAGE, 1
.set EXIT_INVALID_NUM_ARG, 2
.set EXIT_FAIL_WRITE, 8

# reference: https://github.com/valignatev/sleep-from-scratch/blob/master/sleep.c

.section .text

.globl _start
.p2align 2
.type _start, @function
_start:
        ld a0, 0(sp)
        addi a1, sp, 8
        call main
        li a7, SYS_EXIT
        ecall
        j .
.Lfn__start_end:
.size _start, .Lfn__start_end - _start


# main function
.globl main
.p2align 2
.type main, @function
main:
        # : prologue
        addi sp, sp, -16
        sd ra, 8(sp)
        sd s0, 0(sp)
        # : prologue end
        li t0, 2
        bne a0, t0, .Lmain_invalid_prog_usage
        ld s1, 8(a1)
.Lmain_read_prog_arg:
        mv a0, s1
        call parse_uint32
        li t0, -1
        beq a0, t0, .Lmain_invalid_num_arg
        mv s2, a0
.Lmain_log_sleep_seconds:
        li a0, STDOUT
        la a1, dt_sleep_log_1
        lw a2, dt_sleep_log_1_len
        li a7, SYS_WRITE
        ecall
        mv a0, s1
        call strlen
        mv a2, a0
        li a0, STDOUT
        mv a1, s1
        li a7, SYS_WRITE
        ecall
        li a0, STDOUT
        la a1, dt_sleep_log_2
        lw a2, dt_sleep_log_2_len
        li a7, SYS_WRITE
        ecall
.Lmain_sleep_for_seconds:
        mv a0, s2
        call sleep_seconds
        li a0, EXIT_SUCCESS
        j .Lmain_finish
.Lmain_invalid_prog_usage:
        li a0, STDERR
        la a1, data_usage_message
        lw a2, data_usage_message_len
        li a7, SYS_WRITE
        ecall
        li a0, EXIT_INVALID_USAGE
        j .Lmain_finish
.Lmain_invalid_num_arg:
        li a0, STDERR
        la a1, dt_invalid_num_arg_message
        lw a2, dt_invalid_num_arg_message_len
        li a7, SYS_WRITE
        ecall
        li a0, EXIT_INVALID_NUM_ARG
.Lmain_finish:
        # : epilogue
        ld ra, 8(sp)
        addi sp, sp, 16
        # : epilogue end
        ret
.Lfn_main_end:
.size main, .Lfn_main_end - main


# strlen
# a0 = string address
# return a0 = string length
.globl strlen
.p2align 2
.type strlen, @function
strlen:
        mv t0, a0
.Lstrlen_incr_size:
        lbu t1, 0(t0)
        beqz t1, .Lstrlen_done
        addi t0, t0, 1
        j .Lstrlen_incr_size
.Lstrlen_done:
        sub a0, t0, a0
        ret
.Lfn_strlen_end:
.size strlen, .Lfn_strlen_end - strlen


# parse_uint32
# a0 = string address
# return a0 = uint32. -1 when input is invalid
.globl parse_uint32
.p2align 2
.type parse_uint32, @function
parse_uint32:
        li t0, 0
        li t2, 48
        li t3, 57
        li t4, 10
.Lparse_uint32_digit_loop:
        lbu t1, 0(a0)
        beqz t1, .Lparse_uint32_done
        blt t1, t2, .Lparse_uint32_err
        bgt t1, t3, .Lparse_uint32_err
        sub t1, t1, t2
        mul t0, t0, t4
        add t0, t0, t1
        addi a0, a0, 1
        j .Lparse_uint32_digit_loop
.Lparse_uint32_done:
        mv a0, t0
        ret
.Lparse_uint32_err:
        li a0, -1
        ret
.Lfn_parse_uint32_end:
.size parse_uint32, .Lfn_parse_uint32_end - parse_uint32


# sleep_seconds
# a0 = seconds
.globl sleep_seconds
.p2align 2
.type sleep_seconds, @function
sleep_seconds:
        # : prologue
        addi sp, sp, -16
        # : prologue end
        sd a0, 0(sp)
        li t0, 0
        sd t0, 1(sp)
        mv a0, sp
        li a1, 0
        li a7, SYS_NANOSLEEP
        ecall
        # : epilogue
        addi sp, sp, 16
        # : epilogue end
        ret
.Lfn_sleep_seconds_end:
.size sleep_seconds, .Lfn_sleep_seconds_end - sleep_seconds

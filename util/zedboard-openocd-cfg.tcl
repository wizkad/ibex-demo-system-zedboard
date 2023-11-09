# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

adapter driver ftdi
transport select jtag

ftdi device_desc "Digilent USB Device"
ftdi vid_pid 0x0403 0x6014
ftdi channel 0
#ftdi_layout_init 0x0088 0x008b
reset_config srst_only srst_push_pull
ftdi tdo_sample_edge falling
ftdi layout_init 0x2088 0x3f8b
ftdi layout_signal nSRST -data 0x2000
ftdi layout_signal GPIO2 -data 0x2000
ftdi layout_signal GPIO1 -data 0x0200
ftdi layout_signal GPIO0 -data 0x0100

# Configure JTAG chain and the target processor
set _CHIPNAME riscv

# Configure JTAG expected ID
# Zedboard
set _EXPECTED_ID 0x03727093


#jtag newtap $_CHIPNAME cpu -irlen 6 -expected-id $_EXPECTED_ID -ignore-version
#set _TARGETNAME $_CHIPNAME.cpu
#target create $_TARGETNAME riscv -chain-position $_TARGETNAME

jtag newtap $_CHIPNAME cpu -irlen 6 -expected-id $_EXPECTED_ID
jtag newtap arm_unused tap -irlen 4 -expected-id 0x4ba00477

set _TARGETNAME $_CHIPNAME.cpu
target create $_TARGETNAME riscv -chain-position $_TARGETNAME -coreid 0x3e0

riscv set_ir idcode 0x09
riscv set_ir dtmcs 0x22
riscv set_ir dmi 0x23

adapter speed 10000

#riscv set_mem_acces progbuf
gdb_report_data_abort enable
gdb_report_register_access_error enable
gdb_breakpoint_override hard
reset_config none

init
halt

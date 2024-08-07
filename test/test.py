# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in[0].value = 1
    dut.ui_in[1].value = 1
    dut.ui_in[2].value = 1
    dut.uio_in.value = 1

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 10)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    bit_1 = dut.uo_out[1].value
    bit_0 = dut.uo_out[0].value
    assert (bit_1 << 1 | bit_0) == 0b11
    bit_3 = dut.uo_out[3].value
    bit_2 = dut.uo_out[2].value
    assert (bit_3 << 1 | bit_2) == 0b11

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    bit_1 = dut.uo_out[1].value
    bit_0 = dut.uo_out[0].value
    assert (bit_1 << 1 | bit_0) == 0b00

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.

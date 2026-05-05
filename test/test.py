import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


@cocotb.test()
async def test_pm32(dut):
    dut._log.info("Start")

    # ----------------------------
    # Clock
    # ----------------------------
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # ----------------------------
    # Reset
    # ----------------------------
    dut.ena.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # ----------------------------
    # Test values
    # ----------------------------
    mc = 113
    mp = 217

    dut.ui_in.value = mc
    dut.uio_in.value = mp

    await RisingEdge(dut.clk)

    # ----------------------------
    # Start pulse
    # ----------------------------
    dut.ena.value = 1
    await RisingEdge(dut.clk)
    dut.ena.value = 0

    dut._log.info("Start pulse issued")

    # ----------------------------
    # WAIT FOR DONE (KEY FIX)
    # ----------------------------
    dut._log.info("Waiting for done...")

    while int(dut.uio_out.value) & 1 == 0:
        await RisingEdge(dut.clk)

    dut._log.info("Done asserted")

    # ----------------------------
    # Optional settle time
    # ----------------------------
    await ClockCycles(dut.clk, 2)

    # ----------------------------
    # Read back result (byte-wise)
    # ----------------------------
    result = 0

    base = int(dut.uio_in.value) & 0xF8

    for i in range(8):
        dut.uio_in.value = base | i
        await RisingEdge(dut.clk)

        byte = int(dut.uo_out.value)
        dut._log.info(f"byte {i} = {byte:#04x}")

        result |= (byte << (8 * i))

    dut._log.info(f"Final result = {result}")

    # ----------------------------
    # Check correctness
    # ----------------------------
    expected = mc * mp
    assert result == expected, f"Expected {expected}, got {result}"

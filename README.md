# AHB-Lite Module with Burst, Error Recovery, and Data Integrity

## Overview
This repository contains a robust implementation of an AMBA 3 AHB-Lite module, fully compliant with the AHB-Lite protocol and optimized for single-master embedded systems such as microcontrollers. The module features full burst support (fixed and undefined-length), error recovery, and integrated data integrity protection, verified through a comprehensive UVM-based testbench.

## Key Features

- **Adaptive Burst Scripting**
  - Accepts `HSIZE` (8/16/32-bit) and `HBURST` (`INCR`, `INCR4`, `INCR8`, `INCR16`)
  - Automatically calculates address increments and drives `HTRANS` progression: `NONSEQ` → `SEQ` → `IDLE`

- **Flexible INCR-mode Bursts**
  - Supports undefined-length bursts without explicit counters
  - Detects burst termination by monitoring `HTRANS` transition from `SEQ` → `NONSEQ`/`IDLE`

- **Error-aware Retransmission**
  - Monitors `HRESP` on each beat
  - On `ERROR`, retains `HWDATA` and retransmits in the next `SEQ` cycle, ensuring protocol compliance and data consistency

- **HWDATACHK (Per-Byte Data Integrity Check)**
  - Introduces a 4-bit signal (`HWDATACHK`) alongside `HWDATA`
  - Each bit corresponds to an 8-bit lane of the 32-bit `HWDATA` bus
  - Generates even parity per byte before transmission
  - Enables independent single-bit corruption detection within any 8-bit segment
  - Provides lightweight end-to-end data integrity assurance without impacting the AHB-Lite protocol

## FSM Structure
The module uses a 4-state FSM:

1. **IDLE**: Waits for start signal and bus grant; drives `HTRANS = IDLE`.
2. **ADDR_PHASE**: Begins transfer (`HTRANS = NONSEQ`), sets burst parameters, initializes beat counter for fixed bursts.
3. **WAIT**: Holds signals stable if `HREADY = 0`, ensuring pipelining and setup compliance.
4. **DATA_PHASE**: On `HREADY = 1`, continues beats (`SEQ`), checks `HRESP`, manages error recovery and address progression, detects burst completion, and returns to `IDLE`.

## Verification
A UVM-based testbench validates:
- Correct burst sequencing and termination
- Accurate error-handling and retransmission
- Proper `HWDATACHK` parity generation and verification across all lanes

## Usage
1. Integrate module sources into your SystemVerilog project.
2. Refer to testbench examples for UVM-based verification.
3. Configure burst and data integrity features as needed for your application.

## License
This project is released under the MIT License.

---

*Developed and maintained by Vishnu1605DC.*
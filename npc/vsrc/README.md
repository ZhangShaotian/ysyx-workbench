# TOP Modules

## 0. top_running_light

The `top_running_light` module controls a running light pattern on a 16-LED array. The light shifts its position in a circular manner based on a clock input, creating a running light effect.

### Pin Description

- **clk**: Clock signal
- **rst (SW0)**: Reset signal, connected to switch `SW0`; resets the LED pattern to the initial state
- **led (LD0 to LD15)**: 16-bit LED output array (`LD0` to `LD15`) that displays the running light pattern

### Functionality

- The running light pattern starts with the first LED (`LD0`) on.
- The pattern shifts to the next LED in a circular fashion with each clock cycle.
- The speed of the running light can be controlled by adjusting the internal counter value.
- When `rst` (controlled by `SW0`) is asserted, the pattern resets to the initial state.

Connect the `clk` and `rst` signals to control the running light effect on the 16-LED array (`LD0` to `LD15`).

---

## 1. top_switch

The `top_switch` module interfaces with a simple XOR switch module. It takes two input switches (`sw0` and `sw1`) and produces an output to an LED (`led0`) based on the XOR operation.

### Pin Description

- **clk**: Clock signal (not used directly)
- **rst**: Reset signal (not used directly)
- **sw0**: First input switch
- **sw1**: Second input switch
- **led0**: LED output; displays the result of the XOR operation between `sw0` and `sw1`

Connect the input switches (`sw0` and `sw1`) to control the XOR output on `led0`.

---

## 2. top_mux_2x1_1bit

The `top_mux_2x1_1bit` module is a single-bit 2-to-1 multiplexer that outputs to an LED based on a selection input.

### Pin Description

- **clk**: Clock signal (not used directly)
- **rst**: Reset signal (not used directly)
- **sw0**: First input
- **sw1**: Second input
- **sw2**: Selection input; chooses between `sw0` and `sw1`
- **led0**: Output LED; displays the selected input value

Connect the inputs (`sw0`, `sw1`, `sw2`) to control the output on `led0`.

---

## 3. top_mux_4x1_2bit

The `top_mux_4x1_2bit` module is a 4-to-1 multiplexer for 2-bit signals. It selects one of the four 2-bit inputs packed into an 8-bit bus (`sw`) based on a 2-bit selection signal (`sel`) and outputs the selected 2-bit value to two LEDs (`led0` and `led1`).

### Pin Description

- **clk**: Clock signal (not used directly)
- **rst**: Reset signal (not used directly)
- **sw0 - sw9**: Input switches; `sw0` and `sw1` form the selection signal (`sel`), and `sw2` to `sw9` form the input data bus (`sw`).
- **led0**: First LED output (displays the first bit of the selected 2-bit value)
- **led1**: Second LED output (displays the second bit of the selected 2-bit value)

Connect the input switches (`sw0 - sw9`) to set the input values and selection signal, and observe the selected output on `led0` and `led1`.

---

## 4. top_encoder_display

The `top_encoder_display` module takes an 8-bit binary input and performs a priority encoding to generate a 3-bit binary output. It also includes an indicator output to signal if any of the 8 input bits are set. The 3-bit encoded result and the indicator are displayed on four LEDs, and the binary encoded result is converted and displayed in decimal format on a set of seven-segment displays.

### Pin Description

- **clk**: Clock signal
- **rst**: Reset signal
- **sw_toggle**: 8-bit input toggle switches (`sw7` ~ `sw0`)
- **sw_en**: Enable switch (`sw8`)
- **led_outputs**: 3-bit LED outputs (`led2` ~ `led0`)
- **led_indicator**: LED output indicator (`led4`)
- **seg0 to seg7**: Seven-segment display outputs (Display 0 to Display 7)

Connect the toggle switches (`sw7` ~ `sw0`) and the enable switch (`sw8`) to control the encoded output displayed on LEDs and seven-segment displays.

---

## 5. top_alu

The `top_alu` module implements a simple 4-bit signed ALU (Arithmetic Logic Unit) with various operations including addition, subtraction, bitwise operations, comparison, and more. The ALU can detect if the result is zero, if there is an overflow, or if there is a carry.

### Pin Description

- **clk**: Clock signal
- **rst**: Reset signal
- **sw_A**: 4-bit input A (`sw3` ~ `sw0`)
- **sw_B**: 4-bit input B (`sw7` ~ `sw4`)
- **sw_sel**: 3-bit selection switch (`sw10` ~ `sw8`), determines the operation:
  - `000`: A + B
  - `001`: A - B
  - `010`: Not A
  - `011`: A AND B
  - `100`: A OR B
  - `101`: A XOR B
  - `110`: If A < B, then out = 1; else out = 0
  - `111`: If A == B, then out = 1; else out = 0
- **led_result**: 4-bit LED output showing the result (`led3` ~ `led0`)
- **led6_overflow**: Overflow indicator (`led6`)
- **led5_zero**: Zero result indicator (`led5`)
- **led4_carry**: Carry indicator (`led4`)

Connect the switches to set the inputs and select the desired operation, and observe the result and status indicators on the LEDs.

---

## 6. top_shift_register

The `top_shift_register` module implements an 8-bit linear-feedback shift register (LFSR) to generate a pseudo-random sequence. The LFSR outputs an 8-bit binary value, which is displayed in hexadecimal format on a set of seven-segment displays.

### Pin Description

- **clk**: Clock signal
- **button_clk (BTNC)**: Clock input controlled by a button (`BTNC`) for manual stepping
- **rst (SW0)**: Reset signal, connected to switch `SW0`; resets the shift register to its initial state
- **seg0 to seg7**: Seven-segment display outputs that show the 8-bit binary value in hexadecimal format

### Functionality

- The LFSR generates a pseudo-random 8-bit sequence using feedback from specific bits (4, 3, 2, 0).
- Each clock cycle (triggered by `button_clk`), the register shifts right, with the leftmost bit calculated from the feedback of specific bits.
- The sequence generated has a period of 255, avoiding the all-zero state.
- The 8-bit output is displayed in hexadecimal format across two seven-segment displays (`seg0` and `seg1`).

Connect the `button_clk` for manual stepping and `rst` to initialize or reset the sequence, and observe the generated pseudo-random sequence on the seven-segment displays (`seg0` to `seg7`).

---

## 8. top_keyboard

The `top_keyboard` module interfaces with a PS/2 keyboard to display the scan code and ASCII code of the currently pressed key on a set of seven-segment displays. It also keeps track of the total number of key presses and displays this count.

### Pin Description

- **clk**: Clock signal
- **rst (Negative Reset)**: Reset signal, active low
- **ps2_data**: PS/2 keyboard data input
- **ps2_clk**: PS/2 keyboard clock input
- **seg0 to seg7**: Seven-segment display outputs
  - **seg0** to **seg1**: Display the scan code of the pressed key in hexadecimal format
  - **seg2** to **seg3**: Display the ASCII code of the pressed key in hexadecimal format
  - **seg4** to **seg5**: Unused, set to "off"
  - **seg6** to **seg7**: Display the total number of key presses

### Functionality

- **Scan Code and ASCII Display**: When a key is pressed, its scan code and corresponding ASCII code are displayed on the seven-segment displays (`seg0` to `seg3`).
- **Total Key Press Count**: Displays the total number of key presses on the seven-segment displays (`seg6` and `seg7`), counting each distinct key press.
- **Idle State**: When no key is pressed or a key is released, the lower four displays (`seg0` to `seg3`) are turned off.
- **Single Key Handling**: The module only considers single key presses and releases, without handling combinations or multiple simultaneous key presses.

Connect the `ps2_data` and `ps2_clk` to a PS/2 keyboard interface and observe the output on the seven-segment displays for the key scan and ASCII codes, as well as the total key press count.







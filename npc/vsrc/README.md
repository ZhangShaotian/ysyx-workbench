# top_mux_2x1_1bit

The `top_mux_2x1_1bit` module is a single-bit 2-to-1 multiplexer that outputs to an LED based on a selection input.

## Pin Description

- **clk**: Clock signal (not used directly)
- **rst**: Reset signal (not used directly)
- **sw0**: First input
- **sw1**: Second input
- **sw2**: Selection input; chooses between `sw0` and `sw1`
- **led0**: Output LED; displays the selected input value

Connect the inputs (`sw0`, `sw1`, `sw2`) to control the output on `led0`.


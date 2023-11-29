# CE355 Final Project – FPGA Tank Game

**Jackson Bremen and Talia Ben-Naim** -
**Northwestern University CE 355, Fall 2023**

**Contents**
- [CE355 Final Project – FPGA Tank Game](#ce355-final-project--fpga-tank-game)
  - [Introduction](#introduction)
  - [Design Process and Methodology](#design-process-and-methodology)
  - [System Architecture](#system-architecture)
    - [VGA Output](#vga-output)
    - [PS/2 Keyboard Input](#ps2-keyboard-input)
    - [7-Segment LED Display](#7-segment-led-display)
    - [Clock Counter](#clock-counter)
    - [Tank](#tank)
    - [Bullet](#bullet)
    - [Collision Detection](#collision-detection)
    - [Scoring](#scoring)
  - [Board Implementation and Peripherals](#board-implementation-and-peripherals)
  - [Simulation Figures and Testing Methodology](#simulation-figures-and-testing-methodology)
  - [Synthesis Results](#synthesis-results)
    - [Used memory:](#used-memory)
    - [Clocks:](#clocks)
    - [Resource utilization:](#resource-utilization)


## Introduction
For this project we implemented a basic tank game on the DE2-115 FPGA development board. The game is played by two players, each controlling a tank on opposite sides of the screen. The goal of the game is to shoot the other player’s tank before they shoot yours. The game is played on a 640x480 VGA display, and the tanks are controlled by a PS/2 keyboard. Scores are displayed on the 7-segement LED displays, and the winner of the game is displayed on a LCD display. The game is written in VHDL.

## Design Process and Methodology
The game was designed in a modular fashion, with each component of the game being implemented as a separate module. The modules were then integrated together to form the final game in a top-level module. The modules were tested individually using testbenches, then tested together in simulation, and then the game was tested as a whole on the FPGA.

We wanted to create a fully structural top-level module for our design, so each of these modules needed to operate independently of each other, and have outputs that could be directly connected to each other. Before beginning the project, we fully scaffolded out what each module would need to perform, the widths of each `std_logic` or `std_logic_vector` signal, and the inputs and outputs of each module. This allowed us to plan for a fully structural top-level module, and allowed us to easily integrate each module together.

Infrastructure modules were created first and leveraged the provided miniproject code. These modules included

 - VGA Controller
 - PS/2 Keyboard Controller
 - 7-segment LED Control
 - Clock Counter

We then scaffolded and mapped out the other modules needed. In addition to our top-level module, we needed to create modules for the following:

 - Tank
 - Bullet
 - Scoring
 - Collision Detection

Additionally, this design strategy allowed us to divide up the work, and work/test each module independently (see below for more details on our testing strategy).

**PLL:**
The base DE2-115 board has a 50 MHz clock, but for the purposes of the assignment we decided to use a 100 MHz clock. This allowed us to have a higher resolution game. To step between these speeds, we created a PLL module using the Quartus software that took in the 50 MHz clock and output a 100 MHz clock. This PLL module is located in our [pll.vhd](game/pll.vhd) file.

## System Architecture

### VGA Output
We created a custom module to generate pixels for the game, located in our [pixelGenerator.vhd](game/pixelGenerator.vhd) file.

### PS/2 Keyboard Input
To take in keyboard input, we used the PS2 module, located in our [ps2.vhd](game/ps2.vhd) file and the keyboard module located in our [keyboard.vhd](game/keyboard.vhd) file. The keyboard module takes in the PS2 module and outputs the key that was pressed. The keyboard module also debounces the input.

### 7-Segment LED Display
When a player scores a point, the score is displayed on the 7-segment LED display. The 7-segment LED display is controlled by the [de2lcd.vhd](game/de2lcd.vhd) file directly, with the char_buffer module [char_buffer.vhd](game/char_buffer.vhd) taking in the raw scores from the scoring module and converting them into a format that can be displayed on the 7-segment LED display.


### Clock Counter
Since the game clock is 100 MHz, we needed a way to produce a pulse considerably slower to allow for the game to be playable. We targeted a 30 fps game. To do this, we created a clock counter module, located in our [clock_counter.vhd](game/clock_counter.vhd) file. This module takes in the 100 MHz clock and has a 21 bit counter inside. When the counter equals zero (values are unsigned so when the value of $2^{21}-1=2097151$ is passed, the counter resets to zero), the module outputs a pulse. This pulse is used to advance the game logic. This results in an FPS of roughly $\frac{100 *10^{6} Hz}{2^{21}}=47.68$ pulses per second. Each pulse is one clock tick long.

### Tank
The tank module is located in our [tank.vhd](game/tank.vhd) file. The tank takes in a speed from 0-3. It moves in a direction until it reaches a side, in which case it bounces off and moves in the opposite direction. Tank stores its own position, and outputs this position to the top-level module. The tank also takes in a signal to let it know if it has lost the game, and should move off the screen.

### Bullet
The bullet module is located in our [bullet.vhd](game/bullet.vhd) file. When it recieves the fire signal, it moves to its tank's position, and begins to move. If it hits the opposite side, it moves off the screen. It has an input to let it know if it has it the other tank, and should move off the screen. The bullet stores its own position, and outputs this position to the top-level module.

### Collision Detection
The collision detection module is located in our [collision_detection.vhd](game/collision_detection.vhd) file. Two instances of this module are used, one to detect bullet1->tank2, and bullet2->tank1. The module takes in the positions of the two objects, and outputs a signal if they are colliding. It takes the sizes of each object as a generic. The module uses a simple bounding box collision detection algorithm. This algorithm was intentionally kept simple, and has a very short datapath when viewed in RTL.

### Scoring
The scoring module is located in our [scoring.vhd](game/scoring.vhd) file. @talia please fill this in i don't totaly get it


## Board Implementation and Peripherals
**RTL Schematic**
<!-- Add photo images/rtl-diagram.png -->
![RTL Schematic](images/rtl-diagram.png)

The game was compiled, elaborated, and programmed onto the DE2-115 board using the Quartus software, upladed via the USB-Blaster. As can be seen from the above screenshot, the final RTL schematic of the top-level module is structural, with each module being connected to each other. The top-level module is located in our [top_level.vhd](game/top_level.vhd) file.

To read from the PS/2 keyboard peripheral, we wait for an available scan code. We look at the current and most recent scan code. If the scan code is one of our chosen codes, we check to see if the previous code was the break code for the key; if it was, we know that the key was released, otherwise we know that the key was pressed. We use these inputs as control signals for an FSM to select and hold a speed that is then fed to the tank module.

To write to the VGA display, we use the pixel generator module to generate individual pixels, using the positions of the tanks and bullets to determine where to draw them. We then use the VGA controller module to output these pixels to the VGA display. ROM is used to store a color map, allowing us to easily use different colors for the tanks and bullets.

To write to the 7-segment LED display, TALIA WRITE SOMETHING

To write to the LCD display, TALIA WRITE SOMETHING

The other input is hardware button LED-G0 on the dev board, which is used to reset the game. When this button is pressed, the game resets and the score is cleared.


## Simulation Figures and Testing Methodology
As mentioned above, we created simple tests, fully testing one or two modules at a time in simulation before integrating them into larger tests. We chose to structure most of our tests using `assert` statements, as this allowed us to easily see if the test passed or failed. We also used `report` statements to print out the values of signals, and `wait` statements to pause the simulation. This allowed us to easily run many testbenches at the same time with a bash script to rapidly find issues. Each testbench operates independently, and has hard-coded inputs and outputs.


## Synthesis Results
**Includes memory, clocks, and resource utilization**

### Used memory:
192 / 3,981,312 ( < 1 % ) | Total block memory implementation bits:  9,216 / 3,981,312 ( < 1 % 

### Clocks:

| Clock Name                                     | Type      | Period | Frequency | Rise  | Fall   | Duty Cycle | Divide by | Multiply by | Master | Targets            | Slack Setup | Slack Hold |
|-----------------------------------------------:|-----------|--------|-----------|-------|--------|------------|-----------|-------------|--------|--------------------|-------------|------------|
| pll_unit\|altpll_component\|auto_generated\|pll1\|clk[0] | Generated | 10.000 | 100.0 MHz | 0.000 | 5.000  | 50.00      | 1         | 2           | SYSCLK | SYSCLK             | 1.598       | 0.402      |
| SYSCLK                                         | Base      | 20.000 | 50.0 MHz  | 0.000 | 10.000 |            |           |             |        | clk_50Mhz           | 4.032       | 0.405      |

### FMax:
###### Slow 1200mV 85C Model Fmax Summary
| Fmax       | Restricted Fmax | Clock Name                                           |
|------------|-----------------|------------------------------------------------------|
| 159.8 MHz  | 159.8 MHz       | pll_unit\|altpll_component\|auto_generated\|pll1\|clk[0] |
| 219.49 MHz | 219.49 MHz      | SYSCLK                                               |

The maximum frequency available is 159.8 MHz which is 59 MHz higher than the current maximum system frequency of 100 MHz.

The longest datapaths are from keyboard mapper to tank module, and has a data delay of 5.148 with skew of -3.202


### Resource utilization:

###### Fitter Resource Usage Summary

| Resource                                    | Usage                       |
|-------------------------------------------: |:--------------------------- |
| Total logic elements                        | 742 / 114,480 ( < 1 % )     |
|     -- Combinational with no register       | 463                         |
|     -- Register only                        | 49                          |
|     -- Combinational with a register        | 230                         |
|                                             |                             |
| Logic element usage by number of LUT inputs |                             |
|     -- 4 input functions                    | 211                         |
|     -- 3 input functions                    | 207                         |
|     -- <=2 input functions                  | 275                         |
|     -- Register only                        | 49                          |
|                                             |                             |
| Logic elements by mode                      |                             |
|     -- normal mode                          | 387                         |
|     -- arithmetic mode                      | 306                         |
|                                             |                             |
| Total registers*                            | 279 / 117,053 ( < 1 % )     |
|     -- Dedicated logic registers            | 279 / 114,480 ( < 1 % )     |
|     -- I/O registers                        | 0 / 2,573 ( 0 % )           |
|                                             |                             |
| Total LABs:  partially or completely used   | 56 / 7,155 ( < 1 % )        |
| Virtual pins                                | 0                           |
| I/O pins                                    | 63 / 529 ( 12 % )           |
|     -- Clock pins                           | 1 / 7 ( 14 % )              |
|     -- Dedicated input pins                 | 0 / 9 ( 0 % )               |
|                                             |                             |
| M9Ks                                        | 1 / 432 ( < 1 % )           |
| Total block memory bits                     | 192 / 3,981,312 ( < 1 % )   |
| Total block memory implementation bits      | 9,216 / 3,981,312 ( < 1 % ) |
| Embedded Multiplier 9-bit elements          | 0 / 532 ( 0 % )             |
| PLLs                                        | 1 / 4 ( 25 % )              |
| Global signals                              | 6                           |
|     -- Global clocks                        | 6 / 20 ( 30 % )             |
| JTAGs                                       | 0 / 1 ( 0 % )               |
| CRC blocks                                  | 0 / 1 ( 0 % )               |
| ASMI blocks                                 | 0 / 1 ( 0 % )               |
| Oscillator blocks                           | 0 / 1 ( 0 % )               |
| Impedance control blocks                    | 0 / 4 ( 0 % )               |
| Average interconnect usage (total/H/V)      | 0.3% / 0.3% / 0.2%          |
| Peak interconnect usage (total/H/V)         | 5.9% / 6.2% / 5.5%          |
| Maximum fan-out                             | 101                         |
| Highest non-global fan-out                  | 100                         |
| Total fan-out                               | 2952                        |
| Average fan-out                             | 2.55                        |

* Register count does not include registers inside RAM blocks or DSP blocks.



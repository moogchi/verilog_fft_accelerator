# Radix-2 FFT Accelerator - Verilog Implementation

Hardware implementation of a 64-point radix-2 decimation-in-time (DIT) Fast Fourier Transform accelerator in Verilog HDL.

## 📋 Overview

This Verilog implementation features:

- **64-point FFT** computation (configurable via parameters)
- **Radix-2 Decimation-in-Time (DIT)** algorithm
- **Single-cycle butterfly unit** for complex arithmetic
- **Dual-port SRAM** for in-place computation
- **Hierarchical state machine** control unit
- Complete testbench with spectral analysis verification

📖 **[Read the Full Technical Report (PDF)](radix2_fft.pdf)**

## 🏗️ Architecture

The design consists of several key modules:

### Top-Level Module (`fft_top.v`)

- Integrates all submodules
- Parameterized for flexibility (data width N=32, address width M=6 for 64-point FFT)
- Simple start/done handshake interface

### Control Unit (`control_unit.v`)

Implements a hierarchical state machine with:

- **States**: IDLE, LOAD, WRITE, UPDATE
- **Three nested loops**: Stage (outer), Group (middle), Pair (inner)
- **Address generation logic** for butterfly operations
- **Twiddle factor ROM addressing**

### Datapath (`fft_datapath.v`)

- Butterfly computation unit
- Complex multiplication with twiddle factors
- Register pipeline for A, B, and twiddle values

### Memory Components

- **Dual-Port SRAM** (`dual_port_sram.v`): Stores input/output data for in-place computation
- **Twiddle Factor ROM** (`twiddle_rom.v`): Pre-computed rotation coefficients

### Arithmetic Units

- **Complex Multiplier** (`complex_mult.v`): (a + jb) × (c + jd) = (ac - bd) + j(ad + bc)
- **Butterfly Adder** (`butterfly_add.v`): Computes A' = A + W×B and B' = A - W×B

## 📁 File Structure

```
verilog/
├── README.md              # This file
├── fft_top.v              # Top-level integration
├── control_unit.v         # FSM and address generation
├── fft_datapath.v         # Computational datapath
├── dual_port_sram.v       # Dual-port memory
├── twiddle_rom.v          # Twiddle factor storage
├── complex_mult.v         # Complex multiplication
├── butterfly_add.v        # Butterfly computation
├── fft_tb.v               # Testbench with stimulus
├── fft.vcd                # Waveform dump file
├── my_fft                 # Compiled simulation executable
└── radix2_fft.pdf         # FFT algorithm reference
```

## 🚀 Getting Started

### Prerequisites

- **Icarus Verilog** (iverilog) for simulation
- **GTKWave** for waveform viewing

### Installation

On Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install iverilog gtkwave
```

On macOS:

```bash
brew install icarus-verilog gtkwave
```

### Building and Running

1. **Compile the design:**

```bash
cd verilog/
iverilog -o my_fft fft_top.v control_unit.v fft_datapath.v \
         dual_port_sram.v twiddle_rom.v complex_mult.v \
         butterfly_add.v fft_tb.v
```

2. **Run simulation:**

```bash
vvp my_fft
```

3. **View waveforms:**

```bash
gtkwave fft.vcd
```

## 🧪 Testing and Verification

The testbench (`fft_tb.v`) includes:

- **64-point cosine wave** input generation
- **Bit-reversal addressing** for DIT FFT input ordering
- Automatic stimulus generation using system functions
- Waveform dumping for analysis

### Test Signals

- **Impulse Response**: Verifies correct frequency domain spreading
- **Single Frequency Sinusoid**: Validates frequency isolation and magnitude accuracy

### Expected Results

- Clean spectral peaks at expected frequency bins
- Theoretical magnitude accuracy (amplitude × N/2)
- Phase coherence across the transform

## 📊 Performance Characteristics

- **FFT Size**: 64 points (configurable)
- **Data Width**: 32 bits (16-bit real + 16-bit imaginary)
- **Latency**: O(N log₂ N) cycles
- **Throughput**: One complete FFT per (N log₂ N) + overhead cycles
- **Memory**: In-place computation (single N-word RAM)

## 📖 Algorithm Details

The implementation follows the **Cooley-Tukey radix-2 DIT algorithm**:

1. **Bit-reversal** input ordering
2. **log₂(N) stages** of butterfly computations
3. Each stage processes **N/2 butterflies**
4. **Twiddle factors** W_N^k = e^(-j2πk/N)

### Butterfly Operation

```
A' = A + W × B
B' = A - W × B
```

Where W is the complex twiddle factor from ROM.

## 🔧 Configuration

The design is parameterized for easy modification:

```verilog
module fft_top #(
    parameter N = 32,  // Data Width (bits)
    parameter M = 6    // Address Width (log₂ of FFT size)
)(...)
```

To change FFT size:

- **16-point FFT**: M = 4
- **32-point FFT**: M = 5
- **64-point FFT**: M = 6
- **128-point FFT**: M = 7

## Author

**Sihoon Kim**  
New York University  
Email: sk11977@nyu.edu

## Known Issues / Future Work

- [ ] Add support for inverse FFT (IFFT)
- [ ] Implement radix-4 for improved efficiency
- [ ] Add pipelining for higher throughput
- [ ] Create automated test suite with multiple test vectors
- [ ] Add overflow detection and saturation logic

## 📚 References

See `radix2_fft.pdf` for the FFT algorithm reference and detailed technical documentation.

---

_Last updated: January 2026_

# FPGA vs. GPU: AI Inference Efficiency
### Independent Engineering Research Project

Researching the performance tradeoffs between GPUs and FPGAs for artificial intelligence inference, focusing on latency, accuracy, power consumption, and environmental impact.

---

### Research Question
Can customized FPGA hardware perform AI inference with significantly lower power consumption than GPUs while maintaining acceptable processing speed and classification accuracy?

### Project Overview
I developed a 3-layer multilayer perceptron (MLP) using PyTorch and the MNIST handwritten-digit dataset, and designed a corresponding Verilog-based hardware architecture targeting a Xilinx Artix-7 FPGA.

The two implementations were evaluated and compared across inference latency, classification accuracy, power consumption, and energy efficiency.

### Technologies & Tools
- **Software & Training:** Python, PyTorch, Google Colab
- **Hardware Simulation:** Verilog HDL, EDA Playground, ModelSim / Icarus Verilog
- **Target Architecture:** NVIDIA T4 GPU vs. Xilinx Artix-7 FPGA (XC7A35T)
- **Key Metrics:** Single-sample latency, throughput, dynamic power dissipation, energy per inference

### Neural Network Architecture
- **Input:** 784 pixels (28x28 normalized grayscale)
- **Hidden Layer 1:** 128 neurons + ReLU
- **Hidden Layer 2:** 64 neurons + ReLU
- **Output:** 10 classifications (Digits 0-9)
- **Total Parameters:** 109,184 trainable weights and biases

### Repository Organization


### Key Experimental Results
- **Latency (batch = 1):** GPU ~0.22 ms vs. FPGA ~3.3 ms
- **Power Dissipation:** NVIDIA T4 ~70 W active vs. Artix-7 ~1.5 W estimated
- **Classification Accuracy:** 97.2% baseline PyTorch accuracy maintained across fixed-point quantization
- **Efficiency Takeaway:** For low-power edge inference where high-wattage GPUs are impractical, customized FPGA logic offers orders-of-magnitude lower power consumption.

*Note: GPU benchmarks were measured via Google Colab with background  telemetry threads. FPGA performance and power dissipation were modeled and simulated via EDA Playground based on Xilinx Artix-7 specifications.*

### Limitations & Future Work
- Physical deployment to a physical Digilent Basys 3 / Nexys A7 FPGA development board
- Direct shunt-resistor current measurement on hardware power rails
- INT8 / INT4 post-training quantization to reduce memory footprint and latency

---

### Author
**Jake Julius**  
Livingston High School | 11th Grade  
Independent Engineering Research (2026)

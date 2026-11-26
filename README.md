# FPGA vs. GPU: AI Inference Efficiency
### Independent Engineering Research Project

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/18HvLPhz4SPJqvFHclQOzio-YGFWM5YL9#scrollTo=V7zxX-8dhvRt)
[![Simulation: EDA Playground](https://img.shields.io/badge/Simulation-EDA%20Playground-blue.svg)](https://edaplayground.com/x/nwsj)
[![Live Portfolio](https://img.shields.io/badge/Portfolio-Interactive%20Charts-success.svg)](https://jakejulius-portfolio.vercel.app/projects/fpga-vs-gpu)

Researching the performance tradeoffs between GPUs and FPGAs for artificial intelligence inference, focusing on latency, accuracy, power consumption, and environmental impact.

---

### Research Question
Can customized FPGA hardware perform AI inference with significantly lower power consumption than GPUs while maintaining acceptable processing speed and classification accuracy?

### Interactive Research Portfolio
Interactive charts, 12-week development timeline, and architecture diagrams:
- **Interactive Portfolio & Report:** [https://jakejulius-portfolio.vercel.app/projects/fpga-vs-gpu](https://jakejulius-portfolio.vercel.app/projects/fpga-vs-gpu)

### Live Experiments & Code
- **Google Colab Notebook (PyTorch & GPU Benchmarks):** [Open in Google Colab](https://colab.research.google.com/drive/18HvLPhz4SPJqvFHclQOzio-YGFWM5YL9#scrollTo=V7zxX-8dhvRt)
- **EDA Playground (Verilog RTL Simulation):** [Open Simulation on EDA Playground](https://edaplayground.com/x/nwsj)

---

### Repository Structure


---

### Technologies & Tools
- **Software & Training:** Python 3, PyTorch, Google Colab (NVIDIA T4 GPU)
- **Hardware Design & Simulation:** Verilog HDL, EDA Playground, Icarus Verilog
- **Target Architectures:** NVIDIA T4 GPU vs. Xilinx Artix-7 FPGA (XC7A35T)
- **Key Metrics:** Single-sample latency, throughput, dynamic power dissipation, energy per inference

### Neural Network Architecture
- **Input:** 784 pixels (28x28 normalized grayscale)
- **Hidden Layer 1:** 128 neurons + ReLU
- **Hidden Layer 2:** 64 neurons + ReLU
- **Output:** 10 classifications (Digits 0-9)
- **Total Parameters:** 109,184 trainable weights and biases

### Key Experimental Results
- **Latency (batch = 1):** GPU ~0.22 ms vs. FPGA ~3.3 ms
- **Power Dissipation:** NVIDIA T4 ~70 W active vs. Artix-7 ~1.5 W estimated
- **Classification Accuracy:** 97.2% baseline PyTorch accuracy maintained across fixed-point quantization
- **Efficiency Takeaway:** For low-power edge inference where high-wattage GPUs are impractical, customized FPGA logic offers orders-of-magnitude lower power consumption.

*Note: GPU benchmarks were measured via Google Colab with background telemetry threads. FPGA performance and power dissipation were modeled and simulated via EDA Playground based on Xilinx Artix-7 specifications.*

### How to Run
1. **Google Colab:** Open the notebook link above to view model training, accuracy evaluation across Float32 vs INT8, latency profiling, and weight export.
2. **EDA Playground:** Open the EDA Playground link above, select Icarus Verilog as the simulator, and click **Run** to execute the testbench.

---

### Author
**Jake Julius**  
Livingston High School | 11th Grade  
Independent Engineering Research (2026)

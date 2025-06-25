# fonfDNN: Hybrid Deep Tensor Network for Function-on-Function Regression

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

`fonfDNN` is an R package implementing a cutting-edge **hybrid deep tensor network (HDTN)** for **function-on-function regression** with both **functional** and **scalar** predictors.  
The method blends the interpretability of **B-spline tensor products** with the flexibility of **deep neural networks**, and features **distribution-free conformal prediction intervals**.

---

## ⚠️ Prerequisite: A Working Python 3 Installation

`fonfDNN` calls **Keras** / **TensorFlow** through the **reticulate** bridge.  
When the package is first loaded it tries to create a Python virtual environment; without a real Python executable you will see

---


*(Windows users often have only the Microsoft-Store “stub” `python.exe`, which is not sufficient.)*

> **You must make a full Python ≥ 3.8 available to R.**  
> Either of the following options works:

| Option | Command / Link | Notes |
|--------|----------------|-------|
| **System Python** | <https://www.python.org/downloads/> | Install and restart R; `python --version` (or `python3`) should work in a terminal. |
| **reticulate helper** | `reticulate::install_python(version = "3.11.9")` | Downloads a self-contained Miniconda and registers it with R—no admin rights needed. |

---

## 🔧 Installation

```r
# 0. (If needed) install devtools
install.packages("devtools")

# 1. Install fonfDNN from GitHub
devtools::install_github("UfukBeyaztas/fonfDNN")

# 2. Install TensorFlow/Keras once in the chosen Python environment
tensorflow::install_tensorflow()   # from the 'tensorflow' R package

---

📄 Documentation

A full user manual is included with detailed function references, usage examples, implementation notes, and theoretical background.

📘 Manual: fonfDNN_1.0.pdf — the official manual for fonfDNN v1.0.

---

❓ Troubleshooting
Symptom	Likely Cause	Fix
Suitable Python installation for creating a venv not found	No real Python executable on the PATH	Install Python from python.org or run reticulate::install_python()
ModuleNotFoundError: No module named 'tensorflow'	TensorFlow not yet installed in that environment	Run tensorflow::install_tensorflow()
Keras/TensorFlow loads but the GPU is not used	CUDA/cuDNN mismatch	Re-install TensorFlow with tensorflow::install_tensorflow(version = "gpu") and follow the printed CUDA guidance

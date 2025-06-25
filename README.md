# fonfDNN: Hybrid Deep Tensor Network for Function-on-Function Regression

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

`fonfDNN` is an R package implementing a cutting-edge **hybrid deep tensor network (HDTN)** for **function-on-function regression** with both **functional** and **scalar** predictors.  
The method blends the interpretability of **B-spline tensor products** with the flexibility of **deep neural networks**, and features **distribution-free conformal prediction intervals**.

---

## ⚠️  Prerequisite: A Working Python 3 Installation
`fonfDNN` relies on **Keras** and **TensorFlow** via the **reticulate** bridge. When the package is first loaded, it tries to create a Python virtual environment:

Suitable Python installation for creating a venv not found.


If you see the message above (or similar “cannot open file … python.exe” warnings), R could not find a real Python executable—often because only the Microsoft-Store **stub** is present on Windows.

> **You must have a full Python 3 (≥ 3.8) installation available to R.**  
> Any one of the following satisfies the requirement:

| Option | Command / Link | Notes |
|--------|----------------|-------|
| **System Python** | <https://www.python.org/downloads/> | Install, then restart R. `python3 --version` should work in a terminal. |
| **reticulate helper** | `reticulate::install_python(version = "3.11.9")` | Downloads a self-contained Miniconda and registers it with R only—no admin rights needed. |

Once Python is in place, load the package and let it install TensorFlow/Keras automatically:

```r
library(fonfDNN)
fonfDNN::install_tensorflow()  # runs once

# 1. Install devtools if needed
install.packages("devtools")

# 2. Install fonfDNN from GitHub
devtools::install_github("UfukBeyaztas/fonfDNN")

# 3. (First time only) Set up TensorFlow/Keras
library(fonfDNN)
fonfDNN::install_tensorflow()

A full user manual is available with comprehensive documentation for all functions, usage examples, implementation details, and theoretical background.

📘 Manual: fonfDNN_1.0.pdf — the official manual for fonfDNN v1.0.

❓ Troubleshooting

| Symptom                                                      | Likely Cause                                    | Fix                                                                      |
| ------------------------------------------------------------ | ----------------------------------------------- | ------------------------------------------------------------------------ |
| `Suitable Python installation for creating a venv not found` | No real Python executable on the PATH           | Install Python from python.org **or** run `reticulate::install_python()` |
| `ModuleNotFoundError: No module named 'tensorflow'`          | TensorFlow not yet installed in the environment | Run `fonfDNN::install_tensorflow()`                                      |


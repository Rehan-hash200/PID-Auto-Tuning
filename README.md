# Advanced PID Controller with Auto-Tuning & Plant Simulator

[![IEC 61131-3](https://img.shields.io/badge/Language-Structured%20Text-blue)]()
[![Automation](https://img.shields.io/badge/Domain-Industrial%20Control-orange)]()

## Overview
Modul kontrol PID *high-performance* yang dikembangkan dalam bahasa Structured Text (IEC 61131-3). Modul ini bukan sekadar blok PID standar; ia dilengkapi dengan *Auto-Tuning Engine* yang cerdas dan *Process Plant Simulator* internal untuk validasi *offline* tanpa memerlukan hardware fisik.

---

## 🚀 Key Features

### 1. Advanced Auto-Tuning Engine
Modul ini secara otomatis menghitung parameter PID (Kp, Ki, Kd) menggunakan *Step-Response* atau *Relay Method*. Mendukung 12 algoritma tuning industri untuk berbagai karakteristik proses:

| Method ID | Tuning Method |
| :--- | :--- |
| 0 | Ziegler-Nichols (Classic) |
| 1 | Ziegler-Nichols (PI) |
| 2 | Ziegler-Nichols (P only) |
| 3-5 | Advanced/Refined Tuning |
| 6-11 | Specialized Control Response (Cohen-Coon & variations) |

### 2. Integrated Process Plant Simulator
Validasi logika kontrol Anda tanpa risiko merusak mesin fisik. Simulator internal mencakup:
* **Deadtime Compensation:** Simulasi *transport delay* menggunakan *Delay Buffer* (kapasitas 200 step).
* **Dynamic Response:** Simulasi orde pertama (*First-order response*) dengan variabel *Time Constant*.
* **Noise Injection:** Simulasi *real-world sensor noise* menggunakan superposisi gelombang sinus.
* **Disturbance Simulation:** Fitur *step disturbance* otomatis untuk menguji kestabilan kontrol (AutoTest).

### 3. Robust Control Logic
* **Anti-Windup:** Proteksi integral saturasi agar output tetap stabil.
* **Bumpless Transfer:** Transisi halus antara mode *Manual* dan *Auto*.
* **Safety Features:** Manajemen saturasi MV (Manipulated Variable) dengan batasan min/max yang terproteksi.

---

## Technical Specifications
* **Programming Language:** Structured Text (IEC 61131-3)
* **Sampling:** Real-time compliant, adjustable `SampleTime`.
* **Deployment:** Kompatibel dengan controller standar industri (Omron Sysmac, dsb).

## Implementation Guide
1. **Integration:** Salin file `PID_Controller_AutoTune.st` ke POU Anda.
2. **Configuration:** Tentukan `SampleTime`, `MV_Min`, `MV_Max`, dan `TuningMethod`.
3. **Simulation:** Set `Enable := TRUE` dan pantau `PV` serta `MV`. Gunakan `AutoTuneEnable` untuk memulai proses identifikasi sistem secara otomatis.

---
*Disclaimer: Modul ini dirancang untuk tujuan edukasi dan pengembangan profesional. Selalu lakukan audit keamanan sistem sebelum mengimplementasikan kontrol PID pada mesin industri yang krusial.*

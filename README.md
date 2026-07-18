# Smart Bottle Factory & Advanced Control System

[![IEC 61131-3](https://img.shields.io/badge/Language-Structured%20Text-blue)]()
[![Automation](https://img.shields.io/badge/Domain-Industrial%20Automation-green)]()

## Overview
Repositori ini berisi dua modul utama untuk pengembangan sistem otomasi industri:
1. **Digital Twin Bottling Simulation:** Simulasi lini produksi botol yang mencakup pelacakan produk (shift register), kontrol sekuensial, dan perhitungan OEE secara real-time.
2. **Advanced PID Controller:** Modul kontrol loop tertutup dengan fitur Auto-Tuning dan simulasi proses internal (plant simulator).

Proyek ini dirancang untuk menunjukkan keahlian dalam pemrograman **Structured Text (IEC 61131-3)** dan logika kontrol industri tingkat lanjut.

## Key Features

### 1. Bottling Line Simulation
*   **Sequential Data Tracking (Shift Register):** Melacak status botol secara individual.
*   **State Machine Management:** Implementasi `CASE` statement untuk manajemen mode operasi (IDLE, RUNNING, ALARM).
*   **OEE & Analytics:** Perhitungan *Overall Equipment Effectiveness* secara real-time.
*   **Integrated Process Control:** Kontrol pengisian, penutupan, pelabelan, dan *reject handling*.

### 2. PID Control & Auto-Tuning Module
*   **Dynamic Auto-Tuning:** Mendukung berbagai metode tuning (Ziegler-Nichols, Cohen-Coon, dll) untuk optimasi parameter Kp, Ki, dan Kd secara otomatis.
*   **Built-in Plant Simulator:** Simulasi sistem closed-loop mandiri di dalam PLC, termasuk *deadtime buffer* (transport delay), *first-order response*, dan *noise injection* untuk pengujian offline.
*   **Production-Ready:** Dilengkapi dengan *anti-windup logic* dan manajemen saturasi untuk stabilitas proses yang tinggi.

## Code Structure
```text
/src
├── 1_StateMachine.st          # Main logic & sequencer
├── 2_Filling_Station.st       # Filling process control
├── 3_Inspection_Reject.st     # Quality gate logic
├── 4_Statistics_OEE.st        # KPI & Analytics
└── PID_Controller_AutoTune.st # PID module with Auto-Tuning & Plant Simulator

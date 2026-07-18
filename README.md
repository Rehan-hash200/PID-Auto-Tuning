# Advanced PID Controller with Auto-Tuning & Simulation

[![IEC 61131-3](https://img.shields.io/badge/Language-Structured%20Text-blue)]()
[![Control-Theory](https://img.shields.io/badge/Domain-Control%20Engineering-orange)]()

## Overview
Modul kontrol PID tingkat lanjut yang dikembangkan dalam bahasa **Structured Text (IEC 61131-3)**. Modul ini dirancang untuk menyediakan kontrol *closed-loop* yang handal dengan tambahan algoritma *Auto-Tuning* dan sistem simulasi proses internal.

## Key Features
* **Dynamic Auto-Tuning:** Mengotomatisasi penentuan parameter (Kp, Ki, Kd) menggunakan metode *step-response* atau *relay*.
* **Integrated Plant Simulator:** Simulasi sistem fisik di dalam PLC (mencakup *Deadtime*, *Time Constant*, dan *Noise Injection*) untuk memungkinkan pengujian *offline* tanpa hardware fisik.
* **Robust Design:** Dilengkapi dengan *Anti-windup*, *Bumpless Manual-to-Auto Transfer*, dan manajemen saturasi.
* **Production-Ready:** Kode terstruktur dan modular untuk integrasi mudah ke dalam sistem kontrol industri.

## File Structure
* `PID_Controller_AutoTune.st` - Modul utama berisi logika PID, Auto-Tuning, dan Plant Simulator.

## Getting Started
1. Salin isi `PID_Controller_AutoTune.st` ke dalam POU (Program Organization Unit) pada software PLC Anda (misalnya Sysmac Studio).
2. Sesuaikan parameter `SampleTime`, `MV_Limits`, dan `TuningMethod` sesuai kebutuhan proses Anda.
3. Gunakan mode simulasi internal untuk memverifikasi respon sistem sebelum diimplementasikan pada mesin nyata.

## License
Proyek ini dilisensikan di bawah [MIT License](LICENSE).

---
*Disclaimer: Modul ini ditujukan untuk tujuan edukasi dan pengembangan. Selalu lakukan validasi dan pengujian keamanan (Safety Audit) sebelum mengimplementasikan kontrol PID pada mesin industri yang krusial.*

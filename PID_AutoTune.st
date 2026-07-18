IF (NOT Enable) OR Reset THEN
    // ---- Reset semua state ----
    MV              := MV_Min;
    Integral        := 0.0;
    Derivative      := 0.0;
    PrevPV          := PV;
    FirstScan       := TRUE;
    AT_State        := 0;
    AT_ExecPrev     := FALSE;
    AT_Timer        := 0.0;
    AT_StableCount  := 0;
    AT_DeadCaptured := FALSE;
    AT_T_L          := 0.0;
    AutoTuneBusy    := FALSE;
    AutoTuneDone    := FALSE;
    AutoTuneFault   := FALSE;
    AutoTuneFaultID := 0;
    Saturated       := FALSE;
    auto_started    := FALSE;
    AutoTuneEnable  := FALSE;

ELSIF AutoTuneEnable THEN
    // ============================================================
    //  AUTO-TUNE MODE (mulai otomatis)
    // ============================================================
    IF NOT auto_started THEN
        auto_started := TRUE;
        IF SampleTime <= 0.0 THEN
            AT_State := 5; AutoTuneFault := TRUE; AutoTuneFaultID := 20;
        ELSIF RelayAmplitude <= 0.0 THEN
            AT_State := 5; AutoTuneFault := TRUE; AutoTuneFaultID := 21;
        ELSIF MV_Max <= MV_Min THEN
            AT_State := 5; AutoTuneFault := TRUE; AutoTuneFaultID := 22;
        ELSIF TuneTimeout <= 0.0 THEN
            AT_State := 5; AutoTuneFault := TRUE; AutoTuneFaultID := 23;
        ELSIF PV_SafetyBand < 0.0 THEN
            AT_State := 5; AutoTuneFault := TRUE; AutoTuneFaultID := 24;
        ELSE
            AT_State := 1;
            AT_Timer := 0.0;
            AT_PV_Initial := PV;
            AT_MV_Initial := MV;
            AT_PV_Prev := PV;
            AT_StableCount := 0;
            AT_DeadCaptured := FALSE;
            AT_T_L := 0.0;
            AutoTuneBusy := TRUE;
            AutoTuneDone := FALSE;
            AutoTuneFault := FALSE;
            AutoTuneFaultID := 0;
        END_IF;
    END_IF;

    CASE AT_State OF
        1:  // Terapkan step MV
            MV := AT_MV_Initial + RelayAmplitude;
            IF MV < MV_Min THEN MV := MV_Min; ELSIF MV > MV_Max THEN MV := MV_Max; END_IF;
            AT_State := 2;

        2:  // Tunggu respons
            AT_Timer := AT_Timer + SampleTime;
            IF NOT AT_DeadCaptured THEN
                IF ABS(PV - AT_PV_Initial) >= PV_SafetyBand THEN
                    AT_T_L := AT_Timer;
                    AT_DeadCaptured := TRUE;
                END_IF;
            END_IF;
            IF ABS(PV - AT_PV_Prev) < 0.01 THEN
                AT_StableCount := AT_StableCount + 1;
            ELSE
                AT_StableCount := 0;
            END_IF;
            AT_PV_Prev := PV;
            IF (AT_StableCount >= TO_INT(5.0 / SampleTime)) OR (AT_Timer >= TuneTimeout) THEN
                AT_PV_Final := PV;
                AT_State := 3;
            END_IF;

        3:  // Hitung parameter PID
            IF ABS(MV - AT_MV_Initial) > 1.0E-6 THEN
                K_gain := (AT_PV_Final - AT_PV_Initial) / (MV - AT_MV_Initial);
            ELSE
                K_gain := 0.0;
            END_IF;
            IF AT_DeadCaptured THEN L_deadtime := AT_T_L; ELSE L_deadtime := 0.1; END_IF;
            IF L_deadtime < 0.05 THEN L_deadtime := 0.05; END_IF;
            T_timeconst := (AT_Timer - L_deadtime) / 4.0;
            IF T_timeconst < 0.1 THEN T_timeconst := 0.1; END_IF;

            IF (ABS(K_gain) > 1.0E-6) AND (L_deadtime > 0.0) THEN
                CASE TuningMethod OF
                    0:  Kp := 1.2 * T_timeconst / (K_gain * L_deadtime);
                        Ki := Kp / (2.0 * L_deadtime);
                        Kd := Kp * 0.5 * L_deadtime;
                    1:  Kp := 0.9 * T_timeconst / (K_gain * L_deadtime);
                        Ki := Kp / (3.33 * L_deadtime);
                        Kd := 0.0;
                    2:  Kp := T_timeconst / (K_gain * L_deadtime);
                        Ki := 0.0; Kd := 0.0;
                    3:  Kp := (1.0/K_gain) * (T_timeconst/L_deadtime) * (1.333 + (L_deadtime/T_timeconst)/4.0);
                        Ki := Kp / (L_deadtime * (32.0 + 6.0*(L_deadtime/T_timeconst)) / (13.0 + 8.0*(L_deadtime/T_timeconst)));
                        Kd := Kp * (4.0*L_deadtime / (11.0 + 2.0*(L_deadtime/T_timeconst)));
                    4:  Kp := (1.0/K_gain) * (T_timeconst/L_deadtime) * (0.9 + (L_deadtime/T_timeconst)/12.0);
                        Ki := Kp / (L_deadtime * (30.0 + 3.0*(L_deadtime/T_timeconst)) / (9.0 + 20.0*(L_deadtime/T_timeconst)));
                        Kd := 0.0;
                    5:  Kp := (1.0/K_gain) * (T_timeconst/L_deadtime) * (1.0 + (L_deadtime/T_timeconst)/3.0);
                        Ki := 0.0; Kd := 0.0;
                    6:  Kp := (2.0*T_timeconst + L_deadtime) / (K_gain * 2.0 * L_deadtime);
                        Ki := Kp / (T_timeconst + 0.5*L_deadtime);
                        Kd := Kp * (T_timeconst*L_deadtime) / (2.0*T_timeconst + L_deadtime);
                    7:  Kp := T_timeconst / (K_gain * L_deadtime);
                        Ki := Kp / T_timeconst;
                        Kd := 0.0;
                    8:  Kp := T_timeconst / (K_gain * 2.0 * L_deadtime);
                        Ki := 0.0; Kd := 0.0;
                    9:  Kp := 0.6 * T_timeconst / (K_gain * L_deadtime);
                        Ki := Kp / T_timeconst;
                        Kd := Kp * 0.5 * L_deadtime;
                    10: Kp := 0.95 * T_timeconst / (K_gain * L_deadtime);
                        Ki := Kp / (1.357 * T_timeconst);
                        Kd := Kp * 0.473 * L_deadtime;
                    11: Kp := 0.6 * T_timeconst / (K_gain * L_deadtime);
                        Ki := Kp / L_deadtime;
                        Kd := Kp * 0.5 * L_deadtime;
                ELSE Kp := 1.2 * T_timeconst / (K_gain * L_deadtime);
                     Ki := Kp / (2.0 * L_deadtime);
                     Kd := Kp * 0.5 * L_deadtime;
                END_CASE;
                IF Kp < 0.0 THEN Kp := 0.0; ELSIF Kp > 100.0 THEN Kp := 100.0; END_IF;
                IF Ki < 0.0 THEN Ki := 0.0; ELSIF Ki > 50.0 THEN Ki := 50.0; END_IF;
                IF Kd < 0.0 THEN Kd := 0.0; ELSIF Kd > 50.0 THEN Kd := 50.0; END_IF;
                AT_State := 4;
            ELSE
                AT_State := 5;
                AutoTuneFault := TRUE;
                AutoTuneFaultID := 10;
            END_IF;

        4:  // Selesai
            AutoTuneBusy := FALSE;
            AutoTuneDone := TRUE;
            AutoTuneFault := FALSE;
            MV := MV_Bias;
            Integral := 0.0;
            PrevPV := PV;
            FirstScan := TRUE;
            AT_State := 0;
            AutoTuneEnable := FALSE;   // otomatis pindah ke PID normal
            auto_started := FALSE;

        5:  // Fault
            AutoTuneBusy := FALSE;
            AutoTuneFault := TRUE;
            AutoTuneDone := FALSE;
            MV := MV_Bias;
            AT_State := 0;
            AutoTuneEnable := FALSE;
            auto_started := FALSE;

        ELSE
            AutoTuneBusy := FALSE;
            MV := MV_Bias;
    END_CASE;

ELSE
    // ============================================================
    //  MODE PID NORMAL (AutoTuneEnable = FALSE)
    // ============================================================
    AT_State := 0;
    AT_ExecPrev := FALSE;
    auto_started := FALSE;

    IF FirstScan THEN
        PrevPV := PV;
        FirstScan := FALSE;
    END_IF;

    Error := SP - PV;

    // Derivative (PV-based)
    IF SampleTime > 0.0 THEN
        Derivative := -(PV - PrevPV) / SampleTime;
    ELSE
        Derivative := 0.0;
    END_IF;

    // Integral
    IF Manual THEN
        IF ABS(Ki) > 1.0E-9 THEN
            Integral := (MV_Manual - Kp * Error - Kd * Derivative) / Ki;
        END_IF;
    ELSE
        Integral := Integral + Error * SampleTime;
    END_IF;

    MV_unclamped := Kp * Error + Ki * Integral + Kd * Derivative;

    // Anti-windup dan batas output
    IF MV_unclamped > MV_Max THEN
        MV := MV_Max;
        Saturated := TRUE;
        IF NOT Manual THEN
            IF Error > 0.0 THEN Integral := Integral - Error * SampleTime; END_IF;
        END_IF;
    ELSIF MV_unclamped < MV_Min THEN
        MV := MV_Min;
        Saturated := TRUE;
        IF NOT Manual THEN
            IF Error < 0.0 THEN Integral := Integral - Error * SampleTime; END_IF;
        END_IF;
    ELSE
        MV := MV_unclamped;
        Saturated := FALSE;
    END_IF;

    IF Manual THEN
        MV := MV_Manual;
        Saturated := FALSE;
    END_IF;

    PrevPV := PV;
END_IF;
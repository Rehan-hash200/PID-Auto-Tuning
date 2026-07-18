IF NOT Enable THEN
    PV              := AmbientPV;
    PV_Min_Recorded := AmbientPV;
    PV_Max_Recorded := AmbientPV;
    InitDone        := FALSE;
    Running         := FALSE;
    BufferIndex     := 0;
    FOR i := 0 TO 199 DO DelayBuffer[i] := 0.0; END_FOR;
    at_dist_timer   := 0.0;
    at_dist_state   := FALSE;
    at_dist_value   := 0.0;
    NoisePhase      := 0.0;
    plant_debug     := 0;
ELSE
    Running := TRUE;
    plant_debug := 1;

    IF NOT InitDone THEN
        FOR i := 0 TO 199 DO DelayBuffer[i] := 0.0; END_FOR;
        PV              := AmbientPV;
        PV_Min_Recorded := AmbientPV;
        PV_Max_Recorded := AmbientPV;
        BufferIndex     := 0;
        InitDone        := TRUE;
    END_IF;

    // ---- Deadtime buffer ----
    IF SampleTime > 0.0 THEN
        DelaySteps := TO_INT(DeadTime / SampleTime);
    ELSE
        DelaySteps := 0;
    END_IF;
   IF DelaySteps < 0 THEN
    DelaySteps := 0;
ELSIF DelaySteps > 199 THEN
    DelaySteps := 199;
END_IF;

    DelayBuffer[BufferIndex] := MV;   // <-- MENGGUNAKAN MV (bukan mv_1)

    ReadIndex := BufferIndex - DelaySteps;
    IF ReadIndex < 0 THEN ReadIndex := ReadIndex + 200; END_IF;
    DelayedMV := DelayBuffer[ReadIndex];

    BufferIndex := BufferIndex + 1;
    IF BufferIndex > 199 THEN BufferIndex := 0; END_IF;

    // ---- Auto step disturbance ----
    IF AutoTestEnable THEN
        at_dist_timer := at_dist_timer + SampleTime;
        IF at_dist_timer >= AutoTestInterval THEN
            at_dist_timer := 0.0;
            at_dist_state := NOT at_dist_state;
        END_IF;
        at_dist_value := SEL(at_dist_state, AutoTestAmplitude, 0.0);
    ELSE
        at_dist_timer := 0.0;
        at_dist_state := FALSE;
        at_dist_value := 0.0;
    END_IF;

    // ---- 1st-order response ----
    IF TimeConstant > 0.0 THEN
        PV := PV + (SampleTime / TimeConstant) * (ProcessGain * DelayedMV + Disturbance + at_dist_value - PV);
    ELSE
        PV := ProcessGain * DelayedMV + Disturbance + at_dist_value;
    END_IF;

    // ---- Noise ----
    IF NoiseAmplitude > 0.0 THEN
        NoisePhase := NoisePhase + SampleTime;
        IF NoisePhase > 10000.0 THEN NoisePhase := NoisePhase - 10000.0; END_IF;
        PV := PV + NoiseAmplitude * (SIN(NoisePhase*6.0) + SIN(NoisePhase*13.7) + SIN(NoisePhase*31.0)) / 3.0;
    END_IF;

    // ---- Min/Max tracking ----
    IF PV < PV_Min_Recorded THEN PV_Min_Recorded := PV; END_IF;
    IF PV > PV_Max_Recorded THEN PV_Max_Recorded := PV; END_IF;
END_IF;
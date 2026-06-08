VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "C_Conical_Transition"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' C_Conical_Transition

Option Explicit

Implements I_PipeFitting

Public Enum eTransitionType
    eTransition_Unknown = 0
    eTransition_Diffuser = 1 ' (D_in < D_out)
    eTransition_Reducer = 2  ' (D_in > D_out)
End Enum

Private m_Din As Double, m_Dout As Double
Private m_Angle As Double
Private m_Roughness As Double
Private m_VelocityIn As Double
Private m_Viscosity As Double

' ===================================================
' PROPERTIES
' ===================================================
Public Property Let Diameter_Inlet(val As Double): m_Din = val: End Property
Public Property Let Diameter_Outlet(val As Double): m_Dout = val: End Property
Public Property Let AngleDegree(val As Double): m_Angle = val: End Property
Public Property Let AbsoluteRoughness(val As Double): m_Roughness = val: End Property
Public Property Let Velocity_Inlet(val As Double): m_VelocityIn = val: End Property
Public Property Let KinematicViscosity(val As Double): m_Viscosity = val: End Property

' Phan loai
Private Property Get TransitionType() As eTransitionType
    If m_Din <= 0 Or m_Dout <= 0 Then
        TransitionType = eTransition_Unknown
    ElseIf m_Din < m_Dout Then
        TransitionType = eTransition_Diffuser
    ElseIf m_Din > m_Dout Then
        TransitionType = eTransition_Reducer
    Else
        TransitionType = eTransition_Unknown
    End If
End Property

' ===================================================
' INTERFACE
' ===================================================
Private Property Get I_PipeFitting_Zeta() As Double
    ' Zeta quy doi ve Vel_Inlet
    Select Case TransitionType
        Case eTransition_Diffuser
            I_PipeFitting_Zeta = Calc_Diffuser()
        Case eTransition_Reducer
            I_PipeFitting_Zeta = Calc_Reducer()
        Case Else
            I_PipeFitting_Zeta = 0
    End Select
End Property

Private Property Get I_PipeFitting_HeadLoss() As Double
    If m_VelocityIn <= 0 Or m_Din <= 0 Or m_Dout <= 0 Then
        I_PipeFitting_HeadLoss = 0
        Exit Property
    End If
    
    Dim z As Double: z = I_PipeFitting_Zeta
    I_PipeFitting_HeadLoss = z * (m_VelocityIn ^ 2) / (2 * 9.81)
End Property

' ===================================================
' CALCULATIONS
' ===================================================

Private Function Calc_Diffuser() As Double
    ' DIAGRAM 5-2 (Conical Diffuser in a line) F0 > F1
    ' D_in (F0), D_out (F1)
    Dim Re As Double, lambda As Double
    Dim Zeta_exp As Double, Zeta_fr As Double
    Dim F0_F1 As Double, rad As Double
    
    rad = m_Angle * 3.14159265358979 / 180
    F0_F1 = (m_Din / m_Dout) ^ 2
    
    ' Reynolds at F0
    If m_Viscosity > 0 Then Re = m_VelocityIn * m_Din / m_Viscosity Else Re = 0
    
    ' 1. noi sy Zeta_exp
    Zeta_exp = Interp2D_Diag52_Diffuser(F0_F1, m_Angle)
    
    ' 2. Zeta_fr
    If Re >= 2300 And rad > 0 Then
        lambda = F_Colebrook(m_Din, Re, m_Roughness)
        Zeta_fr = (lambda / (8 * Sin(rad / 2))) * (1 - (F0_F1 ^ 2))
    Else
        Zeta_fr = 0 ' laminar
    End If
    
    ' Zeta o D nho hon (Inlet)
    Calc_Diffuser = Zeta_exp + Zeta_fr
End Function

Private Function Calc_Reducer() As Double
    Dim Re_out As Double, v_out As Double, lambda As Double
    Dim Zeta_prime As Double, Zeta_local As Double, Zeta_fr As Double, Zeta_total_ref_out As Double
    Dim F0_F1 As Double, rad As Double, rad_half As Double
    Dim l_Dh As Double
    Dim Pi As Double: Pi = 3.14159265358979
    
    If m_Din <= 0 Or m_Dout <= 0 Then
        Calc_Reducer = 0
        Exit Function
    End If
    
    rad = m_Angle * Pi / 180
    rad_half = rad / 2
    F0_F1 = (m_Dout / m_Din) ^ 2
    
    ' 1. l/Dh
    If m_Angle <= 0 Then
        l_Dh = 0.6
    ElseIf m_Angle >= 180 Then
        l_Dh = 0 ' Sudden contraction
    Else
        l_Dh = ((m_Din / m_Dout) - 1) / (2 * Tan(rad_half))
    End If
    
    ' 2. Noi suy Zeta' D3-6
    Zeta_prime = Interp2D_Diag36_ZetaPrime(l_Dh, m_Angle)
    
    ' 3. TZeta_local D3-7
    Zeta_local = Zeta_prime * (1 - F0_F1)
    
    ' 4. Zeta_fr
    v_out = m_VelocityIn / F0_F1
    If m_Viscosity > 0 Then Re_out = v_out * m_Dout / m_Viscosity Else Re_out = 0
    
    If Re_out >= 2300 And rad > 0 And m_Angle < 180 Then
        lambda = F_Colebrook(m_Dout, Re_out, m_Roughness)
        Zeta_fr = (lambda / (8 * Sin(rad_half))) * (1 - (F0_F1 ^ 2))
    Else
        Zeta_fr = 0
    End If
    
    ' 5. Zeta theo A nho (Outlet)
    Zeta_total_ref_out = Zeta_local + Zeta_fr
    
    ' 6. Quy doi ve Inlet === I_PipeFitting
    Calc_Reducer = Zeta_total_ref_out / (F0_F1 ^ 2)
End Function

' Noi suy Diagram 3-6
Private Function Interp2D_Diag36_ZetaPrime(l_Dh As Double, Alpha As Double) As Double
    ' l/Dh
    Dim arrY As Variant: arrY = Array(0.025, 0.05, 0.075, 0.1, 0.15, 0.6)
    ' Alpha
    Dim arrX As Variant: arrX = Array(0, 10, 20, 30, 40, 60, 100, 140, 180)
    
    Dim matZ(0 To 5, 0 To 8) As Double
    ' Row 0 (l/Dh = 0.025)
    matZ(0, 0) = 0.5: matZ(0, 1) = 0.47: matZ(0, 2) = 0.45: matZ(0, 3) = 0.43: matZ(0, 4) = 0.41: matZ(0, 5) = 0.4: matZ(0, 6) = 0.42: matZ(0, 7) = 0.45: matZ(0, 8) = 0.5
    ' Row 1 (l/Dh = 0.050)
    matZ(1, 0) = 0.5: matZ(1, 1) = 0.45: matZ(1, 2) = 0.41: matZ(1, 3) = 0.36: matZ(1, 4) = 0.33: matZ(1, 5) = 0.3: matZ(1, 6) = 0.35: matZ(1, 7) = 0.42: matZ(1, 8) = 0.5
    ' Row 2 (l/Dh = 0.075)
    matZ(2, 0) = 0.5: matZ(2, 1) = 0.42: matZ(2, 2) = 0.35: matZ(2, 3) = 0.3: matZ(2, 4) = 0.26: matZ(2, 5) = 0.23: matZ(2, 6) = 0.3: matZ(2, 7) = 0.4: matZ(2, 8) = 0.5
    ' Row 3 (l/Dh = 0.10)
    matZ(3, 0) = 0.5: matZ(3, 1) = 0.39: matZ(3, 2) = 0.32: matZ(3, 3) = 0.25: matZ(3, 4) = 0.22: matZ(3, 5) = 0.18: matZ(3, 6) = 0.27: matZ(3, 7) = 0.38: matZ(3, 8) = 0.5
    ' Row 4 (l/Dh = 0.15)
    matZ(4, 0) = 0.5: matZ(4, 1) = 0.37: matZ(4, 2) = 0.27: matZ(4, 3) = 0.2: matZ(4, 4) = 0.16: matZ(4, 5) = 0.15: matZ(4, 6) = 0.25: matZ(4, 7) = 0.37: matZ(4, 8) = 0.5
    ' Row 5 (l/Dh = 0.60)
    matZ(5, 0) = 0.5: matZ(5, 1) = 0.27: matZ(5, 2) = 0.18: matZ(5, 3) = 0.13: matZ(5, 4) = 0.11: matZ(5, 5) = 0.12: matZ(5, 6) = 0.23: matZ(5, 7) = 0.36: matZ(5, 8) = 0.5
    
    ' B.C
    If l_Dh < 0.025 Then l_Dh = 0.025
    If l_Dh > 0.6 Then l_Dh = 0.6
    If Alpha < 0 Then Alpha = 0
    If Alpha > 180 Then Alpha = 180
    
    ' Indexing
    Dim i As Integer, j As Integer
    For i = 0 To UBound(arrY) - 1
        If l_Dh >= arrY(i) And l_Dh <= arrY(i + 1) Then Exit For
    Next i
    For j = 0 To UBound(arrX) - 1
        If Alpha >= arrX(j) And Alpha <= arrX(j + 1) Then Exit For
    Next j
    
    ' Interpolation (BIlinear)
    Dim wy As Double, wx As Double
    wy = (l_Dh - arrY(i)) / (arrY(i + 1) - arrY(i))
    wx = (Alpha - arrX(j)) / (arrX(j + 1) - arrX(j))
    
    Dim Z00 As Double, Z01 As Double, Z10 As Double, Z11 As Double
    Z00 = matZ(i, j): Z01 = matZ(i, j + 1)
    Z10 = matZ(i + 1, j): Z11 = matZ(i + 1, j + 1)
    
    Dim Z_top As Double, Z_bot As Double
    Z_top = Z00 * (1 - wx) + Z01 * wx
    Z_bot = Z10 * (1 - wx) + Z11 * wx
    
    Interp2D_Diag36_ZetaPrime = Z_top * (1 - wy) + Z_bot * wy
End Function

' Noi suy Diagram 5-2
Private Function Interp2D_Diag52_Diffuser(F0_F1 As Double, Alpha As Double) As Double
    Dim arrY As Variant: arrY = Array(0, 0.1, 0.2, 0.4, 0.6) ' F0/F1
    Dim arrX As Variant: arrX = Array(10, 20, 30, 40, 60, 90, 180) ' Angle
    
    Dim matZ(0 To 4, 0 To 6) As Double
    ' R0 (F0/F1 = 0)
    matZ(0, 0) = 0.15: matZ(0, 1) = 0.36: matZ(0, 2) = 0.65: matZ(0, 3) = 0.92: matZ(0, 4) = 1.15: matZ(0, 5) = 1.1: matZ(0, 6) = 1.02
    ' R1 (F0/F1 = 0.1)
    matZ(1, 0) = 0.12: matZ(1, 1) = 0.29: matZ(1, 2) = 0.52: matZ(1, 3) = 0.75: matZ(1, 4) = 0.93: matZ(1, 5) = 0.89: matZ(1, 6) = 0.83
    ' R2 (F0/F1 = 0.2)
    matZ(2, 0) = 0.1: matZ(2, 1) = 0.23: matZ(2, 2) = 0.41: matZ(2, 3) = 0.59: matZ(2, 4) = 0.74: matZ(2, 5) = 0.7: matZ(2, 6) = 0.65
    ' R3 (F0/F1 = 0.4)
    matZ(3, 0) = 0.07: matZ(3, 1) = 0.17: matZ(3, 2) = 0.23: matZ(3, 3) = 0.33: matZ(3, 4) = 0.41: matZ(3, 5) = 0.39: matZ(3, 6) = 0.37
    ' R4 (F0/F1 = 0.6)
    matZ(4, 0) = 0.04: matZ(4, 1) = 0.08: matZ(4, 2) = 0.1: matZ(4, 3) = 0.15: matZ(4, 4) = 0.18: matZ(4, 5) = 0.17: matZ(4, 6) = 0.16
    
    If F0_F1 < 0 Then F0_F1 = 0
    If F0_F1 > 0.6 Then F0_F1 = 0.6
    If Alpha < 10 Then Alpha = 10
    If Alpha > 180 Then Alpha = 180
    
    Dim i As Integer, j As Integer
    For j = 0 To UBound(arrX) - 1
        If Alpha >= arrX(j) And Alpha <= arrX(j + 1) Then Exit For
    Next j
    For i = 0 To UBound(arrY) - 1
        If F0_F1 >= arrY(i) And F0_F1 <= arrY(i + 1) Then Exit For
    Next i
    
    Dim wx As Double, wy As Double
    wx = (Alpha - arrX(j)) / (arrX(j + 1) - arrX(j))
    wy = (F0_F1 - arrY(i)) / (arrY(i + 1) - arrY(i))
    
    Dim Z00 As Double, Z10 As Double, Z01 As Double, Z11 As Double
    Z00 = matZ(i, j): Z10 = matZ(i, j + 1)
    Z01 = matZ(i + 1, j): Z11 = matZ(i + 1, j + 1)
    
    Dim Z_top As Double, Z_bot As Double
    Z_top = Z00 * (1 - wx) + Z10 * wx
    Z_bot = Z01 * (1 - wx) + Z11 * wx
    
    Interp2D_Diag52_Diffuser = Z_top * (1 - wy) + Z_bot * wy
End Function

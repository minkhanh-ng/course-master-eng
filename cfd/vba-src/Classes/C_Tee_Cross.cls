VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "C_Tee_Cross"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' C_Tee_Cross

Option Explicit

Implements I_PipeFitting

Public Enum eFlowPath
    eFlowPath_Straight = 1
    eFlowPath_Branch = 2
End Enum

Private m_Ac As Double, m_As As Double, m_Ab As Double
Private m_Qc As Double, m_Qs As Double, m_Qb As Double
Private m_PathType As eFlowPath
Private m_Velocity As Double ' v nhanh tinh HeadLoss

' Properties
Public Property Let Area_Inlet(val As Double): m_Ac = val: End Property
Public Property Let Area_Straight(val As Double): m_As = val: End Property
Public Property Let Area_Branch(val As Double): m_Ab = val: End Property
Public Property Let Flow_Inlet(val As Double): m_Qc = val: End Property
Public Property Let Flow_Straight(val As Double): m_Qs = val: End Property
Public Property Let Flow_Branch(val As Double): m_Qb = val: End Property
Public Property Let TargetPath(val As eFlowPath): m_PathType = val: End Property

' ===================================================
' INTERFACE
' ===================================================
Private Property Get I_PipeFitting_Zeta() As Double
    I_PipeFitting_Zeta = Calc_DivergingCross()
End Property

Private Property Get I_PipeFitting_HeadLoss() As Double
    ' v nhanh chon
    If m_PathType = eFlowPath_Straight Then
        If m_As <= 0# Then
            I_PipeFitting_HeadLoss = 0#
            Exit Property
        End If
        m_Velocity = m_Qs / m_As
    Else
        If m_Ab <= 0# Then
            I_PipeFitting_HeadLoss = 0#
            Exit Property
        End If
        m_Velocity = m_Qb / m_Ab
    End If
    I_PipeFitting_HeadLoss = I_PipeFitting_Zeta * (m_Velocity ^ 2) / (2 * 9.81)
End Property

' ===================================================
' CALC
' ===================================================
Private Function Calc_DivergingCross() As Double
    Dim wc As Double, ws As Double, wb As Double
    Dim ratio_ws_wc As Double, ratio_wb_wc As Double
    Dim SumAreaRatio As Double, Fs_Fc As Double, hb_hc As Double
    Dim K_local As Double

    If m_Ac <= 0# Or m_As <= 0# Or m_Ab <= 0# Then
        Calc_DivergingCross = 0#
        Exit Function
    End If
    
    ' v nhanh
    wc = m_Qc / m_Ac
    ws = m_Qs / m_As
    wb = m_Qb / m_Ab

    If Abs(wc) < 0.000000000001 Then
        Calc_DivergingCross = 0#
        Exit Function
    End If
    
    ' ratio vo huong
    ratio_ws_wc = ws / wc
    ratio_wb_wc = wb / wc
    SumAreaRatio = (m_As + m_Ab) / m_Ac
    Fs_Fc = m_As / m_Ac
    hb_hc = Sqr(m_Ab / m_Ac) 'h_b/h_c
    
    If m_PathType = eFlowPath_Straight Then
        ' ========================================================
        ' DIAGRAM 7-23 (s)
        ' ========================================================
        If SumAreaRatio > 1# Then
            ' NO. 1 (F_s + F_b > F_c)
            ' Zeta = 0.4 * (1 - ws/wc)^2
            If ratio_ws_wc > 1# Then ratio_ws_wc = 1#
            K_local = 0.4 * (1 - ratio_ws_wc) ^ 2
        Else
            ' NO. 2 (F_s + F_b = F_c)
            K_local = Interp2D_Diag723_No2(ratio_ws_wc, Fs_Fc) 'noi suy
        End If
        
    ElseIf m_PathType = eFlowPath_Branch Then
        If ratio_ws_wc = 0 Then
            Calc_DivergingCross = 1.5
            Exit Function
        End If
        ' ========================================================
        ' DIAGRAM 7-21 (b)
        ' ========================================================
        Dim A_prime As Double
        If ratio_wb_wc <= 0.8 Then A_prime = 1# Else A_prime = 0.9
        
        If hb_hc <= 0.67 Then
            ' NO. 1 (h_b/h_c <= 2/3)
            K_local = A_prime * (1 + ratio_wb_wc ^ 2) '90 do
        Else
            ' NO. 2 (h_b/h_c = 1.0)
            Dim Zeta_prime As Double
            Dim arrX As Variant, arrY As Variant
            arrX = Array(0, 0.1, 0.2, 0.4, 0.6, 0.8, 1#, 1.2, 1.4, 1.6, 2#)
            arrY = Array(1#, 1#, 1.01, 1.05, 1.15, 1.32, 1.45, 1.6, 1.77, 1.95, 2.45)
            
            If ratio_wb_wc <= 0 Then
                Zeta_prime = 1#
            ElseIf ratio_wb_wc >= 2# Then
                Zeta_prime = 2.45
            Else
                Dim i As Integer
                For i = LBound(arrX) To UBound(arrX) - 1
                    If ratio_wb_wc >= arrX(i) And ratio_wb_wc <= arrX(i + 1) Then
                        Zeta_prime = arrY(i) + (ratio_wb_wc - arrX(i)) * (arrY(i + 1) - arrY(i)) / (arrX(i + 1) - arrX(i))
                        Exit For
                    End If
                Next i
            End If
            K_local = A_prime * Zeta_prime
        End If
    End If
    
    Calc_DivergingCross = K_local
End Function

Private Function Interp2D_Diag723_No2(ws_wc As Double, Fs_Fc As Double) As Double
    ' ratio vtoc ws_wc
    Dim arrY As Variant: arrY = Array(0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1#)
    ' ratio A  Fs_Fc
    Dim arrX As Variant: arrX = Array(0.4, 0.5, 0.6, 0.7, 0.8)
    
    ' Zeta_c.s Diagram 7-23
    Dim matZ(0 To 8, 0 To 4) As Double
    ' R0 (ws_wc = 0)
    matZ(0, 0) = 1#: matZ(0, 1) = 1#: matZ(0, 2) = 1#: matZ(0, 3) = 1#: matZ(0, 4) = 1#
    ' R1 (ws_wc = 0.1)
    matZ(1, 0) = 0.81: matZ(1, 1) = 0.81: matZ(1, 2) = 0.81: matZ(1, 3) = 0.81: matZ(1, 4) = 0.81
    ' R2 (ws_wc = 0.2)
    matZ(2, 0) = 0.64: matZ(2, 1) = 0.64: matZ(2, 2) = 0.64: matZ(2, 3) = 0.64: matZ(2, 4) = 0.64
    ' R3 (ws_wc = 0.3)
    matZ(3, 0) = 0.5: matZ(3, 1) = 0.52: matZ(3, 2) = 0.52: matZ(3, 3) = 0.5: matZ(3, 4) = 0.5
    ' R4 (ws_wc = 0.4)
    matZ(4, 0) = 0.36: matZ(4, 1) = 0.4: matZ(4, 2) = 0.38: matZ(4, 3) = 0.37: matZ(4, 4) = 0.36
    ' R5 (ws_wc = 0.5)
    matZ(5, 0) = 0.25: matZ(5, 1) = 0.3: matZ(5, 2) = 0.28: matZ(5, 3) = 0.26: matZ(5, 4) = 0.25
    ' R6 (ws_wc = 0.6)
    matZ(6, 0) = 0.16: matZ(6, 1) = 0.23: matZ(6, 2) = 0.2: matZ(6, 3) = 0.18: matZ(6, 4) = 0.16
    ' R7 (ws_wc = 0.8)
    matZ(7, 0) = 0.04: matZ(7, 1) = 0.16: matZ(7, 2) = 0.12: matZ(7, 3) = 0.07: matZ(7, 4) = 0.04
    ' R8 (ws_wc = 1.0)
    matZ(8, 0) = 0#: matZ(8, 1) = 0.2: matZ(8, 2) = 0.1: matZ(8, 3) = 0.05: matZ(8, 4) = 0#
    
    ' safety
    If Fs_Fc < 0.4 Then Fs_Fc = 0.4
    If Fs_Fc > 0.8 Then Fs_Fc = 0.8
    If ws_wc < 0 Then ws_wc = 0
    If ws_wc > 1# Then ws_wc = 1#
    
    ' Index
    Dim i As Integer, j As Integer
    For j = 0 To UBound(arrX) - 1
        If Fs_Fc >= arrX(j) And Fs_Fc <= arrX(j + 1) Then Exit For
    Next j
    For i = 0 To UBound(arrY) - 1
        If ws_wc >= arrY(i) And ws_wc <= arrY(i + 1) Then Exit For
    Next i
    
    Dim wx As Double, wy As Double
    wx = (Fs_Fc - arrX(j)) / (arrX(j + 1) - arrX(j))
    wy = (ws_wc - arrY(i)) / (arrY(i + 1) - arrY(i))
    
    Dim Z00 As Double, Z10 As Double, Z01 As Double, Z11 As Double
    Z00 = matZ(i, j): Z10 = matZ(i, j + 1)
    Z01 = matZ(i + 1, j): Z11 = matZ(i + 1, j + 1)
    
    Dim Z_top As Double, Z_bot As Double
    Z_top = Z00 * (1 - wx) + Z10 * wx
    Z_bot = Z01 * (1 - wx) + Z11 * wx
    
    Interp2D_Diag723_No2 = Z_top * (1 - wy) + Z_bot * wy
End Function

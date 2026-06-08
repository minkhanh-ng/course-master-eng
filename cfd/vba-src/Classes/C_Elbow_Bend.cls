VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "C_Elbow_Bend"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' C_Elbow_Bend

Option Explicit

Implements I_PipeFitting

' Enum
Public Enum eBendType
    eBend_SharpElbow = 1
    eBend_SmoothBend = 2
    eBend_SharpBend = 3
End Enum

Private m_Dh As Double, m_Ro As Double, m_Angle As Double
Private m_Roughness As Double, m_Velocity As Double, m_Viscosity As Double

' Properties
Public Property Let Diameter(val As Double): m_Dh = val: End Property
Public Property Let RadiusOfCurvature(val As Double): m_Ro = val: End Property
Public Property Let AngleDegree(val As Double): m_Angle = val: End Property
Public Property Let AbsoluteRoughness(val As Double): m_Roughness = val: End Property
Public Property Let Velocity(val As Double): m_Velocity = val: End Property
Public Property Let KinematicViscosity(val As Double): m_Viscosity = val: End Property

Public Property Get Reynolds() As Double
    If m_Dh <= 0# Or m_Viscosity <= 0# Then
        Reynolds = 0#
    Else
        Reynolds = m_Velocity * m_Dh / m_Viscosity
    End If
End Property

' Phan loai
Private Property Get BendType() As eBendType
    If m_Dh <= 0# Then
        BendType = eBend_SharpElbow
        Exit Property
    End If

    Dim ratio As Double: ratio = m_Ro / m_Dh
    If ratio <= 0.5 Then
        BendType = eBend_SharpElbow
    ElseIf ratio >= 1.5 Then
        BendType = eBend_SmoothBend
    Else
        BendType = eBend_SharpBend
    End If
End Property

' ===================================================
' INTERFACE
' ===================================================
Private Property Get I_PipeFitting_Zeta() As Double
    Select Case BendType
        Case eBend_SharpElbow
            I_PipeFitting_Zeta = Calc_SharpElbow()
        Case eBend_SmoothBend
            I_PipeFitting_Zeta = Calc_SmoothBend()
        Case eBend_SharpBend
            I_PipeFitting_Zeta = Calc_SharpBend()
    End Select
End Property

Private Property Get I_PipeFitting_HeadLoss() As Double
    If m_Dh <= 0# Or m_Viscosity <= 0# Or m_Velocity <= 0# Then
        I_PipeFitting_HeadLoss = 0#
        Exit Property
    End If

    I_PipeFitting_HeadLoss = I_PipeFitting_Zeta * (m_Velocity ^ 2) / (2 * 9.81)
End Property

' ===================================================
' CALC
' ===================================================
Private Function Calc_SharpElbow() As Double
    Dim Re As Double, relRough As Double, lambda_Re As Double
    Dim k_Re As Double, k_Rough As Double, Zeta_1 As Double
    Dim A_factor As Double, C1 As Double
    Dim rad As Double
    Dim arrAngles As Variant, arrA As Variant
    Dim i As Integer
    
    rad = m_Angle * 3.14159265358979 / 180
    Re = Me.Reynolds

    If m_Dh <= 0# Or Re <= 0# Then
        Calc_SharpElbow = 0#
        Exit Function
    End If

    relRough = m_Roughness / m_Dh
    C1 = 1#
    
    ' Zeta_1
    Zeta_1 = 0.95 * (Sin(rad / 2) ^ 2) + 2.05 * (Sin(rad / 2) ^ 4)
    
    ' noi sy A
    If m_Angle >= 90 Then
        A_factor = 1.2
    ElseIf m_Angle <= 20 Then
        A_factor = 2.5
    Else
        arrAngles = Array(20, 30, 45, 60, 75, 90)
        arrA = Array(2.5, 2.22, 1.87, 1.5, 1.28, 1.2)
        
        For i = LBound(arrAngles) To UBound(arrAngles) - 1
            If m_Angle >= arrAngles(i) And m_Angle <= arrAngles(i + 1) Then
                A_factor = arrA(i) + (m_Angle - arrAngles(i)) * (arrA(i + 1) - arrA(i)) / (arrAngles(i + 1) - arrAngles(i))
                Exit For
            End If
        Next i
    End If
    
    lambda_Re = F_Colebrook(m_Dh, Re, 0)
    
    ' k_Re vs k_Rough
    If Re >= 3000 And Re < 40000 Then
        k_Re = 45 * lambda_Re
        k_Rough = 1#
    ElseIf Re >= 40000 Then
        If relRough < 0 Then
            Debug.Print ("Roughness must > 0")
            MsgBox "Roughness must > 0", vbCritical, "ERROR"
            Exit Function
        ' --- SMOOTH ----------------------------
        ElseIf relRough = 0 Then
            k_Rough = 1#
            k_Re = 1.1
        ' --- ROUGH ----------------------------
        ElseIf relRough > 0 And relRough <= 0.001 Then
            k_Rough = 1 + 0.5 * (10 ^ 3) * relRough
            k_Re = 1#
        Else
            k_Rough = 1.5
            k_Re = 1#
        End If
    Else
        k_Re = 1#
        k_Rough = 1#
    End If
    
    Debug.Print "Elbow debug | type=SharpElbow | Re=" & Re & " | lambda_Re=" & lambda_Re & " | Zeta1=" & Zeta_1 & " | A_factor=" & A_factor & " | k_Re=" & k_Re & " | k_Rough=" & k_Rough & " | HL_coef=" & (k_Rough * k_Re * C1 * A_factor * Zeta_1)

    Calc_SharpElbow = k_Rough * k_Re * C1 * A_factor * Zeta_1
End Function

Private Function Calc_SmoothBend() As Double
    Dim Re As Double, relRough As Double
    Dim lambda As Double, lambda_Re As Double
    Dim k_Re As Double, k_Rough As Double
    Dim A1 As Double, B1 As Double, C1 As Double
    Dim Eta_1 As Double, Eta_fr As Double
    Dim rad As Double, ratio As Double
    Dim Pi As Double: Pi = 3.14159265358979
    
    Re = Me.Reynolds
    If m_Dh <= 0# Or m_Ro <= 0# Or Re <= 0# Then
        Calc_SmoothBend = 0#
        Exit Function
    End If

    relRough = m_Roughness / m_Dh
    ratio = m_Ro / m_Dh
    If ratio <= 0# Then
        Calc_SmoothBend = 0#
        Exit Function
    End If

    rad = m_Angle * Pi / 180
    
    ' A1 (Table 6-5)
    If m_Angle <= 70 Then
        A1 = 0.9 * Sin(rad)
    ElseIf m_Angle = 90 Then
        A1 = 1#
    ElseIf m_Angle >= 100 Then
        A1 = 0.7 + (0.35 * m_Angle / 90)
    ElseIf m_Angle > 70 And m_Angle < 90 Then
        ' noi suy 70 -> 90
        Dim y70 As Double: y70 = 0.9 * Sin(70 * Pi / 180)
        A1 = y70 + (m_Angle - 70) * (1# - y70) / (90 - 70)
    ElseIf m_Angle > 90 And m_Angle < 100 Then
        ' 90 -> 100
        Dim y100 As Double: y100 = 0.7 + (0.35 * 100 / 90)
        A1 = 1# + (m_Angle - 90) * (y100 - 1#) / (100 - 90)
    End If
    
    ' B1, C1 & Eta_1
    B1 = 0.21 / Sqr(ratio)
    C1 = 1# ' Ti?t di?n tr�n
    Eta_1 = A1 * B1 * C1
    
    ' Msat thuc lambda & ma s�t g�c Eta_fr
    lambda = F_Colebrook(m_Dh, Re, m_Roughness)
    Eta_fr = 0.0175 * lambda * ratio * m_Angle
    
    ' Msat smooth pipe (lambda_Re)
    lambda_Re = F_Colebrook(m_Dh, Re, 0)
    
    ' 5. k_Re & k_Rough (Table 6-6)
    If Re >= 3000 And Re <= 40000 Then
        k_Re = 64 * lambda_Re
        k_Rough = 1#
        
    ElseIf Re > 40000 And Re <= 200000 Then
        k_Re = 64 * lambda_Re
        If relRough <= 0 Then
            k_Rough = 1#
        ElseIf relRough > 0 And relRough <= 0.001 Then
            k_Rough = 1 + (relRough ^ 2) * 1000000
        Else
            k_Rough = 2#
        End If
        
    ElseIf Re > 200000 Then
        k_Re = 1#
        If relRough <= 0 Then
            k_Rough = 1#
        ElseIf relRough > 0 And relRough <= 0.001 Then
            k_Rough = 1 + (relRough ^ 2) * 1000000
        Else
            k_Rough = 2#
        End If
        
    Else
        ' Re < 3000
        k_Re = 1#
        k_Rough = 1#
    End If
    
    ' 6.
    Debug.Print "Elbow debug | type=SmoothBend | Re=" & Re & " | lambda=" & lambda & " | lambda_Re=" & lambda_Re & " | Eta1=" & Eta_1 & " | Eta_fr=" & Eta_fr & " | k_Re=" & k_Re & " | k_Rough=" & k_Rough & " | HL_coef=" & ((k_Rough * k_Re * Eta_1) + Eta_fr)

    Calc_SmoothBend = (k_Rough * k_Re * Eta_1) + Eta_fr
End Function

Private Function Calc_SharpBend() As Double
    ' 6-1
    Debug.Print "Elbow debug | type=SharpBend | HL_coef=1.18"
    Calc_SharpBend = 1.18 ' Tinh sau
End Function








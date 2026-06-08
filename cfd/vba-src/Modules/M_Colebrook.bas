Attribute VB_Name = "M_Colebrook"
Option Explicit

Function F_Colebrook(D As Double, Re As Double, absoluteRoughnes As Double, Optional ByVal fTol As Double = 0.01, Optional ByVal maxIter As Double = 1000) As Double
    ' Implicit Colebrook&White
    
    ' DESCRIPTION
    '   INPUTS
    '    aRou     : Absolute roughness of pipe          [mm]
    '    D        : Inner diameter of the pipe          [mm]
    '    Re       : Reynolds Number                     [-]
    
    '   INPUTS (for Iteration)
    '    fTol     : Termination Tolerance(Iteration)    [-]
    '    MaxIter  : Max. limit (Iteration)              [-]
    
    Dim relativeRoughness As Double
    Dim errVal As Double, iterNum As Long
    Dim term0 As Double, term1 As Double
    Dim X0 As Double, X1 As Double

    If D <= 0# Or Re <= 0# Then
        F_Colebrook = 0#
        Exit Function
    End If

    ' Laminar range
    If Re < 2300# Then
        F_Colebrook = 64# / Re
        Exit Function
    End If

    relativeRoughness = 0#
    If absoluteRoughnes > 0# Then relativeRoughness = absoluteRoughnes / D

    errVal = 10#
    iterNum = 0

    ' Initial estimate by Haaland
    term0 = (relativeRoughness / 3.7) ^ 1.11 + (6.9 / Re)
    If term0 <= 0# Then term0 = 0.0000001
    X0 = (-1.8 * (Log(term0) / Log(10#))) ^ (-2)

    Do While (errVal > fTol And iterNum < maxIter)
        iterNum = iterNum + 1
        term1 = (relativeRoughness / 3.7) + (2.51 / (Re * Sqr(X0)))
        If term1 <= 0# Then term1 = 0.0000001
        X1 = (-2# * (Log(term1) / Log(10#))) ^ (-2)
        errVal = Abs(X1 - X0)
        X0 = X1
    Loop

    If iterNum = maxIter Then
        ' Return latest iterate even if max iteration is reached.
        F_Colebrook = X0
    Else
        F_Colebrook = X1
    End If

End Function

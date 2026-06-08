Attribute VB_Name = "M_StartNode"
Option Explicit

Function F_StartNodeDensity(rho0 As Double, theta0 As Double, gm_m As Double, M As Double, rhos As Double, rhog As Double, _
                            Optional ByVal maxIter As Double = 1000, Optional ByVal eps As Double = 0.0001, Optional ByVal h As Double = 2) As Double

    ' DESCRIPTION
    '   find    :   rho :   Density
    '   rho0 / rho  = (1 - theta0)/(1-theta) * ( 1 + ((gm_m - 1)/2)*(M^2 / (1-theta)^2 )^(1/(gm_m-1))
    '   theta       = (rho - rhog) / (rhos - rhog)
    '   0 is stagnation
    
    ' INPUTS
    '   rho0    : upstream density                  [kg/m3]
    '   theta0  : upstream volume fraction          [-]
    '   gm_m    : Mixture heat coeff. ratio         [-]
    '   M       : Mach number                       [-]
    '   ---for Iteration
    '   eps     : acceptance residual
    '   MaxIter : Max. limit (Iteration)
    '   X0      : Initial value
    
    ' Initializing the Iteration
    Debug.Print "---F_StartNodeDensity---"
    Dim rho As Double
    Dim theta As Double
    Dim f As Double
    Dim df As Double
    Dim iterNum As Integer
    Dim f_plus_h As Double
    Dim f_minus_h As Double
    Dim theta_plus_h As Double
    Dim theta_minus_h As Double
     
    rho = theta0 * (rhos - rhog) + rhog
    '  Initial estimate
    
    ' Iteration starts
    For iterNum = 1 To maxIter
        Debug.Print "   Iteration: " & iterNum
    
        theta = (rho - rhog) / (rhos - rhog)
        f = rho0 / rho - (1 - theta0) / (1 - theta) * (1 + ((gm_m - 1) / 2) * (M ^ 2 / (1 - theta) ^ 2)) ^ (1 / (gm_m - 1))
        Debug.Print "   theta = " & theta
        Debug.Print "   f = " & f
        
        ' Numerical derivative
        theta_plus_h = (rho - rhog + h) / (rhos - rhog)
        theta_minus_h = (rho - rhog + h) / (rhos - rhog)
        f_plus_h = rho0 / (rho + h) - (1 - theta0) / (1 - theta_plus_h) * (1 + ((gm_m - 1) / 2) * (M ^ 2 / (1 - theta_plus_h) ^ 2)) ^ (1 / (gm_m - 1))
        f_minus_h = rho0 / (rho - h) - (1 - theta0) / (1 - theta_minus_h) * (1 + ((gm_m - 1) / 2) * (M ^ 2 / (1 - theta_minus_h) ^ 2)) ^ (1 / (gm_m - 1))
        Debug.Print "   f_plus_h = " & f_plus_h
        Debug.Print "   f_minus_h = " & f_minus_h
        
        df = (f_plus_h - f_minus_h) / (2 * h)
        Debug.Print "   df " & df
        
        rho = rho - f / df
        Debug.Print "   rho = " & rho
        
        If Abs(f) < eps Then
            F_StartNodeDensity = rho
            Exit Function
        End If
        
    Next iterNum
    
    ' If the function does not converge, return an error value
    F_StartNodeDensity = -1
    Debug.Print "F_StartNodeDensity: Newton-Raphson did not converge"
End Function


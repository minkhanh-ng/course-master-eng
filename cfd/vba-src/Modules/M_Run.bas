Attribute VB_Name = "M_Run"
Option Explicit

'Sub TestPipeNetwork()
'    Dim ElbowD As CPipeFitting
'    Set ElbowD = New CPipeFitting
'
'    With ElbowD
'        .Diameter = 0.25
'        .RadiusOfCurvature = 0.125
'        .AngleDegree = 90
'        .AbsoluteRoughness = 0.0015 / 1000 ' ï¿½?i mm sang m
'        .Velocity = 0.17
'        .KinematicViscosity = 0.000001
'    End With
'
'    Debug.Print "Type of fitting: " & ElbowD.FittingType
'    Debug.Print "Reynolds Number: " & ElbowD.Reynolds
'    Debug.Print "Local K (Zeta): " & ElbowD.Zeta
'    Debug.Print "Head Loss (m): " & ElbowD.HeadLoss
'
'    Set ElbowD = Nothing
'End Sub

'Sub TestPolymorphism()
'    Dim fitting As I_PipeFitting
'    Dim TotalHeadLoss As Double
'
'    Dim ElbowD As New C_Elbow_Bend
'    ElbowD.Diameter = 0.25
'    ElbowD.RadiusOfCurvature = 0.125
'    ElbowD.AngleDegree = 90
'    ElbowD.AbsoluteRoughness = 0.0015 / 1000
'    ElbowD.Velocity = 0.17
'    ElbowD.KinematicViscosity = 0.000001
'
'    ' Interface
'    Set fitting = ElbowD
'    TotalHeadLoss = TotalHeadLoss + fitting.HeadLoss
'
'    ' Nga tu C
'    Dim CrossC As New C_Tee_Cross
'    CrossC.Area_Inlet = 3.14 * (0.25 / 2) ^ 2
'    CrossC.Area_Straight = 3.14 * (0.2 / 2) ^ 2
'    CrossC.Area_Branch = 3.14 * (0.15 / 2) ^ 2
'    CrossC.Flow_Inlet = 0.02
'    CrossC.Flow_Straight = 0.012
'    CrossC.Flow_Branch = 0.008
'    CrossC.TargetPath = eFlowPath_Straight
'
'    ' Interface
'    Set fitting = CrossC
'    TotalHeadLoss = TotalHeadLoss + fitting.HeadLoss
'
'    Debug.Print "Tong ton thst cuc bo: " & TotalHeadLoss
'End Sub

'Sub Test_ASME_Reducer()
'
'    Dim ReducerObj As New C_Conical_Transition
'    Dim fitting As I_PipeFitting
'
'
'    Dim D_large As Double, D_small As Double
'    Dim L As Double, alpha_rad As Double, alpha_deg As Double
'    Dim Pi As Double: Pi = 3.14159265358979
'
'
'    D_large = 0.5   ' m
'    D_small = 0.25  ' m
'
'    L = 4.5 * (D_large - D_small)
'
'    alpha_rad = 2 * Atn(((D_large - D_small) / 2) / L)
'    alpha_deg = alpha_rad * 180 / Pi
'
'    With ReducerObj
'        .Diameter_Inlet = D_large
'        .Diameter_Outlet = D_small
'        .AngleDegree = alpha_deg
'        .AbsoluteRoughness = 0.0015 / 1000 ' Ð?i mm sang m
'        .Velocity_Inlet = 1.2
'        .KinematicViscosity = 10 ^ -6
'    End With
'
'    Set fitting = ReducerObj
'
'    Debug.Print "--- REDUCER ---"
'    Debug.Print "Chieu dai L: " & L & " m"
'    Debug.Print "Goc Conical (Alpha): " & Round(alpha_deg, 2) & " do"
'    Debug.Print "Zeta (Tham chieu Inlet): " & fitting.Zeta
'    Debug.Print "Head Loss: " & fitting.HeadLoss & " m"
'
'    Set fitting = Nothing
'    Set ReducerObj = Nothing
'End Sub

Sub Run()
    Calculate_Manifold_Solver createReport:=True, showDoneMessage:=True
End Sub

Attribute VB_Name = "M_Main"
Option Explicit

Private Type ColIndices
    nodeIn As Integer: nodeOut As Integer
    DeltaX As Integer: DeltaY As Integer: DeltaZ As Integer
    Assignment As Integer
    FitType As Integer: CompType As Integer
    D0 As Integer: D1 As Integer: Rough As Integer: L As Integer
    Q As Integer: LocalHL As Integer: totalHL As Integer
    Dens As Integer: DynVisc As Integer
End Type

Public Sub Calculate_Manifold_Solver(Optional ByVal createReport As Boolean = True, Optional ByVal showDoneMessage As Boolean = True)
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("PRG")
    
    Dim cols As ColIndices
    Dim headerRow As Integer: headerRow = 1
    
    ' 1. Data
    cols.nodeIn = FindColumn(ws, headerRow, "Node In")
    cols.nodeOut = FindColumn(ws, headerRow, "Node Out")
    cols.DeltaX = FindColumn(ws, headerRow, "DeltaX")
    cols.DeltaY = FindColumn(ws, headerRow, "DeltaY")
    cols.DeltaZ = FindColumn(ws, headerRow, "DeltaZ")
    cols.Assignment = FindColumn(ws, headerRow, "Assignment")
    cols.FitType = FindColumn(ws, headerRow, "Fit. Type")
    cols.CompType = FindColumn(ws, headerRow, "Comp. Type")
    cols.D0 = FindColumn(ws, headerRow, "D0")
    cols.D1 = FindColumn(ws, headerRow, "D1")
    cols.Rough = FindColumn(ws, headerRow, "Rough")
    cols.L = FindColumn(ws, headerRow, "Length")
    cols.Q = FindColumn(ws, headerRow, "Volume Flowrate")
    cols.LocalHL = FindColumn(ws, headerRow, "Local Headloss")
    cols.totalHL = FindColumn(ws, headerRow, "Total Headloss")
    cols.Dens = FindColumn(ws, headerRow, "Fluid Density")
    cols.DynVisc = FindColumn(ws, headerRow, "Dynamic Viscosity")
    
    If cols.Q = 0 Or cols.totalHL = 0 Then
        MsgBox "Dien Volume Flowrate / Total Headloss!", vbCritical: Exit Sub
    End If

    Dim lastRow As Long
    lastRow = ws.Cells(ws.rows.Count, 1).End(xlUp).Row
    Dim data As Variant
    data = ws.Range(ws.Cells(1, 1), ws.Cells(lastRow, 50)).Value
    
    ' ==========================================
    ' 2. PIPENET
    ' ==========================================
    Dim i As Long, ni As String, no As String
    Dim nodeInDict As Object: Set nodeInDict = CreateObject("Scripting.Dictionary")
    Dim nodeInCount As Object: Set nodeInCount = CreateObject("Scripting.Dictionary")
    
    Dim splitNode As String
    For i = 2 To UBound(data, 1)
        ni = Trim(CStr(data(i, cols.nodeIn)))
        If ni <> "" Then
            nodeInDict(ni) = 1
            If nodeInCount.exists(ni) Then
                nodeInCount(ni) = CLng(nodeInCount(ni)) + 1
            Else
                nodeInCount(ni) = 1
            End If
        End If
    Next i

    ' Chia segment theo input node (>1)
    Dim keyNode As Variant, maxCount As Long
    maxCount = 1
    splitNode = ""
    For Each keyNode In nodeInCount.Keys
        If CLng(nodeInCount(keyNode)) > maxCount Then
            maxCount = CLng(nodeInCount(keyNode))
            splitNode = CStr(keyNode)
        End If
    Next keyNode

    If splitNode = "" Then
        MsgBox "Split Node not found.", vbCritical
        Exit Sub
    End If
    
    Dim outlets As Collection
    Set outlets = CollectOutletNodes(data, cols)
    
    ' Collect cac hang cho moi outlet x
    Dim Branches As New Collection
    Dim outNode As Variant
    Dim branchRows As Collection
    For Each outNode In outlets
        Set branchRows = New Collection
        Dim currNode As String: currNode = outNode
        Dim safety As Integer: safety = 0
        
        Do While currNode <> splitNode And currNode <> "" And safety < 100
            safety = safety + 1
            Dim rFound As Long: rFound = 0
            For i = 2 To UBound(data, 1)
                If Trim(CStr(data(i, cols.nodeOut))) = currNode Then
                    rFound = i
                    If branchRows.Count = 0 Then branchRows.Add i Else branchRows.Add i, Before:=1
                    currNode = Trim(CStr(data(i, cols.nodeIn)))
                    Exit For
                End If
            Next i
            If rFound = 0 Then Exit Do
        Loop
        Branches.Add branchRows
    Next outNode
    
    If Branches.Count = 0 Then
        MsgBox "Error: Loi chia nhanh", vbCritical: Exit Sub
    End If

    If createReport Then
        Dim dbgB As Long, dbgRow As Variant, dbgText As String
        For dbgB = 1 To Branches.Count
            dbgText = "Branch " & dbgB & " rows:"
            For Each dbgRow In Branches(dbgB)
                dbgText = dbgText & " " & CStr(dbgRow)
            Next dbgRow
            Debug.Print dbgText
        Next dbgB
    End If
    
    ' Luu luong dau nguon
    Dim Q_total As Double
    Q_total = FindTotalInletFlow(data, cols)
    
    ' ==========================================
    ' 3. SOLVER
    ' ==========================================
    Dim numBranches As Integer: numBranches = Branches.Count
    Dim branchQ() As Double: ReDim branchQ(1 To numBranches)
    Dim branchHL() As Double: ReDim branchHL(1 To numBranches)
    
    For i = 1 To numBranches
        branchQ(i) = Q_total / numBranches
    Next i
    
    Dim iter As Integer, maxIter As Integer: maxIter = 50
    Dim tolerance As Double: tolerance = 0.000001
    Dim errorMax As Double, b As Integer, elRow As Variant
    Dim sum_1_sqrt_R As Double
    Dim r() As Double: ReDim r(1 To numBranches)
    
    If createReport Then Debug.Print "--- SOLVER ---"
    
    For iter = 1 To maxIter
        errorMax = 0
        sum_1_sqrt_R = 0
        
        ' R = H / Q^2
        For b = 1 To numBranches
            branchHL(b) = 0
            For Each elRow In Branches(b)
                Dim hl As Double, h_f As Double
                Dim qInRow As Double
                qInRow = branchQ(b)
                If Trim(CStr(data(CLng(elRow), cols.nodeIn))) = splitNode Then qInRow = Q_total
                hl = CalcRow(data, CLng(elRow), qInRow, branchQ(b), hl, h_f, cols)
                branchHL(b) = branchHL(b) + hl
            Next elRow
            
            If branchQ(b) > 0 Then r(b) = branchHL(b) / (branchQ(b) ^ 2) Else r(b) = 0.0001
            If r(b) < 0.0001 Then r(b) = 0.0001
            sum_1_sqrt_R = sum_1_sqrt_R + 1 / Sqr(r(b))
        Next b
        
        ' Phan phoi lai luu luong (R)
        For b = 1 To numBranches
            Dim newQ As Double
            newQ = Q_total / (Sqr(r(b)) * sum_1_sqrt_R)
            If Abs(newQ - branchQ(b)) > errorMax Then errorMax = Abs(newQ - branchQ(b))
            branchQ(b) = newQ
        Next b
        
        ' Log
        If createReport Then
            Debug.Print "Iter " & iter & " | Q_nhanh_1: " & Round(branchQ(1), 5) & " | Q_nhanh_2: " & Round(branchQ(2), 5) & " | Q_nhanh_3: " & Round(branchQ(3), 5)
        End If
        
        If errorMax < tolerance Then Exit For
    Next iter
    
    ' ==========================================
    ' 4. XUAT REPORT
    ' ==========================================
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    
    ' Ghi ket qua cho nhanh r
    For b = 1 To numBranches
        For Each elRow In Branches(b)
            Dim hl_l As Double, hl_f As Double, hl_tot As Double
            Dim qInOutRow As Double
            qInOutRow = branchQ(b)
            If Trim(CStr(data(CLng(elRow), cols.nodeIn))) = splitNode Then qInOutRow = Q_total
            ws.Cells(elRow, cols.Q).Value = branchQ(b)
            hl_tot = CalcRow(data, CLng(elRow), qInOutRow, branchQ(b), hl_l, hl_f, cols)
            If cols.LocalHL > 0 Then ws.Cells(elRow, cols.LocalHL).Value = hl_l
            If cols.totalHL > 0 Then ws.Cells(elRow, cols.totalHL).Value = hl_tot
        Next elRow
    Next b
    
    ' Ong chinh
    For i = 2 To UBound(data, 1)
        Dim isBranchRow As Boolean: isBranchRow = False
        For b = 1 To numBranches
            For Each elRow In Branches(b)
                If elRow = i Then isBranchRow = True: Exit For
            Next elRow
            If isBranchRow Then Exit For
        Next b
        
        If Not isBranchRow And Trim(CStr(data(i, cols.nodeIn))) <> "" Then
            ws.Cells(i, cols.Q).Value = Q_total
            hl_tot = CalcRow(data, i, Q_total, Q_total, hl_l, hl_f, cols)
            If cols.LocalHL > 0 Then ws.Cells(i, cols.LocalHL).Value = hl_l
            If cols.totalHL > 0 Then ws.Cells(i, cols.totalHL).Value = hl_tot
        End If
    Next i
    
    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True

    If createReport Then
        Export_Manifold_Report ws, cols, splitNode, Q_total
    End If
    
    If createReport And showDoneMessage Then
        MsgBox "Hydraulic solver converged after " & iter & " iteration(s).", vbInformation, "CFD Solver"
    End If
End Sub

Private Function Infer4WDPathType(data As Variant, cols As ColIndices, ByVal rowIdx As Long) As Integer
    Dim nodeLabel As String
    nodeLabel = Trim(CStr(data(rowIdx, cols.nodeIn)))

    If nodeLabel = "" Then
        Infer4WDPathType = 2
        Exit Function
    End If

    Dim straightRow As Long
    straightRow = Find4WDStraightRow(data, cols, nodeLabel)

    If straightRow = 0 Then
        Infer4WDPathType = 2
        Debug.Print "4WD debug | nodeIn=" & nodeLabel & " | row=" & rowIdx & " | path=branch | fallback=no-explicit-straight"
        Exit Function
    End If

    Dim chosenDiameter As Double
    chosenDiameter = EffectiveDiameterMM(data, cols, straightRow)

    If rowIdx = straightRow Then
        Infer4WDPathType = 1
        Debug.Print "4WD debug | nodeIn=" & nodeLabel & " | row=" & rowIdx & " | nodeOut=" & Trim(CStr(data(rowIdx, cols.nodeOut))) & " | path=straight | straightRow=" & straightRow & " | D_eff=" & chosenDiameter
    Else
        Infer4WDPathType = 2
        Debug.Print "4WD debug | nodeIn=" & nodeLabel & " | row=" & rowIdx & " | nodeOut=" & Trim(CStr(data(rowIdx, cols.nodeOut))) & " | path=branch | straightRow=" & straightRow & " | D_eff=" & chosenDiameter
    End If
End Function

Private Function Find4WDStraightRow(data As Variant, cols As ColIndices, ByVal nodeLabel As String) As Long
    Dim i As Long

    For i = 2 To UBound(data, 1)
        If Trim(CStr(data(i, cols.nodeIn))) = nodeLabel Then
            Dim rowFit As String
            Dim rowComp As String
            rowFit = UCase(Trim(CStr(data(i, cols.FitType))))
            rowComp = UCase(Trim(CStr(data(i, cols.CompType))))

            If InStr(1, rowFit, "4WD_S") > 0 Or InStr(1, rowComp, "4WD_S") > 0 Then
                Find4WDStraightRow = i
                Exit Function
            End If
        End If
    Next i

    Find4WDStraightRow = 0
End Function

Private Function Find4WDLargestRow(data As Variant, cols As ColIndices, ByVal nodeLabel As String) As Long
    Dim i As Long
    Dim bestRow As Long
    Dim bestDiameter As Double

    For i = 2 To UBound(data, 1)
        If Trim(CStr(data(i, cols.nodeIn))) = nodeLabel Then
            Dim rowFit As String
            Dim rowComp As String
            rowFit = UCase(Trim(CStr(data(i, cols.FitType))))
            rowComp = UCase(Trim(CStr(data(i, cols.CompType))))

            If InStr(1, rowFit, "4WD") > 0 Or InStr(1, rowComp, "4WD") > 0 Then
                Dim dEff As Double
                dEff = EffectiveDiameterMM(data, cols, i)
                If dEff > bestDiameter Then
                    bestDiameter = dEff
                    bestRow = i
                End If
            End If
        End If
    Next i

    Find4WDLargestRow = bestRow
End Function

Private Function EffectiveDiameterMM(data As Variant, cols As ColIndices, ByVal rowIdx As Long) As Double
    Dim D0 As Double
    Dim D1 As Double
    D0 = val(data(rowIdx, cols.D0))
    D1 = val(data(rowIdx, cols.D1))

    If D0 > D1 Then
        EffectiveDiameterMM = D0
    Else
        EffectiveDiameterMM = D1
    End If
End Function

Private Function EffectiveAreaM2(data As Variant, cols As ColIndices, ByVal rowIdx As Long) As Double
    Dim dEff As Double
    dEff = EffectiveDiameterMM(data, cols, rowIdx)
    If dEff <= 0# Then Exit Function
    ' dEff is mm -> convert to meters for area (m^2)
    Dim dEff_m As Double: dEff_m = dEff / 1000
    EffectiveAreaM2 = 3.1415926535 * (dEff_m / 2) ^ 2
End Function

Private Function FindIncomingRow(data As Variant, cols As ColIndices, ByVal nodeName As String) As Long
    Dim i As Long
    If nodeName = "" Then Exit Function

    For i = 2 To UBound(data, 1)
        If Trim(CStr(data(i, cols.nodeOut))) = nodeName Then
            FindIncomingRow = i
            Exit Function
        End If
    Next i
End Function

Public Sub Export_Report_Only()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("PRG")

    Dim cols As ColIndices
    Dim headerRow As Integer: headerRow = 1

    cols.nodeIn = FindColumn(ws, headerRow, "Node In")
    cols.nodeOut = FindColumn(ws, headerRow, "Node Out")
    cols.DeltaX = FindColumn(ws, headerRow, "DeltaX")
    cols.DeltaY = FindColumn(ws, headerRow, "DeltaY")
    cols.DeltaZ = FindColumn(ws, headerRow, "DeltaZ")
    cols.Assignment = FindColumn(ws, headerRow, "Assignment")
    cols.FitType = FindColumn(ws, headerRow, "Fit. Type")
    cols.CompType = FindColumn(ws, headerRow, "Comp. Type")
    cols.D0 = FindColumn(ws, headerRow, "D0")
    cols.D1 = FindColumn(ws, headerRow, "D1")
    cols.Rough = FindColumn(ws, headerRow, "Rough")
    cols.L = FindColumn(ws, headerRow, "Length")
    cols.Q = FindColumn(ws, headerRow, "Volume Flowrate")
    cols.LocalHL = FindColumn(ws, headerRow, "Local Headloss")
    cols.totalHL = FindColumn(ws, headerRow, "Total Headloss")
    cols.Dens = FindColumn(ws, headerRow, "Fluid Density")
    cols.DynVisc = FindColumn(ws, headerRow, "Dynamic Viscosity")

    If cols.nodeIn = 0 Or cols.nodeOut = 0 Or cols.Q = 0 Or cols.totalHL = 0 Then
        MsgBox "Thieu thong so!", vbCritical
        Exit Sub
    End If

    Dim lastRow As Long
    lastRow = ws.Cells(ws.rows.Count, 1).End(xlUp).Row

    Dim data As Variant
    data = ws.Range(ws.Cells(1, 1), ws.Cells(lastRow, 50)).Value

    Dim splitNode As String
    splitNode = FindSplitNode(data, cols)

    Dim qTotal As Double
    qTotal = FindTotalInletFlow(data, cols)

    Export_Manifold_Report ws, cols, splitNode, qTotal
    MsgBox "Report updated!", vbInformation
End Sub

Private Sub Export_Manifold_Report(wsPRG As Worksheet, cols As ColIndices, ByVal splitNode As String, ByVal qTotal As Double)
    Dim lastRow As Long
    lastRow = wsPRG.Cells(wsPRG.rows.Count, 1).End(xlUp).Row

    Dim data As Variant
    data = wsPRG.Range(wsPRG.Cells(1, 1), wsPRG.Cells(lastRow, 50)).Value

    Dim wsRpt As Worksheet
    On Error Resume Next
    Set wsRpt = ThisWorkbook.Sheets("Report")
    On Error GoTo 0

    If wsRpt Is Nothing Then
        Set wsRpt = ThisWorkbook.Sheets.Add(After:=wsPRG)
        wsRpt.Name = "Report"
    Else
        wsRpt.Cells.Clear
    End If

    Dim outlets As Collection
    Set outlets = CollectOutletNodes(data, cols)

    wsRpt.Range("A1").Value = "Hydraulic Branch Report"
    wsRpt.Range("A1").Font.Bold = True
    wsRpt.Range("A1").Font.Size = 16
    wsRpt.Range("A2").Value = "Generated:"
    wsRpt.Range("B2").Value = Now
    wsRpt.Range("A3").Value = "Split Node:"
    wsRpt.Range("B3").Value = splitNode
    wsRpt.Range("A4").Value = "Total Inlet Flow (m3/s):"
    wsRpt.Range("B4").Value = qTotal
    wsRpt.Range("A5").Value = "Outlet Count:"
    wsRpt.Range("B5").Value = outlets.Count

    Dim startRow As Long: startRow = 7
    wsRpt.Cells(startRow, 1).Value = "Branch"
    wsRpt.Cells(startRow, 2).Value = "Path (Inlet -> Outlet)"
    wsRpt.Cells(startRow, 3).Value = "Outlet Node"
    wsRpt.Cells(startRow, 4).Value = "Outlet Dia (mm)"
    wsRpt.Cells(startRow, 5).Value = "Outlet Flow (m3/s)"
    wsRpt.Cells(startRow, 6).Value = "Outlet Flow (%)"
    wsRpt.Cells(startRow, 7).Value = "Total Headloss (m)"
    wsRpt.Cells(startRow, 8).Value = "Resistance H/Q^2"
    wsRpt.Cells(startRow, 9).Value = "Segments"
    wsRpt.Range(wsRpt.Cells(startRow, 1), wsRpt.Cells(startRow, 9)).Font.Bold = True

    Dim b As Long: b = 0
    Dim outletNode As Variant
    Dim sumOutletQ As Double: sumOutletQ = 0#

    For Each outletNode In outlets
        Dim pathRows As Collection
        Set pathRows = TracePathRows(data, cols, CStr(outletNode))

        If pathRows.Count > 0 Then
            b = b + 1
            Dim outQ As Double, outHL As Double, outDmm As Double
            outQ = PathOutletFlow(data, pathRows, cols)
            outHL = PathTotalHeadloss(data, pathRows, cols)
            outDmm = PathOutletDiameterMM(data, pathRows, cols)

            sumOutletQ = sumOutletQ + outQ

            Dim rr As Long: rr = startRow + b
            wsRpt.Cells(rr, 1).Value = "B" & b
            wsRpt.Cells(rr, 2).Value = BuildPathNodeString(data, pathRows, cols)
            wsRpt.Cells(rr, 3).Value = CStr(outletNode)
            wsRpt.Cells(rr, 4).Value = outDmm
            wsRpt.Cells(rr, 5).Value = outQ
            If qTotal > 0 Then wsRpt.Cells(rr, 6).Value = outQ / qTotal
            wsRpt.Cells(rr, 7).Value = outHL
            If outQ > 0 Then wsRpt.Cells(rr, 8).Value = outHL / (outQ ^ 2)
            wsRpt.Cells(rr, 9).Value = pathRows.Count
        End If
    Next outletNode

    Dim sumRow As Long: sumRow = startRow + b + 2
    wsRpt.Cells(sumRow, 1).Value = "Summary"
    wsRpt.Cells(sumRow, 1).Font.Bold = True
    wsRpt.Cells(sumRow + 1, 1).Value = "Sum Outlet Flow (m3/s)"
    wsRpt.Cells(sumRow + 1, 2).Value = sumOutletQ
    wsRpt.Cells(sumRow + 2, 1).Value = "Flow Balance Error (Qin - SumQout)"
    wsRpt.Cells(sumRow + 2, 2).Value = qTotal - sumOutletQ

    ' Detailed branch table
    Dim detailHeaderRow As Long
    detailHeaderRow = sumRow + 5

    wsRpt.Cells(detailHeaderRow, 1).Value = "Branch"
    wsRpt.Cells(detailHeaderRow, 2).Value = "Seg"
    wsRpt.Cells(detailHeaderRow, 3).Value = "PRG Row"
    wsRpt.Cells(detailHeaderRow, 4).Value = "Node In"
    wsRpt.Cells(detailHeaderRow, 5).Value = "Node Out"
    wsRpt.Cells(detailHeaderRow, 6).Value = "Fit. Type"
    wsRpt.Cells(detailHeaderRow, 7).Value = "Comp. Type"
    wsRpt.Cells(detailHeaderRow, 8).Value = "D0 (mm)"
    wsRpt.Cells(detailHeaderRow, 9).Value = "D1 (mm)"
    wsRpt.Cells(detailHeaderRow, 10).Value = "Length"
    wsRpt.Cells(detailHeaderRow, 11).Value = "Flow (m3/s)"
    wsRpt.Cells(detailHeaderRow, 12).Value = "Local HL (m)"
    wsRpt.Cells(detailHeaderRow, 13).Value = "Friction HL (m)"
    wsRpt.Cells(detailHeaderRow, 14).Value = "Total HL (m)"
    wsRpt.Cells(detailHeaderRow, 15).Value = "Cumulative HL (m)"
    wsRpt.Range(wsRpt.Cells(detailHeaderRow, 1), wsRpt.Cells(detailHeaderRow, 15)).Font.Bold = True

    Dim detailRow As Long
    detailRow = detailHeaderRow + 1

    Dim detailBranch As Long
    detailBranch = 0

    For Each outletNode In outlets
        Set pathRows = TracePathRows(data, cols, CStr(outletNode))
        If pathRows.Count > 0 Then
            detailBranch = detailBranch + 1

            Dim seg As Long
            Dim cumHL As Double
            cumHL = 0#

            For seg = 1 To pathRows.Count
                Dim prgRow As Long
                prgRow = CLng(pathRows(seg))

                Dim segTotalHL As Double
                Dim segLocalHL As Double
                Dim segFrictionHL As Double
                segTotalHL = val(data(prgRow, cols.totalHL))
                segLocalHL = val(data(prgRow, cols.LocalHL))
                segFrictionHL = segTotalHL - segLocalHL
                cumHL = cumHL + segTotalHL

                wsRpt.Cells(detailRow, 1).Value = "B" & detailBranch
                wsRpt.Cells(detailRow, 2).Value = seg
                wsRpt.Cells(detailRow, 3).Value = prgRow
                wsRpt.Cells(detailRow, 4).Value = Trim(CStr(data(prgRow, cols.nodeIn)))
                wsRpt.Cells(detailRow, 5).Value = Trim(CStr(data(prgRow, cols.nodeOut)))
                wsRpt.Cells(detailRow, 6).Value = Trim(CStr(data(prgRow, cols.FitType)))
                wsRpt.Cells(detailRow, 7).Value = Trim(CStr(data(prgRow, cols.CompType)))
                wsRpt.Cells(detailRow, 8).Value = val(data(prgRow, cols.D0))
                wsRpt.Cells(detailRow, 9).Value = val(data(prgRow, cols.D1))
                wsRpt.Cells(detailRow, 10).Value = val(data(prgRow, cols.L))
                wsRpt.Cells(detailRow, 11).Value = val(data(prgRow, cols.Q))
                wsRpt.Cells(detailRow, 12).Value = segLocalHL
                wsRpt.Cells(detailRow, 13).Value = segFrictionHL
                wsRpt.Cells(detailRow, 14).Value = segTotalHL
                wsRpt.Cells(detailRow, 15).Value = cumHL

                detailRow = detailRow + 1
            Next seg
        End If
    Next outletNode

    If b > 0 Then
        wsRpt.Range(wsRpt.Cells(startRow + 1, 6), wsRpt.Cells(startRow + b, 6)).NumberFormat = "0.00%"
        wsRpt.Range(wsRpt.Cells(startRow + 1, 4), wsRpt.Cells(startRow + b, 8)).NumberFormat = "0.000000"
    End If

    If detailRow > detailHeaderRow + 1 Then
        wsRpt.Range(wsRpt.Cells(detailHeaderRow + 1, 10), wsRpt.Cells(detailRow - 1, 10)).NumberFormat = "0.000"
        wsRpt.Range(wsRpt.Cells(detailHeaderRow + 1, 11), wsRpt.Cells(detailRow - 1, 15)).NumberFormat = "0.000000"
    End If

    wsRpt.Columns("A:O").EntireColumn.AutoFit
End Sub

Private Function TracePathRows(data As Variant, cols As ColIndices, ByVal outletNode As String) As Collection
    Dim rows As New Collection
    Dim currNode As String: currNode = outletNode
    Dim safety As Long: safety = 0

    Do While currNode <> "" And safety < 200
        safety = safety + 1

        Dim foundRow As Long: foundRow = 0
        Dim i As Long
        For i = 2 To UBound(data, 1)
            If Trim(CStr(data(i, cols.nodeOut))) = currNode Then
                foundRow = i
                Exit For
            End If
        Next i

        If foundRow = 0 Then Exit Do
        If rows.Count = 0 Then
            rows.Add foundRow
        Else
            rows.Add foundRow, Before:=1
        End If

        currNode = Trim(CStr(data(foundRow, cols.nodeIn)))
    Loop

    Set TracePathRows = rows
End Function

Private Function BuildPathNodeString(data As Variant, rows As Collection, cols As ColIndices) As String
    Dim i As Long
    Dim s As String

    For i = 1 To rows.Count
        Dim r As Long: r = CLng(rows(i))
        Dim nodeIn As String: nodeIn = Trim(CStr(data(r, cols.nodeIn)))
        Dim nodeOut As String: nodeOut = Trim(CStr(data(r, cols.nodeOut)))

        If i = 1 Then s = nodeIn
        If nodeOut <> "" Then s = s & " -> " & nodeOut
    Next i

    BuildPathNodeString = s
End Function

Private Function PathTotalHeadloss(data As Variant, rows As Collection, cols As ColIndices) As Double
    Dim totalHL As Double: totalHL = 0#
    Dim i As Long

    For i = 1 To rows.Count
        totalHL = totalHL + val(data(CLng(rows(i)), cols.totalHL))
    Next i

    PathTotalHeadloss = totalHL
End Function

Private Function PathOutletFlow(data As Variant, rows As Collection, cols As ColIndices) As Double
    If rows.Count = 0 Then
        PathOutletFlow = 0#
        Exit Function
    End If

    PathOutletFlow = val(data(CLng(rows(rows.Count)), cols.Q))
End Function

Private Function PathOutletDiameterMM(data As Variant, rows As Collection, cols As ColIndices) As Double
    If rows.Count = 0 Then
        PathOutletDiameterMM = 0#
        Exit Function
    End If

    Dim r As Long: r = CLng(rows(rows.Count))
    Dim D1 As Double: D1 = val(data(r, cols.D1))
    Dim D0 As Double: D0 = val(data(r, cols.D0))
    If D1 > 0 Then
        PathOutletDiameterMM = D1
    Else
        PathOutletDiameterMM = D0
    End If
End Function

Private Function FindSplitNode(data As Variant, cols As ColIndices) As String
    Dim nodeInCount As Object: Set nodeInCount = CreateObject("Scripting.Dictionary")
    Dim i As Long, ni As String

    For i = 2 To UBound(data, 1)
        ni = Trim(CStr(data(i, cols.nodeIn)))
        If ni <> "" Then
            If nodeInCount.exists(ni) Then
                nodeInCount(ni) = CLng(nodeInCount(ni)) + 1
            Else
                nodeInCount(ni) = 1
            End If
        End If
    Next i

    Dim maxCount As Long: maxCount = 1
    Dim bestNode As String: bestNode = ""
    Dim keyNode As Variant
    For Each keyNode In nodeInCount.Keys
        If CLng(nodeInCount(keyNode)) > maxCount Then
            maxCount = CLng(nodeInCount(keyNode))
            bestNode = CStr(keyNode)
        End If
    Next keyNode

    FindSplitNode = bestNode
End Function

Private Function FindTotalInletFlow(data As Variant, cols As ColIndices) As Double
    Dim i As Long, j As Long
    Dim ni As String
    Dim sumInletQ As Double
    Dim inletCount As Long

    ' Priority 1: explicit Assignment column.
    If cols.Assignment > 0 Then
        For i = 2 To UBound(data, 1)
            If IsAssignmentTag(CStr(data(i, cols.Assignment)), "INLET") Then
                sumInletQ = sumInletQ + val(data(i, cols.Q))
                inletCount = inletCount + 1
            End If
        Next i
        If inletCount > 0 Then
            FindTotalInletFlow = sumInletQ
            Exit Function
        End If
    End If

    ' Fallback: infer inlet by topology.
    For i = 2 To UBound(data, 1)
        ni = Trim(CStr(data(i, cols.nodeIn)))
        If ni <> "" Then
            Dim isOut As Boolean: isOut = False
            For j = 2 To UBound(data, 1)
                If Trim(CStr(data(j, cols.nodeOut))) = ni Then
                    isOut = True
                    Exit For
                End If
            Next j
            If Not isOut Then
                FindTotalInletFlow = val(data(i, cols.Q))
                Exit Function
            End If
        End If
    Next i

    FindTotalInletFlow = 0#
End Function

Private Function CollectOutletNodes(data As Variant, cols As ColIndices) As Collection
    Dim outlets As New Collection
    Dim i As Long
    Dim no As String

    ' Priority 1: explicit Assignment column.
    If cols.Assignment > 0 Then
        For i = 2 To UBound(data, 1)
            If IsAssignmentTag(CStr(data(i, cols.Assignment)), "OUTLET") Then
                no = Trim(CStr(data(i, cols.nodeOut)))
                If no <> "" Then
                    On Error Resume Next
                    outlets.Add no, no
                    On Error GoTo 0
                End If
            End If
        Next i
        If outlets.Count > 0 Then
            Set CollectOutletNodes = outlets
            Exit Function
        End If
    End If

    ' Fallback: infer outlet by topology.
    Dim nodeInDict As Object
    Set nodeInDict = CreateObject("Scripting.Dictionary")
    Dim ni As String
    For i = 2 To UBound(data, 1)
        ni = Trim(CStr(data(i, cols.nodeIn)))
        If ni <> "" Then nodeInDict(ni) = 1
    Next i

    For i = 2 To UBound(data, 1)
        no = Trim(CStr(data(i, cols.nodeOut)))
        If no <> "" And Not nodeInDict.exists(no) Then
            On Error Resume Next
            outlets.Add no, no
            On Error GoTo 0
        End If
    Next i

    Set CollectOutletNodes = outlets
End Function

Private Function IsAssignmentTag(ByVal assignmentText As String, ByVal tag As String) As Boolean
    IsAssignmentTag = (InStr(1, UCase$(Trim$(assignmentText)), UCase$(tag), vbTextCompare) > 0)
End Function

Public Sub Optimize_ByColumns()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("PRG")

    Dim cols As ColIndices
    Dim headerRow As Integer: headerRow = 1
    cols.nodeIn = FindColumn(ws, headerRow, "Node In")
    cols.nodeOut = FindColumn(ws, headerRow, "Node Out")
    cols.DeltaX = FindColumn(ws, headerRow, "DeltaX")
    cols.DeltaY = FindColumn(ws, headerRow, "DeltaY")
    cols.DeltaZ = FindColumn(ws, headerRow, "DeltaZ")
    cols.Assignment = FindColumn(ws, headerRow, "Assignment")
    cols.FitType = FindColumn(ws, headerRow, "Fit. Type")
    cols.CompType = FindColumn(ws, headerRow, "Comp. Type")
    cols.D0 = FindColumn(ws, headerRow, "D0")
    cols.D1 = FindColumn(ws, headerRow, "D1")
    cols.Rough = FindColumn(ws, headerRow, "Rough")
    cols.L = FindColumn(ws, headerRow, "Length")
    cols.Q = FindColumn(ws, headerRow, "Volume Flowrate")
    cols.LocalHL = FindColumn(ws, headerRow, "Local Headloss")
    cols.totalHL = FindColumn(ws, headerRow, "Total Headloss")
    cols.Dens = FindColumn(ws, headerRow, "Fluid Density")
    cols.DynVisc = FindColumn(ws, headerRow, "Dynamic Viscosity")

    Dim cOptIn As Integer, cOptOut As Integer, cOptTarget As Integer
    cOptIn = FindColumn(ws, headerRow, "Optimization Variable")
    cOptOut = FindColumn(ws, headerRow, "Optimization Result")
    cOptTarget = FindColumn(ws, headerRow, "Optimization Target")

    If cOptIn = 0 Or cOptOut = 0 Then
        MsgBox "Dien Optimization Variable/Optimization Result.", vbCritical
        Exit Sub
    End If

    Dim lastRow As Long
    lastRow = ws.Cells(ws.rows.Count, 1).End(xlUp).Row

    Dim selectedRows As Collection
    Set selectedRows = New Collection

    Dim r As Long
    Dim rItem As Variant
    For r = 2 To lastRow
        If Trim(CStr(ws.Cells(r, cOptIn).Value)) <> "" And Trim(CStr(ws.Cells(r, cOptOut).Value)) <> "" Then
            selectedRows.Add r
        End If
    Next r

    If selectedRows.Count = 0 Then
        MsgBox "Optimization Variable/Result not specified.", vbExclamation
        Exit Sub
    End If

    Dim targetByRow As Object
    Set targetByRow = CreateObject("Scripting.Dictionary")

    For Each rItem In selectedRows
        Dim outName As String
        outName = Trim(CStr(ws.Cells(CLng(rItem), cOptOut).Value))
        Dim outCol As Integer
        outCol = FindColumn(ws, headerRow, outName)
        If cOptTarget > 0 And Trim(CStr(ws.Cells(CLng(rItem), cOptTarget).Value)) <> "" Then
            targetByRow(CStr(CLng(rItem))) = val(ws.Cells(CLng(rItem), cOptTarget).Value)
        ElseIf outCol > 0 Then
            ' Fallback: use current Optimization Result as target.
            targetByRow(CStr(CLng(rItem))) = val(ws.Cells(CLng(rItem), outCol).Value)
        End If
    Next rItem

    ' Run once explicitly
    Calculate_Manifold_Solver False

    Dim maxIterInner As Integer: maxIterInner = 20
    Dim tolInner As Double: tolInner = 0.0000005
    Dim maxOuterIter As Integer: maxOuterIter = 12
    Dim tolSystem As Double: tolSystem = 0.000001

    Dim outerIt As Integer
    Dim outerDone As Integer
    Dim maxSystemErr As Double

    Dim historyErr() As Double
    Dim historyVar() As Double
    ReDim historyErr(1 To maxOuterIter)
    ReDim historyVar(1 To maxOuterIter, 1 To selectedRows.Count)

    For outerIt = 1 To maxOuterIter
        For Each rItem In selectedRows
            Dim rowIdx As Long: rowIdx = CLng(rItem)
            Dim varName As String: varName = Trim(CStr(ws.Cells(rowIdx, cOptIn).Value))
            Dim outMetric As String: outMetric = Trim(CStr(ws.Cells(rowIdx, cOptOut).Value))

            Dim varCol As Integer: varCol = FindColumn(ws, headerRow, varName)
            outCol = FindColumn(ws, headerRow, outMetric)

            If varCol = 0 Or outCol = 0 Then
                Debug.Print "Skip row " & rowIdx & ": khong tim duoc col " & varName & " hoac " & outMetric
                GoTo NextRowOpt
            End If

            Dim targetVal As Double
            If targetByRow.exists(CStr(rowIdx)) Then
                targetVal = CDbl(targetByRow(CStr(rowIdx)))
            Else
                targetVal = val(ws.Cells(rowIdx, outCol).Value)
            End If

            Dim xCur As Double: xCur = val(ws.Cells(rowIdx, varCol).Value)
            Dim xLow As Double, xHigh As Double

            If UCase(varName) = "D1" Then
                Dim d0mm As Double: d0mm = val(ws.Cells(rowIdx, cols.D0).Value)
                If d0mm <= 0 Then d0mm = xCur * 2
                xLow = 10
                xHigh = d0mm - 1
                If xCur < xLow Then xCur = xLow
                If xCur > xHigh Then xCur = xHigh
            Else
                If xCur <= 0 Then xCur = 1
                xLow = 0.5 * xCur
                xHigh = 1.5 * xCur
            End If

            Dim yLow As Double, yHigh As Double, yMid As Double
            yLow = EvaluateOutcome(ws, cols, rowIdx, varCol, xLow, outCol, varName)
            yHigh = EvaluateOutcome(ws, cols, rowIdx, varCol, xHigh, outCol, varName)

            If (targetVal - yLow) * (targetVal - yHigh) > 0 Then
                ' Target is not bracketed: scan the bounded domain and keep the best point.
                xCur = FindBestXByScan(ws, cols, rowIdx, varCol, xLow, xHigh, outCol, varName, targetVal, 30)
                Call ApplyVariableChange(ws, cols, rowIdx, varCol, xCur, varName)
                Calculate_Manifold_Solver False
                GoTo NextRowOpt
            End If

            Dim it As Integer
            For it = 1 To maxIterInner
                Dim xMid As Double
                xMid = 0.5 * (xLow + xHigh)
                yMid = EvaluateOutcome(ws, cols, rowIdx, varCol, xMid, outCol, varName)

                If Abs(yMid - targetVal) < tolInner Then Exit For

                If (targetVal - yLow) * (targetVal - yMid) <= 0 Then
                    xHigh = xMid
                    yHigh = yMid
                Else
                    xLow = xMid
                    yLow = yMid
                End If
            Next it

NextRowOpt:
        Next rItem

        ' Convergence history.
        Dim histIdx As Integer
        histIdx = 0
        For Each rItem In selectedRows
            histIdx = histIdx + 1
            rowIdx = CLng(rItem)
            varName = Trim(CStr(ws.Cells(rowIdx, cOptIn).Value))
            varCol = FindColumn(ws, headerRow, varName)
            If varCol > 0 Then
                historyVar(outerIt, histIdx) = val(ws.Cells(rowIdx, varCol).Value)
            End If
        Next rItem

        ' Coupled convergence check across all rows.
        Calculate_Manifold_Solver False
        maxSystemErr = 0#

        For Each rItem In selectedRows
            rowIdx = CLng(rItem)
            outMetric = Trim(CStr(ws.Cells(rowIdx, cOptOut).Value))
            outCol = FindColumn(ws, headerRow, outMetric)
            If outCol > 0 Then
                If targetByRow.exists(CStr(rowIdx)) Then
                    targetVal = CDbl(targetByRow(CStr(rowIdx)))
                Else
                    targetVal = val(ws.Cells(rowIdx, outCol).Value)
                End If

                Dim currentVal As Double
                currentVal = val(ws.Cells(rowIdx, outCol).Value)
                If Abs(currentVal - targetVal) > maxSystemErr Then
                    maxSystemErr = Abs(currentVal - targetVal)
                End If
            End If
        Next rItem

        historyErr(outerIt) = maxSystemErr
        outerDone = outerIt

        Debug.Print "Optimize outer iter " & outerIt & " | max error = " & Format(maxSystemErr, "0.000000000")
        If maxSystemErr < tolSystem Then Exit For
    Next outerIt

    Calculate_Manifold_Solver True, False
    AppendOptimizationHistory ws, cOptIn, selectedRows, historyErr, historyVar, outerDone
    MsgBox "Optimization done after " & outerIt & " iteration. Max error = " & Format(maxSystemErr, "0.000000000") & ".", vbInformation
End Sub

Private Sub AppendOptimizationHistory(wsPRG As Worksheet, ByVal cOptIn As Integer, selectedRows As Collection, historyErr() As Double, historyVar() As Double, ByVal outerDone As Integer)
    If outerDone <= 0 Then Exit Sub

    Dim wsRpt As Worksheet
    On Error Resume Next
    Set wsRpt = ThisWorkbook.Sheets("Report")
    On Error GoTo 0
    If wsRpt Is Nothing Then Exit Sub

    Dim startRow As Long
    startRow = wsRpt.Cells(wsRpt.rows.Count, 1).End(xlUp).Row + 2

    wsRpt.Cells(startRow, 1).Value = "Optimization Convergence History"
    wsRpt.Cells(startRow, 1).Font.Bold = True

    Dim headerRow As Long
    headerRow = startRow + 1
    wsRpt.Cells(headerRow, 1).Value = "Iter"
    wsRpt.Cells(headerRow, 2).Value = "Max Error"

    Dim rItem As Variant
    Dim idx As Integer
    idx = 0
    For Each rItem In selectedRows
        idx = idx + 1
        Dim rowIdx As Long
        rowIdx = CLng(rItem)
        wsRpt.Cells(headerRow, 2 + idx).Value = "Row " & rowIdx & " " & Trim(CStr(wsPRG.Cells(rowIdx, cOptIn).Value))
    Next rItem
    wsRpt.Range(wsRpt.Cells(headerRow, 1), wsRpt.Cells(headerRow, 2 + selectedRows.Count)).Font.Bold = True

    Dim it As Integer
    For it = 1 To outerDone
        wsRpt.Cells(headerRow + it, 1).Value = it
        wsRpt.Cells(headerRow + it, 2).Value = historyErr(it)
        For idx = 1 To selectedRows.Count
            wsRpt.Cells(headerRow + it, 2 + idx).Value = historyVar(it, idx)
        Next idx
    Next it

    wsRpt.Range(wsRpt.Cells(headerRow + 1, 2), wsRpt.Cells(headerRow + outerDone, 2 + selectedRows.Count)).NumberFormat = "0.000000000"
    wsRpt.Columns("A:O").EntireColumn.AutoFit
End Sub

Private Function EvaluateOutcome(ws As Worksheet, cols As ColIndices, ByVal rowIdx As Long, ByVal varCol As Integer, ByVal xVal As Double, ByVal outCol As Integer, ByVal varName As String) As Double
    ApplyVariableChange ws, cols, rowIdx, varCol, xVal, varName
    Calculate_Manifold_Solver False
    EvaluateOutcome = val(ws.Cells(rowIdx, outCol).Value)
End Function

Private Function FindBestXByScan(ws As Worksheet, cols As ColIndices, ByVal rowIdx As Long, ByVal varCol As Integer, ByVal xLow As Double, ByVal xHigh As Double, ByVal outCol As Integer, ByVal varName As String, ByVal targetVal As Double, Optional ByVal nSteps As Integer = 24) As Double
    Dim bestX As Double
    Dim bestErr As Double
    Dim xRef As Double
    Dim i As Integer

    If nSteps < 2 Then nSteps = 2
    If xHigh < xLow Then
        FindBestXByScan = xLow
        Exit Function
    End If

    xRef = val(ws.Cells(rowIdx, varCol).Value)
    bestX = xLow
    bestErr = 1E+30

    For i = 0 To nSteps
        Dim xTry As Double
        Dim yTry As Double
        Dim errTry As Double

        xTry = xLow + (xHigh - xLow) * CDbl(i) / CDbl(nSteps)
        yTry = EvaluateOutcome(ws, cols, rowIdx, varCol, xTry, outCol, varName)
        errTry = Abs(yTry - targetVal)

        If errTry < bestErr - 0.000000000001 Then
            bestErr = errTry
            bestX = xTry
        ElseIf Abs(errTry - bestErr) <= 0.000000000001 Then
            If Abs(xTry - xRef) < Abs(bestX - xRef) Then
                bestX = xTry
            End If
        End If
    Next i

    FindBestXByScan = bestX
End Function

Private Sub ApplyVariableChange(ws As Worksheet, cols As ColIndices, ByVal rowIdx As Long, ByVal varCol As Integer, ByVal newVal As Double, ByVal varName As String)
    Dim oldVal As Double
    oldVal = val(ws.Cells(rowIdx, varCol).Value)

    ws.Cells(rowIdx, varCol).Value = newVal

    If UCase(varName) = "D1" Then
        UpdateReducerGeometry ws, cols, rowIdx, oldVal, newVal
    End If
End Sub

' ==========================================
' REDUCER LENGTH ADJUSTMENT
' ==========================================
Private Sub UpdateReducerGeometry(ws As Worksheet, cols As ColIndices, ByVal reducerRow As Long, ByVal oldD1 As Double, ByVal newD1 As Double)
    Dim FitType As String, CompType As String
    FitType = UCase(Trim(CStr(ws.Cells(reducerRow, cols.FitType).Value)))
    CompType = UCase(Trim(CStr(ws.Cells(reducerRow, cols.CompType).Value)))

    If InStr(1, FitType, "RC") = 0 And InStr(1, CompType, "RC") = 0 Then Exit Sub

    Dim d0mm As Double
    d0mm = val(ws.Cells(reducerRow, cols.D0).Value)
    If d0mm <= 0 Then Exit Sub

    Dim oldLen As Double, newLen As Double
    oldLen = val(ws.Cells(reducerRow, cols.L).Value)
    newLen = 4.5 * (d0mm - newD1) / 1000
    If newLen < 0 Then newLen = 0
    ws.Cells(reducerRow, cols.L).Value = newLen
    SyncRowDeltaToLength ws, cols, reducerRow, newLen

    Dim upNode As String
    upNode = Trim(CStr(ws.Cells(reducerRow, cols.nodeIn).Value))
    If upNode = "" Then Exit Sub

    Dim prevRow As Long: prevRow = 0
    Dim r As Long, lastRow As Long
    lastRow = ws.Cells(ws.rows.Count, 1).End(xlUp).Row
    For r = 2 To lastRow
        If Trim(CStr(ws.Cells(r, cols.nodeOut).Value)) = upNode Then
            prevRow = r
            Exit For
        End If
    Next r

    If prevRow > 0 Then
        Dim prevFit As String, prevComp As String
        prevFit = UCase(Trim(CStr(ws.Cells(prevRow, cols.FitType).Value)))
        prevComp = UCase(Trim(CStr(ws.Cells(prevRow, cols.CompType).Value)))

        ' Prefer adjusting plain pipe segment right before reducer.
        If prevFit = "" And prevComp = "" Then
            Dim prevLen As Double
            Dim prevLenOld As Double
            prevLen = val(ws.Cells(prevRow, cols.L).Value)
            prevLenOld = prevLen
            prevLen = prevLen - (newLen - oldLen)
            If prevLen < 0 Then prevLen = 0
            ws.Cells(prevRow, cols.L).Value = prevLen
            If Abs(prevLen - prevLenOld) > 0.000000000001 Then
                SyncRowDeltaToLength ws, cols, prevRow, prevLen
            End If
        End If
    End If
End Sub

Private Sub SyncRowDeltaToLength(ws As Worksheet, cols As ColIndices, ByVal rowIdx As Long, ByVal newLen As Double)
    If cols.DeltaX = 0 And cols.DeltaY = 0 And cols.DeltaZ = 0 Then Exit Sub

    Dim dx As Double, dy As Double, dz As Double
    If cols.DeltaX > 0 Then
        dx = val(ws.Cells(rowIdx, cols.DeltaX).Value)
    End If
    If cols.DeltaY > 0 Then
        dy = val(ws.Cells(rowIdx, cols.DeltaY).Value)
    End If
    If cols.DeltaZ > 0 Then
        dz = val(ws.Cells(rowIdx, cols.DeltaZ).Value)
    End If

    Dim vecLen As Double
    vecLen = Sqr(dx * dx + dy * dy + dz * dz)
    If vecLen <= 0 Then Exit Sub

    Dim scaleFactor As Double
    scaleFactor = newLen / vecLen

    If cols.DeltaX > 0 Then
        ws.Cells(rowIdx, cols.DeltaX).Value = dx * scaleFactor
    End If
    If cols.DeltaY > 0 Then
        ws.Cells(rowIdx, cols.DeltaY).Value = dy * scaleFactor
    End If
    If cols.DeltaZ > 0 Then
        ws.Cells(rowIdx, cols.DeltaZ).Value = dz * scaleFactor
    End If
End Sub

' ==========================================
' HAM TRA KET QUA
' ==========================================
Private Function CalcRow(data As Variant, r As Long, Q_in As Double, Q_out As Double, ByRef h_local As Double, ByRef h_friction As Double, cols As ColIndices) As Double
    Dim D0 As Double: D0 = val(data(r, cols.D0)) / 1000
    Dim D1 As Double: D1 = val(data(r, cols.D1)) / 1000
    Dim Rough As Double: Rough = val(data(r, cols.Rough)) / 1000
    Dim L As Double: L = val(data(r, cols.L))
    Dim FitType As String: FitType = UCase(Trim(CStr(data(r, cols.FitType))))
    Dim CompType As String: CompType = UCase(Trim(CStr(data(r, cols.CompType))))
    Dim isReducer As Boolean
    isReducer = (InStr(1, FitType, "RC") > 0 Or InStr(1, CompType, "RC") > 0)

    Dim Dpipe As Double
    If D0 > 0 Then
        Dpipe = D0
    Else
        Dpipe = D1
    End If
    
    Dim Dens As Double: Dens = val(data(r, cols.Dens)): If Dens <= 0 Then Dens = 1000
    Dim DynVisc As Double: DynVisc = val(data(r, cols.DynVisc)): If DynVisc <= 0 Then DynVisc = 0.001
    Dim KinVisc As Double: KinVisc = DynVisc / Dens
    
    Dim V As Double: V = 0
    If Dpipe > 0 Then V = Q_out / (3.1415926535 * (Dpipe / 2) ^ 2)

    Dim V_inlet As Double: V_inlet = 0
    If D0 > 0 Then
        V_inlet = Q_out / (3.1415926535 * (D0 / 2) ^ 2)
    Else
        V_inlet = V
    End If
    
    h_friction = 0: h_local = 0
    
    If (Not isReducer) And L > 0 And V > 0 Then
        Dim Re As Double: Re = V * Dpipe / KinVisc
        h_friction = F_Colebrook(Dpipe, Re, Rough) * (L / Dpipe) * (V ^ 2) / (2 * 9.81)
    End If
    
    Dim fitting As I_PipeFitting
    If InStr(1, FitType, "EL90") > 0 Or InStr(1, CompType, "EL90") > 0 Then
        Dim objElbow As New C_Elbow_Bend
        With objElbow
            .Diameter = D0: .RadiusOfCurvature = 0.5 * D0: .AngleDegree = 90
            .AbsoluteRoughness = Rough: .Velocity = V: .KinematicViscosity = KinVisc
        End With
        Set fitting = objElbow
        h_local = fitting.HeadLoss
        
    ElseIf InStr(1, FitType, "4WD") > 0 Or InStr(1, CompType, "4WD") > 0 Then
        Dim objCross As New C_Tee_Cross
        Dim pathType As Integer
        Dim nodeLabel As String
        Dim inletRow As Long
        Dim straightRow As Long
        Dim largestRow As Long
        Dim inletArea As Double
        Dim straightArea As Double
        Dim branchArea As Double

        nodeLabel = Trim(CStr(data(r, cols.nodeIn)))
        inletRow = FindIncomingRow(data, cols, nodeLabel)
        straightRow = Find4WDStraightRow(data, cols, nodeLabel)
        largestRow = Find4WDLargestRow(data, cols, nodeLabel)

        If inletRow > 0 Then
            inletArea = EffectiveAreaM2(data, cols, inletRow)
        Else
            inletArea = 3.1415926535 * (D0 / 2) ^ 2
        End If

        If straightRow > 0 Then
            straightArea = EffectiveAreaM2(data, cols, straightRow)
            pathType = Infer4WDPathType(data, cols, r)
        Else
            If largestRow > 0 Then
                straightArea = EffectiveAreaM2(data, cols, largestRow)
            Else
                straightArea = 3.1415926535 * (D0 / 2) ^ 2
            End If
            pathType = 2
        End If

        branchArea = EffectiveAreaM2(data, cols, r)
        If branchArea <= 0# Then branchArea = 3.1415926535 * (D0 / 2) ^ 2

        With objCross
            .Area_Inlet = inletArea
            .Area_Straight = straightArea
            .Area_Branch = branchArea
            .Flow_Inlet = Q_in
            .TargetPath = pathType
            If pathType = 1 Then
                .Flow_Straight = Q_out
                .Flow_Branch = Q_in - Q_out
            Else
                .Flow_Branch = Q_out
                .Flow_Straight = 0#
            End If
        End With
        Set fitting = objCross
        h_local = fitting.HeadLoss
        
    ElseIf InStr(1, FitType, "RC") > 0 Or InStr(1, CompType, "RC") > 0 Then
        Dim objReducer As New C_Conical_Transition
        Dim rad_angle As Double
        If L > 0 Then rad_angle = 2 * Atn(((D0 - D1) / 2) / L) Else rad_angle = 0
        With objReducer
            .Diameter_Inlet = D0: .Diameter_Outlet = D1
            .AngleDegree = rad_angle * 180 / 3.1415926535
            .AbsoluteRoughness = Rough: .Velocity_Inlet = V_inlet: .KinematicViscosity = KinVisc
        End With
        Set fitting = objReducer
        h_local = fitting.HeadLoss
    End If
    
    CalcRow = h_local + h_friction
End Function

Private Function FindColumn(ws As Worksheet, rowNum As Integer, searchStr As String) As Integer
    Dim col As Integer
    For col = 1 To 50
        If InStr(1, UCase(ws.Cells(rowNum, col).Value), UCase(searchStr)) > 0 Then
            FindColumn = col: Exit Function
        End If
    Next col
    FindColumn = 0
End Function



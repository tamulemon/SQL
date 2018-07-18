
--EXEC sp_configure 'show advanced options',1
--GO
--RECONFIGURE
--GO
--EXEC sp_configure 'xp_cmdshell',1
--GO
--RECONFIGURE
 

--Error = [Microsoft][ODBC Driver 11 for SQL Server]Unable to open BCP host data-file
exec xp_cmdshell 'bcp UORL_STAGE.dbo.UOR_Merkle_Display_Placement_Cost_121415_122015 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_121415_122015.csv -c -q -t, -T'
--

--These needs to be executed in CMD
bcp UOR_Merkle_Display_Placement_Cost_121415_122015 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_121415_122015.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_122115_122715 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_122115_122715.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_122815_010316 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_122815_010316.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_010416_011016 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_010416_011016.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_011116_011716 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_011116_011716.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_011816_012416 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_011816_012416.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_012516_013116 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_012516_013116.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_020116_020716 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_020116_020716.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_020816_021416 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_020816_021416.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_021516_022116 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_021516_022116.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_022216_022816 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_022216_022816.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_022916_030616 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_022916_030616.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_030716_031316 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_030716_031316.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_031416_032016 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_031416_032016.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_032116_032716 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_032116_032716.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_032816_040316 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_032816_040316.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_040416_041016 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_040416_041016.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_041116_041716 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_041116_041716.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_041816_042416 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_041816_042416.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_042516_050116 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_042516_050116.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_050216_050816 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_050216_050816.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_050916_051516 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_050916_051516.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_051616_052216 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_051616_052216.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE
bcp UOR_Merkle_Display_Placement_Cost_052316_052916 OUT C:\git\UO_documentation\DISPLAY_COST_historical_load\UOR_Merkle_Display_Placement_Cost_052316_052916.csv -c -q -t, -T -S HQUORLSQL90 -d UORL_STAGE

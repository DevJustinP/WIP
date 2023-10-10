use SysproDocument
go
/* Dispatch Process
Update soh.Order_Processes
    set Enabled = 0
where ProcessType = 0
*/
/* BackOrder Process
Update soh.Order_Processes
    set Enabled = 0
where ProcessType = 1
*/

select * from SOH.Order_Processes

:SETVAR Pub   "WarehouseCompany100_004"
:SETVAR PubS "'WarehouseCompany100_004'"
-------------------------------------------------------------------------------
-- Drop a subscription to a publication at the publisher.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
EXEC WarehouseCompany100.sys.sp_dropsubscription 
  @publication                      = $(Pub),
  @subscriber                       = N'SQLREPORTING', 
  @destination_db                   = N'WarehouseCompany100', 
  @article                          = N'all';
GO

-------------------------------------------------------------------------------
-- Drop a subscription to a publication at the subscriber.
-------------------------------------------------------------------------------
:CONNECT SQLREPORTING
EXEC WarehouseCompany100.sys.sp_droppullsubscription 
  @publication                      = $(Pub),
  @publisher                        = N'SQL2008NEW', 
  @publisher_db                     = N'WarehouseCompany100';
GO

-------------------------------------------------------------------------------
-- Drop a publication.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
EXEC WarehouseCompany100.sys.sp_droppublication 
  @publication                      = $(Pub);
GO

/*
-------------------------------------------------------------------------------
-- Drop an article.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
EXEC Warehouse_Control.sys.sp_droparticle 
  @publication                      = $(Pub),
  @article                          = N'Transaction',
  @force_invalidate_snapshot = 1;
GO
*/

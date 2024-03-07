
:SETVAR Pub   "Warehouse_Control_002"
:SETVAR PubS "'Warehouse_Control_002'"
-------------------------------------------------------------------------------
-- Drop a subscription to a publication at the publisher.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
EXEC Warehouse_Control.sys.sp_dropsubscription 
  @publication                      = $(Pub),
  @subscriber                       = N'SQLREPORTING', 
  @destination_db                   = N'Warehouse_Control', 
  @article                          = N'all';
GO

-------------------------------------------------------------------------------
-- Drop a subscription to a publication at the subscriber.
-------------------------------------------------------------------------------
:CONNECT SQLREPORTING
EXEC Warehouse_Control.sys.sp_droppullsubscription 
  @publication                      = $(Pub),
  @publisher                        = N'SQL2008NEW', 
  @publisher_db                     = N'Warehouse_Control';
GO

-------------------------------------------------------------------------------
-- Drop a publication.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
EXEC Warehouse_Control.sys.sp_droppublication 
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

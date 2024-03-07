
:SETVAR Pub   "GWC_001"
:SETVAR PubS "'GWC_001'"
-------------------------------------------------------------------------------
-- Drop a subscription to a publication at the publisher.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
EXEC GWC.sys.sp_dropsubscription 
  @publication                      = $(Pub),
  @subscriber                       = N'SQLREPORTING', 
  @destination_db                   = N'GWC', 
  @article                          = N'all';
GO

-------------------------------------------------------------------------------
-- Drop a subscription to a publication at the subscriber.
-------------------------------------------------------------------------------
:CONNECT SQLREPORTING
EXEC GWC.sys.sp_droppullsubscription 
  @publication                      = $(Pub),
  @publisher                        = N'SQL2008NEW', 
  @publisher_db                     = N'GWC';
GO

-------------------------------------------------------------------------------
-- Drop a publication.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
EXEC GWC.sys.sp_droppublication 
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

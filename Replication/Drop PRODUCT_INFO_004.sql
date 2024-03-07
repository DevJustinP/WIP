
:SETVAR Pub   "PRODUCT_INFO_004"
:SETVAR PubS "'PRODUCT_INFO_004'"
-------------------------------------------------------------------------------
-- Drop a subscription to a publication at the publisher.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
EXEC PRODUCT_INFO.sys.sp_dropsubscription 
  @publication                      = $(Pub),
  @subscriber                       = N'SQLREPORTING', 
  @destination_db                   = N'PRODUCT_INFO', 
  @article                          = N'all';
GO

-------------------------------------------------------------------------------
-- Drop a subscription to a publication at the subscriber.
-------------------------------------------------------------------------------
:CONNECT SQLREPORTING
EXEC PRODUCT_INFO.sys.sp_droppullsubscription 
  @publication                      = $(Pub),
  @publisher                        = N'SQL2008NEW', 
  @publisher_db                     = N'PRODUCT_INFO';
GO

-------------------------------------------------------------------------------
-- Drop a publication.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
EXEC PRODUCT_INFO.sys.sp_droppublication 
  @publication                      = $(Pub);
GO

/*
-------------------------------------------------------------------------------
-- Drop an article.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
EXEC PRODUCT_INFO.sys.sp_droparticle 
  @publication                      = $(Pub),
  @article                          = N'Transaction',
  @force_invalidate_snapshot = 1;
GO
*/

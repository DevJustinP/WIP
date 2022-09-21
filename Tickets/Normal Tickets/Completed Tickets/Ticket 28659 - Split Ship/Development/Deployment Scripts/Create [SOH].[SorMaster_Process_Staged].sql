USE [SysproDocument]
GO

/****** Object:  Table [SOH].[SorMaster_Process_Staged]    Script Date: 5/18/2022 9:01:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SOH].[SorMaster_Process_Staged](
	[ProcessNumber] [int] IDENTITY(1,1) NOT NULL,
	[SalesOrder] [varchar](50) NOT NULL,
	[ProcessType] [int] NOT NULL,
	[Processed] [bit] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[LastChangedDateTime] [datetime] NOT NULL,
	[OptionalParm1] [varchar](250) NULL,
	[ERROR] [bit] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [SOH].[SorMaster_Process_Staged] ADD  CONSTRAINT [DF_SorMaster_Process_Staged_Processed]  DEFAULT ((0)) FOR [Processed]
GO

ALTER TABLE [SOH].[SorMaster_Process_Staged] ADD  CONSTRAINT [DF_SorMaster_Process_Staged_CreateDateTime]  DEFAULT (getdate()) FOR [CreateDateTime]
GO

ALTER TABLE [SOH].[SorMaster_Process_Staged] ADD  CONSTRAINT [DF_SorMaster_Process_Staged_LastChangedDateTime]  DEFAULT (getdate()) FOR [LastChangedDateTime]
GO

ALTER TABLE [SOH].[SorMaster_Process_Staged] ADD  DEFAULT ((0)) FOR [ERROR]
GO



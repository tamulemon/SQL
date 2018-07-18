USE [master];
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'PerfDB') CREATE DATABASE [PerfDB];
GO

USE [PerfDB];
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ANSI_PADDING ON;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TableSizeHistory') 
BEGIN;
CREATE TABLE [dbo].[TableSizeHistory](
	[RowId] [int] IDENTITY(1,1) NOT NULL CONSTRAINT PK_TableSizeHistory PRIMARY KEY NONCLUSTERED,
	[l1] [char](2) NULL,
	[InsertTime] [datetime] NULL CONSTRAINT [DF_TableSizeHistory_InsertTime]  DEFAULT (getdate()),
	[Database] [nvarchar](128) NULL,
	[Schema] [sysname] NOT NULL,
	[Table] [sysname] NOT NULL,
	[row_count] [int] NULL,
	[reserved_MB] [int] NULL,
	[data_MB] [int] NULL,
	[index_size_MB] [int] NULL,
	[unused_MB] [int] NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [IXC_TableSizeHistory_InsertTime] ON [dbo].[TableSizeHistory] ([InsertTime]);

CREATE NONCLUSTERED INDEX [IX_TableSizeHistory_row_count_data_MB] ON [dbo].[TableSizeHistory] ([row_count],	[data_MB])
	INCLUDE ( [InsertTime],[Database],[Table],[reserved_MB],[index_size_MB]);
END;
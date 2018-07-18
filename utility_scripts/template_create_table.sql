SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[be_Categories](
    [CategoryID] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_be_Categories_CategoryID]  DEFAULT (newid()),
    [CategoryName] [nvarchar](50) NULL,
    [Description] [nvarchar](200) NULL,
    [ParentID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_be_Categories] PRIMARY KEY CLUSTERED 
(
    [CategoryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
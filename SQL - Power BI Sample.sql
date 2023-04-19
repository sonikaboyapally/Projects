USE [reports]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- subtask json structure = {
--       "subtask name 1":{"rev_email":"johndoe@gm.com","analyst_name":"John Doe","start_date":"2016-09-14","end_date":"2016-12-16""status":"Complete"}
-- 		 "subtask name 2":{"rev_email":"johndoe@gm.com","analyst_name":"John Doe","start_date":"2016-09-16","end_date":"2016-12-19""status":"Complete"}
--}



-- all completed business items -  tasks & subtasks

CREATE VIEW [dbo].[v_finalized_business_item_task_sub_task_listings] AS 


WITH 
budget_task_sub_tasks_cte AS (SELECT [id] AS task_id
	  ,[business_item_id]
	  ,k.[key] AS 'sub_task'	  
	  ,JSON_VALUE(k.[value], '$.start_date') AS 'sub_task_start_date'
	  ,JSON_VALUE(k.[value], '$.end_date') AS 'sub_task_end_date'
	  ,JSON_VALUE(k.[value], '$.rev_name') AS 'sub_task_assigned_to_nm'
	  ,JSON_VALUE(k.[value], '$.rev_email') AS 'sub_task_assigned_to_email'
	  ,JSON_VALUE(k.[value], '$.status') AS 'sub_task_status'
	  ,[task_assigned_to]
	  ,[task_start_date]
	  ,[task_end_date]
	  ,[task_status]
  FROM [research].[dbo].[budgets]tp
  OUTER APPLY OPENJSON([sub_tasks], '$') AS k
),
billing_task_sub_tasks_cte AS (SELECT [id] AS task_id      
	  ,[business_item_id]
	  ,k.[key] AS 'sub_task'	  
	  ,JSON_VALUE(k.[value], '$.start_date') AS 'sub_task_start_date'
	  ,JSON_VALUE(k.[value], '$.end_date') AS 'sub_task_end_date'
	  ,JSON_VALUE(k.[value], '$.rev_name') AS 'sub_task_assigned_to_nm'
	  ,JSON_VALUE(k.[value], '$.rev_email') AS 'sub_task_assigned_to_email'
	  ,JSON_VALUE(k.[value], '$.status') AS 'sub_task_status'
	  ,[task_assigned_to]
	  ,[task_start_date]
	  ,[task_end_date]
	  ,[task_status]
  FROM [research].[dbo].[billings]tp
  OUTER APPLY OPENJSON([sub_tasks], '$') AS k
),
quality_assurance_task_subtask_cte AS (SELECT [id] AS task_id
	  ,[business_item_id]     
	  ,[closure_status] AS task_closure_status
	  ,k.[key] AS 'sub_task'	  
	  ,JSON_VALUE(k.[value], '$.start_date') AS 'sub_task_start_date'
	  ,JSON_VALUE(k.[value], '$.end_date') AS 'sub_task_end_date'
	  ,JSON_VALUE(k.[value], '$.rev_name') AS 'sub_task_assigned_to_nm'
	  ,JSON_VALUE(k.[value], '$.rev_email') AS 'sub_task_assigned_to_email'
	  ,JSON_VALUE(k.[value], '$.status') AS 'sub_task_status'
	  ,[task_assigned_to]
	  ,[task_start_date]
	  ,[task_end_date]
	  ,[task_status]
  FROM [research].[dbo].[participants]tp
  OUTER APPLY OPENJSON([sub_tasks], '$') AS k
)



SELECT pm.proposal_num
      ,pm.proposal_title
	  ,pm.email_addr AS researcher_email
	  ,p.first_name + ' ' + p.last_name AS researcher_full_name	  
	  ,bim.created AS 'business_item_start_date'
	  ,bim.closure_date AS 'business_item_end_date'
	  ,bim.closure_status AS 'business_item_status'
      ,'Budget' AS task
	  ,tmp_cte.status AS task_status
      ,tmp_cte.start_date AS task_start_date
      ,tmp_cte.end_date AS task_end_date
	  ,(SELECT first_name + ' ' + last_name
		  FROM [research].[dbo].[reviewers]rev WHERE rev.email_addr = tmp_cte.task_assigned_to )AS task_assigned_to_nm
      ,sub_task
	  ,sub_task_status
	  ,sub_task_start_date
	  ,sub_task_end_date
	  ,sub_task_assigned_to_nm
FROM [research].[dbo].[business_items] bim
INNER JOIN [budget_task_sub_tasks_cte] tmp_cte ON tmp_cte.business_item_id = bim.id
INNER JOIN [research].[dbo].[proposals] pm ON pm.id = tmp_cte.proposal_id	
	AND pm.is_active = 1
INNER JOIN [research].[dbo].[researchers] AS p ON p.email_addr = pm.email_addr

UNION

SELECT pm.proposal_num
      ,pm.proposal_title
	  ,pm.email_addr AS researcher_email
	  ,p.first_name + ' ' + p.last_name AS researcher_full_name	  
	  ,bim.created AS 'business_item_start_date'
	  ,bim.closure_date AS 'business_item_end_date'
	  ,bim.closure_status AS 'business_item_status'
      ,'Billing' AS task
	  ,tmp_cte.status AS task_status
      ,tmp_cte.start_date AS task_start_date
      ,tmp_cte.end_date AS task_end_date
	  ,(SELECT first_name + ' ' + last_name
		  FROM [research].[dbo].[reviewers]rev WHERE rev.email_addr = tmp_cte.task_assigned_to )AS task_assigned_to_nm
      ,sub_task
	  ,sub_task_status
	  ,sub_task_start_date
	  ,sub_task_end_date
	  ,sub_task_assigned_to_nm
FROM [research].[dbo].[business_items] bim
INNER JOIN [billing_task_sub_tasks_cte] tmp_cte ON tmp_cte.business_item_id = bim.id
INNER JOIN [research].[dbo].[proposals] pm ON pm.id = tmp_cte.proposal_id	
	AND pm.is_active = 1
INNER JOIN [research].[dbo].[researchers] AS p ON p.email_addr = pm.email_addr

UNION

SELECT pm.proposal_num
      ,pm.proposal_title
	  ,pm.email_addr AS researcher_email
	  ,p.first_name + ' ' + p.last_name AS researcher_full_name	  
	  ,bim.created AS 'business_item_start_date'
	  ,bim.closure_date AS 'business_item_end_date'
	  ,bim.closure_status AS 'business_item_status'
      ,'Quality Assurance' AS task
	  ,tmp_cte.status AS task_status
      ,tmp_cte.start_date AS task_start_date
      ,tmp_cte.end_date AS task_end_date
	  ,(SELECT first_name + ' ' + last_name
		  FROM [research].[dbo].[reviewers]rev WHERE rev.email_addr = tmp_cte.task_assigned_to )AS task_assigned_to_nm
      ,sub_task
	  ,sub_task_status
	  ,sub_task_start_date
	  ,sub_task_end_date
	  ,sub_task_assigned_to_nm
FROM [research].[dbo].[business_items] bim
INNER JOIN [quality_assurance_task_subtask_cte] tmp_cte ON tmp_cte.business_item_id = bim.id
INNER JOIN [research].[dbo].[proposals] pm ON pm.id = tmp_cte.proposal_id	
	AND pm.is_active = 1
INNER JOIN [research].[dbo].[researchers] AS p ON p.email_addr = pm.email_addr


GO


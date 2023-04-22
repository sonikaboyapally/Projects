-- Databricks notebook source
DROP TABLE IF EXISTS coder_performance;
CREATE TABLE coder_performance (
    coder_name varchar(255),
    department varchar(255),
    accuracy int
);
Insert into coder_performance (coder_name, department, accuracy)
values ("alex","pathology",99),
("alex","pathology",91),
("alex","pathology",92),
("alex", "pediatrics",26),
("alex", "pediatrics",78),
("alex", "pediatrics",45),
("caden", "cardiology",79),
("caden", "cardiology",62),
("caden", "cardiology",74),
("alex","cardiology",89),
("caden","pathology",45),
("caden","pediatrics",53),
("alissa","pathology",41),
("alissa","pathology",88),
("alissa","pathology",94),
("alissa","pediatrics",67),
("alissa","cardiology",95)

-- COMMAND ----------

select * from coder_performance;

-- COMMAND ----------

select 
	distinct(coder_id),
	department,
--     accuracy,
	avg(accuracy) over (partition by  department, coder_name) as avg_acc_per_dept
from
	coder_performance;

-- COMMAND ----------

select 
	distinct(coder_name),
	department,
--     accuracy,
    avg(accuracy) over (partition by  department, coder_name) as avg_acc,
	rank() over (partition by  department order by accuracy desc) as rank_in_dept
from
	coder_performance
order by
rank_in_dept;

-- COMMAND ----------

select 
	distinct(coder_name),
	department,
--     accuracy,
    avg(accuracy) over (partition by  department, coder_name) as avg_acc,
	rank() over (partition by  department order by accuracy desc) as rank_in_dept
from
	coder_performance
order by
rank_in_dept;

-- COMMAND ----------

select 
	coder_name,
	department,
    accuracy,
--     avg(accuracy) over (partition by  department, coder_name) as avg_acc,
	first_value(accuracy) over (partition by  department order by accuracy desc) as highest_acc,
    last_value(accuracy) over (partition by  department order by accuracy desc ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as least_acc,
    first_value(accuracy) over (partition by  department order by accuracy desc ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) - last_value(accuracy) over (partition by  department order by accuracy desc) as range_acc
    
from
	coder_performance
order by
department;

-- COMMAND ----------



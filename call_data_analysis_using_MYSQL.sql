use call_analysis;
show tables;
select * from calls_data;

DROP TABLE IF EXISTS calls_data;  
CREATE TABLE calls_data (
    contact_id VARCHAR(50),
    client_phone VARCHAR(50),
    skill_name VARCHAR(100),
    campaign_name VARCHAR(100),
    agent_no VARCHAR(50),
    start_date VARCHAR(50),   
    start_time VARCHAR(50),
    PreQueue VARCHAR(50),
    InQueue VARCHAR(50),
    Agent_Time VARCHAR(50),
    Total_Time VARCHAR(50),
    Abandon_Time VARCHAR(50),
    abandon VARCHAR(5)  
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/calls_Data.csv' 
INTO TABLE calls_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET SQL_SAFE_UPDATES = 0;

UPDATE calls_data 
SET start_date = STR_TO_DATE(start_date, '%d-%m-%Y');

UPDATE calls_data 
SET start_time = STR_TO_DATE(start_time, '%H:%i:%s');

ALTER TABLE calls_data 
MODIFY COLUMN contact_id BIGINT,         
MODIFY COLUMN client_phone VARCHAR(20),  
MODIFY COLUMN skill_name VARCHAR(50),    
MODIFY COLUMN campaign_name VARCHAR(100),
MODIFY COLUMN agent_no INT,              
MODIFY COLUMN start_date DATE,           
MODIFY COLUMN start_time TIME,           
MODIFY COLUMN PreQueue INT,              
MODIFY COLUMN InQueue INT,
MODIFY COLUMN Agent_Time INT,
MODIFY COLUMN Total_Time INT,
MODIFY COLUMN Abandon_Time INT,
MODIFY COLUMN abandon CHAR(1);           

-- Checking if any duplicates
SELECT contact_id, COUNT(*) 
FROM calls_data 
GROUP BY contact_id 
HAVING COUNT(*) > 1;

DESCRIBE calls_data; 

-- 1.Total numbers of rows/records
SELECT COUNT(*) AS total_calls FROM calls_data;

-- 2. Count of inbound and outbound calls
SELECT skill_name, count(*) as total_calls FROM calls_data
GROUP BY skill_name;

-- Returing first 10 rows
SELECT * FROM calls_data LIMIT 10;

-- 3. Abandon call rate
SELECT abandon, count(*) as abandon_calls FROM calls_data
GROUP BY abandon;

-- Numbers of agents
SELECT count(DISTINCT agent_no) as agents FROM calls_data;

-- 4. Numbers of campaign
SELECT DISTINCT campaign_name FROM calls_data; 

-- 5. How many days data we have.
SELECT DISTINCT start_date FROM calls_data;

-- 6. Best time for calls (Hourly rate)
SELECT HOUR(start_time) as call_hour, count(*) as total_calls FROM calls_data
WHERE abandon = 'N'
GROUP BY call_hour
ORDER BY total_calls DESC;

SELECT * FROM calls_data LIMIT 10;

-- 7. Calls per day
SELECT start_date, count(*) as total_calls FROM calls_data
GROUP BY start_date
ORDER BY total_calls;

-- 8. Top 5 active agents by numbers of calls
SELECT agent_no, count(*) as total_calls FROM calls_data
GROUP BY agent_no
ORDER BY total_calls DESC
LIMIT 5;

-- 9. Bottom 5 agents by numbers of calls
SELECT agent_no, count(*) as total_calls FROM calls_data
GROUP BY agent_no
ORDER BY total_calls ASC
LIMIT 5;

SELECT * FROM calls_data LIMIT 10;

-- 10. Average time agent spends on call
SELECT agent_no, Avg(Agent_Time) as avg_agent_call_duration_insec 
FROM calls_data
GROUP BY agent_no
ORDER BY avg_agent_call_duration_insec DESC; 

-- 11. agent call handling efficiency
SELECT agent_no, 
       COUNT(*) AS total_calls,
       SUM(Agent_Time) AS total_agent_time,
       SUM(Agent_Time) / COUNT(*) AS avg_time_per_call
FROM calls_data
GROUP BY agent_no
ORDER BY total_calls Desc;
-- , avg_time_per_call DESC

-- 12. Customers waited in the queue
SELECT agent_no, Max(InQueue) as max_queue_time, Avg(InQueue) as avg_queue_time
FROM calls_data
GROUP BY agent_no
ORDER BY max_queue_time DESC, avg_queue_time DESC;

-- 13. Average waiting time in queue
SELECT 
AVG(PreQueue) AS avg_prequeue_time, 
AVG(InQueue) AS avg_inqueue_time
FROM calls_data;

-- 14. Busiest hours for agents/ agent spending avg time per call in particular hour
SELECT HOUR(start_time) AS call_hour, 
       COUNT(*) AS total_calls, 
       COUNT(DISTINCT agent_no) AS total_agents,
       COUNT(*) / COUNT(DISTINCT agent_no) AS avg_calls_per_agent
FROM calls_data
GROUP BY call_hour
ORDER BY avg_calls_per_agent DESC;

-- 15. follow up call rate
SELECT 
COUNT(DISTINCT client_phone) AS unique_customers, 
COUNT(client_phone) AS total_calls, 
ROUND((COUNT(DISTINCT client_phone) / COUNT(client_phone)) * 100, 2) AS fcr_rate
FROM calls_data;

SELECT * FROM calls_data LIMIT 10;

-- 16. Which phone number required follow up and which does not
SELECT 
    client_phone,
    COUNT(*) AS call_count,
    CASE 
        WHEN COUNT(*) = 1 THEN 'Resolved in First Call'
        ELSE 'Follow-Up Required'
    END AS follow_up_status
FROM calls_data
GROUP BY client_phone
ORDER BY call_count Desc;

-- 17. Count for each category of follow up status
With CTE as (
SELECT 
	client_phone,
    count(*) as total_calls,
    CASE 
        WHEN COUNT(*) = 1 THEN 'Resolved in First Call'
        ELSE 'Follow-Up Required'
    END AS follow_up_status
FROM calls_data
GROUP BY client_phone)

SELECT follow_up_status, count(*) as total_counts FROM CTE
GROUP BY follow_up_status;

-- Call Cadence (Frequency of Calls per Agent)
SELECT agent_no, HOUR(start_time) AS call_hour, COUNT(*) AS total_calls
FROM calls_data
GROUP BY agent_no, call_hour
ORDER BY agent_no, call_hour;



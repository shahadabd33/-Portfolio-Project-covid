-- SQL Project - Data Cleaning

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways



-- 1. Remove Duplicates

# First let's check for duplicates






select*,row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,'date',
stage,country,funds_raised_millions) as row_num
from layoffs_stanging; 

with duplcit_cte as
(select*,
row_number() over(
partition by company,location,
industry,total_laid_off, percentage_laid_off,'date',
stage, country , funds_raised_millions) as row_num
from layoffs_stanging 
)

delete
from duplcit_cte
where row_num > 1 ;


CREATE TABLE layoffs_stanging2 (
  company text,
  location text,
  industry text,
  total_laid_off int DEFAULT NULL,
  percentage_laid_off text,
  date text,
  stage text,
  country text,
  funds_raised_millions int DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


insert into layoffs_stanging2
select*,row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,'date',
stage,country,funds_raised_millions) as row_num
from layoffs_stanging; 
select* from
layoffs_stanging2
where row_num > 1;

delete from
layoffs_stanging2
where row_num > 1;

-- 2. Standardize Data

select company,TRIM(company)
from layoffs_stanging2;

update layoffs_stanging2
set company =TRIM(company);
select *
 from  layoffs_stanging2
 where industry like 'Crypto%';
 
 update layoffs_stanging2
 set country = 'United States'
 where  country like   'United States.%';
 
 -- Let's also fix the date columns:
 select date,
 str_to_date( date, '%m/%d/%Y')
 from layoffs_stanging2;
 
 -- we can use str to date to update this field
 update layoffs_stanging2
 set date = str_to_date( date, '%m/%d/%Y');
 
 -- 3. Look at null values and see what 
 select * 
  from  layoffs_stanging2 t1
   join  layoffs_stanging2 t2
   on t1.company = t2.company
   and t1.location = t2.location
  where t1.industry  is null or t1.industry = ' '
   and t2.industry is not null ;
 select* from layoffs_stanging2
 where total_laid_off is null ;
 update layoffs_stanging2
 set industry = null 
 where industry = '';
 
 
 
 select *
 from layoffs_stanging2 
 where industry is null
 or industry = '';
 
 select *
 from layoffs_stanging2
 where company = "Airbnb";
 
 
 
 select t1.industry, t2.industry 
 from layoffs_stanging2 t1
 join layoffs_stanging2 t2
      on t1.company = t2.company
 where (t1.industry is null or t1.industry = '')
 and t2.industry  is not null ;
update  layoffs_stanging2 t1
join layoffs_stanging2 t2
      on t1.company = t2.company
set t1.industry = t2.industry  
where t1.industry is null 
 and t2.industry  is not null ;   
 
 select* from layoffs_stanging2
 where total_laid_off is null 
 and percentage_laid_off is null;
 
 delete from
 layoffs_stanging2
 where total_laid_off is null 
 and percentage_laid_off is null;
 
 select* from layoffs_stanging2;
  
  -- 4. remove any columns and rows that are not necessary - few ways

 alter table layoffs_stanging2
 drop column row_num;
 
 -- extra work with CTE
 select max(total_laid_off),max(percentage_laid_off)
 from layoffs_stanging2;
 
 select year(date), sum(total_laid_off)
 from layoffs_stanging2
 group by year(date)
 order by 1 desc;
 
  SELECT stage, ROUND(AVG(percentage_laid_off),2)
  FROM layoffs_stanging2
GROUP BY stage
ORDER BY 2 DESC;
select substring(date,1,7)  as month ,sum(total_laid_off)
from layoffs_stanging2
where  substring(date,1,7) is not null
group by month
order by 1 asc;
 with rolling_total as 
 (select substring(date,1,7)  as month ,sum(total_laid_off) as total_off
from layoffs_stanging2
where  substring(date,1,7) is not null
group by month
order by 1 asc)
select month,total_off,
 sum(total_off) over(order by month)
from rolling_total;
select company, year(date), sum(total_laid_off)
 from layoffs_stanging2
 group by company, year(date)
 order by 3 desc;

 with company_year(company,years,total_laid_off) as
 (select company, year(date), sum(total_laid_off)
 from layoffs_stanging2
 group by company, year(date)),
company_rank as 
(select*,dense_rank() over(partition by years order by total_laid_off desc) as renking
from company_year
where years is not null)
   select*
   from company_rank
   where renking<= 5;
   
   
   

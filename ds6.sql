/***********************************************************
This procedure is generated by the query 59 template
in TPC-DS. This query is to report the increase of weekly 
store sales from one year to the next year for each store 
and day of the week.
The detail steps for generating the procedure with loops
by transforming CTE query are as follows. CTE table
variable is :year.
Then, for each scalar parameter that is used in the query
template, the loop, which calculates the query iteratively for
every range of parameter, is inserted. For the experiments
using the benchmark procedures, we created three databases
with different sizes: 10 GB, 50 GB, and 100 GB. Then, we
observed the scalability of the proposed algorithm using
these different database sizes. In addition, we show that the
performance of the algorithm varies according to the table
statistics, even for the same procedure.
***********************************************************/

set schema "TPC10";
ALTER SYSTEM CLEAR SQL PLAN CACHE;
drop procedure "TPC10_Q59";
call "TPC10_Q59"(1176);

create procedure "TPC10_Q59"(in _yearInfo integer)
as begin
declare _year integer;
_year := :_yearInfo;

wss = select d_week_seq, ss_store_sk,
      sum(case when (d_day_name='Sunday') then ss_sales_price else null end) sun_sales,
      sum(case when (d_day_name='Monday') then ss_sales_price else null end) mon_sales,
      sum(case when (d_day_name='Tuesday') then ss_sales_price else  null end) tue_sales,
      sum(case when (d_day_name='Wednesday') then ss_sales_price else null end) wed_sales,
      sum(case when (d_day_name='Thursday') then ss_sales_price else null end) thu_sales,
      sum(case when (d_day_name='Friday') then ss_sales_price else null end) fri_sales,
      sum(case when (d_day_name='Saturday') then ss_sales_price else null end) sat_sales
	  from store_sales, date_dim
	  where d_date_sk = ss_sold_date_sk
	  group by d_week_seq,ss_store_sk with hint(no_inline);
 
while (:_year < 1209) DO

v0 = (select s_store_name s_store_name1,wss.d_week_seq d_week_seq1
        ,s_store_id s_store_id1,sun_sales sun_sales1
        ,mon_sales mon_sales1,tue_sales tue_sales1
        ,wed_sales wed_sales1,thu_sales thu_sales1
        ,fri_sales fri_sales1,sat_sales sat_sales1
  		from :wss wss,store,date_dim d
		where d.d_week_seq = wss.d_week_seq and
        ss_store_sk = s_store_sk and 
        d_month_seq between :_year and :_year + 11);
        
v1 = (select s_store_name s_store_name2,wss.d_week_seq d_week_seq2
      ,s_store_id s_store_id2,sun_sales sun_sales2
      ,mon_sales mon_sales2,tue_sales tue_sales2
      ,wed_sales wed_sales2,thu_sales thu_sales2
      ,fri_sales fri_sales2,sat_sales sat_sales2
	  from :wss wss,store,date_dim d
  	  where d.d_week_seq = wss.d_week_seq and
        ss_store_sk = s_store_sk and 
        d_month_seq between :_year+ 12 and :_year + 23);

 select top 100 s_store_name1,s_store_id1,d_week_seq1
       ,sun_sales1/sun_sales2,mon_sales1/mon_sales2
       ,tue_sales1/tue_sales2,wed_sales1/wed_sales2,thu_sales1/thu_sales2
       ,fri_sales1/fri_sales2,sat_sales1/sat_sales2 from (select * from :v0), (select * from :v1)
 	where s_store_id1=s_store_id2
   	and d_week_seq1=d_week_seq2-52
 	order by s_store_name1,s_store_id1,d_week_seq1;
 _year = :_year + 11;
end while;
end;





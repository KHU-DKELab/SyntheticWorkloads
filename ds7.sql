/***********************************************************
This procedure is generated by the query 74 template
in TPC-DS. This query is to display customers with both 
store and web sales in consecutive years for whom the 
increase in web sales exceeds the increase in store sales 
for a specified year. The sclar parameter is _year.


The detail steps for generating the procedure with loops
by transforming CTE query are as follows. Each CTE table
variable is transformed to the SQL assignment statement.
Then, each query with table variables is decomposed.
Finally, for each scalar parameter that is used in the query
template, the loop, which calculates the query iteratively for
every range of parameter, is inserted. 
***********************************************************/

create procedure "TPC10_Q74" (in yearInfo integer)
as begin

declare _year integer;
_year := :yearInfo;

vv1 = select c_customer_id, c_first_name, c_last_name, c_customer_sk from customer;
vv2 = select ss_net_paid, ss_sold_date_sk, ss_customer_sk from store_sales;
vv3 = select d_date_sk, d_year from date_dim ;
vv4 = select ws_net_paid, ws_bill_customer_sk, ws_sold_date_sk from web_sales;
ww1 = select c_customer_id, c_first_name, c_last_name, c_customer_sk, ss_sold_date_sk, ss_net_paid from :vv1, :vv2 
where c_customer_sk = ss_customer_sk ;
ww2 = select c_customer_id,c_first_name, c_last_name, ws_net_paid, ws_sold_date_sk from :vv1, :vv4 
where c_customer_sk = ws_bill_customer_sk ;


while (_year < 2002) DO
v0 =  select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,d_year as year
       ,min(ss_net_paid) year_total
       ,'s' sale_type
	   from :ww1, :vv3
	   where ss_sold_date_sk = d_date_sk
	   and d_year in (:_year,:_year+1)
	   group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,d_year;
    
v1 =  select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,d_year as year
       ,min(ws_net_paid) year_total
       ,'w' sale_type
	  from :ww2 ,:vv3
	  where ws_sold_date_sk = d_date_sk
	  and d_year in (:_year,:_year+1)
	  group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,d_year;
year_total = select * from :v0 union all select * from :v1;

select top 100 t_s_secyear.customer_id, t_s_secyear.customer_first_name, t_s_secyear.customer_last_name
 from :year_total t_s_firstyear
     ,:year_total t_s_secyear
     ,:year_total t_w_firstyear
     ,:year_total t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
         and t_s_firstyear.customer_id = t_w_secyear.customer_id
         and t_s_firstyear.customer_id = t_w_firstyear.customer_id
         and t_s_firstyear.sale_type = 's'
         and t_w_firstyear.sale_type = 'w'
         and t_s_secyear.sale_type = 's'
         and t_w_secyear.sale_type = 'w'
         and t_s_firstyear.year = :_year
         and t_s_secyear.year = :_year+1
         and t_w_firstyear.year = :_year
         and t_w_secyear.year = :_year+1
         and t_s_firstyear.year_total > 0
         and t_w_firstyear.year_total > 0
         and case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else null end
           > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else null end
 order by 1,2,3;
 
_year = :_year + 1;
end while;
end;


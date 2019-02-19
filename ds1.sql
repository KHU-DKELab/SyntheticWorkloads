/***********************************************************
This procedure is generated by the query 4 template
in TPC-DS. This query is to find customers who spend more
money via catalog than in stores and to identify preferred
customers and their country of origin.
The detail steps for generating the procedure with loops
by transforming CTE query are as follows. CTE table 
variable is _year.
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

drop procedure "TPC10_Q4";
ALTER SYSTEM CLEAR SQL PLAN CACHE;
call "TPC10_Q4"(1998);
create procedure "TPC10_Q4" (in year_Info integer)
AS BEGIN
declare _year integer;
_year := :year_Info;

vv1 = select c_customer_id, c_first_name, c_last_name, c_preferred_cust_flag, c_birth_country, c_login, c_email_address, c_customer_sk from customer;
vv2 = select d_year, d_date_sk from date_dim;
vv3 = select ss_ext_list_price, ss_ext_wholesale_cost, ss_ext_discount_amt, ss_ext_sales_price, ss_sold_date_sk, ss_customer_sk from store_sales;
vv4 = select cs_ext_list_price,cs_ext_wholesale_cost,cs_ext_discount_amt,cs_ext_sales_price,cs_sold_date_sk,cs_bill_customer_sk from catalog_sales;

v1 = select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(((ss_ext_list_price-ss_ext_wholesale_cost-ss_ext_discount_amt)+ss_ext_sales_price)/2) year_total
       ,'s' sale_type
       from :vv1, :vv2, :vv3 
		 where c_customer_sk = ss_customer_sk
   and ss_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year;

v2 =  select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum((((cs_ext_list_price-cs_ext_wholesale_cost-cs_ext_discount_amt)+cs_ext_sales_price)/2) ) year_total
       ,'c' sale_type
 from :vv1
     ,:vv4
     ,:vv2
 where c_customer_sk = cs_bill_customer_sk
   and cs_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year;

vv5 = select ws_sold_date_sk, ws_ext_list_price, ws_ext_wholesale_cost, ws_ext_discount_amt, ws_ext_sales_price, ws_bill_customer_sk from web_sales;
   
v3 =  select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum((((ws_ext_list_price-ws_ext_wholesale_cost-ws_ext_discount_amt)+ws_ext_sales_price)/2) ) year_total
       ,'w' sale_type
 from :vv1
     , :vv5
     , :vv2
 where c_customer_sk = ws_bill_customer_sk
   and ws_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year;
           
year_total = select * from :v1 union all	select * from :v2 union all	select * from :v3 ;

v4 = select t_s_secyear.customer_id
                 ,t_s_secyear.customer_first_name
                 ,t_s_secyear.customer_last_name
                 ,t_s_secyear.customer_preferred_cust_flag
                 ,t_s_firstyear.dyear dsf
                 ,t_s_secyear.dyear dss
                 ,t_c_firstyear.dyear dcf
                 ,t_c_secyear.dyear dcs
                 ,t_w_firstyear.dyear dwf
                 ,t_w_secyear.dyear dws
 from :year_total t_s_firstyear
     ,:year_total t_s_secyear
     ,:year_total t_c_firstyear
     ,:year_total t_c_secyear
     ,:year_total t_w_firstyear
     ,:year_total t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
   and t_s_firstyear.customer_id = t_c_secyear.customer_id
   and t_s_firstyear.customer_id = t_c_firstyear.customer_id
   and t_s_firstyear.customer_id = t_w_firstyear.customer_id
   and t_s_firstyear.customer_id = t_w_secyear.customer_id
   and t_s_firstyear.sale_type = 's'
   and t_c_firstyear.sale_type = 'c'
   and t_w_firstyear.sale_type = 'w'
   and t_s_secyear.sale_type = 's'
   and t_c_secyear.sale_type = 'c'
   and t_w_secyear.sale_type = 'w'
   and t_s_firstyear.year_total > 0
   and t_c_firstyear.year_total > 0
   and t_w_firstyear.year_total > 0
   and case when t_c_firstyear.year_total > 0 then t_c_secyear.year_total / t_c_firstyear.year_total else null end
           > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else null end
   and case when t_c_firstyear.year_total > 0 then t_c_secyear.year_total / t_c_firstyear.year_total else null end
           > case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else null end
 order by t_s_secyear.customer_id
         ,t_s_secyear.customer_first_name
         ,t_s_secyear.customer_last_name
         ,t_s_secyear.customer_preferred_cust_flag;
     	
WHILE (:_year < 2002) DO
   select top 100 customer_id, :_year from :v4 where 
   dsf =  :_year
   and dss  = :_year +1
   and dcf = :_year
   and dcs = :_year + 1
   and dwf = :_year
   and dws = :_year + 1;
   _year = :_year + 1;
end while;
end;
 

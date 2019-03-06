/***********************************************************
This procedure is generated by the query 11 template
in TPC-DS. This query is to find customers whose increase
in spending was large over the web than in stores this year
compared to last year. The scalar parameter is _year.

The detail steps for generating the procedure with loops
by transforming CTE query are as follows. Each CTE table
variable is transformed to the SQL assignment statement.
Then, each query with table variables is decomposed.
Finally, for each scalar parameter that is used in the query
template, the loop, which calculates the query iteratively for
every range of parameter, is inserted. 
***********************************************************/


create procedure "TPC10_Q11" (in YearInfo integer)
as begin
declare _year integer;
_year := :YearInfo;

vv1 = select c_customer_id, c_first_name, c_last_name, c_preferred_cust_flag, c_birth_country, c_login, c_email_address, c_customer_sk from customer;
vv2 = select d_date_sk, d_year from date_dim;
vv3 = select ss_ext_list_price, ss_ext_discount_amt, ss_sold_date_sk, ss_customer_sk from store_sales;
vv4 = select ws_ext_list_price, ws_ext_discount_amt, ws_sold_date_sk, ws_bill_customer_sk from web_sales;

v1 = select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(ss_ext_list_price-ss_ext_discount_amt) year_total
       ,'s' sale_type
 from :vv1
     ,:vv3
     ,:vv2
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
       ,sum(ws_ext_list_price-ws_ext_discount_amt) year_total
       ,'w' sale_type
 from :vv1
     ,:vv4
     ,:vv2
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

year_total = select * from :v1 union all select * from :v2 ;

v3 = select t_s_secyear.customer_id
             ,t_s_secyear.customer_first_name
             ,t_s_secyear.customer_last_name
             ,t_s_secyear.customer_email_address
             ,t_s_firstyear.dyear dsf
             ,t_s_secyear.dyear dss
             ,t_w_firstyear.dyear dwf
             ,t_w_secyear.dyear dws
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
	         and t_s_firstyear.year_total > 0
	         and t_w_firstyear.year_total > 0
	         and case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else 0.0 end
	             > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else 0.0 end
	 order by t_s_secyear.customer_id
	         ,t_s_secyear.customer_first_name
	         ,t_s_secyear.customer_last_name
	         ,t_s_secyear.customer_email_address;
	
WHILE (:_year < 2002) DO
	select top 100 * from :v3 where 
	dsf = :_year
    and dss = :_year+1
    and dwf = :_year
    and dws = :_year+1;
	_year = :_year + 1;
end while;
end;






# Synthetic procedures based on TPC-DS queries
To show the scalability and efficiency of procedure optimization, we generated synthetic procedures by extending the queries in the TPC-DS benchmark.

We chose 34 CTE queries represented by multiple statements among the TPC-DS benchmark queries since the procedure is designed by multiple statements. Because 24 out of 34 queries have less than 0.3 seconds of execution time, even if they are generated as a procedure, the maximum benefit of the query motion is less than 10%. Therefore, we only used the remaining 10 CTE queries (their ids : 4, 11, 23\_1, 23\_2, 51, 59, 74, 75, 78, and 97) from TPC-DS benchmark. We denote these ten procedures as ds1, ds2,..., ds10.

The detail explanation is described as top in each file.

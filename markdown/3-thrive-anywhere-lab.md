



   ```bash
   cockroach sql --certs-dir=certs --host=localhost:30200  
   ```  

   cockroach sql --certs-dir=certs --host=localhost:30200


export region_1="eu-west-1"  
export region_2="us-east-1"  
export region_3="eu-north-1" 


Adding regions (primary and secondary)

```sql
ALTER DATABASE roach_bank PRIMARY REGION "eu-west-1";
ALTER DATABASE roach_bank ADD REGION "us-east-1";
ALTER DATABASE roach_bank ADD REGION "eu-north-1";
```


Table localities (global and regional-by-row)

```sql
USE roach_bank;
SHOW TABLES;
```





Survival goal (from zone to region)
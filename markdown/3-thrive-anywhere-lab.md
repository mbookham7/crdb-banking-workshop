



   ```bash
   cockroach node status --ranges --certs-dir=certs --host=localhost:30200  
   ```  

   cockroach sql --certs-dir=certs --host=localhost:30200


export region_1="eu-west-1"  
export region_2="us-east-1"  
export region_3="eu-north-1" 

ALTER DATABASE roach_bank PRIMARY REGION "eu-west-1";
ALTER DATABASE roach_bank ADD REGION "us-east-1";
ALTER DATABASE roach_bank ADD REGION "eu-north-1";
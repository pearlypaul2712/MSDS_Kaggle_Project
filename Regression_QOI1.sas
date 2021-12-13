proc print data=WORK.IMPORT;
run;


proc glm data= WORK.IMPORT plots=all;

model SalePrice=  GrLivArea/solution clm;
run;

data WORK.IMPORT ;
set WORK.IMPORT ;
if ID='1299' then delete;
if ID='524' then delete;
if ID='643' then delete;
run;

proc glm data= WORK.IMPORT plots=all;
class Neighborhood;
model SalePrice=  GrLivArea | Neighborhood/solution clm;
run;

data WORK.IMPORT;
set WORK.IMPORT;
lSalePrice=log(SalePrice);
lGrLivArea=log(GrLivArea);
run;



proc glm data= WORK.IMPORT plots=all;
class Neighborhood;
model lSalePrice=  GrLivArea | Neighborhood/solution clm;
run;

exp()
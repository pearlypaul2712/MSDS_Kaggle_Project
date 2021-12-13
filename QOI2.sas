/**Remove  X1stFlrSF  X3SsnPorch  X1stFlrSF    	 X2ndFlrSF LotFrontage  as its not found*/
/*** Code **/
/** Id           	 MSSubClass   	 LotFrontage  	 LotArea      	
 OverallQual  	 OverallCond  	 YearBuilt    	 YearRemodAdd 	 
 MasVnrArea   	 BsmtFinSF1   	 BsmtFinSF2   	 BsmtUnfSF    	 
 TotalBsmtSF  	 X1stFlrSF    	 X2ndFlrSF    	 LowQualFinSF 	 GrLivArea    	 
 BsmtFullBath 	 BsmtHalfBath 	 FullBath     	 HalfBath     	 BedroomAbvGr 	 
 KitchenAbvGr 	 TotRmsAbvGrd 	 Fireplaces   	 GarageYrBlt  	 GarageCars   	 
 GarageArea   	 WoodDeckSF   	 OpenPorchSF  	 EnclosedPorch	 X3SsnPorch   	 
 ScreenPorch  	 PoolArea     	 MiscVal      	 MoSold       	 YrSold       	 SalePrice  */ 

/**GarageCars,  GarageArea,  WoodDeckSF,  OpenPorchSF LotArea  OverallQual,  OverallCond, 
 YearBuilt,  YearRemodAdd,  GrLivArea,  FullBath,  TotRmsAbvGrd, Fireplaces  MasVnrArea**/  

/*  1:  Variable  selection  with  scatter  plots  */
/* Linear Relationship with OverallQual SalePrice GarageCars  GarageArea  WoodDeckSF*/
/* Non Linear Relationship with SalePrice  MSSubClass  LotArea */


/**GarageCars, YearRemodAdd ,  GarageArea,  WoodDeckSF, EnclosedPorch	,  OpenPorchSF LotArea  OverallQual,  
OverallCond,  YearBuilt,  YearRemodAdd,  GrLivArea,  FullBath,  TotRmsAbvGrd, Fireplaces MasVnrArea 
 BsmtUnfSF  **/ 

PROC  sgscatter  DATA=WORK.IMPORT1;
 matrix SalePrice
MSSubClass   	  	 LotArea      	OverallQual  	 OverallCond  	 YearBuilt    	 YearRemodAdd 	;
run; 
PROC  sgscatter  DATA=WORK.IMPORT1;
 matrix SalePrice
 MasVnrArea   	 BsmtFinSF1   	 BsmtFinSF2   	 BsmtUnfSF    	 TotalBsmtSF  	  LowQualFinSF 	 GrLivArea  ;  	 
 run; 
 
 PROC  sgscatter  DATA=WORK.IMPORT1;
 matrix SalePrice
 BsmtFullBath 	 BsmtHalfBath 	 FullBath     	 HalfBath     	 BedroomAbvGr 	 KitchenAbvGr 	 TotRmsAbvGrd 	 Fireplaces   	 GarageYrBlt  	 GarageCars  ; 	 
 run;
  PROC  sgscatter  DATA=WORK.IMPORT1;
 matrix SalePrice
 GarageArea   	 WoodDeckSF   	 OpenPorchSF  	 EnclosedPorch	 	 ScreenPorch  	 PoolArea     	 MiscVal      	 MoSold       	 YrSold  ;
 run;
 
 
 
proc print data=WORK.IMPORT;
run;

proc print data=WORK.IMPORT1;
run;

data WORK.IMPORT1;
set WORK.IMPORT1;
SalePrice=.;
run;

data train2;
set WORK.IMPORT WORK.IMPORT1;
run;
/** Deleting the Outliers*/
data train2;
set train2;
if ID='1299' then delete;
if ID='524' then delete;
if ID='643' then delete;
run;

data  train2; 
set train2;  
logPrice  =  log(SalePrice); 
run;
data train2;
set train2;
/* for these, replace with mean */
if LotFrontage = ' ' then LotFrontage  = 70;
if MasVnrArea  = ' ' then MasVnrArea   = 104;
if GarageYrBlt = ' ' then GarageYrBlt  = 1978;
/* for these, replace with 0 */
if BsmtFinSF1  = ' ' then BsmtFinSF1   = 0;
if BsmtFinSF2  = ' ' then  BsmtFinSF2 = 0;
if BsmtFinSF   = ' ' then BsmtFinSF = 0;
if TotalBsmtSF = ' ' then TotalBsmtSF = 0;
if BsmtFullBath  = ' ' then BsmtFullBath = 0;
if BsmtHalfBath  = ' ' then BsmtHalfBath = 0;
if GarageCars   = ' ' then GarageCars = 0;
/* sane values */
if GarageCars   = 0 then GarageArea = 0;
if MSZoning	= ' ' then MSZoning = 'RL';
run;

/**rEMOVED LotFrontage X1stFlrSF    	 X2ndFlrSF X3SsnPorch**/
proc  reg  data=train2;
model  logPrice  = MSSubClass   	  	 LotArea      	
 OverallQual  	 OverallCond  	 YearBuilt    	 YearRemodAdd 	 
 MasVnrArea   	 BsmtFinSF1   	 BsmtFinSF2   	 BsmtUnfSF    	 
 TotalBsmtSF  	    	 LowQualFinSF 	 GrLivArea    	 
 BsmtFullBath 	 BsmtHalfBath 	 FullBath     	 HalfBath     	 BedroomAbvGr 	 
 KitchenAbvGr 	 TotRmsAbvGrd 	 Fireplaces   	 GarageYrBlt  	 GarageCars   	 
 GarageArea   	 WoodDeckSF   	 OpenPorchSF  	 EnclosedPorch	    	 
 ScreenPorch  	 PoolArea     	 MiscVal      	 MoSold       	 YrSold   
  /  selection=forward  slentry=0.1 slstay=0.1  adjrsq VIF; 
run; 


proc glmselect data=train2;
class  Neighborhood_num_cat 
model logPrice  =  GarageCars
OverallCond YearRemodAdd
YearBuilt
BsmtUnfSF
OpenPorchSF
GarageArea
TotRmsAbvGrd
LotArea
WoodDeckSF
GrLivArea
EnclosedPorch
FullBath
Fireplaces
MasVnrArea
OverallQual | Neighborhood_num_cat /selection=stepwise(stop=cv) cvmethod=random(5) stats=adjrsq;
 output out= results p= predict; 
 run;



proc  glmselect  data=train2; 
model  logPrice  =  GarageCars
OverallCond YearRemodAdd YearBuilt
BsmtUnfSF OpenPorchSF GarageArea
TotRmsAbvGrd LotArea WoodDeckSF GrLivArea
EnclosedPorch FullBath
Fireplaces MasVnrArea OverallQual
 /  selection=forward(stop=cv) cvmethod=random(5) stats=adjrsq slentry=0.1 slstay=0.1 ; 
 output out=forward_result p=Predict3;
 run; 
/**GarageCars removing */
 /**Removing RoofMatl_num_cat Exterior1st_num_cat**/
 proc  glmselect data=train2; 
 class
MSZoning_num_cat
Street_num_cat
Alley_num_cat
LotShape_num_cat
LandContour_num_cat
Utilities_num_cat
LotConfig_num_cat
LandSlope_num_cat
Neighborhood_num_cat
Condition1_num_cat
Condition2_num_cat
BldgType_num_cat
HouseStyle_num_cat
RoofStyle_num_cat
Exterior2nd_num_cat
MasVnrType_num_cat
ExterQual_num_cat
ExterCond_num_cat
Foundation_num_cat
BsmtQual_num_cat
BsmtCond_num_cat
BsmtExposure_num_cat
BsmtFinType1_num_cat
BsmtFinType2_num_cat
Heating_num_cat
HeatingQC_num_cat
CentralAir_num_cat
Electrical_num_cat
KitchenQual_num_cat
Functional_num_cat
FireplaceQu_num_cat
GarageType_num_cat
GarageFinish_num_cat
PavedDrive_num_cat
MiscFeature_num_cat
SaleType_num_cat
SaleCondition_num_cat;
model  logPrice  =  
OverallCond
YearRemodAdd
YearBuilt
BsmtUnfSF
OpenPorchSF
GarageArea
TotRmsAbvGrd
LotArea
WoodDeckSF
GrLivArea
EnclosedPorch
FullBath
Fireplaces
MasVnrArea
OverallQual 
MSZoning_num_cat
Street_num_cat
Alley_num_cat
LotShape_num_cat
LandContour_num_cat
Utilities_num_cat
LotConfig_num_cat
LandSlope_num_cat
Neighborhood_num_cat
Condition1_num_cat
Condition2_num_cat
BldgType_num_cat
HouseStyle_num_cat
RoofStyle_num_cat
RoofMatl_num_cat
Exterior2nd_num_cat
MasVnrType_num_cat
ExterQual_num_cat
ExterCond_num_cat
Foundation_num_cat
BsmtQual_num_cat
BsmtCond_num_cat
BsmtExposure_num_cat
BsmtFinType1_num_cat
BsmtFinType2_num_cat
Heating_num_cat
HeatingQC_num_cat
CentralAir_num_cat
Electrical_num_cat
KitchenQual_num_cat
Functional_num_cat
FireplaceQu_num_cat
GarageType_num_cat
GarageFinish_num_cat
PavedDrive_num_cat
MiscFeature_num_cat
SaleType_num_cat
SaleCondition_num_cat/  selection=stepwise(stop=cv)  slentry=0.1 slstay=0.1 ; 
output out=backward_result p=Predict4;
run; 


proc  glmselect data=train2; 
class
MSZoning_num_cat
Street_num_cat
Alley_num_cat
LotShape_num_cat
LandContour_num_cat
Utilities_num_cat
LotConfig_num_cat
LandSlope_num_cat
Neighborhood_num_cat
Condition1_num_cat
Condition2_num_cat
BldgType_num_cat
HouseStyle_num_cat
RoofStyle_num_cat
Exterior2nd_num_cat
MasVnrType_num_cat
ExterQual_num_cat
ExterCond_num_cat
Foundation_num_cat
BsmtQual_num_cat
BsmtCond_num_cat
BsmtExposure_num_cat
BsmtFinType1_num_cat
BsmtFinType2_num_cat
Heating_num_cat
HeatingQC_num_cat
CentralAir_num_cat
Electrical_num_cat
KitchenQual_num_cat
Functional_num_cat
FireplaceQu_num_cat
GarageType_num_cat
GarageFinish_num_cat
PavedDrive_num_cat
MiscFeature_num_cat
SaleType_num_cat
SaleCondition_num_cat;
model  logPrice  =  
OverallCond
YearRemodAdd
YearBuilt
BsmtUnfSF
OpenPorchSF
GarageArea
TotRmsAbvGrd
LotArea
WoodDeckSF
GrLivArea
EnclosedPorch
FullBath
Fireplaces
MasVnrArea
OverallQual 
MSZoning_num_cat
Street_num_cat
Alley_num_cat
LotShape_num_cat
LandContour_num_cat
Utilities_num_cat
LotConfig_num_cat
LandSlope_num_cat
Neighborhood_num_cat
Condition1_num_cat
Condition2_num_cat
BldgType_num_cat
HouseStyle_num_cat
RoofStyle_num_cat
RoofMatl_num_cat
Exterior2nd_num_cat
MasVnrType_num_cat
ExterQual_num_cat
ExterCond_num_cat
Foundation_num_cat
BsmtQual_num_cat
BsmtCond_num_cat
BsmtExposure_num_cat
BsmtFinType1_num_cat
BsmtFinType2_num_cat
Heating_num_cat
HeatingQC_num_cat
CentralAir_num_cat
Electrical_num_cat
KitchenQual_num_cat
Functional_num_cat
FireplaceQu_num_cat
GarageType_num_cat
GarageFinish_num_cat
PavedDrive_num_cat
MiscFeature_num_cat
SaleType_num_cat
SaleCondition_num_cat/selection=stepwise(stop=cv)  slentry=0.1 slstay=0.1 ; 
output out=stepwise_result p=Predict5;
run; 
 
 proc  reg  data=train2;
model  logPrice  =  
OverallCond
YearRemodAdd
YearBuilt
BsmtUnfSF
OpenPorchSF
GarageArea
TotRmsAbvGrd
LotArea
WoodDeckSF
GrLivArea
EnclosedPorch
FullBath
Fireplaces
MasVnrArea
OverallQual /selection=stepwise(stop=cv)  slentry=0.1 slstay=0.1 ; 
output out=stepwise_result p=Predict5;
 run;
 
 data forward_result;
set forward_result;
if Predict2>0 then SalePrice=exp(Predict2);
if Predict2<0 then SalePrice=10000;
keep id SalePrice;
where id>1460;

data backward_result;
set backward_result;
if Predict3>0 then SalePrice=exp(Predict3);
if Predict3<0 then SalePrice=10000;
keep id SalePrice;
where id>1460;

 data stepwise_result;
set stepwise_result;
if Predict5>0 then SalePrice=exp(Predict5);
if Predict5<0 then SalePrice=10000;
keep id SalePrice;
where id>1460;

proc export 
  data=forward_result
  dbms=csv
  outfile="/home/u58342833/sasuser.v94/Exam/submission_forward_result.csv" 
  replace;
run;
proc export 
  data=backward_result
  dbms=csv
  outfile="/home/u58342833/sasuser.v94/Exam/submission_backward_result.csv" 
  replace;
run;
proc export 
  data=stepwise_result
  dbms=csv
  outfile="/home/u58342833/sasuser.v94/Exam/submission_stepwise_result.csv" 
  replace;
run;
run; 


title "Transform Data for Regression";

data train2;
	set train2;

		if 		MSZoning="C"  	then MSZoning_num_cat = 0;
		else if MSZoning="FV"  	then MSZoning_num_cat = 1;
		else if MSZoning="RH"  	then MSZoning_num_cat = 2;
		else if MSZoning="RL"  	then MSZoning_num_cat = 3;
		else MSZoning_num_cat = 4;

		if LotFrontage="NA"		then LotFrontage_num_cat = 0;
		else LotFrontage_num_cat = LotFrontage;

		if Street = "Pave"			then Street_num_cat = 0;
		else Street_num_cat = 1;

		if Alley = "Pa"			then Alley_num_cat = 1;
		else if Alley = "Gr"		then Alley_num_cat = 2;
		else Alley_num_cat = 0;

		if LotShape="IR1" then LotShape_num_cat  = 3;
		else if LotShape = "IR2" then LotShape_num_cat = 2;
		else if LotShape = "IR3" then LotShape_num_cat = 1;
		else LotShape_num_cat = 0;

		if LandContour = "Bnk" 			then LandContour_num_cat = 0;
		else if LandContour = "HLS" 	then LandContour_num_cat = 1;
		else if LandContour = "Low" 	then LandContour_num_cat = 2;
		else  LandContour_num_cat = 3;

		if Utilities = "AllPub"			then Utilities_num_cat = 1;
		else Utilities_num_cat = 0;

		if LotConfig = "Corner" 		then LotConfig_num_cat = 0;
		else if LotConfig = "CulDSac" 	then LotConfig_num_cat = 1;
		else if LotConfig = "FR2"		then LotConfig_num_cat = 2;
		else if LotConfig = "FR3" 		then LotConfig_num_cat = 3;
		else  LotConfig_num_cat = 4;

		if LandSlope= "Gtl" 	 then LandSlope_num_cat = 0;
		else if LandSlope= "Mod" then LandSlope_num_cat = 1;
		else LandSlope_num_cat = 2;

		if Neighborhood = "Blmngtn" 		then Neighborhood_num_cat = 1;
		else if Neighborhood = "Blueste" 	then Neighborhood_num_cat = 2;
		else if Neighborhood = "BrDale" 	then Neighborhood_num_cat = 3;
		else if Neighborhood = "BrkSide" 	then Neighborhood_num_cat = 4;
		else if Neighborhood = "ClearCr" 	then Neighborhood_num_cat = 5;
		else if Neighborhood = "CollgCr" 	then Neighborhood_num_cat = 6;
		else if Neighborhood = "Crawfor" 	then Neighborhood_num_cat = 7;
		else if Neighborhood = "Edwards" 	then Neighborhood_num_cat = 8;
		else if Neighborhood = "Gilbert" 	then Neighborhood_num_cat = 9;
		else if Neighborhood = "IDOTRR" 	then Neighborhood_num_cat = 10;
		else if Neighborhood = "MeadowV" 	then Neighborhood_num_cat = 11;
		else if Neighborhood = "Mitchel" 	then Neighborhood_num_cat = 12;
		else if Neighborhood = "NAmes" 		then Neighborhood_num_cat = 13;
		else if Neighborhood = "NoRidge" 	then Neighborhood_num_cat = 14;
		else if Neighborhood = "NPkVill" 	then Neighborhood_num_cat = 15;
		else if Neighborhood = "NPkVill" 	then Neighborhood_num_cat = 16;
		else if Neighborhood = "NWAmes"		then Neighborhood_num_cat = 17;
		else if Neighborhood = "OldTown" 	then Neighborhood_num_cat = 18;
		else if Neighborhood = "Sawyer" 	then Neighborhood_num_cat = 19;
		else if Neighborhood = "SawyerW" 	then Neighborhood_num_cat = 20;
		else if Neighborhood = "Somerst" 	then Neighborhood_num_cat = 21;
		else if Neighborhood = "StoneBr" 	then Neighborhood_num_cat = 22;
		else if Neighborhood = "SWISU" 		then Neighborhood_num_cat = 23;
		else if Neighborhood = "Timber" 	then Neighborhood_num_cat = 25;
		else  	Neighborhood_num_cat = 0;

		if Condition1="Norm" 		then Condition1_num_cat = 0;
		else if Condition1="Artery" then Condition1_num_cat = 1;
		else if Condition1="Feedr" 	then Condition1_num_cat = 2;
		else if Condition1="PosA" 	then Condition1_num_cat = 3;
		else if Condition1="PosN" 	then Condition1_num_cat = 4;
		else if Condition1="RRAe" 	then Condition1_num_cat = 5;
		else if Condition1="RRAn" 	then Condition1_num_cat = 6;
		else if Condition1="RRNe" 	then Condition1_num_cat = 7;
		else 	Condition1_num_cat = 8;

		if Condition2="Norm" 		then Condition2_num_cat = 0;
		else if Condition2="Artery" then Condition2_num_cat = 1;
		else if Condition2="Feedr" 	then Condition2_num_cat = 2;
		else if Condition2="PosA" 	then Condition2_num_cat = 3;
		else if Condition2="PosN" 	then Condition2_num_cat = 4;
		else if Condition2="RRAe" 	then Condition2_num_cat = 5;
		else if Condition2="RRAn" 	then Condition2_num_cat = 6;
		else if Condition2="RRNe" 	then Condition2_num_cat = 7;
		else 	Condition2_num_cat = 8;

		if BldgType="1Fam" 			then BldgType_num_cat = 0;
		else if BldgType="2fmCon" 	then BldgType_num_cat = 1;
		else if BldgType="Duplex" 	then BldgType_num_cat = 2;
		else if BldgType="Twnhs" 	then BldgType_num_cat = 3;
		else  BldgType_num_cat = 4;

		if HouseStyle="1.5Fin" 		then HouseStyle_num_cat = 0;
		else if HouseStyle="1.5Unf" then HouseStyle_num_cat = 1;
		else if HouseStyle="1Story" then HouseStyle_num_cat = 2;
		else if HouseStyle="2.5Fin" then HouseStyle_num_cat = 3;
		else if HouseStyle="2.5Unf" then HouseStyle_num_cat = 4;
		else if HouseStyle="2Story" then HouseStyle_num_cat = 5;
		else if HouseStyle="SFoyer" then HouseStyle_num_cat = 6;
		else  HouseStyle_num_cat = 7;

		if RoofStyle="Flat" 		then RoofStyle_num_cat = 0;
		else if RoofStyle="Gable" 	then RoofStyle_num_cat = 1;
		else if RoofStyle="Gambrel" then RoofStyle_num_cat = 2;
		else if RoofStyle="Hip" 	then RoofStyle_num_cat = 3;
		else if RoofStyle="Mansard" then RoofStyle_num_cat = 4;
		else RoofStyle_num_cat = 5;

		if RoofMatl="CompShg" 		then RoofMatl_num_cat = 1;
		else if RoofMatl="Metal" 	then RoofMatl_num_cat = 2;
		else if RoofMatl="WdShngl" 	then RoofMatl_num_cat = 3;
		else if RoofMatl="WdShake" 	then RoofMatl_num_cat = 4;
		else if RoofMatl="ClyTile" 	then RoofMatl_num_cat = 5;
		else if RoofMatl="Roll" 	then RoofMatl_num_cat = 6;
		else if RoofMatl="Membran" 	then RoofMatl_num_cat = 7;
		else  RoofMatl_num_cat = 0;

		if Exterior1st="AsbShng" 		then Exterior1st_num_cat = 1;
		else if Exterior1st="AsphShn" 	then Exterior1st_num_cat = 2;
		else if Exterior1st="BrkComm" 	then Exterior1st_num_cat = 3;
		else if Exterior1st="BrkFace" 	then Exterior1st_num_cat = 4;
		else if Exterior1st="CBlock" 	then Exterior1st_num_cat = 5;
		else if Exterior1st="CemntBd" 	then Exterior1st_num_cat = 6;
		else if Exterior1st="HdBoard" 	then Exterior1st_num_cat = 7;
		else if Exterior1st="ImStucc" 	then Exterior1st_num_cat = 8;
		else if Exterior1st="MetalSd" 	then Exterior1st_num_cat = 9;
		else if Exterior1st="Plywood" 	then Exterior1st_num_cat = 10;
		else if Exterior1st="Stone" 	then Exterior1st_num_cat = 11;
		else if Exterior1st="Stucco" 	then Exterior1st_num_cat = 12;
		else if Exterior1st="VinylSd" 	then Exterior1st_num_cat = 13;
		else if Exterior1st="Wd Sdng" 	then Exterior1st_num_cat = 14;
		else Exterior1st_num_cat = 0;

		if Exterior2nd="AsbShng" 		then Exterior2nd_num_cat = 1;
		else if Exterior2nd="AsphShn" 	then Exterior2nd_num_cat = 2;
		else if Exterior2nd="BrkComm" 	then Exterior2nd_num_cat = 3;
		else if Exterior2nd="BrkFace" 	then Exterior2nd_num_cat = 4;
		else if Exterior2nd="CBlock" 	then Exterior2nd_num_cat = 5;
		else if Exterior2nd="CemntBd" 	then Exterior2nd_num_cat = 6;
		else if Exterior2nd="HdBoard" 	then Exterior2nd_num_cat = 7;
		else if Exterior2nd="ImStucc" 	then Exterior2nd_num_cat = 8;
		else if Exterior2nd="MetalSd" 	then Exterior2nd_num_cat = 9;
		else if Exterior2nd="Plywood" 	then Exterior2nd_num_cat = 10;
		else if Exterior2nd="Stone" 	then Exterior2nd_num_cat = 11;
		else if Exterior2nd="Stucco" 	then Exterior2nd_num_cat = 12;
		else if Exterior2nd="VinylSd" 	then Exterior2nd_num_cat = 13;
		else if Exterior2nd="Wd Sdng" 	then Exterior2nd_num_cat = 14;
		else Exterior2nd_num_cat = 0;

		if MasVnrType="NA" 			then MasVnrType_num_cat = 0;
		else if MasVnrType="BrkCmn" then MasVnrType_num_cat = 1;
		else if MasVnrType="BrkFace" then MasVnrType_num_cat = 2;
		else if MasVnrType="Stone" 	then MasVnrType_num_cat = 3;
		else MasVnrType_num_cat = 4;

		if ExterQual="Ex" 		then ExterQual_num_cat = 6;
		else if ExterQual="Gd" 	then ExterQual_num_cat = 5;
		else if ExterQual="TA" 	then ExterQual_num_cat = 4;
		else if ExterQual="Av" 	then ExterQual_num_cat = 4;
		else if ExterQual="Fa" 	then ExterQual_num_cat = 3;
		else if ExterQual="Po" 	then ExterQual_num_cat = 2;
		else if ExterQual="No" 	then ExterQual_num_cat = 1;
		else if ExterQual="NA" 	then ExterQual_num_cat = 0;

		if ExterCond="Ex" 		then ExterCond_num_cat = 6;
		else if ExterCond="Gd" 	then ExterCond_num_cat = 5;
		else if ExterCond="TA" 	then ExterCond_num_cat = 4;
		else if ExterCond="Av" 	then ExterCond_num_cat = 4;
		else if ExterCond="Fa" 	then ExterCond_num_cat = 3;
		else if ExterCond="Po" 	then ExterCond_num_cat = 2;
		else if ExterCond="No" 	then ExterCond_num_cat = 1;
		else if ExterCond="NA" 	then ExterCond_num_cat = 0;

		if Foundation="BrkTil" then Foundation_num_cat= 1;
		else if Foundation="CBlock" then Foundation_num_cat= 2;
		else if Foundation="PConc" then Foundation_num_cat= 3;
		else if Foundation="Slab" then Foundation_num_cat= 4;
		else if Foundation="Stone" then Foundation_num_cat= 5;
		else Foundation_num_cat= 0;

		if BsmtQual="Ex" 		then BsmtQual_num_cat = 6;
		else if BsmtQual="Gd" 	then BsmtQual_num_cat = 5;
		else if BsmtQual="TA" 	then BsmtQual_num_cat = 4;
		else if BsmtQual="Av" 	then BsmtQual_num_cat = 4;
		else if BsmtQual="Fa" 	then BsmtQual_num_cat = 3;
		else if BsmtQual="Po" 	then BsmtQual_num_cat = 2;
		else if BsmtQual="No" 	then BsmtQual_num_cat = 1;
		else if BsmtQual="NA" 	then BsmtQual_num_cat = 0;

		if BsmtCond="Ex" 		then BsmtCond_num_cat = 6;
		else if BsmtCond="Gd" 	then BsmtCond_num_cat = 5;
		else if BsmtCond="TA" 	then BsmtCond_num_cat = 4;
		else if BsmtCond="Av" 	then BsmtCond_num_cat = 4;
		else if BsmtCond="Fa" 	then BsmtCond_num_cat = 3;
		else if BsmtCond="Po" 	then BsmtCond_num_cat = 2;
		else if BsmtCond="No" 	then BsmtCond_num_cat = 1;
		else if BsmtCond="NA" 	then BsmtCond_num_cat = 0;

		if BsmtExposure="Ex" 		then BsmtExposure_num_cat = 6;
		else if BsmtExposure="Gd" 	then BsmtExposure_num_cat = 5;
		else if BsmtExposure="TA" 	then BsmtExposure_num_cat = 4;
		else if BsmtExposure="Av" 	then BsmtExposure_num_cat = 4;
		else if BsmtExposure="Fa" 	then BsmtExposure_num_cat = 3;
		else if BsmtExposure="Mn" 	then BsmtExposure_num_cat = 2;
		else if BsmtExposure="No" 	then BsmtExposure_num_cat = 1;
		else if BsmtExposure="NA" 	then BsmtExposure_num_cat = 0;

		if BsmtFinType1="ALQ" then BsmtFinType1_num_cat = 5;
		else if BsmtFinType1="BLQ" then BsmtFinType1_num_cat = 4;
		else if BsmtFinType1="GLQ" then BsmtFinType1_num_cat = 6;
		else if BsmtFinType1="LwQ" then BsmtFinType1_num_cat = 2;
		else if BsmtFinType1="NA" then BsmtFinType1_num_cat = 0;
		else if BsmtFinType1="Rec" then BsmtFinType1_num_cat = 3;
		else if BsmtFinType1="Unf" then BsmtFinType1_num_cat = 1;
		

		if BsmtFinType2="ALQ" then BsmtFinType2_num_cat = 5;
		else if BsmtFinType2="BLQ" then BsmtFinType2_num_cat = 4;
		else if BsmtFinType2="GLQ" then BsmtFinType2_num_cat = 6;
		else if BsmtFinType2="LwQ" then BsmtFinType2_num_cat = 2;
		else if BsmtFinType2="NA" then BsmtFinType2_num_cat = 0 ;
		else if BsmtFinType2="Rec" then BsmtFinType2_num_cat = 3;
		else if BsmtFinType2="Unf" then BsmtFinType2_num_cat = 1;


		if Heating="Floor" then Heating_num_cat = 1;
		else if Heating="GasA" then Heating_num_cat = 2;
		else if Heating="GasW" then Heating_num_cat = 3;
		else if Heating="Grav" then Heating_num_cat = 4;
		else if Heating="OthW" then Heating_num_cat = 5;
		else  Heating_num_cat = 0;
		
		if HeatingQC="Ex" 		then HeatingQC_num_cat = 6;
		else if HeatingQC="Gd" 	then HeatingQC_num_cat = 5;
		else if HeatingQC="TA" 	then HeatingQC_num_cat = 4;
		else if HeatingQC="Av" 	then HeatingQC_num_cat = 4;
		else if HeatingQC="Fa" 	then HeatingQC_num_cat = 3;
		else if HeatingQC="Po" 	then HeatingQC_num_cat = 2;
		else if HeatingQC="No" 	then HeatingQC_num_cat = 1;
		else if HeatingQC="NA" 	then HeatingQC_num_cat = 0;

		
		if CentralAir = "Y" then CentralAir_num_cat = 1;
		else CentralAir_num_cat = 0;

		if Electrical = "FuseA" then Electrical_num_cat = 1;
		else if Electrical = "FuseF" then Electrical_num_cat = 2;
		else if Electrical = "FuseP" then Electrical_num_cat = 3;
		else if Electrical = "Mix" then Electrical_num_cat = 4;
		else if Electrical = "NA" then Electrical_num_cat = 5;
		else Electrical_num_cat = 0;

		if KitchenQual="Ex" 		then KitchenQual_num_cat = 6;
		else if KitchenQual="Gd" 	then KitchenQual_num_cat = 5;
		else if KitchenQual="TA" 	then KitchenQual_num_cat = 4;
		else if KitchenQual="Av" 	then KitchenQual_num_cat = 4;
		else if KitchenQual="Fa" 	then KitchenQual_num_cat = 3;
		else if KitchenQual="Po" 	then KitchenQual_num_cat = 2;
		else if KitchenQual="No" 	then KitchenQual_num_cat = 1;
		else if KitchenQual="NA" 	then KitchenQual_num_cat = 0;


		if Functional="Maj1" then Functional_num_cat = 2;
		else if Functional="Maj2" then Functional_num_cat = 1;
		else if Functional="Min1" then Functional_num_cat = 5;
		else if Functional="Min2" then Functional_num_cat = 4;
		else if Functional="Mod" then Functional_num_cat =3;
		else if Functional="Sev" then Functional_num_cat = 0;
		else if Functional="Typ" then Functional_num_cat = 6;

		if FireplaceQu="Ex" 		then FireplaceQu_num_cat = 6;
		else if FireplaceQu="Gd" 	then FireplaceQu_num_cat = 5;
		else if FireplaceQu="TA" 	then FireplaceQu_num_cat = 4;
		else if FireplaceQu="Av" 	then FireplaceQu_num_cat = 4;
		else if FireplaceQu="Fa" 	then FireplaceQu_num_cat = 3;
		else if FireplaceQu="Po" 	then FireplaceQu_num_cat = 2;
		else if FireplaceQu="No" 	then FireplaceQu_num_cat = 1;
		else if FireplaceQu="NA" 	then FireplaceQu_num_cat = 0;


		if GarageType="Attchd" then GarageType_num_cat = 5;
		else if GarageType="2Types" then GarageType_num_cat = 6;
		else if GarageType="Basment" then GarageType_num_cat = 4;
		else if GarageType="BuiltIn" then GarageType_num_cat = 3;
		else if GarageType="CarPort" then GarageType_num_cat = 2;
		else if GarageType="Detchd" then GarageType_num_cat = 1;
		else  GarageType_num_cat = 0;

		if GarageFinish="RFn" then GarageFinish_num_cat = 2;
		else if GarageFinish="Fin" then GarageFinish_num_cat = 3;
		else if GarageFinish="Unf" then GarageFinish_num_cat = 1;
		else GarageFinish_num_cat = 0;	

		if GarageQual="Ex" 		then GarageQual_num_cat = 6;
		else if GarageQual="Gd" 	then GarageQual_num_cat = 5;
		else if GarageQual="TA" 	then GarageQual_num_cat = 4;
		else if GarageQual="Av" 	then GarageQual_num_cat = 4;
		else if GarageQual="Fa" 	then GarageQual_num_cat = 3;
		else if GarageQual="Po" 	then GarageQual_num_cat = 2;
		else if GarageQual="No" 	then GarageQual_num_cat = 1;
		else if GarageQual="NA" 	then GarageQual_num_cat = 0;

		if GarageCond="Ex" 		then GarageCond_num_cat = 6;
		else if GarageCond="Gd" 	then GarageCond_num_cat = 5;
		else if GarageCond="TA" 	then GarageCond_num_cat = 4;
		else if GarageCond="Av" 	then GarageCond_num_cat = 4;
		else if GarageCond="Fa" 	then GarageCond_num_cat = 3;
		else if GarageCond="Po" 	then GarageCond_num_cat = 2;
		else if GarageCond="No" 	then GarageCond_num_cat = 1;
		else if GarageCond="NA" 	then GarageCond_num_cat = 0;
		
		if PavedDrive = "Y" then PavedDrive_num_cat = 1;
		else if PavedDrive = "N" then PavedDrive_num_cat = 0;
		else PavedDrive_num_cat = 2;

		if PoolQC="Ex" 		then PoolQC_num_cat = 6;
		else if PoolQC="Gd" 	then PoolQC_num_cat = 5;
		else if PoolQC="TA" 	then PoolQC_num_cat = 4;
		else if PoolQC="Av" 	then PoolQC_num_cat = 4;
		else if PoolQC="Fa" 	then PoolQC_num_cat = 3;
		else if PoolQC="Po" 	then PoolQC_num_cat = 2;
		else if PoolQC="No" 	then PoolQC_num_cat = 1;
		else if PoolQC="NA" 	then PoolQC_num_cat = 0;

		if Fence="GdPrv" then Fence_num_cat = 4;
		else if Fence="GdWo" then Fence_num_cat = 3;
		else if Fence="MnPrv" then Fence_num_cat = 2;
		else if Fence="MnWw" then Fence_num_cat = 1;
		else if Fence="NA" then Fence_num_cat = 0;

		if MiscFeature="NA" then MiscFeature_num_cat = 0;
		else if MiscFeature="Gar2" then MiscFeature_num_cat = 3;
		else if MiscFeature="Othr" then MiscFeature_num_cat = 1;
		else if MiscFeature="Shed" then MiscFeature_num_cat = 2;
		else if MiscFeature="TenC" then MiscFeature_num_cat = 4;

	
		if SaleType="COD" then SaleType_num_cat = 1;
		else if SaleType="Con" then SaleType_num_cat = 2;
		else if SaleType="ConLD" then SaleType_num_cat = 3;
		else if SaleType="ConLI" then SaleType_num_cat = 4;
		else if SaleType="ConLw" then SaleType_num_cat = 5;
		else if SaleType="CWD" then SaleType_num_cat = 6;
		else if SaleType="New" then SaleType_num_cat = 7;
		else if SaleType="Oth" then SaleType_num_cat = 8;
		else SaleType_num_cat = 0;

		if SaleCondition = "Abnorml" then SaleCondition_num_cat = 1;
		else if SaleCondition = "AdjLand" then SaleCondition_num_cat = 2;
		else if SaleCondition = "Alloca" then SaleCondition_num_cat = 3;
		else if SaleCondition = "Family" then SaleCondition_num_cat = 4;
		else if SaleCondition = "Normal" then SaleCondition_num_cat = 5;
		else SaleCondition_num_cat = 0;

		if MasVnrArea="" then MasVnrArea = 0;
		if GarageYrBlt="" then GarageYrBlt = 0;

run;

/* Kaggle score:Custom Selection 0.13 */ 
proc glmselect data=train2;
class LotConfig_num_cat 
  Neighborhood_num_cat ExterQual_num_cat BsmtQual_num_cat HeatingQC_num_cat 
  KitchenQual_num_cat FireplaceQu_num_cat 
  GarageQual_num_cat PoolQC_num_cat SaleCondition_num_cat; 
model logPrice  =   GarageCars
OverallCond
YearRemodAdd
YearBuilt
BsmtUnfSF
OpenPorchSF
GarageArea
TotRmsAbvGrd
LotArea
WoodDeckSF
GrLivArea
EnclosedPorch
FullBath
Fireplaces
MasVnrArea
OverallQual | Neighborhood_num_cat /selection=stepwise(stop=cv) cvmethod=random(5) stats=adjrsq;
 output out= results p= predict; 
 run; 
 
 
  data results;
set results;
if predict>0 then SalePrice=exp(predict);
if predict<0 then SalePrice=10000;
keep id SalePrice;
where id>1460;

proc export 
  data=results
  dbms=csv
  outfile="/home/u58342833/sasuser.v94/Exam/submission_result.csv" 
  replace;
run;

proc reg data=train2;
class MSZoning_num_cat
Street_num_cat
Alley_num_cat
LotShape_num_cat
LandContour_num_cat
Utilities_num_cat
LotConfig_num_cat
LandSlope_num_cat
Neighborhood_num_cat
Condition1_num_cat
Condition2_num_cat
BldgType_num_cat
HouseStyle_num_cat
RoofStyle_num_cat
RoofMatl_num_cat
Exterior1st_num_cat
Exterior2nd_num_cat
MasVnrType_num_cat
ExterQual_num_cat
ExterCond_num_cat
Foundation_num_cat
BsmtQual_num_cat
BsmtCond_num_cat
BsmtExposure_num_cat
BsmtFinType1_num_cat
BsmtFinType2_num_cat
Heating_num_cat
HeatingQC_num_cat
CentralAir_num_cat
Electrical_num_cat
KitchenQual_num_cat
Functional_num_cat
FireplaceQu_num_cat
GarageType_num_cat
GarageFinish_num_cat
PavedDrive_num_cat
PoolQC_num_cat
Fence_num_cat
MiscFeature_num_cat
SaleType_num_cat
SaleCondition_num_cat;
model logPrice  = 
GarageCars
OverallCond
YearRemodAdd
YearBuilt
BsmtUnfSF
OpenPorchSF
GarageArea
TotRmsAbvGrd
LotArea
WoodDeckSF
GrLivArea
EnclosedPorch
FullBath
Fireplaces
MasVnrArea
OverallQual
 / selection=backward  stb     VIF ss1 ss2;
OUTPUT OUT = reg_House_price4 PREDICTED=PRCDT RESIDUAL = h_Res
	L95M = h_l95m U95M  = h_u95m L95 =h_l95 U95 = h_u95 
	rstudent = h_rstudent h = lev cookd = Cookd dffits = dffit 
	STDP = h_spredicted STDR = h_s_residual STUDENT = h_student;
      
quit;
      


 




  data results;
set results;
if predict>0 then SalePrice=exp(predict);
if predict<0 then SalePrice=10000;
keep id SalePrice;
where id>1460;

proc export 
  data=results
  dbms=csv
  outfile="/home/u58342833/sasuser.v94/Exam/custom_result.csv" 
  replace;
run;




proc glmselect data=train2Ames3NoOutlier; 
model logSalePrice = logOverallQual | GrLivArea GarageArea | YearBuilt | OverallCond | YearRemodAdd   FullBath TotRmsAbvGrd Fireplaces GarageCars WoodDeckSF OpenPorchSF LotConfig_num   Neighborhood_num ExterQual_num BsmtQual_num HeatingQC_num
 KitchenQual_num FireplaceQu_num   GarageQual_num PoolQC_num SaleCondition_num  /selection=Backward(stop=cv) cvmethod=random(5) stats=adjrsq; 
 output out= results p= predict;
 run; 
 
 
 
 proc reg data=Train2;
	model 	SalePrice =		
		MSZoning_num_cat
Street_num_cat
Alley_num_cat
LotShape_num_cat
LandContour_num_cat
Utilities_num_cat
LotConfig_num_cat
LandSlope_num_cat
Neighborhood_num_cat
Condition1_num_cat
Condition2_num_cat
BldgType_num_cat
HouseStyle_num_cat
RoofStyle_num_cat
RoofMatl_num_cat
Exterior1st_num_cat
Exterior2nd_num_cat
MasVnrType_num_cat
ExterQual_num_cat
ExterCond_num_cat
Foundation_num_cat
BsmtQual_num_cat
BsmtCond_num_cat
BsmtExposure_num_cat
BsmtFinType1_num_cat
BsmtFinType2_num_cat
Heating_num_cat
HeatingQC_num_cat
CentralAir_num_cat
Electrical_num_cat
KitchenQual_num_cat
Functional_num_cat
FireplaceQu_num_cat
GarageType_num_cat
GarageFinish_num_cat
GarageQual_num_cat
GarageCond_num_cat
PavedDrive_num_cat
PoolQC_num_cat
Fence_num_cat
MiscFeature_num_cat
SaleType_num_cat
SaleCondition_num_cat
OverallCond
YearRemodAdd
YearBuilt
BsmtUnfSF
OpenPorchSF
GarageArea
TotRmsAbvGrd
LotArea
WoodDeckSF
GrLivArea
EnclosedPorch
FullBath
Fireplaces
MasVnrArea
OverallQual
GarageCars
	
	/   stb     VIF ss1 ss2 selection=stepwise slentry=0.1 slstay=0.1;
	OUTPUT OUT = reg_House_price PREDICTED=PRCDT RESIDUAL = h_Res
	L95M = h_l95m U95M  = h_u95m L95 =h_l95 U95 = h_u95 
	rstudent = h_rstudent h = lev cookd = Cookd dffits = dffit 
	STDP = h_spredicted STDR = h_s_residual STUDENT = h_student;
      
quit;


proc  glmselect data=train2; 
class MSZoning_num_cat	Street_num_cat	Alley_num_cat	LotShape_num_cat	
LandContour_num_cat	Utilities_num_cat	LotConfig_num_cat	LandSlope_num_cat	
Neighborhood_num_cat	Condition1_num_cat	Condition2_num_cat	BldgType_num_cat	
HouseStyle_num_cat	RoofStyle_num_cat	Exterior2nd_num_cat	MasVnrType_num_cat	
ExterQual_num_cat	ExterCond_num_cat	Foundation_num_cat	BsmtQual_num_cat	
BsmtCond_num_cat	BsmtExposure_num_cat	BsmtFinType1_num_cat	BsmtFinType2_num_cat	
Heating_num_cat	HeatingQC_num_cat	CentralAir_num_cat	Electrical_num_cat	
KitchenQual_num_cat	Functional_num_cat	FireplaceQu_num_cat	GarageType_num_cat	
GarageFinish_num_cat	PavedDrive_num_cat	MiscFeature_num_cat	SaleType_num_cat;
model  logPrice  = MSZoning_num_cat	Street_num_cat	Alley_num_cat	LotShape_num_cat	
LandContour_num_cat	Utilities_num_cat	LotConfig_num_cat	LandSlope_num_cat	
Neighborhood_num_cat	Condition1_num_cat	Condition2_num_cat	BldgType_num_cat	
HouseStyle_num_cat	RoofStyle_num_cat	Exterior2nd_num_cat	MasVnrType_num_cat	
ExterQual_num_cat	ExterCond_num_cat	Foundation_num_cat	BsmtQual_num_cat	
BsmtCond_num_cat	BsmtExposure_num_cat	BsmtFinType1_num_cat	BsmtFinType2_num_cat	
Heating_num_cat	HeatingQC_num_cat	CentralAir_num_cat	Electrical_num_cat	
KitchenQual_num_cat	Functional_num_cat	FireplaceQu_num_cat	GarageType_num_cat	
GarageFinish_num_cat	PavedDrive_num_cat	MiscFeature_num_cat	SaleType_num_cat	
SaleCondition_num_cat	OverallCond	YearRemodAdd	YearBuilt	BsmtUnfSF	OpenPorchSF	
GarageArea	TotRmsAbvGrd	LotArea	WoodDeckSF	GrLivArea	EnclosedPorch	FullBath	
Fireplaces	MasVnrArea	OverallQual /  selection=backward (stop=cv) slentry=0.1 slstay=0.1; 
output out=backward_result p=Predict4;
run;  

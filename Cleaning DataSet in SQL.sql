SET GLOBAL local_infile = 1;

DROP TABLE IF EXISTS housing;
CREATE TABLE housing 
(UniqueID 	INT,
ParcelID	TEXT,
LandUse	TEXT,
PropertyAddress	TEXT,
SaleDate	TEXT,
SalePrice	INT,
LegalReference	TEXT,
SoldAsVacant	TEXT,
OwnerName	TEXT,
OwnerAddress	TEXT,
Acreage	INT,
TaxDistrict	TEXT,
LandValue	INT,
BuildingValue	INT,
TotalValue	INT,
YearBuilt	INT,
Bedrooms	INT,
FullBath	INT,
HalfBath INT
);


LOAD DATA LOCAL INFILE "C:/Users/Kiril/Desktop/SQL/Guided Project/Project 3 (Clearing Data in SQL)/Nashville Housing Data for Data Cleaning.csv"
INTO TABLE housing 
FIELDS TERMINATED BY ';'
enclosed by '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Checking visualy if the data was imported proprely || Check if the amount of rows are inline with file 

SELECT *
FROM housing;

SELECT COUNT(*)
FROM housing;

-- Import was successful 


-- DATA CLEANING 

-----------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format 


SELECT STR_TO_DATE(SaleDate, '%M %d, %Y') as date, SaleDate
FROM housing;


ALTER TABLE housing 
ADD COLUMN SalesDate DATE;


UPDATE housing 
SET SalesDate = STR_TO_DATE(SaleDate, '%M %d, %Y');

ALTER TABLE housing 
DROP COLUMN SaleDate;

-----------------------------------------------------------------------------------------------------------------------------

-- Populate Property Adress data

UPDATE housing 
SET PropertyAddress = NULL
WHERE PropertyAddress = "";

SELECT *
FROM housing
WHERE PropertyAddress IS NULL;


SELECT h.ParcelID, h.PropertyAddress, h2.ParcelID, h2.PropertyAddress, IFNULL(h.PropertyAddress, h2.PropertyAddress)
FROM housing h
JOIN housing h2 
ON h.ParcelID = h2.ParcelID
and h.UniqueID <> h2.UniqueID
WHERE h.PropertyAddress IS NULL;


UPDATE housing h
JOIN housing h2 
	ON h.ParcelID = h2.ParcelID
	and h.UniqueID <> h2.UniqueID
SET h.PropertyAddress = IFNULL(h.PropertyAddress, h2.PropertyAddress)
WHERE h.PropertyAddress IS NULL;


----------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Addresses into individual columns 

SELECT PropertyAddress 
FROM housing;

-- First way to split the address from the Location 

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) + 1 , length(PropertyAddress)) as Location
FROM housing;

-- Second, more easier way 

SELECT PropertyAddress,
SUBSTRING_INDEX(PropertyAddress, ',', 1) as Address,
SUBSTRING_INDEX(PropertyAddress, ',', -1) as Location
FROM housing;

ALTER TABLE housing 
ADD COLUMN PropertySplitAddress VARCHAR(255);

UPDATE housing 
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress,',',1);

ALTER TABLE housing 
ADD COLUMN City VARCHAR(255);

UPDATE housing 
SET City = SUBSTRING_INDEX(PropertyAddress,',',-1);




SELECT OwnerAddress
FROM housing;

SELECT OwnerAddress, 
SUBSTRING_INDEX(OwnerAddress,',',1) as Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1) as City,
SUBSTRING_INDEX(OwnerAddress,',',-1) as Codex
FROM housing;

ALTER TABLE housing 
ADD COLUMN OwnerSplitAddress VARCHAR(255);

UPDATE housing 
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',',1);

ALTER TABLE housing 
ADD COLUMN OwnerSplitCity VARCHAR(255);

UPDATE housing 
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1);

ALTER TABLE housing 
ADD COLUMN OwnerSplitState VARCHAR(255);

UPDATE housing 
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress,',',-1);



-- Change Y and N to Yes and No on 'SoldAsVacant' filed 

SELECT SoldAsVacant, COUNT(SoldAsVacant)
from housing
GROUP BY SoldAsVacant;

SELECT *
FROM housing 
WHERE SoldASVacant in ('N','Y');

SELECT UniqueId, ParcelID, PropertyAddress, SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
END as Changedway 
FROM housing
WHERE SoldASVacant in ('N','Y');

UPDATE housing
SET SoldAsVacant =  CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;

-------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 


SELECT * 
FROM housing;

with RowNumCTE as
(
SELECT *,
ROW_NUMBER()OVER(PARTITION BY ParcelID,PropertyAddress, SalePrice, SalesDate, LegalReference ORDER BY  UniqueID) as count_rows
FROM housing
)
SELECT *
FROM RowNumCTE
WHERE count_rows > 1;


DELETE FROM housing 
WHERE UniqueID IN (
    SELECT UniqueID 
    FROM (
    SELECT UniqueID, 
    ROW_NUMBER()OVER(PARTITION BY ParcelID,PropertyAddress, SalePrice, SalesDate, LegalReference ORDER BY  UniqueID) as count_rows
    FROM housing
    ) t
    WHERE count_rows > 1
    );
    

-------------------------------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns 

SELECT * 
FROM housing;

ALTER TABLE  housing
DROP COLUMN PropertyAddress;

ALTER TABLE  housing
DROP COLUMN OwnerAddress;

ALTER TABLE  housing
DROP COLUMN TaxDistrict;
 

-- 1. Looking at the dataset 
SELECT * 
FROM nashville

--2. SaleDate is in datetime format, change the datatype
SELECT 
  SaleDate, 
  CAST(SaleDate AS date) AS SaleDate
FROM nashville

ALTER TABLE nashville 
ADD SaleDateConverted DATE

UPDATE nashville
SET SaleDateConverted = CAST(SaleDate AS date) 

SELECT 
 SaleDateConverted
FROM nashville

--3. Populate Property Address Data 

/*there are null values in the PropertyAddress  which should not be
the case as there these were the address of the properties sold. Studying the dataset
revealed that there duplicates in the dataset. The same ParceID corresponded to the same
PropertyAddress.*/ 

--I need all NULL property address by self-joiingn the dataset to itself on ParcelID and where the UniqueID is different

SELECT 
  a.ParcelID, 
  a.PropertyAddress, 
  b.ParcelID,
  b.PropertyAddress
FROM nashville AS a
INNER JOIN nashville AS b
        ON a.ParcelID = b.ParcelID 
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Where a.PropertyAddress is NULL, popluated with values from b.PropertyAddress
SELECT 
  a.ParcelID, 
  a.PropertyAddress, 
  b.ParcelID,
  b.PropertyAddress,
  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville AS a
INNER JOIN nashville AS b
        ON a.ParcelID = b.ParcelID 
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--update nashville dataset a 
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville AS a
INNER JOIN nashville AS b
        ON a.ParcelID = b.ParcelID 
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

SELECT * FROM nashville
WHERE PropertyAddress IS NULL 
--this did not return any values, hence all NULL values in PropertyAddress have been replaced. 

--4. Breaking PropertyAddress into Address, City, State

SELECT 
  PropertyAddress
FROM nashville 

/* current PropertyAddress list the addres and the city with a comma as the delimiter, 
I want to reorganise the values so that it will be neater*/

SELECT 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )AS Address, 
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) AS State 
FROM nashville

--update and insert the new column
ALTER TABLE nashville
ADD Property_Address VARCHAR(255)

UPDATE nashville 
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE nashville
ADD Property_Address_City VARCHAR(255)

UPDATE nashville 
SET Property_Address_City =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

--check your dataset for the 2 new PropertyAddress columns 
SELECT * 
FROM nashville

--5. Split OwnerAddress using PARSENAME() into Address, City, State
SELECT 
  OwnerAddress
FROM nashville

--OwnerAddress has delimiter ','

SELECT 
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
FROM nashville

--alter table and add in new columns
ALTER TABLE nashville
ADD Owner_Address VARCHAR(255)

UPDATE nashville 
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE nashville
ADD Owner_Address_City VARCHAR(255)

UPDATE nashville 
SET Owner_Address_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE nashville
ADD Owner_Address_State VARCHAR(255)

UPDATE nashville 
SET Owner_Address_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--6. standardize values in the SoldAsVacant column
/*There are currently 'Y', 'N', 'Yes', 'No', 4 types of values in the column, 
I want to standardize them with only 'Yes' and 'No' values.*/

SELECT 
  SoldAsVacant,
  CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant 
	END
FROM nashville

--update table 

UPDATE nashville 
SET SoldAsVacant = (CASE 
                       WHEN SoldAsVacant = 'Y' THEN 'Yes'
	                   WHEN SoldAsVacant = 'N' THEN 'No'
                       ELSE SoldAsVacant 
	                   END)

--7. Look for duplicates and delete duplicates 
-- I will use window function here 

WITH duplicates_row_num AS (
  SELECT 
    *, 
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
	--if duplicates all these values will be the same
  FROM nashville
)

/*
SELECT 
  *
FROM duplicates_row_num
WHERE row_num > 1  
the row_num will restart itself as long as the partition by values is different.
*/

--delete the duplicates
DELETE 
FROM duplicates_row_num
WHERE row_num > 1

--8. Delete not in use columns
ALTER TABLE nashville
DROP COLUMN 
  OwnerAddress, 
  TaxDistrict,
  PropertyAddress,
  SaleDate

 




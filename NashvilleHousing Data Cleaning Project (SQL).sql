--Cleaning Data in SQL Queries



------------------------STANDARDIZING THE DATE FORMAT------------------------

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

------------------------POPULATE PROPERTY ADDRESS DATA------------------------

--Locating all of the null PropertyAddress rows and replacing it with existing recorded Address of the same ParcelID locations.
SELECT x.ParcelID , x.PropertyAddress , y.ParcelID, y.PropertyAddress , ISNULL(x.PropertyAddress, y.PropertyAddress)
FROM NashvilleHousing x
JOIN NashvilleHousing y
	ON x.ParcelID = y.ParcelID
	AND x.UniqueID <> y.UniqueID
WHERE x.PropertyAddress is null

--Updating the null values of PropertyAddress in NashvilleHousing 
UPDATE  x
SET PropertyAddress = ISNULL(x.PropertyAddress, y.PropertyAddress)
FROM NashvilleHousing x
JOIN NashvilleHousing y
	ON x.ParcelID = y.ParcelID
	AND x.UniqueID <> y.UniqueID
WHERE x.PropertyAddress is null

------------------------BREAKING DOWN ADDRESS INTO INDIVIDUAL COLUMNS (BY ADDRESS, CITY, AND STATE)------------------------

--PT 1. Using CharIndex for PropertyAddress to create multiple columns of splitted (one for each of Address,City,State)
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1   , LEN(PropertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1   , LEN(PropertyAddress))

--PT 2. Using PARSENAME for OwnerAddress to create multiple columns of splitted (one for each of Address,City,State)
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)

------------------------CHANGING Y AND N IN SoldAsVacant TO YES AND NO------------------------

-- Checking for the count of Y and N
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant

--Setting up the Case Statement
SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE	SoldAsVacant
			END
FROM NashvilleHousing

--Updating SoldAsVacant
UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE	SoldAsVacant
			END
FROM NashvilleHousing

------------------------REMOVING DUPLICATES------------------------

--Using CTE to remove duplicates
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY UniqueID
								) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

--Checking to make sure that the duplicate rows were deleted (below code returns empty table, meaning that the duplicate rows were successfully deleted from the queries above)
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY UniqueID
								) row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

------------------------DELETING UNUSED COLUMNS------------------------

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


------------------------FINAL CHECK ON THE TABLE AFTER CLEANING------------------------
SELECT *
FROM NashvilleHousing

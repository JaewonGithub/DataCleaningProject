# Introduction
Data Cleaning Using Microsoft SQL Server Management Studio on :house: housing data from Nashville 
<br><br/>
Interested in the full SQL Query? Check it out [Here](/NashvilleHousing Data Cleaning Project (SQL).sql)
# Background 
The motivation behind undertaking a data cleaning project on Nashville Housing data lies in the need to understand and analyze the real estate landscape within Nashville comprehensively. This initiative not only ensures data accuracy but also sets the stage for in-depth analysis and visualization using business intelligence tools, potentially revealing actionable patterns and opportunities within Nashville's housing market.
<br><br/>
# Utilized Tools
To enhance my process of data cleaning, I utilized several tools :
- **SQL**: Serving as the language of my project, enabling me to modify and update raw data into useful standardized format.
- **Microsoft SQL Server Management Studio**: Tool for database management tasks and executing SQL queries.
<br><br/>
<br><br/>
# Data Cleaning begins
## Standardize the Date Format
- Creates a new column called <i>SaleDateConverted</i>, which stores <i>SaleDate </i>column in DATE format. 
```sql
-- PT 1. Creating the column
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

-- PT 2. Inserting the values
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);
```

## Populate Property Address Area
- Locates all of the null PropertyAddress rows, and replaces it with existing recorded Address of the same ParcelID locations.

```sql
-- PT 1. Selecting the null rows
SELECT 
    x.ParcelID , 
    x.PropertyAddress, 
    y.ParcelID, 
    y.PropertyAddress, 
    ISNULL(x.PropertyAddress, y.PropertyAddress)
FROM 
    NashvilleHousing x
    INNER JOIN NashvilleHousing y ON x.ParcelID = y.ParcelID AND x.UniqueID <> y.UniqueID
WHERE 
    x.PropertyAddress IS NULL;

-- PT 2. Updating the null rows
UPDATE x
SET PropertyAddress = ISNULL(x.PropertyAddress, y.PropertyAddress)
FROM 
    NashvilleHousing x 
    INNER JOIN NashvilleHousing y ON x.ParcelID = y.ParcelID AND x.UniqueID <> y.UniqueID
WHERE x.PropertyAddress IS NULL;
```
## Splitting <i>PropertyAddress</i> and <i>OwnerAddress</i> columns
- Split the two columns that contains full address into three columns - each containing the address, city and the state.
```sql
--PT 1. Using CharIndex for PropertyAddress
SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1) as Address,         
    SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress))

--PT 2. Using Parsename for OwnerAddress
SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3),
    PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2),
    PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
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
```
<b>Output for PropertyAddress:</b>
```sql
SELECT TOP(10) UniqueID, PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing
```
| UniqueID |         PropertyAddress        | PropertySplitAddress | PropertySplitCity |
|----------|--------------------------------|----------------------|-------------------|
|   2045   | 1808  FOX CHASE DR, GOODLETTSVILLE |  1808  FOX CHASE DR |   GOODLETTSVILLE  |
|  16918   | 1832  FOX CHASE DR, GOODLETTSVILLE |  1832  FOX CHASE DR |   GOODLETTSVILLE  |
|  54582   | 1864 FOX CHASE  DR, GOODLETTSVILLE |  1864 FOX CHASE  DR |   GOODLETTSVILLE  |
|  43070   | 1853  FOX CHASE DR, GOODLETTSVILLE |  1853  FOX CHASE DR |   GOODLETTSVILLE  |
|  22714   | 1829  FOX CHASE DR, GOODLETTSVILLE |  1829  FOX CHASE DR |   GOODLETTSVILLE  |
|  18367   | 1821  FOX CHASE DR, GOODLETTSVILLE |  1821  FOX CHASE DR |   GOODLETTSVILLE  |
|  19804   |    2005  SADIE LN, GOODLETTSVILLE   |      2005  SADIE LN |   GOODLETTSVILLE  |
|  54583   | 1917 GRACELAND  DR, GOODLETTSVILLE  | 1917 GRACELAND  DR  |   GOODLETTSVILLE  |
|  36500   | 1428  SPRINGFIELD HWY, GOODLETTSVILLE | 1428  SPRINGFIELD HWY | GOODLETTSVILLE |
|  19805   | 1420  SPRINGFIELD HWY, GOODLETTSVILLE | 1420  SPRINGFIELD HWY | GOODLETTSVILLE |

<b>Output for OwnerAddress:</b>
```sql
SELECT TOP(10) UniqueID , OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing
```
| UniqueID |          OwnerAddress             |   OwnerSplitAddress   | OwnerSplitCity | OwnerSplitState |
|----------|----------------------------------|-----------------------|----------------|-----------------|
|   2045   | 1808  FOX CHASE DR, GOODLETTSVILLE, TN |  1808  FOX CHASE DR  | GOODLETTSVILLE |       TN        |
|  16918   | 1832  FOX CHASE DR, GOODLETTSVILLE, TN |  1832  FOX CHASE DR  | GOODLETTSVILLE |       TN        |
|  54582   | 1864  FOX CHASE DR, GOODLETTSVILLE, TN |  1864  FOX CHASE DR  | GOODLETTSVILLE |       TN        |
|  43070   | 1853  FOX CHASE DR, GOODLETTSVILLE, TN |  1853  FOX CHASE DR  | GOODLETTSVILLE |       TN        |
|  22714   | 1829  FOX CHASE DR, GOODLETTSVILLE, TN |  1829  FOX CHASE DR  | GOODLETTSVILLE |       TN        |
|  18367   | 1821  FOX CHASE DR, GOODLETTSVILLE, TN |  1821  FOX CHASE DR  | GOODLETTSVILLE |       TN        |
|  19804   |   2005  SADIE LN, GOODLETTSVILLE, TN   |    2005  SADIE LN    | GOODLETTSVILLE |       TN        |
|  54583   | 1917  GRACELAND DR, GOODLETTSVILLE, TN | 1917  GRACELAND DR   | GOODLETTSVILLE |       TN        |
|  36500   |1428  SPRINGFIELD HWY, GOODLETTSVILLE, TN| 1428  SPRINGFIELD HWY | GOODLETTSVILLE |       TN        |
|  19805   |1420  SPRINGFIELD HWY, GOODLETTSVILLE, TN| 1420  SPRINGFIELD HWY | GOODLETTSVILLE |       TN        |

## Unifying response to Yes and No for SoldAsVacant column
- For better readability, changed all of Y and N in the cells of <i>SoldAsVacant</i> column to Yes and No.
```sql
-- PT 1. Checking for the count of Y and N
SELECT 
    DISTINCT(SoldAsVacant), 
    Count(SoldAsVacant)
FROM 
    NashvilleHousing
GROUP BY 
    SoldAsVacant
ORDER BY 
    SoldAsVacant

-- PT 2. Setting up the Case Statement
SELECT 
    SoldAsVacant, 
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing

-- PT 3. Updating SoldAsVacant
UPDATE NashvilleHousing
SET SoldAsVacant = 
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'    
        WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing
```

<b>Output after modifying: </b>
```sql
SELECT 
    TOP(10) UniqueID,
    SoldAsVacant
FROM
    NashvilleHousing
```
| UniqueID | SoldAsVacant |
|----------|--------------|
|  29467   |      No      |
|  19805   |      No      |
|  36500   |      Yes      |
|  54583   |      No      |
|  19804   |      Yes      |
|  18367   |      No      |
|  22714   |      No      |
|  43070   |      No      |
|  54582   |      Yes      |
|  16918   |      No      |

## Removing Duplicate rows (CTE)
- Used Common Table Expression to remove duplicates, and checked the modified table to make sure that the duplicates were successfully deleted.
```sql
-- PT 1. Using CTE to remove duplicates
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY 
            ParcelID, 
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

--PT 2. Checker code returns empty table, meaning that the duplicate rows were successfully deleted from the queries above
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY	
            ParcelID,
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

```
## Deletion of unnecessary columns
- Deleted all of the unnecessary columns, for better readability.
```sql
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
```

## Final Cleaned Table
- After all of the process of cleaning, here is the final table.
```sql
SELECT 
    TOP(5) *
FROM 
    NashvilleHousing
```
| UniqueID |   ParcelID   |   LandUse    | SalePrice | LegalReference  | SoldAsVacant |             OwnerName            | Acreage | LandValue | BuildingValue | TotalValue | YearBuilt | Bedrooms | FullBath | HalfBath | SaleDateConverted | PropertySplitAddress | PropertySplitCity | OwnerSplitAddress | OwnerSplitCity | OwnerSplitState |
|----------|--------------|--------------|-----------|-----------------|--------------|---------------------------------|---------|-----------|---------------|------------|-----------|----------|----------|----------|-------------------|----------------------|--------------------|-------------------|----------------|-----------------|
|   2045   | 007 00 0 125 | SINGLE FAMILY| 240000.00 | 20130412-0036474|       0      | FRAZIER, CYRENTHA LYNETTE        | 2.30    | 50000     | 168200        | 235700     | 1986      | 3        | 3        | 0        | 2013-04-09        | 1808 FOX CHASE DR    | GOODLETTSVILLE     | 1808 FOX CHASE DR  | GOODLETTSVILLE | TN              |
|  16918   | 007 00 0 130 | SINGLE FAMILY| 366000.00 | 20140619-0053768|       0      | BONER, CHARLES & LESLIE          | 3.50    | 50000     | 264100        | 319000     | 1998      | 3        | 3        | 2        | 2014-06-10        | 1832 FOX CHASE DR    | GOODLETTSVILLE     | 1832 FOX CHASE DR  | GOODLETTSVILLE | TN              |
|  54582   | 007 00 0 138 | SINGLE FAMILY| 435000.00 | 20160927-0101718|       0      | WILSON, JAMES E. & JOANNE        | 2.90    | 50000     | 216200        | 298000     | 1987      | 4        | 3        | 0        | 2016-09-26        | 1864 FOX CHASE DR    | GOODLETTSVILLE     | 1864 FOX CHASE DR  | GOODLETTSVILLE | TN              |
|  43070   | 007 00 0 143 | SINGLE FAMILY| 255000.00 | 20160129-0008913|       0      | BAKER, JAY K. & SUSAN E.         | 2.60    | 50000     | 147300        | 197300     | 1985      | 3        | 3        | 0        | 2016-01-29        | 1853 FOX CHASE DR    | GOODLETTSVILLE     | 1853 FOX CHASE DR  | GOODLETTSVILLE | TN              |
|  22714   | 007 00 0 149 | SINGLE FAMILY| 278000.00 | 20141015-0095255|       0      | POST, CHRISTOPHER M. & SAMANTHA C.| 2.00    | 50000     | 152300        | 202300     | 1984      | 4        | 3        | 0        | 2014-10-10        | 1829 FOX CHASE DR    | GOODLETTSVILLE     |

# What I learned
Throughout this project, I have significantly enhanced my SQL proficiency with advanced capabilities:

- 🧩**Query Construction for Updates:** 
I have acquired proficiency in updating tables using SQL queries, adeptly transforming data to enhance readability and ensure a more useful format.
- :bulb:**Usage of functions:** During the cleaning process, I utilized a range of functions to significantly improve efficiency. This experience also afforded me the opportunity to expand my skillset by learning and applying functions like ROW_NUMBER() and PARSENAME() to enhance data manipulation techniques.
- :thinking:**Critical Thinking:** 
Engaging in the project enhanced my critical thinking skills by prompting me to evaluate and prioritize optimal modifications over others based on careful consideration and analysis.
<br></br>
# Closing Thoughts
While data cleaning represents just a fraction of the entire data analysis process, this project has paved the way for me to delve deeper into exploring data with a correctly standardized dataset. It has ignited my desire to expand my knowledge in data analytics by delving into BI (Business Intelligence) tools and techniques.
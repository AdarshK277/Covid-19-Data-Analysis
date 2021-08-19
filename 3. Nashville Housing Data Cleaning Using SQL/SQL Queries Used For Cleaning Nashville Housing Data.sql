-- SQL Queries For Cleaning Nashville Housing Data --
/*
## Viewing The Data
*/
SELECT *
FROM NashvilleHousing;



/*
## Standardize The Date Format
*/
SELECT 
	SaleDate, 
	CONVERT(Date, SaleDate) as Std_Date
FROM 
	NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate); /*DOESN'T SEEM TO WORK, So "Improvise, Adapt, and Overcome"*/

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted
FROM NashvilleHousing;



/*
## Populating Property Address Data
*/
SELECT *
FROM
	NashvilleHousing;
--WHERE 
--	PropertyAddress IS NULL;

-- Query to check for NULLs in property address and to create a table comparing `ParcelID` and `PropertyAddress`
SELECT 
	nha.ParcelID, 
	nha.PropertyAddress, 
	nhb.ParcelID,
	nhb.PropertyAddress,
	ISNULL(nha.PropertyAddress, nhb.PropertyAddress)
FROM NashvilleHousing nha
JOIN NashvilleHousing nhb
	ON nha.ParcelID = nhb.ParcelID
	AND nha.[UniqueID ] != nhb.[UniqueID ]
WHERE nha.PropertyAddress IS NULL;

-- Updating a NULL `PropertyAddress` with a `PropertyAddress` associated with the `ParcelID` same as the NULL `PropertyAddress`
UPDATE nha
SET PropertyAddress = ISNULL(nha.PropertyAddress, nhb.PropertyAddress)
FROM NashvilleHousing nha
JOIN NashvilleHousing nhb
	ON nha.ParcelID = nhb.ParcelID
	AND nha.[UniqueID ] != nhb.[UniqueID ];



/*
## Breaking Out Address Into Individual Columns (Address, City, State)
*/
-- Breaking Property Address
SELECT PropertyAddress
FROM NashvilleHousing;

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS [Address] 
	--,CHARINDEX(',', PropertyAddress) AS [CharIndex]
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS [City]
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT *
FROM NashvilleHousing;

-- Breaking Owner Address
SELECT OwnerAddress
FROM NashvilleHousing;

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS [Street],
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS [City],
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS [State]
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3); 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM NashvilleHousing;



/*
## Change "Y" and "N" to "Yes" and "No" in `SoldAsVacant`
*/
SELECT DISTINCT(SoldAsVacant), COUNT(*) AS [Count]
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END AS SoldAsVacantCorrected
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
					WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
				   END



/*
## Remove Duplicates
*/
-- Create a CTE, which is then used to find duplicates
WITH RowNumCTE AS(
SELECT 
	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *   -- Replace by DELETE to delete duplicate rows... This is already done here...
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress



/*
## Delete Unused Columns
*/
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
------------------------------------------------------------------------------

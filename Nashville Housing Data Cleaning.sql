-- Cleaning Data in SQL Queries

SELECT *
FROM Portfolio.dbo.NashvilleHousing



-- Standardize Date Format

SELECT SaleDateConverted, CONVERT (Date, SaleDate)
From Portfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT (Date, SaleDate)

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate)



----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
SELECT *
From Portfolio.dbo.NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b. ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.NashvilleHousing a
JOIN Portfolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.NashvilleHousing a
JOIN Portfolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City. State
SELECT PropertyAddress
From Portfolio.dbo.NashvilleHousing



SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM Portfolio.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM Portfolio.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT OwnerAddress
FROM Portfolio.dbo.NashvilleHousing



SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



SELECT *
FROM Portfolio.dbo.NashvilleHousing



----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Portfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM Portfolio.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



SELECT *
FROM Portfolio.dbo.NashvilleHousing



-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

SELECT *
FROM Portfolio.dbo.NashvilleHousing

ALTER TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate

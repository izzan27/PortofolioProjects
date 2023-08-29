/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortofolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
-- Merubah Format Tanggal

SELECT SaleDateNew --CONVERT(Date,SaleDate)
FROM PortofolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
add SaleDateNew Date;

UPDATE NashvilleHousing
SET SaleDateNew = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
-- Mengisi data PropertyAddress yang bernilai NULL

SELECT *
FROM PortofolioProject..NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, a.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- Memisahkan data PropertyAddress menjadi beberapa kolom (Address, City, State) 

SELECT PropertyAddress
FROM PortofolioProject..NashvilleHousing
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM PortofolioProject..NashvilleHousing




SELECT OwnerAddress
FROM PortofolioProject..NashvilleHousing


SELECT
PARSENAME (REPLACE(OwnerAddress, ',','.') , 3) AS Adress
, PARSENAME (REPLACE(OwnerAddress, ',','.') , 2) AS City
, PARSENAME (REPLACE(OwnerAddress, ',','.') , 1) AS State
FROM PortofolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.') , 3)

ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.') , 2)

ALTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.') , 1)

SELECT *
FROM PortofolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
-- Merubah 'Y' dan 'N' Menjadi 'Yes' dan 'No pada Kolom "Sold as Vacant" 

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortofolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortofolioProject.dbo.NashvilleHousing

UPDATE PortofolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- Menghapus Data duplikat

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				 ) row_num
FROM PortofolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

SELECT *
FROM PortofolioProject.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
-- Menghapus Kolom yang tidak digunakan

SELECT *
FROM PortofolioProject.dbo.NashvilleHousing

ALTER TABLE PortofolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress, SaleDate



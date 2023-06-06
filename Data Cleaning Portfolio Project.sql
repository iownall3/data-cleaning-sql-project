SELECT * 
FROM [Nashville Housing]

--Standardize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate) as UpdatedSaleDate
FROM [Nashville Housing]

UPDATE [Nashville Housing]
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [Nashville Housing]
ADD SaleDateConverted DATE;

UPDATE [Nashville Housing]
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data
SELECT PropertyAddress
FROM [Nashville Housing]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT NASH1.ParcelID, NASH1.PropertyAddress, NASH2.ParcelID, NASH2.PropertyAddress, ISNULL(NASH1.PropertyAddress, NASH2.PropertyAddress)
FROM [Nashville Housing] AS NASH1
	JOIN [Nashville Housing] AS NASH2
	ON NASH1.ParcelID = NASH2.ParcelID
	AND NASH1.[UniqueID ] <> NASH2.[UniqueID ]
WHERE NASH1.PropertyAddress IS NULL 

UPDATE NASH1
SET PropertyAddress = ISNULL(NASH1.PropertyAddress, NASH2.PropertyAddress)
FROM [Nashville Housing] AS NASH1
	JOIN [Nashville Housing] AS NASH2
	ON NASH1.ParcelID = NASH2.ParcelID
	AND NASH1.[UniqueID ] <> NASH2.[UniqueID ]
WHERE NASH1.PropertyAddress IS NULL 


--Breaking out Address into Individual Columns (Address, City, State) using SUBSTRING
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) AS Address,
SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress)+ 1), LEN(PropertyAddress)) AS City
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1)

ALTER TABLE [Nashville Housing]
ADD PropertySplitCity NVARCHAR(255);

UPDATE [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress)+ 1), LEN(PropertyAddress))


--Breaking out OwnerAddress into Individual Columns (Address, City, State) using PARSE
SELECT 
PARSENAME (REPLACE(OwnerAddress, ',' ,'.'), 3) AS Address,
PARSENAME (REPLACE(OwnerAddress, ',' ,'.'), 2) AS City,
PARSENAME (REPLACE(OwnerAddress, ',' ,'.'), 1) AS State
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE [Nashville Housing]
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',' ,'.'), 3)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [Nashville Housing]
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',' ,'.'), 2)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState NVARCHAR(255);

UPDATE [Nashville Housing]
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',' ,'.'), 1)


--Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM [Nashville Housing]

UPDATE [Nashville Housing]
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END


--Remove Duplicates


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
				ORDER BY
					UniqueID) AS row_num
FROM [Nashville Housing]
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--Delete Unused Columns
SELECT *
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Nashville Housing]
DROP COLUMN SaleDate
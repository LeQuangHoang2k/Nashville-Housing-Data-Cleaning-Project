/*
	Cleaning Data in SQL query
*/

-- Standardize Date Format

using		PortfolioProject
SELECT		*
FROM		PortfolioProject.dbo.NashvilleHousing


UPDATE		PortfolioProject.dbo.NashvilleHousing
SET			SaleDate = convert(Date, SaleDate)


ALTER TABLE	PortfolioProject.dbo.NashvilleHousing
ADD			SaleDateConverted DATE


UPDATE		PortfolioProject.dbo.NashvilleHousing
SET			SaleDateConverted = convert(Date, SaleDate)


-- Populate Property Address Data

SELECT		PropertyAddress
FROM		PortfolioProject.dbo.NashvilleHousing
--WHERE		PropertyAddress is null
ORDER BY	ParcelID



SELECT		a.ParcelID, a.PropertyAddress,
			b.ParcelID, b.PropertyAddress,
			isnull(a.PropertyAddress, b.PropertyAddress)
FROM		PortfolioProject.dbo.NashvilleHousing a JOIN PortfolioProject.dbo.NashvilleHousing b
ON			a.ParcelID	=	b.ParcelID AND
			a.UniqueID	<>	b.UniqueID
WHERE		a.PropertyAddress is null

UPDATE		a
SET			PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM		PortfolioProject.dbo.NashvilleHousing a JOIN PortfolioProject.dbo.NashvilleHousing b
ON			a.ParcelID	=	b.ParcelID AND
			a.UniqueID	<>	b.UniqueID
WHERE		a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

SELECT		substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address,
			substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as Address	 
FROM		PortfolioProject.dbo.NashvilleHousing	

ALTER TABLE	PortfolioProject.dbo.NashvilleHousing
ADD			PropertySplitAddress	NVARCHAR(255)

UPDATE		PortfolioProject.dbo.NashvilleHousing
SET			PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

ALTER TABLE	PortfolioProject.dbo.NashvilleHousing
ADD			PropertySplitCity		NVARCHAR(255)

UPDATE		PortfolioProject.dbo.NashvilleHousing
SET			PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

---
SELECT		OwnerAddress
FROM		PortfolioProject.dbo.NashvilleHousing


SELECT		OwnerAddress,
			parsename(replace(OwnerAddress, ',', '.'), 3),
			parsename(replace(OwnerAddress, ',', '.'), 2),
			parsename(replace(OwnerAddress, ',', '.'), 1)
FROM		PortfolioProject.dbo.NashvilleHousing


ALTER TABLE	PortfolioProject.dbo.NashvilleHousing
ADD			OwnerSplitAddress	NVARCHAR(255)

ALTER TABLE	PortfolioProject.dbo.NashvilleHousing
ADD			OwnerSplitCity		NVARCHAR(255)

ALTER TABLE	PortfolioProject.dbo.NashvilleHousing
ADD			OwnerSplitState		NVARCHAR(255)

UPDATE		PortfolioProject.dbo.NashvilleHousing
SET			OwnerSplitAddress	=	parsename(replace(OwnerAddress, ',', '.'), 3)

UPDATE		PortfolioProject.dbo.NashvilleHousing
SET			OwnerSplitCity		=	parsename(replace(OwnerAddress, ',', '.'), 2)

UPDATE		PortfolioProject.dbo.NashvilleHousing
SET			OwnerSplitState		=	parsename(replace(OwnerAddress, ',', '.'), 1)

SELECT		*
FROM		PortfolioProject.dbo.NashvilleHousing

--Change Y & N to Yes & No in "Sold as Vacant" Field

SELECT		distinct(SoldAsVacant), count(SoldAsVacant)
FROM		PortfolioProject.dbo.NashvilleHousing
--WHERE		PropertyAddress is null
GROUP BY	SoldAsVacant
ORDER BY	2



SELECT		SoldAsVacant,
			case 
				when	SoldAsVacant = 'Y' then 'Yes' 
				when	SoldAsVacant = 'N' then 'No' 
				else	SoldAsVacant
			end
FROM		PortfolioProject.dbo.NashvilleHousing
--WHERE		PropertyAddress is null
GROUP BY	SoldAsVacant
ORDER BY	2

ALTER TABLE	PortfolioProject.dbo.NashvilleHousing
ADD			SoldAsVacantEdited	NVARCHAR(255)



SELECT		SoldAsVacant,
			SoldAsVacantEdited =
			case 
				when	SoldAsVacant = 1 then 'Yes'
				when	SoldAsVacant = 0 then 'No'
				else	'No'
			end
FROM		PortfolioProject.dbo.NashvilleHousing


UPDATE		PortfolioProject.dbo.NashvilleHousing
SET			SoldAsVacantEdited =
			case 
				when	SoldAsVacant = 1 then 'Yes'
				when	SoldAsVacant = 0 then 'No'
				else	'No'
			end


SELECT		SoldAsVacant,
			SoldAsVacantEdited
FROM		PortfolioProject.dbo.NashvilleHousing
GROUP BY	SoldAsVacant,
			SoldAsVacantEdited

--Remove Duplicate

--useCTE

WITH			RowNumCTE AS(
	SELECT		*,
				row_number() over(
					partition by	ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
					order by		UniqueID
				) row_num
	FROM		PortfolioProject.dbo.NashvilleHousing
	--ORDER BY	ParcelID
	--WHERE		row_number > 1
)
SELECT		* 
FROM		RowNumCTE
WHERE		row_num > 1
ORDER BY	PropertyAddress




WITH			RowNumCTE AS(
	SELECT		*,
				row_number() over(
					partition by	ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
					order by		UniqueID
				) row_num
	FROM		PortfolioProject.dbo.NashvilleHousing
	--ORDER BY	ParcelID
	--WHERE		row_number > 1
)
DELETE		
FROM		RowNumCTE
WHERE		row_num > 1



--Delete Unused Columns

SELECT		*
FROM		PortfolioProject.dbo.NashvilleHousing

ALTER TABLE	PortfolioProject.dbo.NashvilleHousing
DROP COLUMN	OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE	PortfolioProject.dbo.NashvilleHousing
DROP COLUMN	SaleDate

UPDATE		PortfolioProject.dbo.NashvilleHousing
SET			OwnerSplitAddress	=	parsename(replace(OwnerAddress, ',', '.'), 3)
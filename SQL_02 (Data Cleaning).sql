/*
Cleaning Data in SQL Queries
*/

Select *
From [Portfolio Project ].dbo.['Nashville Housing']
...............................................................................................

-- Standardize Date Format
Select SaleDateConverted, CONVERT(Date,SaleDate)
From [Portfolio Project ].dbo.['Nashville Housing']


Update ['Nashville Housing']
SET SaleDate = CONVERT(Date,SaleDate)

-- If it is unable to update originally
ALTER TABLE ['Nashville Housing']
Add SaleDateConverted Date;

Update ['Nashville Housing']
SET SaleDateConverted = CONVERT(Date,SaleDate)
...............................................................................................

-- Populate Property Address data
Select *
From [Portfolio Project ].dbo.['Nashville Housing']
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project ].dbo.['Nashville Housing'] a
JOIN [Portfolio Project ].dbo.['Nashville Housing'] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project ].dbo.['Nashville Housing'] a
JOIN [Portfolio Project ].dbo.['Nashville Housing'] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
...............................................................................................

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From [Portfolio Project ].dbo.['Nashville Housing']
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [Portfolio Project ].dbo.['Nashville Housing']

ALTER TABLE ['Nashville Housing']
Add PropertySplitAddress Nvarchar(255);

Update ['Nashville Housing']
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE ['Nashville Housing']
Add PropertySplitCity Nvarchar(255);

Update ['Nashville Housing']
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- (To check)
Select*
From [Portfolio Project ].dbo.['Nashville Housing']
...............................................................................................

-- Owner Address
Select OwnerAddress
From [Portfolio Project ].dbo.['Nashville Housing']

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From [Portfolio Project ].dbo.['Nashville Housing']

ALTER TABLE ['Nashville Housing']
Add OwnerSplitAddress Nvarchar(255);

Update ['Nashville Housing']
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE ['Nashville Housing']
Add OwnerSplitCity Nvarchar(255);

Update ['Nashville Housing']
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE ['Nashville Housing']
Add OwnerSplitState Nvarchar(255);

Update ['Nashville Housing']
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- (To check)
Select *
From [Portfolio Project ].dbo.['Nashville Housing']
...............................................................................................

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project ].dbo.['Nashville Housing']
Group By SoldAsVacant
order by 2

Select SoldAsVacant 
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
			When SoldAsVacant = 'N' THEN 'No'
			Else SoldAsVacant
			END
From [Portfolio Project ].dbo.['Nashville Housing']

Update ['Nashville Housing']
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		  When SoldAsVacant = 'N' THEN 'No'
		  ELSE SoldAsVacant
		  END
...............................................................................................

-- Remove Duplicates
WITH RowNumCTE AS(
Select*,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
				     PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID
						) row_num

From [Portfolio Project ].dbo.['Nashville Housing']
)

Select*
FROM RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- (To Check)
Select *
From [Portfolio Project ].dbo.['Nashville Housing']
...............................................................................................

-- Delete Unused Columns
Select *
From [Portfolio Project ].dbo.['Nashville Housing']

ALTER TABLE [Portfolio Project ].dbo.['Nashville Housing']
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
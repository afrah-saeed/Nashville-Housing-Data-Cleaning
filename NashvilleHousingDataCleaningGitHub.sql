/* Cleaning Data in SQL Queries */

Select *
From
PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------

--Standardize Format--

Select SaleDateConverted,CONVERT(Date,SaleDate)
From
PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)

--In case it doesn't update properly:

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate);

---------------------------------------------------------------------------------------

--Populate Property Address Data--

Select *
From
PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress IS NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
From
PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From
PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)--

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select
Substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)) as Address,
CHARINDEX(',',PropertyAddress)

From PortfolioProject.dbo.NashvilleHousing

Select
Substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing;

Select
Parsename(REPLACE(OwnerAddress,',','.'), 3)
,Parsename(REPLACE(OwnerAddress,',','.'), 2)
,Parsename(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = Parsename(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = Parsename(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = Parsename(REPLACE(OwnerAddress,',','.'), 1)

Select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field--

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = 
Case When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

---------------------------------------------------------------------------------------

--Remove Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--Order By ParcelID
)

--DELETE 
--FROM RowNumCTE
--where row_num > 1
--Order by PropertyAddress

--Check:
Select * 
FROM RowNumCTE
where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------

--Delete Unused Columns 

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

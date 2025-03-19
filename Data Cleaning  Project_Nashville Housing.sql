/*

Cleaning Data in SQL Queries

*/


Select *
from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate
from PortfolioProject.dbo.NashvilleHousing

select SaleDate ,Convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SaleDate DATE

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

Select  a.[UniqueID ] ,a.ParcelID, a.PropertyAddress,b.[UniqueID ] ,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where b.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress)) as City
from  PortfolioProject.dbo.NashvilleHousing

Alter TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255),
	PropertySplitCity nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing


select OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerSplitState
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant;


Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
END as Full_SoldAsVacant
from PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
					    when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
				   END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with cte_duplicates as
(
select *,
row_number() OVER(
Partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
order by UniqueID) as row_num
from PortfolioProject.dbo.NashvilleHousing
)
select *
from cte_duplicates
where row_num > 1
order by PropertyAddress


with cte_duplicates as
(
select *,
row_number() OVER(
Partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
order by UniqueID) as row_num
from PortfolioProject.dbo.NashvilleHousing
)
Delete
from cte_duplicates
where row_num > 1
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from  PortfolioProject.dbo.NashvilleHousing

Alter table  PortfolioProject.dbo.NashvilleHousing
Drop column PropertyAddress, OwnerAddress, TaxDistrict

















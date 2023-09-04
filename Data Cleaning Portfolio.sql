Select *
From PortfolioProject..NashvilleHousing
Order by UniqueID
-------------------------------------------------------------------------------------------------------------------------------------------
--Standardize date format

Select SaleDateConverted--, Convert(date, SaleDate)
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SaleDate = Convert(date, Saledate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
Set SaleDateConverted = Convert(date, SaleDate)

-------------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address
Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on  a.ParcelID=b.ParcelID and
		a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on  a.ParcelID=b.ParcelID and
		a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual collumns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID


Select
SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress) - 1 ) as Address,
SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) + 1, LEN(PropertyAddress))
From PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255) ;

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress) - 1 )


Alter table NashvilleHousing
Add PropertyCity nvarchar(255) ;

Update PortfolioProject..NashvilleHousing
Set PropertyCity = SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) + 1, LEN(PropertyAddress))

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2) ,
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing


Alter table NashVilleHousing
Add OwnerStreet nvarchar(255);

Update NashVilleHousing
Set OwnerStreet = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)



Alter table NashvilleHousing
Add OwnerCity nvarchar(255);

Update NashvilleHousing
Set OwnerCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerState nvarchar(255);

Update NashvilleHousing
Set OwnerState= PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select	*
from NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacant

Select	SoldAsVacant,
Case When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
from NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End

-------------------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates
With RowNumCTE as(
Select *,
ROW_NUMBER() Over (
Partition by ParcelID,
			 PropertyAddress,
			 SalePrice, 
			 LegalReference,
			 SaleDate
			 Order by 
				UniqueID) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)

Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


-------------------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Collums

Select * 
From PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
Drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate
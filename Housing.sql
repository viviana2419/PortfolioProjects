Select SaleDateNew, CONVERT(Date, SaleDate)
from [Portfoilo Project].dbo.Housing

Update Housing
set SaleDate=CONVERT(Date, SaleDate)

Alter table Housing
Add SaleDateNew Date;

update Housing
set SaleDateNew = CONVERT(Date, SaleDate)

--property address
Select PropertyAddress
from [Portfoilo Project].dbo.Housing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfoilo Project].dbo.Housing a
join [Portfoilo Project].dbo.Housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfoilo Project].dbo.Housing a
join [Portfoilo Project].dbo.Housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--3. breaking out address into indiv colm


select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) Ad,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) City
from [Portfoilo Project].dbo.Housing

Alter table Housing
Add PropertySplitAd Nvarchar(255);

Update Housing
set PropertySplitAd=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter table Housing
Add PropertySplitCity Nvarchar(255);

Update Housing
set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

--4. modify with parsename
Select *
from [Portfoilo Project].dbo.Housing

Select PARSENAME(replace (owneraddress,',','.'),3),
 PARSENAME(replace (owneraddress,',','.'),2),
 PARSENAME(replace (owneraddress,',','.'),1)
from [Portfoilo Project].dbo.Housing

Alter table [Portfoilo Project].dbo.Housing
Add OwnerSplitAd Nvarchar(255);

Alter table [Portfoilo Project].dbo.Housing
Add OwnerSplitCity Nvarchar(255);

Alter table [Portfoilo Project].dbo.Housing
Add OwnerSplitState Nvarchar(255);

Update [Portfoilo Project].dbo.Housing
set OwnerSplitAd=PARSENAME(replace (owneraddress,',','.'),3)

Update [Portfoilo Project].dbo.Housing
set OwnerSplitCity= PARSENAME(replace (owneraddress,',','.'),2)

Update [Portfoilo Project].dbo.Housing
set OwnerSplitState= PARSENAME(replace (owneraddress,',','.'),1)

--5. Change Y&N to yes and no in "sold as vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from [Portfoilo Project].dbo.Housing
group by SoldAsVacant
order by 2

select SoldAsVacant, case when SoldAsVacant ='Y' then 'Yes'
when SoldAsVacant ='N' then 'No' 
else SoldAsVacant end
from [Portfoilo Project].dbo.Housing

Update [Portfoilo Project].dbo.Housing
set SoldAsVacant= case when SoldAsVacant ='Y' then 'Yes'
when SoldAsVacant ='N' then 'No' 
else SoldAsVacant end

--6. remove duplicate
with RowNumCTE as(
select *,
ROW_NUMBER( ) over ( partition by ParcelID, Pro order by UniqueID) row_num
from [Portfoilo Project].dbo.Housing
)
select *
from RowNumCTE
where row_num>1
order by PropertyAddress

--7. delete unused columns
select *
from [Portfoilo Project].dbo.Housing

Alter table [Portfoilo Project].dbo.Housing
drop column SaleDate
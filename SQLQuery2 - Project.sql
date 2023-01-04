--Data Cleaning

Select * from [Portfolio Porject].[dbo].NashvilleHousing


------------------------------------------------------------------------------
--Standardize Date Format
----The time mentioned in the date is no use for us so lets extract it.


Select SaleDate, CONVERT(date,saledate),salesdateconverted 
from [Portfolio Porject].[dbo].NashvilleHousing

--tried to change the date formate using update but it didn't worked so addign the another column and updating that one

alter table [Portfolio Porject].[dbo].NashvilleHousing
add salesdateconverted date;

update NashvilleHousing
set salesdateconverted = CONVERT(date,saledate)

----dateformate has been changed

------------------------------------------------------------------
--Popullar property adress data
--By analysing data got to know that the once parcel ID cotains a unique add and those parcelID is being repeated again and agian is getting null vaues

---Finding out which parcelid had what add and filling that value at the palce of null value

Select * from [Portfolio Porject].[dbo].NashvilleHousing
--where PropertyAddress is not  null 
order by ParcelID

--- joinning the same table to itself where primary key will be parcel id but unique ID will not be equal this way, am able to compare both add and parcel id together
--- By using #isnull function replaceing null value buy the specified address


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,isnull(a.propertyaddress,b.PropertyAddress) 
from [Portfolio Porject].[dbo].NashvilleHousing a
join [Portfolio Porject].[dbo].NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update A                   ---- using alias as above join is used and will use join to update the table         
set PropertyAddress = isnull(a.propertyaddress,b.PropertyAddress)   
from [Portfolio Porject].[dbo].NashvilleHousing a    --- using this bcz we have to specify that replacing value is coming form where? 
join [Portfolio Porject].[dbo].NashvilleHousing b    ---this can be called as substing
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null                  -----only make the changed where value is null


select * from NashvilleHousing
where PropertyAddress is not null


------------------------------------------------------------------------------------------------------
---breaking out the address into individual column (Address, city, State)



Select propertyaddress from [Portfolio Porject].[dbo].NashvilleHousing

--Break into address and city
select 
SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1) as Address,
SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,LEN(propertyaddress)) as City
from NashvilleHousing

---add new address column
alter table nashvillehousing
add Address nvarchar(255);


--update the value in the column
update NashvilleHousing
set Address = SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1) 


--- Add city column 
alter table Nashvillehousing
add city nvarchar(255)

----update city column
update NashvilleHousing
set City = SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,LEN(propertyaddress))


select OwnerAddress from NashvilleHousing	

select 
PARSENAME(replace(owneraddress,',', '.') , 1), 
PARSENAME(replace(owneraddress,',', '.') , 2), 
PARSENAME(replace(owneraddress,',', '.') , 3) 

from NashvilleHousing


---add new address column
alter table nashvillehousing
add Owner__address nvarchar(255);


--update the value in the column
update NashvilleHousing
set owner__Address = PARSENAME(replace(owneraddress,',', '.') , 3)

--- Add city column 
alter table Nashvillehousing
add Owner__city nvarchar(255)

----update city column
update NashvilleHousing
set Owner__City = PARSENAME(replace(owneraddress,',', '.') , 2)


--- Add State column 
alter table Nashvillehousing
add Owner__State nvarchar(255)

----update city column
update NashvilleHousing
set Owner__State = PARSENAME(replace(owneraddress,',', '.') , 1)


Select * from NashvilleHousing


-----------------------------------------------------------------

---Change Y and N to Yes and nO=o in sold as vacant

select distinct(SoldAsVacant),COUNT(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,

case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'NO'
else SoldAsVacant
end

from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'NO'
else SoldAsVacant
end

--------------------------------------------------------------------------------------
-----Remove duplicate

with RowNumCTE as(
select *
,row_number() over( 

partition By parceliD, propertyaddress,saleprice,saledate,legalreference order by uniqueID) as rowid

from NashvilleHousing
--order by ParcelID
)


select * 
from RowNumCTE
order by PropertyAddress

-----------------------------------------------------------------------------------------
--Delete unused Column


select * from NashvilleHousing

alter table nashvillehousing
drop column owneraddress,taxdistrict,propertyaddress

alter table nashvillehousing
drop column saledate




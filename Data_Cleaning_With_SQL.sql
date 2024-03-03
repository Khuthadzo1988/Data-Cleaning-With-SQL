 SELECT *
 FROM [master].[dbo].[Nashville Housing Data for Data Cleaning]
 --where PropertyAddress is NULL


 ---------------------------------------------------------------------------------------------------------------------------------------------------
  
  --Standardize Date Format from "month day, yyyy" (i.e Jan 1, 2024) to yyyy-m-d (2024-01-01)
  
  SELECT try_CAST(SaleDate AS date)
  FROM [master].[dbo].[Nashville Housing Data for Data Cleaning]

  update [Nashville Housing Data for Data Cleaning]
  set SaleDate = try_CAST(SaleDate AS date)

 ---------------------------------------------------------------------------------------------------------------------------------------------------

 --Populate Property Address data
 --Property Address Column to be deleted later

 SELECT *
  FROM [master].[dbo].[Nashville Housing Data for Data Cleaning]
  where PropertyAddress is null
 -- order by ParcelID


 SELECT A.PropertyAddress, A.ParcelID, B.PropertyAddress, B.ParcelID, ISNULL(A.PropertyAddress, B.PropertyAddress)
 FROM [master].[dbo].[Nashville Housing Data for Data Cleaning] A 
 JOIN [master].[dbo].[Nashville Housing Data for Data Cleaning] B 
    on A.ParcelID = B.ParcelID
    AND A.UniqueID <> B.UniqueID
 where A.PropertyAddress is NULL

 update A 
 set PropertyAddress =  ISNULL(A.PropertyAddress, B.PropertyAddress)
  FROM [master].[dbo].[Nashville Housing Data for Data Cleaning] A 
  JOIN [master].[dbo].[Nashville Housing Data for Data Cleaning] B 
    on A.ParcelID = B.ParcelID
    AND A.UniqueID <> B.UniqueID
 where A.PropertyAddress is NULL

 ---------------------------------------------------------------------------------------------------------------------------------------------------
 --Splitting Property Address into Individual Columns (Street Address and City)

 SELECT PropertyAddress
 FROM [master].[dbo].[Nashville Housing Data for Data Cleaning]
  

 SELECT
 SUBSTRING(PropertyAddress, 1, case when CHARINDEX(',', PropertyAddress) = 0 then LEN(PropertyAddress) 
 else CHARINDEX (',', PropertyAddress) -1 end) as Street_address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City_address
 FROM  [master].[dbo].[Nashville Housing Data for Data Cleaning]


 alter table [Nashville Housing Data for Data Cleaning]
 add PropertySplitAddress NVARCHAR (255)

 update [Nashville Housing Data for Data Cleaning]
 set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, case when CHARINDEX(',', PropertyAddress) = 0 then LEN(PropertyAddress) 
 else CHARINDEX (',', PropertyAddress) -1 end)

 
 alter table [Nashville Housing Data for Data Cleaning]
 add PropertySplitCity NVARCHAR (255)

 update [Nashville Housing Data for Data Cleaning]
 set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

 select *
 FROM  [master].[dbo].[Nashville Housing Data for Data Cleaning]

 -- a simpler way of splitting the property address is to use Parsename

 select 
 PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2),
 PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)
 FROM [master].[dbo].[Nashville Housing Data for Data Cleaning]

 alter table [Nashville Housing Data for Data Cleaning]
 add PropertySplitAddress_2 NVARCHAR (255)

 update [Nashville Housing Data for Data Cleaning]
 set PropertySplitAddress_2 = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)

 alter table [Nashville Housing Data for Data Cleaning]
 add PropertySplitCity_2 NVARCHAR (255)

 update [Nashville Housing Data for Data Cleaning]
 set PropertySplitCity_2 = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)

  select *
 FROM  [master].[dbo].[Nashville Housing Data for Data Cleaning]

 ---------------------------------------------------------------------------------------------------------------------------------------------------
 --Splitting owners Address into Individual Columns (Street Address, City and state)

 SELECT 
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
 FROM [master].[dbo].[Nashville Housing Data for Data Cleaning]

 alter table [Nashville Housing Data for Data Cleaning]
 add OwnerSplitAddress NVARCHAR (255)

 update [Nashville Housing Data for Data Cleaning]
 set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

 alter table [Nashville Housing Data for Data Cleaning]
 add OwnerSplitCity NVARCHAR (255)

 update [Nashville Housing Data for Data Cleaning]
 set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

  alter table [Nashville Housing Data for Data Cleaning] 
 add OwnerSplitState NVARCHAR (255)

 update [Nashville Housing Data for Data Cleaning]
 set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


 ---------------------------------------------------------------------------------------------------------------------------------------------------

 -- Change Y and N to Yes and No in "Sold as Vacant" field
 -- First do a distinct count to see 

 select Distinct(SoldAsVacant), count(SoldAsVacant)
 FROM  [master].[dbo].[Nashville Housing Data for Data Cleaning]
 group by SoldAsVacant
 order by 2 DESC

 --replace the Y and N with Yes and No respectively

 SELECT SoldAsVacant,
 CASE when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
      else SoldAsVacant --if its already a No or Yes leave it
      END
 FROM  [master].[dbo].[Nashville Housing Data for Data Cleaning]

 UPDATE [master].[dbo].[Nashville Housing Data for Data Cleaning]
 SET SoldAsVacant =  CASE when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
      else SoldAsVacant --if its already a No or Yes leave it
      END

 ---------------------------------------------------------------------------------------------------------------------------------------------------
 --Remove Duplicates in the data 

 --Create a CTE statement

 with RowNumCTE as (
 SELECT*,
 ROW_NUMBER() over (
    PARTITION by ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 order by
                  UniqueID) row_num
 FROM  [master].[dbo].[Nashville Housing Data for Data Cleaning]
 --order by ParcelID 
 )

 Delete 
 From RowNumCTE
 where row_num > 1
 --order by PropertyAddress


 ---------------------------------------------------------------------------------------------------------------------------------------------------
 --Delete Unused and duplicate Columns

 select *
 FROM  [master].[dbo].[Nashville Housing Data for Data Cleaning]


 alter table [Nashville Housing Data for Data Cleaning]
 DROP column PropertyAddress, OwnerAddress, TaxDistrict, PropertySplitAddress_2, PropertySplitCity_2
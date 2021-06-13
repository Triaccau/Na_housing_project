-- Adjustment to the date format (delete time information)

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM Nashville_housing;

ALTER TABLE Nashville_housing
ADD SaleDateConverted DATE;

UPDATE Nashville_housing
SET SaleDateConverted = CONVERT(DATE, SaleDate);


-- Completing property address where it is NULL (populating using reference)

SELECT A.PropertyAddress, A.ParcelID, B.PropertyAddress, B.ParcelID, ISNULL(A.PropertyAddress, B.PropertyAddress) 
FROM Nashville_housing AS A
JOIN Nashville_housing AS B
    ON A.ParcelID = B.ParcelID
    AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress) 
FROM Nashville_housing AS A
JOIN Nashville_housing AS B
    ON A.ParcelID = B.ParcelID
    AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;


-- Separate from the column property address the name of the city

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Nashville_housing;

ALTER TABLE Nashville_housing
ADD PropertySplitAddress VARCHAR(200);

ALTER TABLE Nashville_housing
ADD PropertySplitCity VARCHAR(200);

UPDATE Nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

UPDATE Nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));


-- Separate from the column owner address the name of the city and the state

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Nashville_housing;

ALTER TABLE Nashville_housing
ADD OwnerSplitAddress VARCHAR(200);

ALTER TABLE Nashville_housing
ADD OwnerSplitCity VARCHAR(200);

ALTER TABLE Nashville_housing
ADD OwnerSplitState VARCHAR(200);

UPDATE Nashville_housing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE Nashville_housing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE Nashville_housing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


-- Modify column Sold (From Y-N to Yes-No)

SELECT SoldAsVacant,
       CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	        WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant 
			END
FROM Nashville_housing;

UPDATE Nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	        WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant 
			END;


-- Removing duplicates rows from the table

WITH CTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) RW
FROM Nashville_housing)

SELECT *
FROM CTE
WHERE RW > 1;

WITH CTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) RW
FROM Nashville_housing)

DELETE
FROM CTE
WHERE RW > 1;


-- 1 
select power_plants.PlantName, countries.CountryName, operators.OperatorName, fuel_types.FuelCategory,  
		fuel_types.FuelName, power_plants.CapacityMW, power_plants.CommissionYear
from power_plants
	inner join countries on power_plants.CountryCode = countries.CountryCode
    inner join operators on power_plants.OperatorID = operators.OperatorID
    inner join fuel_types on power_plants.FuelID = fuel_types.FuelID
order by power_plants.CapacityMW desc;

-- 2
select power_plants.PlantName, power_plants.CountryCode,
		generation_records.year, generation_records.generationgwh
from power_plants
	inner join generation_records on power_plants.PlantID = generation_records.plantid
order by generation_records.generationgwh desc;

-- 3
select power_plants.PlantID, power_plants.CountryCode, generation_records.year,
		generation_records.year, emission_metrics.co2emmisonstonnes
from power_plants
	inner join generation_records on power_plants.PlantID = generation_records.plantid
    inner join emission_metrics on power_plants.PlantID = emission_metrics.plantid
order by emission_metrics.co2emmisonstonnes asc;

-- 4 (each operator we'll see
with totalgenerationgwh as (
	select operators.OperatorID as operatorid, generation_records.generationgwh
    from power_plants
		inner join operators on power_plants.OperatorID = operators.OperatorID
        inner join generation_records on power_plants.PlantID = generation_records.plantid
)
select operators.OperatorName, operators.HeadquartersCountry, totalgenerationgwh.total
from operators
	inner join totalgenerationgwh on operators.OperatorID = totalgenerationgwh.operatorid
order by totalgenerationgwh.total desc;
-- table creation so diagram is possible
create table countries (
	countrycode varchar(3),
    countryname varchar(15),
    continent varchar(15),
    primary key (countrycode)
);
insert into countries 
	values ('USA','United States','North America'),
    ('CAN','Canada','North America'),
    ('DEU','Germany','Europe'),
    ('IND','India','Asia'),
    ('BRA','Brazil','South America'),
    ('JPN','Japan','Asia'),
    ('AUS','Australia','Oceania'),
    ('ZAF','South Africa','Africa'),
    ('GBR','United Kingdom','Europe'),
    ('CHN','China','Asia');
create table operators (
	operatorid numeric(3,0),
    operatorname varchar(20),
    HeadquartersCountry varchar(3),
    primary key (operatorid)
);
insert into operators
	values (101,'Global Hydro Inc','USA'),
    (102,'Rhein Power AG','DEU'),
    (103,'NTPC Limited','IND'),
    (104,'Electrobras','BRA'),
    (105,'Tepco Energy','JPN'),
    (106,'Snowy Hydro','AUS'),
    (107,'Eskom Holdings','ZAF'),
    (108,'China Yangtze Power','CHN');
create table fuel_types (
	fuelid numeric(1,0),
    fuelcategory varchar(10),
    fuelname varchar(10),
    primary key (fueliD)
);
insert into fuel_types
	values (1,'Renewable','Hydro'),
    (2,'Fossil','Coal'),
    (3,'Nuclear','Uranium'),
    (4,'Fossil','Gas'),
    (5,'Renewable','Solar');
create table power_plants (
	plantid numeric(1,0) primary key,
    plantname varchar(20),
    countrycode varchar(3),
    operatorid numeric(3,0),
    fuelid numeric(1,0),
    capacitymw numeric(10,0),
    commissionyear numeric(4,0),
    foreign key (countrycode) references countries(countrycode),
    foreign key (operatorid) references operators(operatorid),
    foreign key (fuelid) references fuel_types(fuelid)
);
insert into power_plants 
	values (1,'Grand Coulee','USA',101,1,6809,1942),
    (2,'Janschwalde','DEU',102,2,3000,1981),
    (3,'Vindhyachal','IND',103,2,4760,1987),
    (4,'Itaipu','BRA',104,1,14000,1984),
    (5,'Kashiwazaki-Kariwa','JPN',105,3,8212,1985),
    (6,'Loy Yang','AUS',106,2,2210,1984),
    (7,'Three Gorges','CHN',108,1,22500,2003),
    (8,'Tuoketuo','CHN',108,2,13200,1995);
create table generation_records (
	plantid numeric(1,0),
    year numeric(4,0),
    generationgwh numeric(10,2),
    primary key (plantid, year),
    foreign key (plantid) references power_plants(plantid)
);
insert into generation_records
	values (1,2024,21500.50),
    (2,2024,18400.20),
    (3,2024,35600.80),
    (4,2024,89000.10),
    (5,2024,0.00),
    (6,2024,14200.40),
    (7,2024,98800.00),
    (8,2024,71000.30);
create table emission_metrics (
	plantid numeric(1,0),
    year numeric(4,0),
    co2emissionstonnes numeric(10,2)
);
insert into emission_metrics
	values (1,2024,0.00),
    (2,2024,2450000.00),
    (3,2024,3100000.00),
    (4,2024,0.00),
    (5,2024,0.00),
    (6,2024,1950000.00),
    (7,2024,0.00),
    (8,2024,5200000.00);
-- 1 
select power_plants.plantname, countries.countryname, operators.operatorname, fuel_types.fuelcategory,  
		fuel_types.fuelname, power_plants.capacitymw, power_plants.commissionyear
from power_plants
	inner join countries on power_plants.countrycode = countries.countrycode
    inner join operators on power_plants.operatorid = operators.operatorid
    inner join fuel_types on power_plants.fuelid = fuel_types.fuelid
order by power_plants.capacitymw desc;

-- 2
select power_plants.plantname, power_plants.countrycode,
		generation_records.year, generation_records.generationgwh
from power_plants
	inner join generation_records on power_plants.plantid = generation_records.plantid
order by generation_records.generationgwh desc;

-- 3
select power_plants.plantid, power_plants.countrycode, generation_records.year,
		generation_records.year, emission_metrics.co2emissionstonnes
from power_plants
	inner join generation_records on power_plants.plantid = generation_records.plantid
    inner join emission_metrics on power_plants.plantid = emission_metrics.plantid
order by emission_metrics.co2emissionstonnes asc;

-- 4 
with operatorgeneration as (
	select operators.operatorname, operators.headquarterscountry,
			sum(generation_records.generationgwh) as total
    from power_plants
		inner join operators on power_plants.operatorid = operators.operatorid
        inner join generation_records on power_plants.plantid = generation_records.plantid
	group by operators.operatorname, operators.headquarterscountry
)
select OperatorName, headquarterscountry, total
from operatorgeneration
order by total desc;

-- 5 (an attempt)
with operatorgeneration as (
	select sum(generation_records.generationgwh) as total
    from power_plants
        inner join generation_records on power_plants.plantid = generation_records.plantid
	group by power_plants.countrycode
),
CO2emissions as (
	select sum(emission_metrics.co2emissionstonnes) as total_co2
    from power_plants
        inner join emission_metrics on power_plants.plantid = emission_metrics.plantid
	group by power_plants.countrycode
)
select countries.CountryName, total, total_co2
from countries
	inner join operatorgeneration on countries.countrycode = operatorgeneration.countrycode
    inner join CO2emissions on countries.countrycode = CO2emissions.countrycode
order by total desc;
-- table creation so diagram is possible
create table countries (
	countrycode varchar(3) primary key,
    countryname varchar(20),
    continent varchar(20)
);
insert into countries
	values ('USA','United States','North America'),
    ('RUS','Russia','Europe'),
    ('FRA','France','Europe'),
    ('IND','India','Asia'),
    ('CHN','China','Asia'),
    ('JPN','Japan','Asia'),
    ('NZL','New Zealand','Oceania'),
    ('GBR','United Kingdom','Europe');

create table organizations (
	orgid numeric(3,0) primary key,
    orgname varchar(50),
    headquarterscountry varchar(3),
    orgtype varchar(10)
);
insert into organizations
	values (201,'National Aeronautics and Space Administration','USA','Government'),
    (202,'Space Exploration Technologies Corp','USA','Private'),
    (203,'Roscosmos State Corporation','RUS','Government'),
    (204,'Indian Space Research Organisation','IND','Government'),
    (205,'China National Space Administration','CHN','Government'),
    (206,'Arianespace','FRA','Private'),
    (207,'Rocket Lab','NZL','Private'),
    (208,'Japan Aerospace Exploration Agency','JPN','Government');

create table launch_sites (
	siteid numeric(3,0) primary key,
    sitename varchar(40),
    countrycode varchar(3),
    status varchar(10),
    foreign key (countrycode) references countries(countrycode)
);
insert into launch_sites 
	values (301,'Kennedy Space Center','USA','Active'),
    (302,'Baikonur Cosmodrome','RUS','Active'),
    (303,'Guiana Space Centre','FRA','Active'),
    (304,'Satish Dhawan Space Centre','IND','Active'),
    (305,'Jiuquan Satellite Launch Center','CHN','Active'),
    (306,'Tanegashima Space Center','JPN','Active'),
    (307,'Mahia Launch Complex 1','NZL','Active'),
    (308,'Vandenberg Space Force Base','USA','Active');
    
create table rockets (
	rocketid numeric(3,0) primary key,
    rocketname varchar(20),
    orgid numeric(3,0),
    payloadcapacitykg numeric(10,0),
    operationalstatus varchar(7),
    foreign key (orgid) references organizations(orgid)
);
insert into rockets
	values (401,'Falcon 9',202,22800,'Active'),
    (402,'Saturn V',201,140000,'Retired'),
    (403,'Proton-M',203,23000,'Active'),
    (404,'PSLV',204,3800,'Active'),
    (405,'Long March 2F',205,8400,'Active'),
    (406,'H-IIB',208,19000,'Retired'),
    (407,'Electron',207,300,'Active'),
    (408,'Ariane 5',206,20000,'Retired');
    
create table missions (
	missionid numeric(1,0) primary key,
    missionname varchar(20),
    rocketid numeric(3,0),
    siteid numeric(3,0),
    destination varchar(5),
    launchyear numeric(4,0),
    outcome varchar(10),
    foreign key (rocketid) references rockets(rocketid),
    foreign key (siteid) references launch_sites(siteid)
);
insert into missions
	values (1,'Artemis I',402,301,'Moon',2024,'Success'),
    (2,'Crew-8',401,301,'ISS',2024,'Success'),
    (3,'Gaganyaan Test',404,304,'LEO',2024,'Success'),
    (4,"Chang'e 6",405,305,'Moon',2024,'Success'),
    (5,'Progress MS-27',403,302,'ISS',2024,'Success'),
    (6,'HTV-X1 Test',406,306,'ISS',2024,'Success'),
    (7,'StriX-1',407,307,'LEO',2024,'Success'),
    (8,'Sentinel-6B',401,308,'LEO',2024,'Success');

create table payloads (
	payloadid numeric(1,0) primary key,
    missionid numeric(1,0),
    payloadname varchar(40),
    payloadtype varchar(15),
    masskg numeric(10,2),
    foreign key (missionid) references missions(missionid)
);
insert into payloads 
	values (1,1,'Orion MPCV','Crew Capsule',25800.00),
    (2,2,'Dragon Endeavour','Crew Capsule',12500.00),
    (3,3,'Vyommitra Prototype','Robotics',150.00),
    (4,4,'Queqiao-2 Relay','Satellite',1200.00),
    (5,5,'Progress Cargo Supply','Cargo',2450.00),
    (6,6,'HTV-X Cargo Transporter','Cargo',6000.00),
    (7,7,'StriX-1 Synthetic Aperture Radar','Satellite',100.00),
    (8,8,'Sentinel-6B Altimetry Satellite','Satellite',1192.00);

-- 1
select missions.missionname, rockets.rocketname, organizations.orgname, launch_sites.sitename, 
		missions.destination, missions.launchyear, missions.outcome
from missions
	inner join rockets on missions.rocketid = rockets.rocketid
    inner join launch_sites on missions.siteid = launch_sites.siteid
    inner join organizations on rockets.orgid = organizations.orgid
order by missions.launchyear desc, missions.missionname asc;

-- 2
select missions.missionname, rockets.rocketname, payloads.payloadname,
		payloads.payloadtype, payloads.masskg
from payloads
	inner join missions on missions.missionid = payloads.missionid
    inner join rockets on missions.rocketid = rockets.rocketid
order by payloads.masskg desc;

-- 3
select launch_sites.sitename, missions.missionname, rockets.rocketname, missions.launchyear
from launch_sites
	left join missions on launch_sites.siteid = missions.siteid
    left join rockets on missions.rocketid = rockets.rocketid
order by launch_sites.sitename asc;

-- 4
with payloadmass as (
	select organizations.orgname, organizations.headquarterscountry, organizations.orgtype,
			sum(payloads.masskg) as total
	from organizations
		inner join rockets on organizations.orgid = rockets.orgid
        inner join missions on missions.rocketid = rockets.rocketid
        inner join payloads on payloads.missionid = missions.missionid
	group by organizations.orgname, organizations.headquarterscountry, organizations.orgtype
)
select orgname, headquarterscountry, orgtype, total
from payloadmass
order by total desc;

-- 5
with missionsbycc as (
	select launch_sites.countrycode, sum(missions.missionid) as totalmissions
    from missions
		inner join launch_sites on missions.siteid = launch_sites.siteid
	group by launch_sites.countrycode
),
payloadmass as (
	select launch_sites.countrycode, sum(payloads.masskg) as totalpayload
    from payloads
		inner join missions on missions.missionid = payloads.missionid
        inner join launch_sites on missions.siteid = launch_sites.siteid
	group by launch_sites.countrycode
)
select countries.countryname, totalmissions, totalpayload
from countries
	inner join missionsbycc on missionsbycc.countrycode = countries.countrycode
    inner join payloadmass on payloadmass.countrycode = countries.countrycode
group by countries.countrycode
order by totalpayload desc;
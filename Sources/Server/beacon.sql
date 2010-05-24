-- beacon.sql

create table if not exists signals (
  id                    int not null primary key auto_increment,
  createDate            timestamp not null,
  ip                    varchar(15) not null,
  deviceJailbroken      tinyint(1) not null,
  deviceIdentifier      varchar(64) not null,
  deviceModel           varchar(32) not null,
  deviceSystemVersion   varchar(8) not null,
  applicationVersion    varchar(8) not null,
  applicationIdentifier varchar(255) not null,
  hardwareMachine       varchar(32) not null,
  hardwareModel         varchar(32) not null
);

create table if not exists devices (
  id                    varchar(40) not null unique primary key,
  description           varchar(255) not null
);

select signals.*,devices.description as deviceDescription
	from signals
		left join (devices) on (signals.deviceIdentifier = devices.id);

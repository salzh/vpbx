require '../api/include.pl';

@sql = (
'create table v_unopbx_inbound (
    dialplan_uuid char(36) not null,
    dialplan_name char(255) not null,
    condition_field_1 char(50) not null,
    condition_expression_1 char (50) not null,
    condition_field_2 char(50),
    condition_expression_2 char(50),
    action_1  char (255),
    action_2 char(255),
    `limit` int,
    dialplan_enabled char(10),
    dialplan_description char(255),
    domain_uuid char(50),
    primary key(dialplan_uuid)
);',

'create table v_unopbx_outbound (
    dialplan_uuid char(36) not null,
    gateway char(100),
    gateway_2 char(100),
    gateway_3 char(100),
    dialplan_expression char(50),
    prefix_number char(10),
    `limit` int,
    accountcode char(50),
    dialplan_enabled char(10),
    domain_uuid char(50),
    primary key(dialplan_uuid)
);',
'create table v_unopbx_timecondition (
    dialplan_uuid char(36) not null,
    dialplan_name char(100),
    condition_mday char(50),
    condition_wday char(50),
    condition_minute_of_day char(50),
    condition_mon char(50),
    condition_mweek char(50),
    condition_yday char(50),
    condition_hour char(50),
    condition_minute char(50),
    condition_week char(50),
    condition_year char(50),
    action_1 char(255),
    anti_action_1 char(255),
    dialplan_enabled char(10),
    dialplan_description char(255),
    domain_uuid char(50),
    primary key(dialplan_uuid)
);'
);

for (@sql) {
    &database_do($_);
}

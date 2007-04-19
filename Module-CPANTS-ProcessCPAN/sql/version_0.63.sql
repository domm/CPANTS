alter table dist add file_license integer not null default 0;
alter table kwalitee add metayml_conforms_spec integer not null default 0;
alter table kwalitee add metayml_has_license integer not null default 0;
alter table kwalitee rename has_license to has_humanreadable_license;
#
alter table dist add metayml_error text;
alter table kwalitee rename metayml_conforms_spec to metayml_conforms_spec_1_2;
alter table kwalitee add metayml_conforms_spec_1_0 integer not null default 0;
#
alter table kwalitee rename metayml_conforms_spec_1_2 to metayml_conforms_spec_current;


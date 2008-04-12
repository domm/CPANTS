alter table kwalitee add has_separate_license_file integer not null default 0;
alter table kwalitee add has_license_in_source_file integer not null default 0;
alter table kwalitee add metayml_has_provides integer not null default 0;
alter table dist add external_license_file text;
alter table dist add file_licence text;
alter table dist add licence_file text;
alter table dist add license_file text;
alter table dist add file_license text;
alter table dist add license_type text;


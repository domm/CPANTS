alter table kwalitee add uses_test_nowarnings integer not null default 0;
alter table kwalitee add latest_version_distributed_by_debian integer not null default 0;
alter table kwalitee add has_no_bugs_reported_in_debian integer not null default 0;
alter table kwalitee add has_no_patches_in_debian integer not null default 0;
alter table kwalitee add distributed_by_debian integer not null default 0;

alter table dist add license_in_pod integer not null default 0;
alter table dist add license_from_yaml text;
alter table dist add license_from_external_license_file text;
alter table dist add test_files_list text;

alter table error add has_no_patches_in_debian text;
alter table error add latest_version_distributed_by_debian text;
alter table error add has_no_bugs_reported_in_debian text;

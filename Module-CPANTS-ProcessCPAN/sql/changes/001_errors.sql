alter table error drop column pod;
alter table error RENAME column metayml_parse to metayml_is_parsable;
alter table error RENAME column metayml to metayml_conforms_to_known_spec;
alter table error RENAME column pod_message to no_pod_errors;
alter table error RENAME column prereq to prereq_matches_use;
alter table error RENAME column build_prereq to build_prereq_matches_use;



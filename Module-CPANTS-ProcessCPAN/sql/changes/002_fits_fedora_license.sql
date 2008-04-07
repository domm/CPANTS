alter table kwalitee add fits_fedora_license integer not null default 0;
alter table kwalitee add metayml_declares_perl_version integer not null default 0;
alter table error add easily_repackageable_by_fedora text;
alter table error add metayml_conforms_spec_current text;

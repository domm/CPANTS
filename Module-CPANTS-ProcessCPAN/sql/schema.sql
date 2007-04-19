
BEGIN;

create table run (
   id serial primary key,
   version text,
   available_kwalitee integer not null default 0,
   date timestamp
);


create table author (
   id serial primary key,
   pauseid text UNIQUE,
   name text,
   email text,
   average_kwalitee numeric,
   num_dists integer,
   rank integer,
   prev_av_kw numeric,
   prev_rank integer
);
create index auth_av on author(average_kwalitee);
create index auth_num on author(num_dists);
create index auth_rank on author(rank);
create index auth_pav on author(prev_av_kw);
create index auth_prank on author(prev_rank);

create table author_history (
   id serial primary key,
   run integer references run (id),
   author integer references author (id),
   average_kwalitee numeric,
   num_dists integer,
   rank integer
);
create index auth_hist_av on author_history(average_kwalitee);
create index auth_hist_num on author_history(num_dists);
create index auth_hist_rank on author_history(rank);

create table dist (
   id serial primary key,
   run integer references run (id) ON DELETE SET NULL;, 
   dist text UNIQUE,
   package text UNIQUE,
   vname text UNIQUE,
   author integer references author (id) ON DELETE CASCADE,
   version text,
   version_major text,
   version_minor text,
   extension text,
   extractable integer not null default 0,
   extracts_nicely integer not null default 0,
   size_packed integer not null default 0,
   size_unpacked integer not null default 0,
   released timestamp,
   cpants_errors text,
   files integer not null default 0,
   files_list text,
   dirs integer not null default 0,
   dirs_list text,
   symlinks integer not null default 0,
   symlinks_list text,
   bad_permissions integer not null default 0,
   bad_permissions_list text,
   file_makefile_pl integer not null default 0,
   file_build_pl integer not null default 0,
   file_readme integer not null default 0,
   file_manifest integer not null default 0,
   file_meta_yml integer not null default 0,
   file_signature integer not null default 0,
   file_ninja integer not null default 0,
   file_test_pl integer not null default 0,
   file_changelog text,
   dir_lib integer  not null default 0,
   dir_t integer not null default 0,
   pod_errors integer not null default 0
);
create index dist_auth on dist(author);

create table dist_history (
   id serial primary key,
   run integer references run (id),
   dist integer references dist (id),
   kwalitee integer not null default 0
);
create index dist_hist_dist on dist_history(dist);

create table kwalitee (
   id serial primary key,
   dist integer references dist (id) ON DELETE CASCADE,
   run integer references run (id) ON DELETE CASCADE,
   kwalitee integer not null default 0,
   extractable integer not null default 0,
   extracts_nicely integer not null default 0,
   has_version integer not null default 0,
   has_proper_version integer not null default 0,
   no_cpants_errors integer not null default 0,
   has_readme integer not null default 0,
   has_manifest integer not null default 0,
   has_meta_yml integer not null default 0,
   has_buildtool integer not null default 0,
   has_changelog integer not null default 0,
   no_symlinks integer not null default 0,
   has_tests integer not null default 0,
   proper_libs integer not null default 0,
   is_prereq integer not null default 0,
   use_strict integer not null default 0,
   has_test_pod integer not null default 0,
   has_test_pod_coverage integer not null default 0,
   no_pod_errors integer not null default 0
);

create table modules (
   id serial primary key,
   dist integer references dist (id) ON DELETE CASCADE,
   module text,
   file text,
   in_lib integer not null default 0,
   in_basedir integer not null default 0
);
CREATE INDEX modules_dist on modules(dist);
CREATE INDEX modules_lib on modules(in_lib);
CREATE INDEX modules_basedir on modules(in_basedir);

create table prereq (
   id serial primary key,
   dist integer references dist (id) ON DELETE CASCADE,
   requires text,
   version text,
   in_dist integer references dist (id) ON DELETE CASCADE
);
create index prereq_dist on prereq(dist);
create index prereq_requires on prereq(requires);
create index prereq_in_dist on prereq(in_dist);

create table uses (
   id serial primary key,
   dist integer references dist (id) ON DELETE CASCADE,
   module text,
   in_dist integer references dist (id) ON DELETE CASCADE,
   in_code integer,
   in_tests integer
);
CREATE INDEX uses_dist on uses(dist);
CREATE INDEX uses_module on uses(module);
CREATE INDEX uses_in_dist on uses(in_dist);
CREATE INDEX uses_in_code on uses(in_code);
CREATE INDEX uses_in_tests on uses(in_tests);

COMMIT;


-- Deploy personnel:unit to pg

set client_min_messages to warning; -- disable warning from create extension
create extension if not exists ltree;
reset client_min_messages;

begin;

create table personnel.unit (
  id          serial primary key,
  name        text check (char_length(name) < 80),
  abbr        text not null check (char_length(abbr) < 10),
  parent_path ltree
);

create index unit_parent_path_gist_idx on personnel.unit using gist(parent_path);
create index unit_parent_path_inx on personnel.unit using btree(parent_path);

commit;

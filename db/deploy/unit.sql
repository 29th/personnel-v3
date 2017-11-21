-- Deploy personnel:unit to pg

begin;

create extension if not exists ltree;

create table public.unit (
  id          serial primary key,
  name        text check (char_length(name) < 80),
  abbr        text not null check (char_length(abbr) < 10),
  parent_path ltree
);

create index unit_parent_path_gist_idx on public.unit using gist(parent_path);
create index unit_parent_path_inx on public.unit using btree(parent_path);

commit;

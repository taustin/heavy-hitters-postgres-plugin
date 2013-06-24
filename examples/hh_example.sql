
CREATE DATABASE IF NOT EXISTS hh_test;

\connect hh_test;

-- Enables heavy_hitters plugin and plpython2u plugin
CREATE EXTENSION IF NOT EXISTS plpython2u;
CREATE EXTENSION IF NOT EXISTS heavy_hitters;


-- Sample table, imagining data being collected for different sites
DROP TABLE IF EXISTS stats;
CREATE TABLE stats (
  data_center_id   integer PRIMARY KEY,
  top_zones        heavy_hitters
);

-- Tracking 10 entries for each center
INSERT INTO stats (data_center_id, top_zones) VALUES (1, heavy_hitters(10));
INSERT INTO stats (data_center_id, top_zones) VALUES (2, heavy_hitters(10));


-- Loading some initial data.  Whenever possible, this
-- variant of the add_items function should be used.
UPDATE stats SET top_zones = add_items(top_zones,
  ARRAY['a.com', 'b.com', 'c.com', 'd.com', 'e.com', 'f.com', 'g.com', 'h.com', 'i.com', 'j.com'],
  ARRAY[15, 11, 10, 7, 6, 3, 2, 2, 1, 1]);
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;

-- more hits: updating one item at a time just to show the evolution of the algorithm
UPDATE stats SET top_zones = add_item(top_zones, 'z.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'z.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'z.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'a.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'd.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'j.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'h.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'z.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'e.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'a.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'z.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'z.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'j.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'f.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'x.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;
UPDATE stats SET top_zones = add_item(top_zones, 'b.com', 1) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;

-- Mass update, all incremented by 1.  In general, it is faster to use the variant of
-- this function that passes in two arrays, but this version is available for ease of use.
UPDATE stats SET top_zones = add_items(top_zones,
  ARRAY['b.com', 'q.com', 'd.com', 'a.com', 'q.com', 'f.com', 'a.com', 'd.com',
  'a.com', 'q.com', 'f.com', 'a.com', 'd.com', 'a.com', 'q.com', 'f.com', 'a.com',
  'd.com', 'a.com', 'q.com', 'f.com', 'a.com', 'd.com', 'a.com', 'q.com', 'f.com',
  'a.com', 'd.com', 'a.com', 'q.com', 'f.com', 'a.com', 'd.com', 'a.com', 'q.com',
  'f.com', 'a.com', 'd.com', 'a.com', 'q.com', 'f.com', 'a.com', 'd.com', 'a.com',
  'q.com', 'f.com', 'a.com', 'd.com', 'a.com', 'q.com', 'f.com', 'a.com']
) WHERE data_center_id=1;
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;

-- Show all results
SELECT list_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;

-- Show results in guaranteed order
SELECT list_ordered_heavy_hitters(top_zones) FROM stats WHERE  data_center_id=1;

-- Same as above, but just show the zone
SELECT (list_ordered_heavy_hitters(top_zones)).item AS top_zones_ordered FROM stats WHERE  data_center_id=1;

-- Same as above, but just show the top 5 zones
SELECT (list_ordered_heavy_hitters(top_zones)).item
AS top_zones_ordered
FROM stats
WHERE  data_center_id=1
LIMIT 5;

-- Select all items that might have 7 or more hits
SELECT item AS items_maybe_over_7
FROM list_heavy_hitters(
  (SELECT top_zones FROM stats WHERE data_center_id=1)
) WHERE high >= 7;

-- Select all items guaranteed to have 7 or more hits
SELECT item AS items_guaranteed_over_7
FROM list_heavy_hitters(
  (SELECT top_zones FROM stats WHERE data_center_id=1)
) WHERE low >= 7;

-- Select the "grey area": items where we are not sure if they are over the threshold or not
SELECT item AS grey_area
FROM list_heavy_hitters(
  (SELECT top_zones FROM stats WHERE data_center_id=1)
) WHERE high >= 7
AND low < 7;


CREATE TYPE heavy_hitters AS (
  packed bytea
);

-- Create a new, empty set of heavy_hitters
CREATE OR REPLACE FUNCTION heavy_hitters(set_size integer)
RETURNS heavy_hitters AS
$$
import pickle
return {'packed': pickle.dumps(([],{},set_size), 1)}
$$
LANGUAGE 'plpython2u' VOLATILE SECURITY DEFINER;

-- List top order, as much as we can guarantee
CREATE OR REPLACE FUNCTION list_heavy_hitters(hh heavy_hitters)
RETURNS TABLE (
  item text,
  low  integer,
  high integer
) AS
$$
import pickle
leaders, mleads, set_size = pickle.loads(hh['packed'])
res = []
i = 0
while (i<len(leaders)):
  item, max_count = leaders[i]
  min_count = max_count - mleads[item][1]
  res.append({'item':item, 'low':min_count, 'high':max_count})
  i += 1
return res
$$
language 'plpython2u' VOLATILE SECURITY DEFINER;

-- List heavy hitters tracked
CREATE OR REPLACE FUNCTION list_ordered_heavy_hitters(hh heavy_hitters)
RETURNS TABLE (
  item text,
  low  integer,
  high integer
) AS
$$
import pickle
leaders, mleads, set_size = pickle.loads(hh['packed'])
num_items = len(leaders)
if (num_items <= 1):
  return []
res = []
# First record
first_item, first_max = leaders[0]
prev_record = {
  'item': first_item,
  'high': first_max,
  'low':  first_max - mleads[first_item][1]
}
i = 1
while (i<len(leaders)):
  item, max_count = leaders[i]
  min_count = max_count - mleads[item][1]
  if (max_count > prev_record['low']):
    return res
  res.append(prev_record)
  prev_record = {'item':item, 'low':min_count, 'high':max_count}
  i += 1
return res
$$
language 'plpython2u' VOLATILE SECURITY DEFINER;

-- Add item to the list of heavy hitters
CREATE OR REPLACE FUNCTION add_item(hh heavy_hitters, item text, incr_val integer)
RETURNS heavy_hitters AS
$$
import pickle
leaders, mleads, set_size = pickle.loads(hh['packed'])
if (item in mleads):
  ind = mleads[item][0]
  leaders[ind] = leaders[ind][0], leaders[ind][1]+incr_val
elif (len(leaders) < set_size):
  cur_len = len(leaders)
  leaders.append((item, incr_val))
  mleads[item] = cur_len, 0
else:
  low_key, low_value = leaders[set_size-1]
  del mleads[low_key]
  leaders[set_size-1] = item, low_value + incr_val
  mleads[item] = set_size-1, low_value
# Changed item might need to be moved into its correct position
i = mleads[item][0] - 1
while (i >= 0 and leaders[i+1][1] > leaders[i][1]):
  leaders[i], leaders[i+1] = leaders[i+1], leaders[i]
  k1, k2 = leaders[i][0], leaders[i+1][0]
  mleads[k1] = i, mleads[k1][1]
  mleads[k2] = i+1, mleads[k2][1]
  i -= 1
return {'packed': pickle.dumps((leaders, mleads, set_size), 1)}
$$
language 'plpython2u' VOLATILE SECURITY DEFINER;

-- Add an array of items to the list of heavy hitters, incrementing all values by 1
CREATE OR REPLACE FUNCTION add_items(hh heavy_hitters, items text[])
RETURNS heavy_hitters AS
$$
import pickle
leaders, mleads, set_size = pickle.loads(hh['packed'])
for item in items:
  if (item in mleads):
    ind = mleads[item][0]
    leaders[ind] = leaders[ind][0], leaders[ind][1]+1
  elif (len(leaders) < set_size):
    cur_len = len(leaders)
    leaders.append((item, 1))
    mleads[item] = cur_len, 0
  else:
    low_key, low_value = leaders[set_size-1]
    del mleads[low_key]
    leaders[set_size-1] = item, low_value + 1
    mleads[item] = set_size-1, low_value
  # Changed item might need to be moved into its correct position
  i = mleads[item][0] - 1
  while (i >= 0 and leaders[i+1][1] > leaders[i][1]):
    leaders[i], leaders[i+1] = leaders[i+1], leaders[i]
    k1, k2 = leaders[i][0], leaders[i+1][0]
    mleads[k1] = i, mleads[k1][1]
    mleads[k2] = i+1, mleads[k2][1]
    i -= 1
return {'packed': pickle.dumps((leaders, mleads, set_size), 1)}
$$
language 'plpython2u' VOLATILE SECURITY DEFINER;

-- Add an array of items to the list of heavy hitters, incrementing values by
-- the equivalent position in the second array.  THIS VERSION IS THE MOST
-- EFFICIENT WAY TO ADD ITEMS.
CREATE OR REPLACE FUNCTION add_items(hh heavy_hitters, items text[], incr_vals integer[])
RETURNS heavy_hitters AS
$$
import pickle
leaders, mleads, set_size = pickle.loads(hh['packed'])
for i in range(len(items)):
  item = items[i]
  incr_val = incr_vals[i]
  if (item in mleads):
    ind = mleads[item][0]
    leaders[ind] = leaders[ind][0], leaders[ind][1]+incr_val
  elif (len(leaders) < set_size):
    cur_len = len(leaders)
    leaders.append((item, incr_val))
    mleads[item] = cur_len, 0
  else:
    low_key, low_value = leaders[set_size-1]
    del mleads[low_key]
    leaders[set_size-1] = item, low_value + incr_val
    mleads[item] = set_size-1, low_value
  # Changed item might need to be moved into its correct position
  i = mleads[item][0] - 1
  while (i >= 0 and leaders[i+1][1] > leaders[i][1]):
    leaders[i], leaders[i+1] = leaders[i+1], leaders[i]
    k1, k2 = leaders[i][0], leaders[i+1][0]
    mleads[k1] = i, mleads[k1][1]
    mleads[k2] = i+1, mleads[k2][1]
    i -= 1
return {'packed': pickle.dumps((leaders, mleads, set_size), 1)}
$$
language 'plpython2u' VOLATILE SECURITY DEFINER;




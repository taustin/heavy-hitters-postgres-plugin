heavy-hitters-postgres-plugin
=============================

A plugin for Posgresql providing a heavy hitters data type, following Metwally et al.'s "Efficient Computation of Frequent and Top-k Elements in Data Streams", written in Python.  The original paper can be found at http://www.cs.ucsb.edu/research/tech_reports/reports/2005-23.pdf.

The algorithm used in this plugin guarantees fixed space requirements.  In essence, we only track the top items and keep a range for each tracked value.  So we might not know how many times the top item has showed up exactly, but we will know it is between (for instance) 100,232-100,239 times.  Assuming typical Zipfian data distribution, we can guarantee the order of the top tracked items.  In practice, it seems that you need to track about ten times the results you care about (e.g. track 1,000 items if you care about the top 100), though that is just a rule of thumb.

The examples directory shows how to use this plugin.  Note that each call pickles and unpickles the data, so fewer calls tends to be better.  As a result, using the variants that pass in arrays of items and arrays of counts are substantially more efficient.


# Cache Notes

### Replacement Policy

LRU, least recently used cache line will be replaced
First, check to see if there are any hits, if no hits, then check to see if any tags are in the empty state
Replace empty tags in increasing order&mdash;i.e. if all tags are empty (init state), then start by fetching into tag 0.
If no tags are empty, and there are not hits, then use LRU. LRU is updated every time a tag is updated

### Cache Controller

Use a state machine: idle, reading, writing (D-Cache only).

In initialization for compulsory misses (and in I-Cache), sumbit read request to SDRAM controller and wait for data to be ready (also process future misses).
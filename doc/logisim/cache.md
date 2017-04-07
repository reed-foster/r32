# Cache
This processor will use a Harvard Architecture (split instruction/data) cache
The cache is fully associative with 1KiB long cache lines and supports byte, halfword, and word loads and stores.
Uses least recently used strategy for cache eviction.
Write-through write policy with a FIFO to prevent delays when evicting old data.
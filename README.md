# cma-archives-utils
Helper scripts for managing the CMA Archival Repository

## Batch ingest
Batch ingest scripts generate a manifest file for each matching folder that
is found under a root path. Generic batches will include anything that is not
a dot file. This behaviour can and should be overriden for specific types of
collections as needed. See the _lib/_ directory for alternate implementations.

To fully customize a batch these methods should be replaced in a subclass
* extract_title
* include?
* is_parseable?
* generate_metadata
* parent_collection

Default and extracted metadata fields should be appended to @properties. Any
attributes defined here will be set as defaults. An example batch file is
provided for reference.

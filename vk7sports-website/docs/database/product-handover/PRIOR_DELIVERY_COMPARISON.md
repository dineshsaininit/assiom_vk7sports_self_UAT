# Comparison with the earlier database delivery

Compared with commit 0a140e56066560f3dbb8d21a27451322ca916342 on database/uat-dataset-handover. No merge or cherry-pick was performed. Both deliveries start from main e745b38ba928b4361fd68a07abc5eecabaf863d7.

| Earlier functionality | Current package |
|---|---|
| Combined products.csv repeating style fields, one inventory source per SKU | Separate styles/variants/inventory, multiple sources per SKU, explicit parent relationships. Old combined-file CLI is intentionally not retained; use new templates. |
| Required/type/duplicate/price/tier/provenance checks; 31 tests | Preserved equivalent checks with 48 tests, plus approved combinations, target options, source/group lists and required media. |
| Optional image strings with missing-image warning | Required manifest references and size charts; local presence/path checks, URL warnings and image-mode consistency. |
| Native CSV converter with en/default hardcoded | Native converter now uses supplied locale/family configuration. Same actual native header contract, verified against source. |
| Read-only PostgreSQL verification queries | Preserved and extended with family membership, categories, channel/source and source-level stock/image reconciliation. |
| Machine-readable source inventory, hashes and export counts | Preserved as prior_source_inventory.json with historical provenance; no fresh audit or live-data claim. |
| Detailed environment/admin/rerun caveats | Carried into README, importer contract and missing-input register. |
| Broad statement that importer manages options / parent_sku mapping | Corrected: existing options required; configurable_variants establishes links. |

Useful missing functionality found during comparison: the historical machine-readable source evidence and verification SQL were initially absent from the new folder; both are now included. The older single-file input interface is not supported by this normalized package, and automatic migration of populated old-format files is not provided. There is no approved old business dataset to migrate.

Remaining operational gaps shared by both: genuine business inputs, verified target references/configuration, runtime-supported importer access, actual staging import and reconciliation. Neither commit includes a live importer or changes APIs.

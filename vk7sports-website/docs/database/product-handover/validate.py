"""Offline product handover validation / native Bagisto CSV preparation.

Python 3.10+, standard library. Reads files only; no database, network or writes.
"""
import argparse
import csv
import io
import json
import re
import sys
from collections import defaultdict
from datetime import date
from decimal import Decimal
from pathlib import Path
from urllib.parse import urlencode, urlsplit

META = ["data_class", "source_ref", "approval_ref"]
SCHEMAS = {
    "styles": META + "style_sku name category_path short_description description status moq_qty moq_basis currency tax_basis size_chart_id".split(),
    "variants": META + "sku style_sku colour size price weight_kg tier_policy image_ids".split(),
    "inventory": META + "sku inventory_source_code stock_qty stock_as_of".split(),
    "tiers": META + "sku customer_group min_qty max_qty unit_price quantity_basis".split(),
    "media": META + "media_id style_sku sku kind location".split(),
    "allowed_combinations": META + "style_sku colour size".split(),
    "inventory_sources": META + ["code", "status"],
    "customer_groups": META + ["code"],
    "configuration": META + "channel_code channel_count locale attribute_family_code currency weight_unit tax_basis moq_qty moq_basis".split(),
    "attribute_options": META + ["attribute_family_code", "attribute_code", "label"],
}
OPTIONAL = {"tiers": {"max_qty"}, "media": {"sku"}}
IMPORT_COLUMNS = (
    "sku parent_sku locale attribute_family_code type categories images name "
    "description short_description status visible_individually guest_checkout "
    "weight price url_key manage_stock inventories configurable_variants customer_group_prices"
).split()
SKU = re.compile(r"[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*\Z")
CODE = re.compile(r"[A-Za-z0-9_-]+\Z")
MONEY = re.compile(r"[0-9]{1,8}(?:\.[0-9]{1,4})?\Z")
UNKNOWN = {"unknown", "tbd", "tbc", "n/a", "null", "?"}


def quantity(text):
    return int(text) if re.fullmatch(r"[0-9]{1,10}", text) and int(text) <= 2147483647 else None


def money(text):
    return Decimal(text) if MONEY.fullmatch(text) and Decimal(text) > 0 else None


class Audit:
    """Check one complete, normalized batch without altering input."""
    def __init__(self, data_dir, allow_synthetic=False, media_root=None):
        self.data_dir = Path(data_dir)
        self.allow_synthetic = allow_synthetic
        self.media_root = Path(media_root).resolve() if media_root else None
        self.errors, self.blockers, self.warnings = [], [], []
        self.data, self.classes = {}, set()

    def add(self, code, row, field, message, level="errors"):
        getattr(self, level).append(dict(
            code=code, file=row.get("_file", ""), row=row.get("_line", 0),
            field=field, message=message,
        ))

    def load(self):
        for table, columns in SCHEMAS.items():
            rows = []
            self.data[table] = rows
            location = {"_file": table + ".csv", "_line": 1}
            try:
                with (self.data_dir / (table + ".csv")).open(encoding="utf-8-sig", newline="") as stream:
                    reader = csv.DictReader(stream, strict=True)
                    header = reader.fieldnames or []
                    if len(header) != len(set(header)) or set(header) != set(columns):
                        self.add("HEADER", location, "", "Use each exact template column once.")
                        continue
                    for row in reader:
                        location = {"_file": table + ".csv", "_line": reader.line_num}
                        if None in row or any(value is None for value in row.values()):
                            self.add("CSV_SHAPE", location, "", "Wrong number of CSV fields.")
                            continue
                        row.update(location)
                        rows.append(row)
                        for field in columns:
                            value = row[field]
                            if field not in OPTIONAL.get(table, set()) and not value.strip():
                                self.add("REQUIRED", row, field, "Missing required value; do not invent it.")
                            if value.strip().casefold() in UNKNOWN:
                                self.add("UNKNOWN_VALUE", row, field, "Obtain the source value.")
                            if value != value.strip():
                                self.add("WHITESPACE", row, field, "Remove surrounding whitespace explicitly.")
                            if any(ord(c) < 32 for c in value) and field not in {"description", "short_description"}:
                                self.add("CONTROL_CHARACTER", row, field, "Control characters are not allowed here.")
                        kind = row["data_class"]
                        self.classes.add(kind)
                        if kind not in {"business", "synthetic"}:
                            self.add("DATA_CLASS", row, "data_class", "Use business or synthetic.")
                        if kind == "synthetic" and not self.allow_synthetic:
                            self.add("SYNTHETIC_FORBIDDEN", row, "data_class", "Synthetic tests require --allow-synthetic.")
                        if kind == "business" and any(
                            row.get(field, "").upper().startswith(("SYNTHETIC", "TEST-"))
                            for field in ("style_sku", "sku", "source_ref", "approval_ref")
                        ):
                            self.add("SYNTHETIC_MISLABELLED", row, "data_class", "Test markers cannot become business data.")
                        if kind == "synthetic" and any(
                            row.get(field) and not row[field].startswith("SYNTHETIC-")
                            for field in ("style_sku", "sku")
                        ):
                            self.add("SYNTHETIC_PREFIX", row, "sku", "Synthetic SKU references must start SYNTHETIC-.")
            except (OSError, UnicodeError, csv.Error) as error:
                self.add("CSV_READ", location, "", str(error))
        if len(self.classes) > 1:
            self.add("MIXED_DATA_CLASSES", {}, "data_class", "Keep business and synthetic batches separate.")

    def unique(self, table, field, code):
        result = {}
        for row in self.data[table]:
            key = row[field].casefold()
            if key in result:
                self.add(code, row, field, "Duplicate identifier, ignoring case.")
            else:
                result[key] = row
        return result

    def link(self, row, field, records, code, target_field=None):
        value = row[field]
        target = records.get(value.casefold())
        if target is None:
            self.add(code, row, field, "Referenced record is missing.")
        elif value != target[target_field or field]:
            self.add("REFERENCE_SPELLING", row, field, "Use the exact reference spelling/case.")
        return target

    def identifier(self, row, field, maximum=255, pattern=SKU):
        if len(row[field]) > maximum or not pattern.fullmatch(row[field]):
            self.add("IDENTIFIER", row, field, "Identifier has invalid characters or length.")

    def media_check(self, row, media_id, kind, style_sku, sku=""):
        item = self.media.get(media_id.casefold())
        if item is None:
            self.add("MISSING_MEDIA_REFERENCE", row, "media", "Missing manifest ID: " + media_id)
        elif (
            item["media_id"] != media_id or item["kind"] != kind
            or item["style_sku"] != style_sku
            or item["sku"] and item["sku"] != sku
        ):
            self.add("MEDIA_SCOPE", row, "media", "Media kind/owner does not match: " + media_id)

    def check(self):
        self.load()
        for table in ("styles", "variants", "inventory", "media", "allowed_combinations", "inventory_sources", "configuration", "attribute_options"):
            if not self.data[table]:
                self.add("EMPTY_TABLE", {"_file": table + ".csv"}, "", "Required table is empty.")
        self.styles = self.unique("styles", "style_sku", "DUPLICATE_STYLE_SKU")
        self.variants = self.unique("variants", "sku", "DUPLICATE_VARIANT_SKU")
        self.media = self.unique("media", "media_id", "DUPLICATE_MEDIA_ID")
        sources = self.unique("inventory_sources", "code", "DUPLICATE_SOURCE")
        groups = self.unique("customer_groups", "code", "DUPLICATE_GROUP")
        if len(self.data["configuration"]) != 1:
            self.add("CONFIGURATION_COUNT", {"_file": "configuration.csv"}, "", "Exactly one verified target configuration is required.")
        self.config = self.data["configuration"][0] if self.data["configuration"] else {}
        config = self.config
        if config:
            for field in ("channel_code", "locale", "attribute_family_code"):
                self.identifier(config, field, pattern=CODE)
            if config["channel_count"] != "1":
                self.add("MULTICHANNEL_UNSUPPORTED", config, "channel_count", "CSV omits channel and importer selects the default; this package supports one verified target channel.", "blockers")
            if config["weight_unit"] != "kgs":
                self.add("WEIGHT_UNIT", config, "weight_unit", "weight_kg requires target unit kgs.", "blockers")
            if not re.fullmatch(r"[A-Z]{3}", config["currency"]):
                self.add("CURRENCY", config, "currency", "Use the verified three-letter currency code.")
            if config["tax_basis"] not in {"inclusive", "exclusive"}:
                self.add("TAX_BASIS", config, "tax_basis", "Use inclusive or exclusive.")
            if not quantity(config["moq_qty"]):
                self.add("MOQ", config, "moq_qty", "Positive integer required.")
            if config["moq_basis"] not in {"per_style", "per_variant", "per_order"}:
                self.add("MOQ_BASIS", config, "moq_basis", "Unknown MOQ aggregation basis.")
        for row in sources.values():
            self.identifier(row, "code", pattern=CODE)
            if row["status"] not in {"active", "inactive"}:
                self.add("SOURCE_STATUS", row, "status", "Use active or inactive.")
        for row in groups.values():
            self.identifier(row, "code", pattern=CODE)
            if row["code"] == "all":
                self.add("ALL_GROUPS_UNSUPPORTED", row, "code", "Provide an explicit existing customer group.")
        options = set()
        for row in self.data["attribute_options"]:
            key = (row["attribute_family_code"], row["attribute_code"], row["label"])
            if key in options:
                self.add("DUPLICATE_OPTION", row, "label", "Duplicate target option reference.")
            options.add(key)
            if row["attribute_code"] not in {"color", "size"}:
                self.add("OPTION_CODE", row, "attribute_code", "Expected native code color or size.")
        approved = {}
        for row in self.data["allowed_combinations"]:
            self.link(row, "style_sku", self.styles, "UNKNOWN_STYLE")
            key = tuple(row[x].casefold() for x in ("style_sku", "colour", "size"))
            if key in approved:
                self.add("DUPLICATE_APPROVED_COMBINATION", row, "colour,size", "Approved combination repeats.")
            approved[key] = row
        for row in self.styles.values():
            self.identifier(row, "style_sku", 64)
            if len(row["name"]) > 255:
                self.add("NAME_LENGTH", row, "name", "Maximum 255 characters.")
            if row["style_sku"].casefold() in self.variants:
                self.add("STYLE_VARIANT_SKU_COLLISION", row, "style_sku", "Styles and variants share the products SKU namespace.")
            if any(not part.strip() or len(part) > 255 or part != part.strip() for part in row["category_path"].split("/")):
                self.add("CATEGORY_PATH", row, "category_path", "Use nonempty category levels separated by /.")
            if row["status"] not in {"active", "hidden"}:
                self.add("STATUS", row, "status", "Use active or hidden.")
            if not quantity(row["moq_qty"]):
                self.add("MOQ", row, "moq_qty", "Positive integer required.")
            for field in ("moq_qty", "moq_basis", "currency", "tax_basis"):
                if config and row[field] != config[field]:
                    self.add("POLICY_MISMATCH", row, field, "Does not match the supplied common target policy.", "blockers")
            self.media_check(row, row["size_chart_id"], "size_chart", row["style_sku"])
        pairs, parents, image_modes = set(), set(), set()
        for row in self.data["variants"]:
            self.identifier(row, "sku")
            parent = self.link(row, "style_sku", self.styles, "UNKNOWN_STYLE")
            parents.add(row["style_sku"].casefold())
            key = tuple(row[x].casefold() for x in ("style_sku", "colour", "size"))
            if key in pairs:
                self.add("DUPLICATE_VARIANT_COMBINATION", row, "colour,size", "A style/colour/size pair repeats.")
            pairs.add(key)
            reference = approved.get(key)
            if not reference:
                self.add("UNAPPROVED_COMBINATION", row, "colour,size", "Pair is absent from approved combinations.")
            elif any(row[field] != reference[field] for field in ("colour", "size")):
                self.add("COMBINATION_SPELLING", row, "colour,size", "Use exact approved labels.")
            for field, native, limit in (("colour", "color", 100), ("size", "size", 20)):
                if not row[field] or len(row[field]) > limit:
                    self.add("VARIANT_LABEL", row, field, "Missing or oversized option label.")
                if config and (config["attribute_family_code"], native, row[field]) not in options:
                    self.add("MISSING_TARGET_OPTION", row, field, "Importer requires an existing option for this family/attribute.", "blockers")
            if money(row["price"]) is None:
                self.add("PRICE", row, "price", "Positive numeric(12,4) value required; no exponent or NaN.")
            if money(row["weight_kg"]) is None:
                self.add("WEIGHT", row, "weight_kg", "Measured positive decimal kg required.")
            if parent and len(parent["name"] + " " + row["colour"] + " " + row["size"]) > 255:
                self.add("NAME_LENGTH", row, "sku", "Generated variant name exceeds 255 characters.")
            if row["tier_policy"] not in {"none", "provided"}:
                self.add("TIER_POLICY", row, "tier_policy", "Use approved none or provided.")
            ids = row["image_ids"].split("|")
            if len(ids) != len(set(ids)):
                self.add("DUPLICATE_IMAGE_REFERENCE", row, "image_ids", "Image IDs repeat.")
            for media_id in ids:
                self.media_check(row, media_id, "image", row["style_sku"], row["sku"])
        for key, row in self.styles.items():
            if key not in parents:
                self.add("STYLE_WITHOUT_VARIANTS", row, "style_sku", "Style has no sellable variant rows.")
        for row in self.data["media"]:
            self.identifier(row, "media_id", pattern=CODE)
            self.link(row, "style_sku", self.styles, "UNKNOWN_STYLE")
            if row["sku"]:
                variant = self.link(row, "sku", self.variants, "UNKNOWN_VARIANT")
                if variant and variant["style_sku"] != row["style_sku"]:
                    self.add("MEDIA_SCOPE", row, "sku", "Variant belongs to another style.")
            if row["kind"] not in {"image", "size_chart"}:
                self.add("MEDIA_KIND", row, "kind", "Use image or size_chart.")
            location = row["location"]
            if "," in location:
                self.add("MEDIA_DELIMITER", row, "location", "Native image lists cannot contain a literal comma.")
            if any(ord(char) < 32 for char in location):
                continue
            try:
                parsed = urlsplit(location)
                parsed.port
            except ValueError:
                self.add("MEDIA_URL", row, "location", "Malformed media URL.")
                continue
            remote = parsed.scheme in {"http", "https"} and bool(parsed.netloc)
            if remote:
                if parsed.username or parsed.password:
                    self.add("MEDIA_URL_CREDENTIALS", row, "location", "Do not put credentials in media links.")
                self.add("REMOTE_MEDIA_UNVERIFIED", row, "location", "URL availability/content/rights require separate verification.", "warnings")
            else:
                relative = Path(location)
                if parsed.scheme or relative.is_absolute() or ".." in relative.parts or "\\" in location:
                    self.add("MEDIA_PATH", row, "location", "Use a relative forward-slash path or an HTTP(S) URL.")
                elif self.media_root is None:
                    self.add("MEDIA_ROOT_REQUIRED", row, "location", "Supply --media-root to verify local manifest files.", "blockers")
                else:
                    try:
                        resolved = (self.media_root / relative).resolve()
                        if not resolved.is_relative_to(self.media_root) or not resolved.is_file():
                            raise ValueError
                    except (OSError, ValueError):
                        self.add("MISSING_MEDIA_FILE", row, "location", "Local media file is missing or escapes the media root.")
            if row["kind"] == "image":
                image_modes.add("url" if remote else "file")
        if len(image_modes) > 1:
            self.add("MIXED_IMAGE_MODES", {}, "location", "A native import uses one image-source mode.", "blockers")
        self.image_mode = next(iter(image_modes), None)
        inventory_keys, inventory_skus = set(), set()
        for row in self.data["inventory"]:
            self.link(row, "sku", self.variants, "UNKNOWN_VARIANT")
            source = self.link(row, "inventory_source_code", sources, "MISSING_INVENTORY_SOURCE", "code")
            if source and source["status"] != "active":
                self.add("INACTIVE_INVENTORY_SOURCE", row, "inventory_source_code", "Source is not active.")
            key = (row["sku"].casefold(), row["inventory_source_code"].casefold())
            if key in inventory_keys:
                self.add("DUPLICATE_INVENTORY", row, "sku,inventory_source_code", "SKU/source repeats.")
            inventory_keys.add(key)
            inventory_skus.add(row["sku"].casefold())
            if quantity(row["stock_qty"]) is None:
                self.add("STOCK", row, "stock_qty", "Known non-negative 32-bit integer required.")
            try:
                if date.fromisoformat(row["stock_as_of"]).isoformat() != row["stock_as_of"]:
                    raise ValueError
            except ValueError:
                self.add("STOCK_DATE", row, "stock_as_of", "Use valid YYYY-MM-DD.")
        schedules, tier_skus = defaultdict(list), set()
        for row in self.data["tiers"]:
            variant = self.link(row, "sku", self.variants, "UNKNOWN_VARIANT")
            self.link(row, "customer_group", groups, "MISSING_CUSTOMER_GROUP", "code")
            low, high, price = quantity(row["min_qty"]), quantity(row["max_qty"]) if row["max_qty"] else None, money(row["unit_price"])
            if not low or row["max_qty"] and (high is None or low is not None and high < low):
                self.add("TIER_RANGE", row, "min_qty,max_qty", "Minimum > 0; maximum >= minimum or blank for unbounded.")
            if price is None:
                self.add("TIER_PRICE", row, "unit_price", "Positive numeric(12,4) value required.")
            if variant:
                if variant["tier_policy"] != "provided":
                    self.add("UNEXPECTED_TIERS", row, "sku", "Variant declares no tiers.")
                if price is not None and money(variant["price"]) is not None and price > money(variant["price"]):
                    self.add("TIER_ABOVE_BASE", row, "unit_price", "Tier exceeds base selling price.")
            if row["quantity_basis"] != "per_variant":
                self.add("TIER_BASIS_UNSUPPORTED", row, "quantity_basis", "Native thresholds apply per variant; style aggregation needs backend support.", "blockers")
            if low and price is not None and (not row["max_qty"] or high is not None and high >= low):
                schedules[(row["sku"].casefold(), row["customer_group"].casefold())].append((low, high, price, row))
            tier_skus.add(row["sku"].casefold())
        for key, row in self.variants.items():
            if key not in inventory_skus:
                self.add("MISSING_INVENTORY", row, "sku", "No stock row, even for zero stock.")
            if row["tier_policy"] == "provided" and key not in tier_skus:
                self.add("MISSING_TIERS", row, "sku", "Declared schedule is missing.")
        for schedule in schedules.values():
            schedule.sort(key=lambda entry: (entry[0], entry[3]["_line"]))
            previous = None
            for low, high, price, row in schedule:
                if previous:
                    if previous[1] is None or low != previous[1] + 1:
                        self.add("TIER_OVERLAP_OR_GAP", row, "min_qty,max_qty", "Intervals must be contiguous, unique and nonoverlapping.")
                    if price > previous[2]:
                        self.add("TIER_PRICE_INCREASE", row, "unit_price", "Price increases at higher volume.")
                previous = (low, high, price)
            if schedule[-1][1] is not None:
                self.add("TIER_FINAL_BOUND", schedule[-1][3], "max_qty", "Final interval must be unbounded; native prices store minimum thresholds only.")
        for key in self.styles:
            prices = {money(row["price"]) for row in self.variants.values() if row["style_sku"].casefold() == key}
            if len(prices) > 1:
                self.add("ADMIN_PRICE_OVERWRITE", self.styles[key], "price", "Existing VK7 style edits may overwrite differing variant prices.", "warnings")
        return {
            "valid": not self.errors, "mapping_compatible": not self.errors and not self.blockers,
            "synthetic": "synthetic" in self.classes, "database_verified": False,
            "business_authenticity_verified": False, "native_image_mode": self.image_mode,
            "summary": {"styles": len(self.styles), "variants": len(self.variants),
                        "inventory_rows": len(self.data["inventory"]), "tier_rows": len(self.data["tiers"]),
                        "media_rows": len(self.data["media"]),
                        "stock_units": sum(quantity(row["stock_qty"]) or 0 for row in self.data["inventory"])},
            "errors": self.errors, "blockers": self.blockers, "warnings": self.warnings,
        }

    def import_rows(self):
        """Called only after successful validation; yields native importer columns."""
        inventories, prices = defaultdict(list), defaultdict(list)
        for row in self.data["inventory"]:
            inventories[row["sku"]].append(row["inventory_source_code"] + "=" + row["stock_qty"])
        for row in self.data["tiers"]:
            encoded = urlencode({"group": row["customer_group"], "qty": row["min_qty"],
                                 "type": "fixed", "price": row["unit_price"]}).replace("&", ",")
            prices[row["sku"]].append((int(row["min_qty"]), row["customer_group"], encoded))
        for style in self.styles.values():
            variants = [row for row in self.data["variants"] if row["style_sku"] == style["style_sku"]]
            common = {
                "locale": self.config["locale"], "attribute_family_code": self.config["attribute_family_code"],
                "categories": style["category_path"], "description": style["description"],
                "short_description": style["short_description"], "status": "1" if style["status"] == "active" else "0",
                "guest_checkout": "0", "manage_stock": "1",
            }
            all_images = list(dict.fromkeys(media_id for row in variants for media_id in row["image_ids"].split("|")))
            yield dict(common, sku=style["style_sku"], parent_sku="", type="configurable",
                       name=style["name"], visible_individually="1", url_key=style["style_sku"].lower(),
                       images=",".join(self.media[key.casefold()]["location"] for key in all_images),
                       configurable_variants="|".join(urlencode({
                           "sku": row["sku"], "color": row["colour"], "size": row["size"],
                       }).replace("&", ",") for row in variants))
            for row in variants:
                yield dict(common, sku=row["sku"], parent_sku=style["style_sku"], type="simple",
                           name=style["name"] + " " + row["colour"] + " " + row["size"],
                           visible_individually="0", url_key=row["sku"].lower(), price=row["price"],
                           weight=row["weight_kg"], inventories=",".join(inventories[row["sku"]]),
                           images=",".join(self.media[key.casefold()]["location"] for key in row["image_ids"].split("|")),
                           customer_group_prices="|".join(entry[2] for entry in sorted(prices[row["sku"]])))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data-dir", required=True, type=Path)
    parser.add_argument("--media-root", type=Path)
    parser.add_argument("--allow-synthetic", action="store_true")
    parser.add_argument("--bagisto-csv", action="store_true", help="Prepare CSV on stdout; never import.")
    args = parser.parse_args(argv)
    audit = Audit(args.data_dir, args.allow_synthetic, args.media_root)
    report = audit.check()
    if args.bagisto_csv:
        print(json.dumps(report, indent=2), file=sys.stderr)
        if report["mapping_compatible"]:
            buffer = io.StringIO(newline="")
            writer = csv.DictWriter(buffer, fieldnames=IMPORT_COLUMNS, lineterminator="\n")
            writer.writeheader()
            writer.writerows(audit.import_rows())
            sys.stdout.write(buffer.getvalue())
    else:
        print(json.dumps(report, indent=2))
    return 0 if report["mapping_compatible"] else 1


if __name__ == "__main__":
    raise SystemExit(main())

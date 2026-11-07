"""Synthetic-only validation and source-contract tests. No network or database."""
import copy
import csv
import hashlib
import io
import json
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from urllib.parse import parse_qs

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT.parents[2]
sys.path.insert(0, str(ROOT))
from validate import Audit, SCHEMAS, IMPORT_COLUMNS


class HandoverTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="vk7-day4-synthetic-")
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name)
        self.data = {}
        for table in SCHEMAS:
            with (ROOT / "tests/fixtures/synthetic" / (table + ".csv")).open(encoding="utf-8", newline="") as stream:
                self.data[table] = list(csv.DictReader(stream))

    def write(self):
        for table, columns in SCHEMAS.items():
            with (self.path / (table + ".csv")).open("w", encoding="utf-8", newline="") as stream:
                writer = csv.DictWriter(stream, fieldnames=columns)
                writer.writeheader()
                writer.writerows(self.data[table])

    def check(self, allow=True, media_root=None):
        self.write()
        audit = Audit(self.path, allow, media_root)
        return audit.check(), audit

    def codes(self, result):
        return {item["code"] for item in result["errors"] + result["blockers"]}

    def test_valid_synthetic_fixture(self):
        report, _ = self.check()
        self.assertTrue(report["mapping_compatible"], report)
        self.assertEqual(report["summary"], dict(styles=1, variants=2, inventory_rows=3, tier_rows=6, media_rows=3, stock_units=9))
        self.assertTrue(report["synthetic"])
        self.assertFalse(report["database_verified"])
        self.assertFalse(report["business_authenticity_verified"])

    def test_synthetic_rejected_without_explicit_flag(self):
        self.assertIn("SYNTHETIC_FORBIDDEN", self.codes(self.check(False)[0]))

    def test_synthetic_cannot_be_relabelled(self):
        for rows in self.data.values():
            for row in rows:
                row["data_class"] = "business"
        self.assertIn("SYNTHETIC_MISLABELLED", self.codes(self.check()[0]))

    def test_all_required_columns(self):
        optional = {"tiers": {"max_qty"}, "media": {"sku"}}
        for table, fields in SCHEMAS.items():
            for field in fields:
                if field in optional.get(table, set()):
                    continue
                with self.subTest(table=table, field=field):
                    original = self.data[table][0][field]
                    self.data[table][0][field] = ""
                    self.assertIn("REQUIRED", self.codes(self.check()[0]))
                    self.data[table][0][field] = original

    def test_unknown_values_are_reported(self):
        self.data["variants"][0]["price"] = "unknown"
        self.assertIn("UNKNOWN_VALUE", self.codes(self.check()[0]))

    def test_duplicate_style_sku(self):
        self.data["styles"].append(copy.deepcopy(self.data["styles"][0]))
        self.assertIn("DUPLICATE_STYLE_SKU", self.codes(self.check()[0]))

    def test_duplicate_variant_sku_ignores_case(self):
        self.data["variants"][1]["sku"] = self.data["variants"][0]["sku"].lower()
        self.assertIn("DUPLICATE_VARIANT_SKU", self.codes(self.check()[0]))

    def test_style_variant_namespace_collision(self):
        self.data["variants"][0]["sku"] = self.data["styles"][0]["style_sku"]
        self.assertIn("STYLE_VARIANT_SKU_COLLISION", self.codes(self.check()[0]))

    def test_orphan_variant(self):
        self.data["variants"][0]["style_sku"] = "SYNTHETIC-MISSING"
        self.assertIn("UNKNOWN_STYLE", self.codes(self.check()[0]))

    def test_exact_parent_spelling_required(self):
        self.data["variants"][0]["style_sku"] = self.data["styles"][0]["style_sku"].lower()
        self.assertIn("REFERENCE_SPELLING", self.codes(self.check()[0]))

    def test_style_without_children(self):
        self.data["variants"] = []
        self.assertIn("STYLE_WITHOUT_VARIANTS", self.codes(self.check()[0]))

    def test_duplicate_variant_pair(self):
        self.data["variants"][1]["size"] = self.data["variants"][0]["size"]
        self.assertIn("DUPLICATE_VARIANT_COMBINATION", self.codes(self.check()[0]))

    def test_unapproved_colour_size_pair(self):
        self.data["allowed_combinations"].pop()
        self.assertIn("UNAPPROVED_COMBINATION", self.codes(self.check()[0]))

    def test_missing_existing_attribute_option(self):
        self.data["attribute_options"].pop()
        self.assertIn("MISSING_TARGET_OPTION", self.codes(self.check()[0]))

    def test_stock_boundaries(self):
        for value in ("-1", "0.5", "NaN", "1e2", "2147483648"):
            with self.subTest(value=value):
                self.data["inventory"][0]["stock_qty"] = value
                self.assertIn("STOCK", self.codes(self.check()[0]))

    def test_known_zero_stock_is_retained(self):
        report, audit = self.check()
        child = list(audit.import_rows())[1]
        self.assertIn("synthetic-main=0", child["inventories"])

    def test_missing_inventory_row(self):
        self.data["inventory"] = self.data["inventory"][:2]
        self.assertIn("MISSING_INVENTORY", self.codes(self.check()[0]))

    def test_unknown_inventory_source(self):
        self.data["inventory"][0]["inventory_source_code"] = "missing"
        self.assertIn("MISSING_INVENTORY_SOURCE", self.codes(self.check()[0]))

    def test_inactive_inventory_source(self):
        self.data["inventory_sources"][0]["status"] = "inactive"
        self.assertIn("INACTIVE_INVENTORY_SOURCE", self.codes(self.check()[0]))

    def test_duplicate_inventory_source_pair(self):
        self.data["inventory"].append(copy.deepcopy(self.data["inventory"][0]))
        self.assertIn("DUPLICATE_INVENTORY", self.codes(self.check()[0]))

    def test_missing_customer_group(self):
        self.data["customer_groups"] = []
        self.assertIn("MISSING_CUSTOMER_GROUP", self.codes(self.check()[0]))

    def test_bad_dates(self):
        self.data["inventory"][0]["stock_as_of"] = "2026-02-30"
        self.assertIn("STOCK_DATE", self.codes(self.check()[0]))

    def test_invalid_prices(self):
        for price in ("0", "-2", "Infinity", "NaN", "1e2", "100000000", "0.00001"):
            with self.subTest(price=price):
                self.data["variants"][0]["price"] = price
                self.assertIn("PRICE", self.codes(self.check()[0]))

    def test_tier_gaps_overlaps_and_duplicates(self):
        for start in ("49", "51", "24"):
            with self.subTest(start=start):
                self.data["tiers"][1]["min_qty"] = start
                self.assertIn("TIER_OVERLAP_OR_GAP", self.codes(self.check()[0]))

    def test_duplicate_open_tier_does_not_crash(self):
        self.data["tiers"].append(copy.deepcopy(self.data["tiers"][2]))
        self.assertIn("TIER_OVERLAP_OR_GAP", self.codes(self.check()[0]))

    def test_tiers_above_base_and_increasing(self):
        self.data["tiers"][1]["unit_price"] = "110"
        self.assertTrue({"TIER_ABOVE_BASE", "TIER_PRICE_INCREASE"} <= self.codes(self.check()[0]))

    def test_finite_final_tier_rejected(self):
        self.data["tiers"][2]["max_qty"] = "199"
        self.assertIn("TIER_FINAL_BOUND", self.codes(self.check()[0]))

    def test_missing_declared_tiers(self):
        self.data["tiers"] = []
        self.assertIn("MISSING_TIERS", self.codes(self.check()[0]))

    def test_approved_no_tiers(self):
        self.data["tiers"] = []
        for row in self.data["variants"]:
            row["tier_policy"] = "none"
        self.assertTrue(self.check()[0]["mapping_compatible"])

    def test_moq_override_blocked(self):
        self.data["styles"][0]["moq_qty"] = "100"
        self.assertIn("POLICY_MISMATCH", self.codes(self.check()[0]))

    def test_style_tier_aggregation_blocked(self):
        self.data["tiers"][0]["quantity_basis"] = "per_style"
        self.assertIn("TIER_BASIS_UNSUPPORTED", self.codes(self.check()[0]))

    def test_missing_image_reference(self):
        self.data["variants"][0]["image_ids"] = "SYNTHETIC-MISSING"
        self.assertIn("MISSING_MEDIA_REFERENCE", self.codes(self.check()[0]))

    def test_missing_size_chart_reference(self):
        self.data["styles"][0]["size_chart_id"] = "SYNTHETIC-MISSING"
        self.assertIn("MISSING_MEDIA_REFERENCE", self.codes(self.check()[0]))

    def test_image_belongs_to_other_variant(self):
        self.data["variants"][0]["image_ids"] = self.data["variants"][1]["image_ids"]
        self.assertIn("MEDIA_SCOPE", self.codes(self.check()[0]))

    def test_local_media_requires_root_and_actual_file(self):
        self.data["media"][0]["location"] = "SYNTHETIC-test.png"
        self.assertIn("MEDIA_ROOT_REQUIRED", self.codes(self.check()[0]))
        self.assertIn("MISSING_MEDIA_FILE", self.codes(self.check(media_root=self.path)[0]))
        (self.path / "SYNTHETIC-test.png").write_text("SYNTHETIC presence fixture; not a product image.", encoding="utf-8")
        self.assertNotIn("MISSING_MEDIA_FILE", self.codes(self.check(media_root=self.path)[0]))

    def test_media_traversal_rejected(self):
        self.data["media"][0]["location"] = "../outside.png"
        self.assertIn("MEDIA_PATH", self.codes(self.check(media_root=self.path)[0]))

    def test_malformed_media_url_and_control_character(self):
        for value in ("https://[", "https://example.invalid:bad/x"):
            self.data["media"][0]["location"] = value
            self.assertIn("MEDIA_URL", self.codes(self.check()[0]))
        self.data["media"][0]["location"] = "bad\x00file"
        self.assertIn("CONTROL_CHARACTER", self.codes(self.check()[0]))

    def test_media_modes_cannot_mix(self):
        self.data["media"][0]["location"] = "SYNTHETIC-local.png"
        self.assertIn("MIXED_IMAGE_MODES", self.codes(self.check()[0]))

    def test_multichannel_target_blocked(self):
        self.data["configuration"][0]["channel_count"] = "2"
        self.assertIn("MULTICHANNEL_UNSUPPORTED", self.codes(self.check()[0]))

    def test_inputs_unchanged(self):
        self.write()
        before = {path.name: hashlib.sha256(path.read_bytes()).digest() for path in self.path.glob("*.csv")}
        Audit(self.path, True).check()
        after = {path.name: hashlib.sha256(path.read_bytes()).digest() for path in self.path.glob("*.csv")}
        self.assertEqual(before, after)

    def test_empty_templates_fail(self):
        self.assertFalse(Audit(ROOT / "templates").check()["mapping_compatible"])

    def test_csv_bom_and_quoted_name(self):
        self.data["styles"][0]["name"] = 'SYNTHETIC, "quoted" fixture'
        self.write()
        path = self.path / "styles.csv"
        path.write_bytes(b"\xef\xbb\xbf" + path.read_bytes())
        self.assertTrue(Audit(self.path, True).check()["mapping_compatible"])

    def test_malformed_headers_and_rows(self):
        self.write()
        path = self.path / "styles.csv"
        path.write_text("sku,sku\nx,x\n", encoding="utf-8")
        self.assertIn("HEADER", self.codes(Audit(self.path, True).check()))
        path.write_text(",".join(SCHEMAS["styles"]) + "\n\"unterminated", encoding="utf-8")
        self.assertIn("CSV_READ", self.codes(Audit(self.path, True).check()))

    def test_native_output_semantics(self):
        report, audit = self.check()
        self.assertTrue(report["mapping_compatible"])
        parent, first, second = list(audit.import_rows())
        self.assertEqual(parent["type"], "configurable")
        self.assertEqual(first["type"], "simple")
        self.assertEqual(first["parent_sku"], parent["sku"])
        self.assertEqual(first["price"], "100.00")
        self.assertEqual(first["inventories"], "synthetic-main=0,synthetic-other=2")
        self.assertEqual(second["inventories"], "synthetic-main=7")
        self.assertEqual(parent["images"], "https://example.invalid/SYNTHETIC-image-1.png,https://example.invalid/SYNTHETIC-image-2.png")
        self.assertNotIn("size-chart", parent["images"])
        parsed = parse_qs(parent["configurable_variants"].split("|")[0].replace(",", "&"))
        self.assertEqual(parsed, {"sku": ["SYNTHETIC-SKU-001"], "color": ["Test Blue"], "size": ["Test S"]})
        self.assertIn("group=synthetic-trade,qty=50,type=fixed,price=90.00", first["customer_group_prices"])

    def test_native_option_delimiters_roundtrip(self):
        label = "Test Blue & White + 5%"
        for table in ("variants", "allowed_combinations"):
            for row in self.data[table]:
                row["colour"] = label
        self.data["attribute_options"][0]["label"] = label
        report, audit = self.check()
        self.assertTrue(report["mapping_compatible"])
        parent = next(audit.import_rows())
        parsed = parse_qs(parent["configurable_variants"].split("|")[0].replace(",", "&"))
        self.assertEqual(parsed["color"], [label])

    def test_generated_headers_match_actual_importer_and_attribute_source(self):
        importer = (PROJECT / "backend/app/packages/Webkul/DataTransfer/src/Helpers/Importers/Product/Importer.php").read_text(encoding="utf-8")
        native = re.search(r"protected array \$validColumnNames = \[(.*?)\];", importer, re.S).group(1)
        native = set(re.findall(r"'([^']+)'", native))
        base = (PROJECT / "docs/database/vk7sports_base_data.sql").read_text(encoding="utf-8")
        attributes = re.search(r"INSERT INTO public\.attributes .*?VALUES\s*(.*?);", base, re.S).group(1)
        dynamic = set(re.findall(r"(?m)^\s*\(\d+, '([^']+)'", attributes))
        self.assertEqual(set(IMPORT_COLUMNS) - native - dynamic, set())
        self.assertIn("parse_str(str_replace(',', '&', $variant), $variantAttributes)", importer)
        self.assertIn("->findWhereIn('admin_name', $optionLabels)", importer)
        with (ROOT / "templates/bagisto_import.csv").open(encoding="utf-8", newline="") as stream:
            self.assertEqual(next(csv.reader(stream)), IMPORT_COLUMNS)

    def test_cli_rejects_invalid_export_with_empty_stdout(self):
        self.write()
        result = subprocess.run([sys.executable, "-B", str(ROOT / "validate.py"), "--data-dir", str(self.path), "--bagisto-csv"], capture_output=True, text=True)
        self.assertEqual(result.returncode, 1)
        self.assertEqual(result.stdout, "")
        self.assertFalse(json.loads(result.stderr)["mapping_compatible"])

    def test_cli_synthetic_csv_stdout_only(self):
        self.write()
        before = sorted(path.name for path in self.path.iterdir())
        result = subprocess.run([sys.executable, "-B", str(ROOT / "validate.py"), "--data-dir", str(self.path), "--allow-synthetic", "--bagisto-csv"], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        rows = list(csv.DictReader(io.StringIO(result.stdout)))
        self.assertEqual(len(rows), 3)
        self.assertTrue(all(row["sku"].startswith("SYNTHETIC-") for row in rows))
        self.assertEqual(before, sorted(path.name for path in self.path.iterdir()))


if __name__ == "__main__":
    unittest.main()

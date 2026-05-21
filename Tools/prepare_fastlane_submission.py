from __future__ import annotations

import json
import os
import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIELDS_PATH = ROOT / "AppStoreSubmission" / "app-store-connect-fields.json"
FASTLANE = ROOT / "fastlane"
LOCALE = "en-GB"


def env(name: str, fallback: str) -> str:
    value = os.environ.get(name, "").strip()
    return value if value else fallback


def required_url(name: str, fallback: str) -> str:
    value = env(name, fallback)
    if os.environ.get("CI") and ("YOUR_DOMAIN" in value or not value.startswith("https://")):
        raise SystemExit(f"{name} must be set to a live https:// URL for App Store upload.")
    return value


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.strip() + "\n", encoding="utf-8")


def prepare_metadata() -> None:
    fields = json.loads(FIELDS_PATH.read_text(encoding="utf-8"))
    listing = fields["localization_en_GB"]
    version = fields["version"]
    review = fields["review_information"]
    metadata_dir = FASTLANE / "metadata" / LOCALE
    review_dir = FASTLANE / "metadata" / "review_information"
    metadata_dir.mkdir(parents=True, exist_ok=True)
    review_dir.mkdir(parents=True, exist_ok=True)

    keywords = env(
        "APP_KEYWORDS",
        "fleet,vehicle checks,defects,van,truck,courier,MOT,maintenance,PDF,logistics",
    )

    write(metadata_dir / "name.txt", env("APP_NAME", listing["name"]))
    write(metadata_dir / "subtitle.txt", env("APP_SUBTITLE", listing["subtitle"]))
    write(metadata_dir / "promotional_text.txt", env("APP_PROMOTIONAL_TEXT", listing["promotional_text"]))
    write(metadata_dir / "description.txt", env("APP_DESCRIPTION", listing["description"]))
    write(metadata_dir / "keywords.txt", keywords[:100])
    write(metadata_dir / "support_url.txt", required_url("APP_SUPPORT_URL", listing["support_url"]))
    write(metadata_dir / "marketing_url.txt", required_url("APP_MARKETING_URL", listing["marketing_url"]))
    write(metadata_dir / "privacy_url.txt", required_url("APP_PRIVACY_URL", listing["privacy_policy_url"]))
    write(metadata_dir / "release_notes.txt", env("APP_RELEASE_NOTES", version["release_notes"]))
    write(FASTLANE / "metadata" / "copyright.txt", env("APP_COPYRIGHT", version["copyright"]))
    write(review_dir / "first_name.txt", env("APP_REVIEW_FIRST_NAME", review["contact_first_name"]))
    write(review_dir / "last_name.txt", env("APP_REVIEW_LAST_NAME", review["contact_last_name"]))
    write(review_dir / "phone_number.txt", env("APP_REVIEW_PHONE", review["contact_phone"]))
    write(review_dir / "email_address.txt", env("APP_REVIEW_EMAIL", review["contact_email"]))
    write(review_dir / "notes.txt", env("APP_REVIEW_NOTES", review["notes"]))

    app_icon = ROOT / "AppStoreSubmission" / "Assets" / "AppStoreIcon-1024.png"
    if app_icon.exists():
        shutil.copy2(app_icon, FASTLANE / "metadata" / "app_icon.png")


def prepare_screenshots() -> None:
    source = ROOT / "AppStoreSubmission" / "Screenshots" / LOCALE
    destination = FASTLANE / "screenshots" / LOCALE
    if destination.exists():
        shutil.rmtree(destination)
    destination.mkdir(parents=True, exist_ok=True)

    for png in sorted(source.glob("*/*.png")):
        device = png.parent.name
        shutil.copy2(png, destination / f"{device}-{png.name}")


def main() -> None:
    prepare_metadata()
    prepare_screenshots()


if __name__ == "__main__":
    main()

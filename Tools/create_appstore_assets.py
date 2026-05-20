from __future__ import annotations

import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ICONSET = ROOT / "FleetScanAI" / "Resources" / "Assets.xcassets" / "AppIcon.appiconset"
SUBMISSION = ROOT / "AppStoreSubmission"


BLUE = (0, 97, 230)
DEEP_BLUE = (11, 31, 59)
CHARCOAL = (31, 41, 55)
TEXT = (20, 26, 35)
MUTED = (94, 105, 118)
BG = (244, 248, 252)
CARD = (255, 255, 255)
GREEN = (22, 163, 74)
ORANGE = (245, 128, 32)
RED = (220, 38, 38)
YELLOW = (255, 212, 59)


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
    ]
    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def multiline(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    fnt: ImageFont.ImageFont,
    fill: tuple[int, int, int],
    max_width: int,
    spacing: int = 8,
) -> int:
    words = text.split()
    lines: list[str] = []
    line = ""
    for word in words:
        candidate = word if not line else f"{line} {word}"
        if text_size(draw, candidate, fnt)[0] <= max_width:
            line = candidate
        else:
            if line:
                lines.append(line)
            line = word
    if line:
        lines.append(line)

    x, y = xy
    for line in lines:
        draw.text((x, y), line, font=fnt, fill=fill)
        y += text_size(draw, line, fnt)[1] + spacing
    return y


def rounded(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int, fill, outline=None, width: int = 1) -> None:
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def draw_truck(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], color: tuple[int, int, int], width: int) -> None:
    x1, y1, x2, y2 = box
    w = x2 - x1
    h = y2 - y1
    body = (x1, y1 + int(h * 0.25), x1 + int(w * 0.62), y1 + int(h * 0.68))
    cab = (x1 + int(w * 0.62), y1 + int(h * 0.38), x2, y1 + int(h * 0.68))
    draw.rounded_rectangle(body, radius=max(4, width), outline=color, width=width)
    draw.rounded_rectangle(cab, radius=max(4, width), outline=color, width=width)
    draw.line((x1 + int(w * 0.69), y1 + int(h * 0.38), x1 + int(w * 0.77), y1 + int(h * 0.25), x2 - width, y1 + int(h * 0.38)), fill=color, width=width)
    for cx in (x1 + int(w * 0.23), x1 + int(w * 0.76)):
        draw.ellipse((cx - int(h * 0.12), y1 + int(h * 0.62), cx + int(h * 0.12), y1 + int(h * 0.86)), outline=color, width=width)


def draw_check(draw: ImageDraw.ImageDraw, points: tuple[tuple[int, int], tuple[int, int], tuple[int, int]], color, width: int) -> None:
    draw.line(points, fill=color, width=width, joint="curve")


def app_icon(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), DEEP_BLUE)
    draw = ImageDraw.Draw(img)
    margin = int(size * 0.08)
    rounded(draw, (margin, margin, size - margin, size - margin), int(size * 0.18), BLUE)
    for i in range(10):
        alpha = i / 9
        color = (
            int(BLUE[0] * (1 - alpha) + 0 * alpha),
            int(BLUE[1] * (1 - alpha) + 160 * alpha),
            int(BLUE[2] * (1 - alpha) + 255 * alpha),
        )
        y = margin + int((size - 2 * margin) * i / 10)
        draw.rectangle((margin, y, size - margin, y + int(size * 0.08)), fill=color)
    rounded(draw, (margin, margin, size - margin, size - margin), int(size * 0.18), None, outline=(255, 255, 255), width=max(2, int(size * 0.012)))

    truck_box = (int(size * 0.19), int(size * 0.36), int(size * 0.80), int(size * 0.68))
    draw_truck(draw, truck_box, (255, 255, 255), max(4, int(size * 0.035)))
    draw.ellipse((int(size * 0.62), int(size * 0.16), int(size * 0.85), int(size * 0.39)), fill=(255, 255, 255))
    draw_check(
        draw,
        (
            (int(size * 0.675), int(size * 0.275)),
            (int(size * 0.725), int(size * 0.325)),
            (int(size * 0.805), int(size * 0.225)),
        ),
        BLUE,
        max(4, int(size * 0.025)),
    )
    draw.text((int(size * 0.20), int(size * 0.72)), "AI", font=font(int(size * 0.15), True), fill=(255, 255, 255))
    return img


def save_app_icons() -> None:
    ICONSET.mkdir(parents=True, exist_ok=True)
    entries = [
        ("iphone", "20x20", "2x", 40),
        ("iphone", "20x20", "3x", 60),
        ("iphone", "29x29", "2x", 58),
        ("iphone", "29x29", "3x", 87),
        ("iphone", "40x40", "2x", 80),
        ("iphone", "40x40", "3x", 120),
        ("iphone", "60x60", "2x", 120),
        ("iphone", "60x60", "3x", 180),
        ("ipad", "20x20", "1x", 20),
        ("ipad", "20x20", "2x", 40),
        ("ipad", "29x29", "1x", 29),
        ("ipad", "29x29", "2x", 58),
        ("ipad", "40x40", "1x", 40),
        ("ipad", "40x40", "2x", 80),
        ("ipad", "76x76", "1x", 76),
        ("ipad", "76x76", "2x", 152),
        ("ipad", "83.5x83.5", "2x", 167),
        ("ios-marketing", "1024x1024", "1x", 1024),
    ]
    images = []
    for idiom, size_label, scale, pixels in entries:
        name = f"AppIcon-{idiom}-{size_label.replace('.', '_')}@{scale}.png"
        app_icon(pixels).save(ICONSET / name)
        images.append({"idiom": idiom, "size": size_label, "scale": scale, "filename": name})

    (ICONSET / "Contents.json").write_text(
        json.dumps({"images": images, "info": {"author": "xcode", "version": 1}}, indent=2),
        encoding="utf-8",
    )

    asset_dir = SUBMISSION / "Assets"
    asset_dir.mkdir(parents=True, exist_ok=True)
    app_icon(1024).save(asset_dir / "AppStoreIcon-1024.png")


def draw_status_bar(draw: ImageDraw.ImageDraw, width: int, y: int, color=CHARCOAL) -> None:
    draw.text((80, y), "9:41", font=font(28, True), fill=color)
    x = width - 170
    draw.rounded_rectangle((x, y + 6, x + 66, y + 26), radius=6, outline=color, width=3)
    draw.rectangle((x + 66, y + 12, x + 72, y + 20), fill=color)
    draw.rectangle((x + 8, y + 12, x + 55, y + 21), fill=color)


def draw_phone_frame(base: Image.Image, x: int, y: int, w: int, h: int, screen_name: str) -> None:
    draw = ImageDraw.Draw(base)
    rounded(draw, (x, y, x + w, y + h), 54, (9, 16, 28))
    rounded(draw, (x + 18, y + 18, x + w - 18, y + h - 18), 42, (248, 250, 252))
    draw.rounded_rectangle((x + w // 2 - 70, y + 34, x + w // 2 + 70, y + 50), radius=8, fill=(9, 16, 28))
    content = (x + 44, y + 78, x + w - 44, y + h - 52)
    draw_app_ui(draw, content, screen_name)


def draw_ipad_frame(base: Image.Image, x: int, y: int, w: int, h: int, screen_name: str) -> None:
    draw = ImageDraw.Draw(base)
    rounded(draw, (x, y, x + w, y + h), 42, (9, 16, 28))
    rounded(draw, (x + 20, y + 20, x + w - 20, y + h - 20), 28, (248, 250, 252))
    content = (x + 54, y + 62, x + w - 54, y + h - 56)
    draw_app_ui(draw, content, screen_name, ipad=True)


def badge(draw: ImageDraw.ImageDraw, x: int, y: int, text: str, fill, color=(255, 255, 255)) -> int:
    f = font(22, True)
    tw, th = text_size(draw, text, f)
    rounded(draw, (x, y, x + tw + 28, y + th + 18), 18, fill)
    draw.text((x + 14, y + 8), text, font=f, fill=color)
    return x + tw + 42


def draw_app_ui(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], screen_name: str, ipad: bool = False) -> None:
    x1, y1, x2, y2 = box
    w = x2 - x1
    y = y1
    draw.text((x1, y), "FleetScan AI", font=font(36 if ipad else 28, True), fill=TEXT)
    y += 60

    if screen_name == "dashboard":
        draw.text((x1, y), "Dashboard", font=font(46 if ipad else 34, True), fill=TEXT)
        y += 70
        cols = 2
        tile_w = (w - 18) // cols
        for i, (label, value, color) in enumerate([
            ("Vehicles", "12", BLUE),
            ("Open defects", "4", ORANGE),
            ("Due checks", "3", RED),
            ("Plan", "Pro", GREEN),
        ]):
            tx = x1 + (i % cols) * (tile_w + 18)
            ty = y + (i // cols) * 135
            rounded(draw, (tx, ty, tx + tile_w, ty + 118), 18, CARD)
            draw.text((tx + 22, ty + 18), value, font=font(38, True), fill=color)
            draw.text((tx + 22, ty + 70), label, font=font(20), fill=MUTED)
        y += 290
        rounded(draw, (x1, y, x2, y + 74), 18, BLUE)
        draw.text((x1 + 30, y + 20), "New Vehicle Check", font=font(26, True), fill=(255, 255, 255))
        y += 105
        for label, sev in [("Ford Transit - tyres failed", "High"), ("Mercedes Sprinter due service", "Due today")]:
            rounded(draw, (x1, y, x2, y + 96), 18, CARD)
            draw.text((x1 + 24, y + 20), label, font=font(24, True), fill=TEXT)
            badge(draw, x2 - 160, y + 24, sev, RED if sev == "High" else BLUE)
            y += 118

    elif screen_name == "inspection":
        draw.text((x1, y), "Daily walkaround", font=font(42 if ipad else 32, True), fill=TEXT)
        y += 68
        for i, (label, status, color) in enumerate([
            ("Tyres", "Pass", GREEN),
            ("Lights", "Pass", GREEN),
            ("Brakes", "Pass", GREEN),
            ("Windscreen", "Fail", RED),
            ("Load security", "Pass", GREEN),
        ]):
            rounded(draw, (x1, y, x2, y + 86), 16, CARD)
            draw.text((x1 + 24, y + 24), label, font=font(24, True), fill=TEXT)
            badge(draw, x2 - 130, y + 22, status, color)
            y += 102

    elif screen_name == "ai":
        draw.text((x1, y), "AI defect scan", font=font(42 if ipad else 32, True), fill=TEXT)
        y += 64
        rounded(draw, (x1, y, x2, y + 250), 20, (224, 239, 255))
        draw_truck(draw, (x1 + 70, y + 64, x2 - 70, y + 172), BLUE, 9)
        y += 280
        rounded(draw, (x1, y, x2, y + 165), 18, CARD)
        draw.text((x1 + 24, y + 20), "Possible windscreen crack", font=font(25, True), fill=TEXT)
        badge(draw, x1 + 24, y + 68, "High", RED)
        draw.text((x1 + 24, y + 112), "Recommend qualified inspection", font=font(20), fill=MUTED)
        y += 190
        rounded(draw, (x1, y, x2, y + 96), 18, CARD)
        draw.text((x1 + 24, y + 22), "AI findings must be reviewed", font=font(22, True), fill=RED)

    elif screen_name == "fleet":
        draw.text((x1, y), "Fleet manager", font=font(42 if ipad else 32, True), fill=TEXT)
        y += 70
        for label, value, color in [("Urgent vehicles", "2", RED), ("Failed checks", "5", ORANGE), ("Open defects", "9", BLUE)]:
            rounded(draw, (x1, y, x2, y + 106), 18, CARD)
            draw.text((x1 + 24, y + 24), value, font=font(38, True), fill=color)
            draw.text((x1 + 100, y + 36), label, font=font(24, True), fill=TEXT)
            y += 128
        for vehicle in ["Van 04 - not roadworthy", "Truck 12 - brake warning"]:
            rounded(draw, (x1, y, x2, y + 88), 16, CARD)
            draw.text((x1 + 24, y + 24), vehicle, font=font(22, True), fill=TEXT)
            y += 104

    elif screen_name == "reports":
        draw.text((x1, y), "PDF reports", font=font(42 if ipad else 32, True), fill=TEXT)
        y += 72
        rounded(draw, (x1, y, x2, y + 320), 22, CARD)
        draw.text((x1 + 26, y + 28), "Inspection Report", font=font(30, True), fill=TEXT)
        draw.text((x1 + 26, y + 80), "Vehicle: Transit T-104", font=font(22), fill=MUTED)
        draw.text((x1 + 26, y + 122), "Severity breakdown", font=font(23, True), fill=TEXT)
        bx = x1 + 26
        for label, color in [("Low 2", GREEN), ("Med 1", ORANGE), ("High 1", RED)]:
            bx = badge(draw, bx, y + 166, label, color)
        draw.line((x1 + 26, y + 240, x2 - 26, y + 240), fill=(210, 220, 230), width=3)
        draw.text((x1 + 26, y + 260), "Signature: __________________", font=font(20), fill=MUTED)
        y += 350
        rounded(draw, (x1, y, x2, y + 74), 18, BLUE)
        draw.text((x1 + 30, y + 20), "Export PDF", font=font(26, True), fill=(255, 255, 255))

    elif screen_name == "paywall":
        draw.text((x1, y), "FleetScan AI Plans", font=font(38 if ipad else 30, True), fill=TEXT)
        y += 64
        for plan, price, color in [("Free", "£0", MUTED), ("Pro Monthly", "£24.99", BLUE), ("Business", "£99.99", GREEN)]:
            rounded(draw, (x1, y, x2, y + 135), 18, CARD)
            draw.text((x1 + 24, y + 22), plan, font=font(26, True), fill=TEXT)
            draw.text((x2 - 170, y + 24), price, font=font(25, True), fill=color)
            draw.text((x1 + 24, y + 74), "AI scans, reports, reminders", font=font(20), fill=MUTED)
            y += 155


def screenshot(path: Path, size: tuple[int, int], title: str, subtitle: str, screen: str, ipad: bool = False) -> None:
    width, height = size
    img = Image.new("RGB", size, BG)
    draw = ImageDraw.Draw(img)

    draw.rectangle((0, 0, width, int(height * 0.36)), fill=(229, 241, 255))
    draw_status_bar(draw, width, 44)

    top = int(height * 0.10)
    draw.text((80, top), title, font=font(74 if not ipad else 82, True), fill=TEXT)
    multiline(draw, (80, top + (180 if not ipad else 190)), subtitle, font(34 if not ipad else 38), MUTED, width - 160, 10)

    if ipad:
        draw_ipad_frame(img, 220, int(height * 0.34), width - 440, int(height * 0.58), screen)
    else:
        draw_phone_frame(img, int(width * 0.19), int(height * 0.36), int(width * 0.62), int(height * 0.58), screen)

    draw.text((80, height - 82), "AI suggestions are not legal, MOT, or mechanical certification.", font=font(22), fill=MUTED)
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)


def save_screenshots() -> None:
    shots = [
        ("01-dashboard", "Daily checks in minutes", "Start vehicle inspections, see open defects, due checks, reminders, and subscription status from one fast dashboard.", "dashboard"),
        ("02-inspection", "Field-worker checklist", "Pass, fail, add notes, severity, and photo evidence for every daily walkaround item.", "inspection"),
        ("03-ai-scan", "AI-assisted defect review", "Mock AI suggests visible issues with confidence and recommended next actions for human approval.", "ai"),
        ("04-fleet", "Fleet visibility for managers", "Track urgent vehicles, failed checks, inspection history, and driver-submitted reports.", "fleet"),
        ("05-reports", "Export PDF records", "Generate inspection PDFs with vehicle details, checklist results, defect photos, AI findings, notes, and disclaimers.", "reports"),
    ]
    iphone_dir = SUBMISSION / "Screenshots" / "en-GB" / "iPhone-6.9"
    iphone_65_dir = SUBMISSION / "Screenshots" / "en-GB" / "iPhone-6.5"
    ipad_dir = SUBMISSION / "Screenshots" / "en-GB" / "iPad-13"
    for name, title, subtitle, screen in shots:
        screenshot(iphone_dir / f"{name}.png", (1320, 2868), title, subtitle, screen, ipad=False)
        screenshot(iphone_65_dir / f"{name}.png", (1242, 2688), title, subtitle, screen, ipad=False)
        screenshot(ipad_dir / f"{name}.png", (2048, 2732), title, subtitle, screen, ipad=True)

    screenshot(
        SUBMISSION / "InAppPurchase" / "subscription-review-screenshot.png",
        (1320, 2868),
        "Subscriptions",
        "Free, Pro, and Business plans with clear limits and upgrade options.",
        "paywall",
        ipad=False,
    )


def main() -> None:
    save_app_icons()
    save_screenshots()


if __name__ == "__main__":
    main()

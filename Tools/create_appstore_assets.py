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
    img = Image.new("RGB", size, (248, 250, 252))
    draw = ImageDraw.Draw(img)

    draw_status_bar(draw, width, 44 if not ipad else 36)
    safe_top = 112 if not ipad else 92
    side_margin = 64 if not ipad else 96
    content_bottom = height - (152 if not ipad else 112)
    draw_app_ui(draw, (side_margin, safe_top, width - side_margin, content_bottom), screen, ipad=ipad)

    if not ipad:
        bar_y = height - 116
        rounded(draw, (38, bar_y, width - 38, height - 34), 34, CARD)
        tabs = [("Dashboard", BLUE), ("Vehicles", MUTED), ("Defects", MUTED), ("Reports", MUTED)]
        tab_w = (width - 76) // len(tabs)
        for i, (label, color) in enumerate(tabs):
            x = 38 + i * tab_w
            draw.ellipse((x + tab_w // 2 - 12, bar_y + 18, x + tab_w // 2 + 12, bar_y + 42), fill=color)
            tw, _ = text_size(draw, label, font(18, True))
            draw.text((x + (tab_w - tw) // 2, bar_y + 50), label, font=font(18, True), fill=color)
    else:
        draw.text((side_margin, height - 64), "FleetScan AI uses local data and mock AI suggestions for review.", font=font(22), fill=MUTED)

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


def scaled_font(size: int, width: int, ipad: bool = False, bold: bool = False) -> ImageFont.FreeTypeFont:
    base = 2048 if ipad else 1320
    return font(max(11, int(size * width / base)), bold)


def premium_badge(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    label: str,
    fill,
    width: int,
    ipad: bool = False,
    color=(255, 255, 255),
) -> int:
    f = scaled_font(24, width, ipad, True)
    tw, th = text_size(draw, label, f)
    pad_x = int(18 * width / (2048 if ipad else 1320))
    pad_y = int(10 * width / (2048 if ipad else 1320))
    radius = int(18 * width / (2048 if ipad else 1320))
    rounded(draw, (x, y, x + tw + pad_x * 2, y + th + pad_y * 2), radius, fill)
    draw.text((x + pad_x, y + pad_y - 1), label, font=f, fill=color)
    return x + tw + pad_x * 2 + int(12 * width / (2048 if ipad else 1320))


def card(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int, fill=CARD, outline=(226, 232, 240)) -> None:
    x1, y1, x2, y2 = box
    rounded(draw, (x1 + 5, y1 + 7, x2 + 5, y2 + 7), radius, (221, 229, 238))
    rounded(draw, box, radius, fill, outline=outline, width=2)


def progress_bar(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], progress: float, color=BLUE) -> None:
    x1, y1, x2, y2 = box
    rounded(draw, box, max(4, (y2 - y1) // 2), (224, 232, 242))
    fill_x = x1 + max(y2 - y1, int((x2 - x1) * max(0, min(progress, 1))))
    rounded(draw, (x1, y1, fill_x, y2), max(4, (y2 - y1) // 2), color)


def draw_vehicle_photo(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], width: int, ipad: bool = False) -> None:
    x1, y1, x2, y2 = box
    h = y2 - y1
    rounded(draw, box, int(28 * width / (2048 if ipad else 1320)), (222, 239, 255), outline=(190, 218, 247), width=2)
    for i in range(18):
        yy = y1 + int(h * i / 18)
        color = (222 - i * 2, 239 - i, 255)
        draw.line((x1 + 2, yy, x2 - 2, yy), fill=color, width=max(2, h // 45))
    road_y = y1 + int(h * 0.72)
    draw.polygon([(x1 + 20, road_y), (x2 - 20, road_y), (x2 - 80, y2 - 20), (x1 + 80, y2 - 20)], fill=(205, 216, 228))
    draw.line((x1 + int((x2 - x1) * 0.50), road_y + 18, x1 + int((x2 - x1) * 0.50), y2 - 28), fill=(255, 255, 255), width=5)
    truck_box = (x1 + int((x2 - x1) * 0.16), y1 + int(h * 0.30), x2 - int((x2 - x1) * 0.14), y1 + int(h * 0.68))
    draw.rounded_rectangle((truck_box[0], truck_box[1], truck_box[2] - int((x2 - x1) * 0.23), truck_box[3]), radius=16, fill=(255, 255, 255), outline=(145, 164, 185), width=4)
    draw.rounded_rectangle((truck_box[2] - int((x2 - x1) * 0.25), truck_box[1] + int(h * 0.08), truck_box[2], truck_box[3]), radius=16, fill=(235, 242, 250), outline=(145, 164, 185), width=4)
    draw.rectangle((truck_box[2] - int((x2 - x1) * 0.20), truck_box[1] + int(h * 0.13), truck_box[2] - int((x2 - x1) * 0.05), truck_box[1] + int(h * 0.24)), fill=(91, 145, 205))
    for cx in (truck_box[0] + int((x2 - x1) * 0.15), truck_box[2] - int((x2 - x1) * 0.12)):
        draw.ellipse((cx - 28, truck_box[3] - 24, cx + 28, truck_box[3] + 32), fill=(34, 45, 61))
        draw.ellipse((cx - 12, truck_box[3] - 8, cx + 12, truck_box[3] + 16), fill=(226, 232, 240))


def premium_status_bar(draw: ImageDraw.ImageDraw, width: int, ipad: bool = False) -> None:
    y = 40 if ipad else 46
    draw.text((int(width * 0.055), y), "9:41", font=scaled_font(28, width, ipad, True), fill=TEXT)
    x = width - int(width * 0.16)
    signal_y = y + int(8 * width / (2048 if ipad else 1320))
    for i, h in enumerate([8, 13, 18]):
        draw.rounded_rectangle((x + i * 15, signal_y + 18 - h, x + i * 15 + 8, signal_y + 18), radius=3, fill=TEXT)
    battery_x = width - int(width * 0.085)
    draw.rounded_rectangle((battery_x, signal_y, battery_x + 58, signal_y + 24), radius=7, outline=TEXT, width=3)
    draw.rectangle((battery_x + 8, signal_y + 7, battery_x + 48, signal_y + 17), fill=GREEN)
    draw.rectangle((battery_x + 60, signal_y + 8, battery_x + 66, signal_y + 16), fill=TEXT)


def nav_scaffold(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    screen: str,
    ipad: bool = False,
) -> tuple[int, int, int, int]:
    x1, y1, x2, y2 = box
    width = x2 - x1
    if ipad:
        sidebar_w = int(width * 0.23)
        card(draw, (x1, y1, x1 + sidebar_w, y2), 26, fill=(252, 253, 255), outline=(232, 237, 244))
        draw.text((x1 + 32, y1 + 34), "FleetScan AI", font=scaled_font(30, x2, True, True), fill=TEXT)
        items = [
            ("Dashboard", "dashboard"),
            ("Inspection", "inspection"),
            ("AI Scan", "ai"),
            ("Defects", "defects"),
            ("Fleet", "fleet"),
            ("Maintenance", "maintenance"),
            ("Reports", "reports"),
            ("Plans", "plans"),
        ]
        yy = y1 + 118
        for label, key in items:
            selected = key == screen
            fill = (229, 241, 255) if selected else (252, 253, 255)
            rounded(draw, (x1 + 22, yy, x1 + sidebar_w - 22, yy + 58), 16, fill)
            dot = BLUE if selected else (176, 190, 205)
            draw.ellipse((x1 + 42, yy + 21, x1 + 58, yy + 37), fill=dot)
            draw.text((x1 + 76, yy + 16), label, font=scaled_font(20, x2, True, selected), fill=TEXT if selected else MUTED)
            yy += 74
        premium_badge(draw, x1 + 30, y2 - 88, "Business Plan", BLUE, x2, True)
        return (x1 + sidebar_w + 42, y1 + 18, x2, y2)

    draw.text((x1, y1), "FleetScan AI", font=scaled_font(28, x2, False, True), fill=TEXT)
    premium_badge(draw, x2 - int(148 * x2 / 1320), y1 - 2, "Pro", BLUE, x2, False)
    return (x1, y1 + int(76 * x2 / 1320), x2, y2)


def bottom_tabs(draw: ImageDraw.ImageDraw, width: int, height: int, selected: str) -> None:
    bar_y = height - 132
    rounded(draw, (50, bar_y, width - 50, height - 34), 34, (255, 255, 255), outline=(222, 230, 240), width=2)
    tabs = [("dashboard", "Home"), ("inspection", "Check"), ("defects", "Defects"), ("reports", "Reports")]
    tab_w = (width - 100) // len(tabs)
    for i, (key, label) in enumerate(tabs):
        cx = 50 + i * tab_w + tab_w // 2
        color = BLUE if (selected == key or (selected in ("ai", "fleet", "maintenance", "plans") and i == 0)) else (132, 146, 166)
        draw.ellipse((cx - 14, bar_y + 22, cx + 14, bar_y + 50), fill=color)
        tw, _ = text_size(draw, label, scaled_font(17, width, False, True))
        draw.text((cx - tw // 2, bar_y + 58), label, font=scaled_font(17, width, False, True), fill=color)


def section_heading(draw: ImageDraw.ImageDraw, x: int, y: int, title: str, subtitle: str, max_width: int, width: int, ipad: bool) -> int:
    draw.text((x, y), title, font=scaled_font(50 if not ipad else 54, width, ipad, True), fill=TEXT)
    return multiline(draw, (x, y + int(70 * width / (2048 if ipad else 1320))), subtitle, scaled_font(23 if not ipad else 24, width, ipad), MUTED, max_width, spacing=8)


def metric(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], value: str, label: str, color, width: int, ipad: bool) -> None:
    card(draw, box, 22)
    x1, y1, x2, _ = box
    draw.text((x1 + 24, y1 + 20), value, font=scaled_font(42 if not ipad else 40, width, ipad, True), fill=color)
    draw.text((x1 + 24, y1 + 78), label, font=scaled_font(20, width, ipad), fill=MUTED)


def list_row(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    title: str,
    subtitle: str,
    badge_text: str,
    badge_color,
    width: int,
    ipad: bool,
) -> None:
    card(draw, box, 18)
    x1, y1, x2, _ = box
    draw.text((x1 + 22, y1 + 20), title, font=scaled_font(23 if not ipad else 21, width, ipad, True), fill=TEXT)
    draw.text((x1 + 22, y1 + 58), subtitle, font=scaled_font(18 if not ipad else 17, width, ipad), fill=MUTED)
    f = scaled_font(19, width, ipad, True)
    tw, th = text_size(draw, badge_text, f)
    bx = x2 - tw - 54
    rounded(draw, (bx, y1 + 28, x2 - 22, y1 + 28 + th + 20), 16, badge_color)
    draw.text((bx + 16, y1 + 38), badge_text, font=f, fill=(255, 255, 255))


def draw_dashboard_screen(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], width: int, ipad: bool) -> None:
    x1, y1, x2, y2 = box
    y = section_heading(draw, x1, y1, "Fleet checks, faster.", "See readiness, urgent defects, due checks, and reminders before vehicles leave the yard.", x2 - x1, width, ipad) + 28
    hero_h = 390 if not ipad else 360
    card(draw, (x1, y, x2, y + hero_h), 28, fill=(12, 34, 64), outline=(12, 34, 64))
    draw.text((x1 + 34, y + 34), "Today's fleet readiness", font=scaled_font(24, width, ipad, True), fill=(209, 226, 249))
    draw.text((x1 + 34, y + 84), "86%", font=scaled_font(78, width, ipad, True), fill=(255, 255, 255))
    progress_bar(draw, (x1 + 36, y + 190, x1 + int((x2 - x1) * 0.48), y + 212), 0.86, GREEN)
    draw.text((x1 + 34, y + 236), "12 vehicles checked | 2 urgent | 3 due today", font=scaled_font(22, width, ipad), fill=(209, 226, 249))
    draw_vehicle_photo(draw, (x1 + int((x2 - x1) * 0.54), y + 38, x2 - 34, y + hero_h - 34), width, ipad)
    y += hero_h + 34
    cols = 4 if ipad else 2
    gap = 22
    tile_w = (x2 - x1 - gap * (cols - 1)) // cols
    for i, (value, label, color) in enumerate([("2", "Urgent", RED), ("5", "Open defects", ORANGE), ("3", "Due checks", BLUE), ("Pro", "Subscription", GREEN)]):
        tx = x1 + (i % cols) * (tile_w + gap)
        ty = y + (i // cols) * 142
        metric(draw, (tx, ty, tx + tile_w, ty + 120), value, label, color, width, ipad)
    y += (142 if ipad else 284) + 20
    draw.text((x1, y), "Needs attention", font=scaled_font(28, width, ipad, True), fill=TEXT)
    y += 50
    for title, sub, b, c in [
        ("Transit T-104", "High severity tyre sidewall damage", "High", RED),
        ("Sprinter V-22", "Service due today at 48,210 miles", "Due", BLUE),
        ("Truck 12", "Brake warning captured by driver", "Critical", RED),
    ]:
        list_row(draw, (x1, y, x2, y + 104), title, sub, b, c, width, ipad)
        y += 126


def draw_inspection_screen(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], width: int, ipad: bool) -> None:
    x1, y1, x2, _ = box
    y = section_heading(draw, x1, y1, "Daily walkaround.", "Pass, fail, add severity, notes, and photo evidence without slowing drivers down.", x2 - x1, width, ipad) + 26
    card(draw, (x1, y, x2, y + 170), 24)
    draw.text((x1 + 26, y + 24), "Ford Transit - T104", font=scaled_font(28, width, ipad, True), fill=TEXT)
    draw.text((x1 + 26, y + 70), "11 of 15 checklist items complete", font=scaled_font(21, width, ipad), fill=MUTED)
    progress_bar(draw, (x1 + 26, y + 118, x2 - 26, y + 140), 0.73, BLUE)
    y += 204
    rows = [
        ("Tyres", "All visible tread and sidewalls checked", "Pass", GREEN),
        ("Lights", "Front, rear, indicators, brake lights", "Pass", GREEN),
        ("Windscreen", "Possible chip logged with photo", "Fail", RED),
        ("Body damage", "Rear door dent, note added", "Medium", ORANGE),
        ("Load security", "Load restraint checked", "Pass", GREEN),
        ("Dashboard warnings", "No warning lights visible", "Pass", GREEN),
        ("Trailer coupling", "Not applicable to this vehicle", "N/A", MUTED),
    ]
    for title, sub, b, c in rows:
        list_row(draw, (x1, y, x2, y + 102), title, sub, b, c, width, ipad)
        y += 119


def draw_ai_screen(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], width: int, ipad: bool) -> None:
    x1, y1, x2, _ = box
    y = section_heading(draw, x1, y1, "AI defect scan.", "AI-assisted review highlights visible issues from inspection photos for human review and approval.", x2 - x1, width, ipad) + 26
    photo_h = 430 if not ipad else 420
    draw_vehicle_photo(draw, (x1, y, x2, y + photo_h), width, ipad)
    premium_badge(draw, x1 + 28, y + 28, "Scanning photo", BLUE, width, ipad)
    rounded(draw, (x1 + 96, y + 182, x2 - 118, y + 210), 14, (255, 255, 255))
    rounded(draw, (x1 + 134, y + 256, x2 - 180, y + 282), 13, (255, 255, 255))
    y += photo_h + 32
    card(draw, (x1, y, x2, y + 260), 24)
    draw.text((x1 + 26, y + 24), "Possible windscreen crack", font=scaled_font(29, width, ipad, True), fill=TEXT)
    bx = x1 + 26
    bx = premium_badge(draw, bx, y + 78, "High severity", RED, width, ipad)
    premium_badge(draw, bx, y + 78, "88% confidence", BLUE, width, ipad)
    multiline(draw, (x1 + 26, y + 132), "Appears to show a visible crack. Recommend inspection by a qualified mechanic before use.", scaled_font(21, width, ipad), MUTED, x2 - x1 - 52)
    y += 292
    card(draw, (x1, y, x2, y + 122), 20, fill=(255, 248, 237), outline=(249, 211, 159))
    draw.text((x1 + 24, y + 24), "AI findings must be reviewed", font=scaled_font(23, width, ipad, True), fill=TEXT)
    draw.text((x1 + 24, y + 62), "Not MOT, legal, roadworthiness, or mechanical certification.", font=scaled_font(18, width, ipad), fill=MUTED)


def draw_defects_screen(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], width: int, ipad: bool) -> None:
    x1, y1, x2, _ = box
    y = section_heading(draw, x1, y1, "Prioritise repairs.", "Approve AI findings, mark roadworthiness, track repair notes, and resolve defects with before and after photos.", x2 - x1, width, ipad) + 28
    card(draw, (x1, y, x2, y + 150), 24, fill=(255, 245, 245), outline=(255, 205, 205))
    draw.text((x1 + 26, y + 26), "Vehicle status", font=scaled_font(23, width, ipad, True), fill=TEXT)
    draw.text((x1 + 26, y + 74), "Not roadworthy until critical defects are reviewed", font=scaled_font(22, width, ipad), fill=RED)
    premium_badge(draw, x2 - int(190 * width / (2048 if ipad else 1320)), y + 48, "Urgent", RED, width, ipad)
    y += 184
    for title, sub, sev, color in [
        ("Tyre sidewall damage", "Repair priority: immediate | approved by manager", "Critical", RED),
        ("Rear light housing cracked", "Before photo attached | repair booked", "Medium", ORANGE),
        ("Mirror scuff", "Resolved with after photo and notes", "Resolved", GREEN),
    ]:
        list_row(draw, (x1, y, x2, y + 116), title, sub, sev, color, width, ipad)
        y += 138
    card(draw, (x1, y, x2, y + 230), 24)
    draw.text((x1 + 26, y + 24), "Before / after evidence", font=scaled_font(25, width, ipad, True), fill=TEXT)
    thumb_w = (x2 - x1 - 78) // 2
    draw_vehicle_photo(draw, (x1 + 26, y + 78, x1 + 26 + thumb_w, y + 206), width, ipad)
    draw_vehicle_photo(draw, (x1 + 52 + thumb_w, y + 78, x2 - 26, y + 206), width, ipad)


def draw_fleet_screen(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], width: int, ipad: bool) -> None:
    x1, y1, x2, _ = box
    y = section_heading(draw, x1, y1, "Fleet visibility.", "Managers can see failed checks, urgent vehicles, open defects, and driver-submitted reports.", x2 - x1, width, ipad) + 30
    cols = 3
    gap = 20
    tile_w = (x2 - x1 - gap * 2) // 3
    for i, (value, label, color) in enumerate([("18", "Vehicles", BLUE), ("4", "Failed today", RED), ("9", "Open defects", ORANGE)]):
        metric(draw, (x1 + i * (tile_w + gap), y, x1 + i * (tile_w + gap) + tile_w, y + 126), value, label, color, width, ipad)
    y += 162
    for title, sub, b, c in [
        ("Van 04", "Driver: A. Cole | check failed 08:12", "Critical", RED),
        ("Truck 12", "Dashboard warning | submitted with 2 photos", "High", RED),
        ("Pickup 7", "MOT expires in 12 days", "Due", BLUE),
        ("Trailer 2", "Coupling inspection completed", "Clear", GREEN),
        ("Car 3", "No open defects", "Ready", GREEN),
    ]:
        list_row(draw, (x1, y, x2, y + 104), title, sub, b, c, width, ipad)
        y += 124


def draw_maintenance_screen(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], width: int, ipad: bool) -> None:
    x1, y1, x2, _ = box
    y = section_heading(draw, x1, y1, "Stay ahead of due dates.", "Track MOT, insurance, service, tyres, brakes, oil changes, and inspection reminders locally.", x2 - x1, width, ipad) + 30
    card(draw, (x1, y, x2, y + 170), 24, fill=(235, 247, 255), outline=(198, 224, 248))
    draw.text((x1 + 26, y + 24), "Next critical reminder", font=scaled_font(23, width, ipad, True), fill=TEXT)
    draw.text((x1 + 26, y + 72), "MOT expiry - Transit T-104", font=scaled_font(32, width, ipad, True), fill=BLUE)
    draw.text((x1 + 26, y + 124), "Due in 9 days | notification scheduled", font=scaled_font(21, width, ipad), fill=MUTED)
    y += 206
    for title, sub, b, c in [
        ("Insurance renewal", "Fleet policy renewal | Jun 18, 2026", "24 days", BLUE),
        ("Brake inspection", "Truck 12 | high priority defect follow-up", "7 days", RED),
        ("Oil change", "Sprinter V-22 | 49,000 mile service", "Soon", ORANGE),
        ("Tyre replacement", "Pickup 7 | front axle notes attached", "Booked", GREEN),
        ("Daily inspection", "All active vehicles | weekday reminder", "On", GREEN),
    ]:
        list_row(draw, (x1, y, x2, y + 104), title, sub, b, c, width, ipad)
        y += 124


def draw_reports_screen(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], width: int, ipad: bool) -> None:
    x1, y1, x2, _ = box
    y = section_heading(draw, x1, y1, "PDF records ready to share.", "Generate inspection reports with photos, checklist results, AI findings, driver notes, and disclaimers.", x2 - x1, width, ipad) + 30
    card(draw, (x1, y, x2, y + 520), 28)
    draw.text((x1 + 34, y + 32), "Inspection Report", font=scaled_font(36, width, ipad, True), fill=TEXT)
    draw.text((x1 + 34, y + 92), "Vehicle: Transit T-104 | Date: 25 May 2026", font=scaled_font(22, width, ipad), fill=MUTED)
    yb = y + 152
    for label, color, pct in [("Passed checklist", GREEN, 0.78), ("Open defects", ORANGE, 0.42), ("Critical severity", RED, 0.18)]:
        draw.text((x1 + 34, yb), label, font=scaled_font(21, width, ipad, True), fill=TEXT)
        progress_bar(draw, (x1 + 280, yb + 8, x2 - 34, yb + 26), pct, color)
        yb += 70
    draw.line((x1 + 34, y + 382, x2 - 34, y + 382), fill=(218, 226, 236), width=3)
    draw.text((x1 + 34, y + 418), "Signature: __________________________", font=scaled_font(21, width, ipad), fill=MUTED)
    y += 552
    rounded(draw, (x1, y, x2, y + 92), 26, BLUE)
    draw.text((x1 + 34, y + 28), "Export and share PDF", font=scaled_font(28, width, ipad, True), fill=(255, 255, 255))


def draw_plans_screen(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], width: int, ipad: bool) -> None:
    x1, y1, x2, _ = box
    y = section_heading(draw, x1, y1, "Unlock Pro fleet workflows.", "Subscriptions add AI defect scanning, PDF exports, reminders, fleet dashboards, and business tools.", x2 - x1, width, ipad) + 28
    plans = [
        ("Free", "GBP 0", "2 vehicles | 5 inspections/month | basic reports", MUTED, False),
        ("Pro Monthly", "GBP 24.99/mo", "AI scans | PDF exports | reminders | 10 vehicles", BLUE, True),
        ("Business", "GBP 99.99/mo", "Unlimited vehicles | fleet dashboard | custom branding", GREEN, False),
    ]
    for name, price, features, color, selected in plans:
        fill = (235, 247, 255) if selected else CARD
        outline = BLUE if selected else (226, 232, 240)
        card(draw, (x1, y, x2, y + 178), 24, fill=fill, outline=outline)
        draw.text((x1 + 26, y + 24), name, font=scaled_font(28, width, ipad, True), fill=TEXT)
        draw.text((x1 + 26, y + 70), price, font=scaled_font(24, width, ipad, True), fill=color)
        multiline(draw, (x1 + 26, y + 112), features, scaled_font(19, width, ipad), MUTED, x2 - x1 - 52)
        if selected:
            premium_badge(draw, x2 - int(188 * width / (2048 if ipad else 1320)), y + 34, "Best value", BLUE, width, ipad)
        y += 202
    card(draw, (x1, y, x2, y + 112), 20, fill=(255, 248, 237), outline=(249, 211, 159))
    draw.text((x1 + 24, y + 24), "Auto-renewable subscription", font=scaled_font(22, width, ipad, True), fill=TEXT)
    draw.text((x1 + 24, y + 62), "Manage or cancel from your Apple ID subscription settings.", font=scaled_font(18, width, ipad), fill=MUTED)


def draw_premium_app_ui(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], screen: str, ipad: bool = False) -> None:
    content = nav_scaffold(draw, box, screen, ipad)
    width = box[2]
    if screen == "dashboard":
        draw_dashboard_screen(draw, content, width, ipad)
    elif screen == "inspection":
        draw_inspection_screen(draw, content, width, ipad)
    elif screen == "ai":
        draw_ai_screen(draw, content, width, ipad)
    elif screen == "defects":
        draw_defects_screen(draw, content, width, ipad)
    elif screen == "fleet":
        draw_fleet_screen(draw, content, width, ipad)
    elif screen == "maintenance":
        draw_maintenance_screen(draw, content, width, ipad)
    elif screen == "reports":
        draw_reports_screen(draw, content, width, ipad)
    elif screen == "plans":
        draw_plans_screen(draw, content, width, ipad)


def draw_context_panel(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    screen: str,
    width: int,
    ipad: bool,
) -> None:
    x1, y1, x2, y2 = box
    if y2 <= y1 + 220:
        return

    panel_copy = {
        "dashboard": (
            "Premium fleet operations",
            ["Live readiness snapshot", "Priority repair queue", "Business plan status"],
            "A single command surface for checks, defects, reminders, and compliance records.",
        ),
        "inspection": (
            "Inspection evidence trail",
            ["Pass/fail results", "Severity and notes", "Photo attachments"],
            "Drivers can capture structured walkaround records quickly in the field.",
        ),
        "ai": (
            "Cautious AI assistance",
            ["Visible issues only", "Confidence scoring", "Human approval flow"],
            "AI suggestions are clearly labelled and must be reviewed before action.",
        ),
        "defects": (
            "Repair workflow built in",
            ["Roadworthy status", "Before/after photos", "Resolution tracking"],
            "Managers can prioritise urgent work and keep repair notes with the vehicle history.",
        ),
        "fleet": (
            "Manager-grade visibility",
            ["Failed checks", "Urgent vehicles", "Driver submissions"],
            "See which vehicles need action before they are assigned to routes.",
        ),
        "maintenance": (
            "Due dates under control",
            ["MOT and insurance", "Service reminders", "Local notifications"],
            "Maintenance warnings help teams avoid missed renewals and overdue inspections.",
        ),
        "reports": (
            "Professional PDF records",
            ["Checklist results", "Defect photos", "Signature placeholder"],
            "Reports are designed for sharing, filing, and internal compliance workflows.",
        ),
        "plans": (
            "Monetised Pro features",
            ["AI scans", "PDF exports", "Fleet dashboard"],
            "Subscriptions unlock the tools fleet operators expect from a paid SaaS product.",
        ),
    }
    title, points, summary = panel_copy[screen]
    card(draw, (x1, y1, x2, y2), 28, fill=(12, 34, 64), outline=(12, 34, 64))
    draw.text((x1 + 32, y1 + 30), title, font=scaled_font(30 if not ipad else 28, width, ipad, True), fill=(255, 255, 255))
    multiline(draw, (x1 + 32, y1 + 82), summary, scaled_font(20 if not ipad else 19, width, ipad), (209, 226, 249), x2 - x1 - 64, spacing=7)

    area_top = y1 + int(172 * width / (2048 if ipad else 1320))
    gap = int(18 * width / (2048 if ipad else 1320))
    cols = 3 if ipad else 1
    item_h = int(110 * width / (2048 if ipad else 1320))
    item_w = (x2 - x1 - 64 - gap * (cols - 1)) // cols
    for index, point in enumerate(points):
        px = x1 + 32 + (index % cols) * (item_w + gap)
        py = area_top + (index // cols) * (item_h + gap)
        rounded(draw, (px, py, px + item_w, py + item_h), 20, (255, 255, 255))
        draw.ellipse((px + 22, py + 32, px + 54, py + 64), fill=BLUE)
        draw.text((px + 72, py + 32), point, font=scaled_font(21 if not ipad else 18, width, ipad, True), fill=TEXT)

    note_y = y2 - int(90 * width / (2048 if ipad else 1320))
    if note_y > area_top + item_h + gap:
        rounded(draw, (x1 + 32, note_y, x2 - 32, y2 - 28), 18, (235, 247, 255))
        draw.text((x1 + 56, note_y + 24), "Local-first records with cautious AI suggestions and safety disclaimers.", font=scaled_font(18, width, ipad, True), fill=DEEP_BLUE)


def premium_screenshot(path: Path, size: tuple[int, int], screen: str, ipad: bool = False) -> None:
    width, height = size
    img = Image.new("RGB", size, (246, 249, 252))
    draw = ImageDraw.Draw(img)
    premium_status_bar(draw, width, ipad)
    top = 106 if not ipad else 96
    side = 64 if not ipad else 88
    bottom = 164 if not ipad else 82
    draw_premium_app_ui(draw, (side, top, width - side, height - bottom), screen, ipad)
    if ipad:
        total_w = width - side * 2
        panel_x = side + int(total_w * 0.23) + 42
        panel_y = height - bottom - 900
        panel_box = (panel_x, panel_y, width - side, height - bottom - 18)
    else:
        panel_y = height - bottom - 980
        panel_box = (side, panel_y, width - side, height - bottom - 20)
    draw_context_panel(draw, panel_box, screen, width, ipad)
    if not ipad:
        bottom_tabs(draw, width, height, screen)
    else:
        draw.text((side, height - 54), "FleetScan AI keeps inspections local-first with cautious AI suggestions.", font=scaled_font(18, width, True), fill=MUTED)
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, optimize=True)


def clear_pngs(folder: Path) -> None:
    folder.mkdir(parents=True, exist_ok=True)
    for png in folder.glob("*.png"):
        png.unlink()


def save_screenshots() -> None:
    shots = [
        ("01-dashboard", "dashboard"),
        ("02-inspection", "inspection"),
        ("03-ai-scan", "ai"),
        ("04-defects", "defects"),
        ("05-fleet", "fleet"),
        ("06-maintenance", "maintenance"),
        ("07-reports", "reports"),
        ("08-plans", "plans"),
    ]
    iphone_dir = SUBMISSION / "Screenshots" / "en-GB" / "iPhone-6.9"
    iphone_65_dir = SUBMISSION / "Screenshots" / "en-GB" / "iPhone-6.5"
    ipad_dir = SUBMISSION / "Screenshots" / "en-GB" / "iPad-13"
    for folder in (iphone_dir, iphone_65_dir, ipad_dir):
        clear_pngs(folder)

    for name, screen in shots:
        premium_screenshot(iphone_dir / f"{name}.png", (1320, 2868), screen, ipad=False)
        premium_screenshot(iphone_65_dir / f"{name}.png", (1242, 2688), screen, ipad=False)
        premium_screenshot(ipad_dir / f"{name}.png", (2048, 2732), screen, ipad=True)

    premium_screenshot(
        SUBMISSION / "InAppPurchase" / "subscription-review-screenshot.png",
        (1320, 2868),
        "plans",
        ipad=False,
    )


def main() -> None:
    save_app_icons()
    save_screenshots()


if __name__ == "__main__":
    main()

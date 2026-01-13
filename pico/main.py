import time
import gc
import network
import urequests

import secrets

import inky_frame
from picographics import PicoGraphics, DISPLAY_INKY_FRAME_SPECTRA_7
import pngdec


URL = "https://jcleary.github.io/family-info/images/screenshot.png"

# If you're running on battery and want RTC wake-ups, set this True.
# Note: when plugged in via USB, Inky Frame won't enter deep sleep. :contentReference[oaicite:6]{index=6}
USE_DEEP_SLEEP = False

# In deep sleep mode, Inky Frame wakes, runs main.py once, then sleeps again.
SLEEP_MINUTES = 60


def connect_wifi(timeout_s=30):
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)

    if wlan.isconnected():
        return wlan

    wlan.connect(secrets.WIFI_SSID, secrets.WIFI_PASSWORD)

    t0 = time.time()
    while not wlan.isconnected():
        if time.time() - t0 > timeout_s:
            raise RuntimeError("WiFi connect timed out")
        time.sleep(0.25)

    return wlan


def fetch_png_bytes(url):
    # Keep it simple: pull into RAM, then pngdec.open_RAM(...)
    # If you hit MemoryError, see notes below about using microSD + open_file().
    r = urequests.get(url)
    try:
        if r.status_code != 200:
            raise RuntimeError("HTTP status {}".format(r.status_code))
        data = r.content
        return data
    finally:
        r.close()


def show_error(display, msg):
    # Minimal error rendering (so you can see failures without a serial console)
    display.set_pen(display.create_pen(255, 255, 255))
    display.clear()
    display.set_pen(display.create_pen(0, 0, 0))
    display.set_font("sans")
    display.text("Update failed:", 10, 10, scale=2)
    display.text(str(msg), 10, 40, wordwrap=780, scale=1)
    display.update()


def update_screen(display):
    gc.collect()

    png_bytes = fetch_png_bytes(URL)

    # Decode + draw
    png = pngdec.PNG(display)
    png.open_RAM(png_bytes)

    # If your PNG is exactly 800x480, (0,0) is perfect.
    # If not, you can use decode(..., scale=..., source=..., rotate=...) :contentReference[oaicite:7]{index=7}
    # 'mode' controls dithering/posterise behavior. Default is PNG_POSTERISE in many builds. :contentReference[oaicite:8]{index=8}
    png.decode(0, 0)

    # Push to the e-paper panel (slow refresh is normal)
    display.update()


def main():
    # This firmware is typically pre-configured for 7.3" Spectra builds. :contentReference[oaicite:9]{index=9}
    display = PicoGraphics(display=DISPLAY_INKY_FRAME_SPECTRA_7)

    # Connect Wi-Fi once per wake/run
    connect_wifi()

    try:
        update_screen(display)
    except Exception as e:
        show_error(display, e)
        return

    if USE_DEEP_SLEEP:
        # Uses RTC on Inky Frame to wake after N minutes. :contentReference[oaicite:10]{index=10}
        inky_frame.sleep_for(SLEEP_MINUTES)
    else:
        # USB-powered “always on” mode: update every hour forever.
        while True:
            time.sleep(3600)
            try:
                update_screen(display)
            except Exception as e:
                show_error(display, e)


main()

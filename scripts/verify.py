from pathlib import Path
import hashlib
import tempfile
import zipfile
from lupa.lua51 import LuaRuntime

root = Path(__file__).resolve().parents[1]
files = [root / "ThreatPercentage.toc", root / "ThreatPercentage.lua"]
lua_source = files[1].read_text()
for initial in ("0", "1"):
    for reload in range(2):
        lua = LuaRuntime()
        lua.execute('''
            value = nil
            writes = 0
            C_CVar = { SetCVar = function(name, newValue)
                assert(name == "threatShowNumeric")
                value = newValue
                writes = writes + 1
            end }
            function CreateFrame(kind)
                assert(kind == "Frame")
                frame = { events = {} }
                function frame:RegisterEvent(event) self.events[event] = true end
                function frame:UnregisterEvent(event) self.events[event] = nil end
                function frame:SetScript(kind, handler)
                    assert(kind == "OnEvent")
                    self.handler = handler
                end
                return frame
            end
            function dispatch(event)
                if frame.events[event] then frame.handler(frame, event) end
            end
        ''')
        lua.globals().value = initial
        lua.execute(lua_source)
        lua.execute('dispatch("ADDON_LOADED"); dispatch("PLAYER_ENTERING_WORLD")')
        assert lua.globals().writes == 0
        lua.execute('dispatch("PLAYER_LOGIN")')
        assert lua.globals().value == "1"
        assert lua.globals().writes == 1
        lua.execute('dispatch("PLAYER_ENTERING_WORLD"); dispatch("PLAYER_LOGIN")')
        assert lua.globals().writes == 1

dist = root / "dist"
dist.mkdir(exist_ok=True)
package = dist / "ThreatPercentage.zip"
with zipfile.ZipFile(package, "w", zipfile.ZIP_DEFLATED) as archive:
    for file in files:
        archive.write(file, "ThreatPercentage/" + file.name)
with tempfile.TemporaryDirectory() as directory:
    destination = Path(directory) / "_retail_" / "Interface" / "AddOns"
    with zipfile.ZipFile(package) as archive:
        archive.extractall(destination)
    for file in files:
        assert (destination / "ThreatPercentage" / file.name).read_bytes() == file.read_bytes()
results = ["Command: python scripts/verify.py", "PASS: login from enabled/disabled state, fresh UI reload, unrelated events, and packaged installation."]
for file in files + [package]:
    results.append(f"SHA256 {file.name}: {hashlib.sha256(file.read_bytes()).hexdigest()}")
(dist / "verification.txt").write_text("\n".join(results) + "\n")
print("\n".join(results))

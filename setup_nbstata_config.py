"""Configure nbstata for Stata integration."""

from pathlib import Path

# Create nbstata config directory if it doesn't exist
config_dir = Path.home() / ".nbstata"
config_dir.mkdir(exist_ok=True)

# Create configuration file
config_file = config_dir / "config.ini"

config_content = """[nbstata]
stata_dir = C:\\Program Files\\Stata18
stata_edition = se
graph_format = svg
graph_redundant_svgfix = False

[pystata]
stata_path = C:\\Program Files\\Stata18\\StataSE-64.exe
"""

with open(config_file, "w") as f:
    f.write(config_content)

print(f"✓ Created nbstata configuration at: {config_file}")
print("Configuration contents:")
print(config_content)

print("\n✅ nbstata is now configured to work with your Stata installation!")
print("\nTo test:")
print("1. Start Jupyter Lab: just lab")
print("2. Create a new notebook with 'nbstata' kernel")
print("3. Try running: sysuse auto, clear")

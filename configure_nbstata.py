"""Configure nbstata to work with Stata installation"""

import os

import nbstata.config

# Set the Stata directory (not the executable)
stata_dir = r"C:\Program Files\Stata18"
stata_executable = r"C:\Program Files\Stata18\StataSE-64.exe"

print("Configuring nbstata...")
print(f"Stata directory: {stata_dir}")
print(f"Stata executable: {stata_executable}")

# Check if Stata exists
if os.path.exists(stata_executable):
    print("✓ Stata executable found")

    # Try to set the pystata path with directory
    try:
        nbstata.config.set_pystata_path(stata_dir)
        print("✓ nbstata configured successfully")
    except Exception as e:
        print(f"Error configuring nbstata: {e}")

    # Try to launch stata to test
    try:
        result = nbstata.config.launch_stata()
        print(f"✓ Stata launch test result: {result}")
    except Exception as e:
        print(f"Warning - Stata launch test failed: {e}")

else:
    print("✗ Stata executable not found at specified path")
    print("Please check your Stata installation")

print("\nConfiguration complete!")

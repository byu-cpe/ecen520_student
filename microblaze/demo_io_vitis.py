# Python script to build the vitis 

# Import the vitis library
import vitis
import shutil

# Create a vitis client and set the workspace
client = vitis.create_client()
client.set_workspace(path="./demo_io/vitis")

# Create the microblaze platform componetn
platform = client.create_platform_component(name = "microblaze_io",hw_design = "./demo_io/demo_io.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0")
# Build the platform component
platform = client.get_component(name="microblaze_io")
status = platform.build()

# Create the empty "demo_io" application
comp = client.create_app_component(name="demo_io",platform = "./demo_io/vitis/microblaze_io/export/microblaze_io/microblaze_io.xpfm",domain = "standalone_microblaze_0",template = "empty_application")
# Copy the `demo_io.c` application to the project
shutil.copy("demo_io.c", "./demo_io/vitis/demo_io/src/demo_io.c")
# Copy the `CMakeLists.txt` application to the project
shutil.copy("CMakeLists.txt.demo_io", "./demo_io/vitis/demo_io/CMakeLists.txt")

# Build the "demo_io" application
comp = client.get_component(name="demo_io")
comp.build()

vitis.dispose()


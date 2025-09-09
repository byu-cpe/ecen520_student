# Simulate the transfer of the value 0xa5 using the default baud rate of 19_200
restart -force
run 100 ns
# Setup initial signals
force rst 1
force send 0
force din 8'h00
run 100 ns
# Setup clock (100 MHz)
force clk 1 0, 0 {5 ns} -r 10
force rst 0
run 400 ns
# start transfer
force din 8'ha5
run 10 ns
force send 1
run 20 ns
force send 0
run 10 us
force din 8'hff
# Wait the time to transfer (11 baud periods x )
run 640 us

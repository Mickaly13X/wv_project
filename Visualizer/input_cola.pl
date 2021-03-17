dut = [2:4];
fren = {1,3};
config in [| dut + fren];
#config = 2;
config[1] = dut

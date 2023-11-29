# create and clear output file
output_file="output.txt"
> "$output_file"
# compile design files
echo "compiling all"
ghdl -a --workdir=work -g -fexplicit -fsynopsys bullet_tank_const.vhd bullet.vhd tank.vhd char_buffer.vhd clock_counter.vhd collision_check.vhd colorROM.vhd pixelGenerator.vhd vga_sync.vhd de2lcd.vhd oneshot.vhd keyboard.vhd kb_mapper.vhd ps2.vhd leddcd.vhd score.vhd top_level.vhd bullet_tank_tb.vhd fire_collision_tb.vhd score_tb.vhd char_buffer_tb.vhd kb_mapper_tb.vhd collision_check_tb.vhd pixelGenerator_tb.vhd
# find test bench files
tbs=($(ls *_tb.vhd --format=single-column | sed 's/\..*$//'))
# run tests
for tb in "${tbs[@]}"; do
    echo "Running test $tb"
	ghdl --elab-run -g --workdir=work -fsynopsys $tb >> "$output_file"
done
echo "Output has been written to $output_file"
# Check for errors raised during simulation
if grep -q "assertion error" "$output_file"; then
	echo -e "\nFailed tests:"
	grep "assertion error" "$output_file"
else
    echo -e "\nAll tests passed!"
fi
# How to open the project correctly

**When opening the project,**

Remove all files
 ``` 
remove_files [get_files]
 ```

Then, add all the source files again (considering they are in the srcs/ directory)
 ``` 
set proj_dir [get_property DIRECTORY [current_project]]
add_files [glob $proj_dir/srcs/*.v]
set_property file_type {Verilog Header} [get_files constants.vh]
set_property top soc [current_fileset]
 ```

Then add the test bench files (considering they are in the sim/ directory)
 ```
set proj_dir [get_property DIRECTORY [current_project]]
add_files -fileset sim_1 [glob $proj_dir/sim/*.v]
set_property top tb_Soc [get_filesets sim_1]
 ```

This will let the .xpr know they exist and where they are.


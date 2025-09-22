# Goal: Compile


# --- Project Configuration ---
set project_dir      "/home/developer/vivado_projects/CPU" ;# Desired directory for the project
set project_name     "my_fpga_project"                        ;# Name of the Vivado project
set part_name        "xc7a100t-csg324-3"                        ;# Your target FPGA part

puts "Closing any designs that are currently open..."
puts ""
close_project -quiet
puts "Continuing..."

# --- Construct Full Project Path ---
set project_xpr_path [file join $project_dir $project_name.xpr]

# --- Check if Project Exists and Act Accordingly ---
if {[file exists $project_xpr_path]} {
    puts "INFO: Project '$project_name' already exists. Opening it."
    open_project $project_xpr_path
} else {
    puts "INFO: Project '$project_name' does not exist. Creating a new one."
    # Ensure the project directory exists before creating the project
    if {![file isdirectory $project_dir]} {
        file mkdir $project_dir
        puts "INFO: Created project directory: $project_dir"
    }
    create_project $project_name $project_dir -part $part_name
    save_project $project_name;# Save the newly created project
}

proc grab_files {fileset args} {
    if {[llength $args] > 0} {
        foreach rtl_path $args {
            if {[glob -nocomplain $rtl_path/*.sv] != ""} {
            read_verilog -fileset $fileset -sv [glob $rtl_path/*.sv]
            }
            if {[glob -nocomplain $rtl_path/*.v] != ""} {
            read_verilog -fileset $fileset [glob $rtl_path/*.v]
            }            
        }
    } else {
        error "args has length 0!"
    }
}

proc compile {top rtl_path part_name} {
    
    puts "rtl_path: $rtl_path"

    # Compile any .sv and .v files that exist in the current directory
    grab_files sources_1 rtl_path

    # puts "Synthesizing design..."
    # synth_design -top $top -flatten_hierarchy full 
    
    # Here is how you add a .xdc file to the project
    # read_xdc $top.xdc

    # start_gui

    # do functional verification
    # elaborate
    # launch_simulation
    # run 1000ns
    # add_wave *
    # restart
    # quit


    # do terminal-based simulation
    puts "----launching sim-----\n"
    # add files to 
    puts "grabbing sim files"
    grab_files sim_1 rtl_path
    puts "done grabbing sim files"
    set_property top $top [get_filesets sim_1]
    launch_simulation
    start_gui
    # can add a breakpoint in code (specifiy line number)
    puts "----finished launching sim-----\n"
    # stop_gui
    # reset_simulation

    ######

    # link_design -part $part_name; # I think this should be done after synthesis

    #####################

    
    # You will get DRC errors without the next two lineswhen you
    # # generate a bitstream.
    # set_property CFGBVS VCCO [current_design]
    # set_property CONFIG_VOLTAGE 3.3 [current_design]

    # # If you don't need an .xdc for pinouts (just generating designs for analysis),
    # # you can include the next line to avoid errors about unconstrained pins.
    # set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]

    # puts "Placing Design..."
    # place_design
    
    # puts "Routing Design..."
    # route_design

    # puts "Writing checkpoint"
    # write_checkpoint -force $top.dcp

    # STA


    # puts "Writing bitstream"
    # write_bitstream -force $top.bit
    
    # puts "All done..."

    # # You might want to close the project at this point, 
    # but probably not since you may want to do things with the design.
    #close_project

    }


# compile main rtl
compile main_tb rtl $part_name
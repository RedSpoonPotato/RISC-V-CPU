set_param project.enableReportConfiguration 0
load_feature core
current_fileset
xsim {tb_sim} -view {{wcfgs/latest.wcfg}} -tclbatch {init.tcl}

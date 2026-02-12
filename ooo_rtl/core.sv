module core #(

) (
    input clk;
);
    import global_params::*;
    
    // pipeline stages
    fetch_stage #() fetch_stage_inst;

    decode_stage #() decode_stage_inst;

    issue_stage #() issue_stage_inst;

    execute_memory_stage #() execute_memory_stage_inst;

    writeback_stage #() writeback_stage_inst;

    commit_stage #() commit_stage_inst;

endmodule
module core #(

) (
    input clk;
);
    import global_params::*;
    
    // IF
    if_stage #() if_stage_inst;
    
    
    // ID
    id_stage #() id_stage_inst;

    // EX
    ex_stage #() ex_stage_inst;

    // MEM
    mem_stage #() mem_stage_inst;

    // WB
    wb_stage #() wb_stage_inst;

endmodule
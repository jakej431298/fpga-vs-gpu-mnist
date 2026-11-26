module relu #(
    parameter SIZE       = 128,  
    parameter DATA_WIDTH = 24    
)(
    input  wire signed [DATA_WIDTH-1:0] data_in  [0:SIZE-1],
    output wire signed [DATA_WIDTH-1:0] data_out [0:SIZE-1]
);

    genvar i;
    generate
        for (i = 0; i < SIZE; i = i + 1) begin : relu_inst
            assign data_out[i] = data_in[i][DATA_WIDTH-1]
                                  ? {DATA_WIDTH{1'b0}}  
                                  : data_in[i];         
        end
    endgenerate
endmodule

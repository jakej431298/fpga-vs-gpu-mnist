module mac_unit #(
    parameter DATA_WIDTH = 8,   
    parameter ACC_WIDTH  = 24   
)(
    input  wire clk,
    input  wire rst_n,
    input  wire en,
    input  wire clear,
    input  wire signed [DATA_WIDTH-1:0] weight,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    output reg  signed [ACC_WIDTH-1:0]  acc_out,
    output reg valid_out
);

    
    reg signed [2*DATA_WIDTH-1:0] product_reg;
    reg                            valid_pipe;  
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            
            product_reg <= 0;
            valid_pipe  <= 1'b0;
        end else if (clear) begin
            
            product_reg <= 0;
            valid_pipe  <= 1'b0;
        end else if (en) begin
           
            product_reg <= weight * data_in;
            valid_pipe  <= 1'b1;
        end else begin
           
            valid_pipe  <= 1'b0;
        end
    end

  
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_out   <= 0;
            valid_out <= 1'b0;
        end else if (clear) begin
            acc_out   <= 0;
            valid_out <= 1'b0;
        end else if (valid_pipe) begin
            acc_out   <= acc_out +
                         {{(ACC_WIDTH - 2*DATA_WIDTH){product_reg[2*DATA_WIDTH-1]}},
                          product_reg};
            valid_out <= 1'b1;
        end
    end

endmodule

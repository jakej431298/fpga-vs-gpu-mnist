module fc_layer #(
    parameter INPUT_SIZE  = 4,          
    parameter OUTPUT_SIZE = 2,           
    parameter DATA_WIDTH  = 8,
    parameter ACC_WIDTH   = 24,
    parameter WEIGHT_FILE = "weights.mem" 
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         start,
    input  wire signed [DATA_WIDTH-1:0] data_in  [0:INPUT_SIZE-1],
    output reg  signed [ACC_WIDTH-1:0]  data_out [0:OUTPUT_SIZE-1],
    output reg                          done
);

    reg signed [DATA_WIDTH-1:0] weights [0:OUTPUT_SIZE*INPUT_SIZE-1];
    initial $readmemh(WEIGHT_FILE, weights);

    localparam IDLE    = 2'd0;
    localparam COMPUTE = 2'd1;  
    localparam DRAIN   = 2'd2; 
    localparam FINISH  = 2'd3;  
    reg [1:0] state;

    reg [$clog2(INPUT_SIZE)-1:0]  col;       
    reg [$clog2(OUTPUT_SIZE)-1:0] row;       
    reg [1:0]                     drain_cnt; 
    reg  mac_en, mac_clear;
    reg  signed [DATA_WIDTH-1:0] mac_w, mac_d;
    wire signed [ACC_WIDTH-1:0]  mac_acc;
    wire                         mac_valid;

    mac_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) u_mac (
        .clk      (clk),
        .rst_n    (rst_n),
        .en       (mac_en),
        .clear    (mac_clear),
        .weight   (mac_w),
        .data_in  (mac_d),
        .acc_out  (mac_acc),
        .valid_out(mac_valid)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            col       <= 0;
            row       <= 0;
            done      <= 1'b0;
            mac_en    <= 1'b0;
            mac_clear <= 1'b0;
            drain_cnt <= 0;
        end else begin
            
            done      <= 1'b0;
            mac_clear <= 1'b0;

            case (state)

                IDLE: begin
                    mac_en <= 1'b0;
                    if (start) begin
                        col       <= 0;
                        row       <= 0;
                        mac_clear <= 1'b1;  
                        state     <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    mac_en <= 1'b1;
                   
                    mac_w  <= weights[row * INPUT_SIZE + col];
                    mac_d  <= data_in[col];

                    if (col == INPUT_SIZE - 1) begin
                        mac_en    <= 1'b0;
                        col       <= 0;
                        drain_cnt <= 2;
                        state     <= DRAIN;
                    end else begin
                        col <= col + 1;
                    end
                end
                DRAIN: begin
                    if (drain_cnt == 0) begin
                        data_out[row] <= mac_acc;
                        mac_clear     <= 1'b1;  
                        if (row == OUTPUT_SIZE - 1) begin
                            state <= FINISH;
                        end else begin
                            row   <= row + 1;
                            state <= COMPUTE;
                        end
                    end else begin
                        drain_cnt <= drain_cnt - 1;
                    end
                end
                FINISH: begin
                    done  <= 1'b1;
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule

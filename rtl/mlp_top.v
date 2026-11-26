module mlp_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire signed [7:0] pixel_in  [0:783],
    output reg  [3:0]  predicted_class,
    output reg         done
);
    wire signed [23:0] l1_raw  [0:127];
    wire signed [23:0] l1_relu [0:127];
    wire               l1_done;

    fc_layer #(
        .INPUT_SIZE(784),
        .OUTPUT_SIZE(128),
        .DATA_WIDTH(8),
        .ACC_WIDTH(24),
        .WEIGHT_FILE("weights_l1.mem")
    ) u_layer1 (
        .clk     (clk),
        .rst_n   (rst_n),
        .start   (start),
        .data_in (pixel_in),
        .data_out(l1_raw),
        .done    (l1_done)
    );

    relu #(.SIZE(128), .DATA_WIDTH(24)) u_relu1 (
        .data_in (l1_raw),
        .data_out(l1_relu)
    );

    wire signed [7:0] l1_scaled [0:127];
    genvar k;
    generate
        for (k = 0; k < 128; k = k + 1) begin : scale1
            assign l1_scaled[k] = l1_relu[k][15:8];
        end
    endgenerate

    wire signed [23:0] l2_raw  [0:63];
    wire signed [23:0] l2_relu [0:63];
    wire               l2_done;

    fc_layer #(
        .INPUT_SIZE(128),
        .OUTPUT_SIZE(64),
        .DATA_WIDTH(8),
        .ACC_WIDTH(24),
        .WEIGHT_FILE("weights_l2.mem")
    ) u_layer2 (
        .clk     (clk),
        .rst_n   (rst_n),
        .start   (l1_done),    
        .data_in (l1_scaled),
        .data_out(l2_raw),
        .done    (l2_done)
    );

    relu #(.SIZE(64), .DATA_WIDTH(24)) u_relu2 (
        .data_in (l2_raw),
        .data_out(l2_relu)
    );

    wire signed [7:0] l2_scaled [0:63];
    generate
        for (k = 0; k < 64; k = k + 1) begin : scale2
            assign l2_scaled[k] = l2_relu[k][15:8];
        end
    endgenerate
    wire signed [23:0] l3_logits [0:9];
    wire               l3_done;

    fc_layer #(
        .INPUT_SIZE(64),
        .OUTPUT_SIZE(10),
        .DATA_WIDTH(8),
        .ACC_WIDTH(24),
        .WEIGHT_FILE("weights_l3.mem")
    ) u_layer3 (
        .clk     (clk),
        .rst_n   (rst_n),
        .start   (l2_done),
        .data_in (l2_scaled),
        .data_out(l3_logits),
        .done    (l3_done)
    );

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            predicted_class <= 4'd0;
            done            <= 1'b0;
        end else if (l3_done) begin
            begin : argmax
                reg signed [23:0] max_val;
                reg [3:0]         max_idx;
                max_val = l3_logits[0];
                max_idx = 4'd0;
                for (i = 1; i < 10; i = i + 1) begin
                    if (l3_logits[i] > max_val) begin
                        max_val = l3_logits[i];
                        max_idx = i[3:0];
                    end
                end
                predicted_class <= max_idx;
            end
            done <= 1'b1;
        end else begin
            done <= 1'b0;
        end
    end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2021 12:23:46 AM
// Design Name: 
// Module Name: i2c_temp
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module i2c_temp(
    input CLK100MHZ,
    input btnC,
    input btnR,
    inout I2C_SDA,
    output I2C_SCL,
    output [15:0] LED
    );

wire reset;

reg [15:0] ACK;
reg TEMP_ACK = 1'b1;
reg master_enable;
reg START = 1'bx;
reg SCL, SDA;
reg [6:0] SD_COUNTER;
reg [9:0] COUNT = 10'b0;
reg [7:0] MSB = 8'b0;
reg [7:0] LSB = 8'b0;

assign reset = btnC;
assign LED = ACK;

always @(posedge CLK100MHZ) begin
    COUNT <= COUNT + 1;
end

always @(posedge COUNT[9] or posedge reset) begin
    if (reset)
        START <= 0;
    else if (btnR)
        START <= 1;
end

always @(posedge COUNT[9] or posedge reset) begin
    if (reset)
        SD_COUNTER <= 7'b0;
    else begin
        if (!START)
            SD_COUNTER <= 0;
        else if (SD_COUNTER < 60)
            SD_COUNTER <= SD_COUNTER + 1;
    end
end

always @(posedge COUNT[9] or posedge reset) begin
    if (reset) begin
        ACK <= 16'b1111111111111111;
        master_enable <= 1;
        SCL <= 1;
        SDA <= 1;
    end
    else begin
        case (SD_COUNTER)
            7'd0: begin // start
                SDA <= 1;
                SCL <= 1;
            end
            7'd1: SDA <= 0;
            7'd2: SCL <= 0;
            7'd3: SDA <= 1; // slave addr
            7'd4: SDA <= 0;
            7'd5: SDA <= 0;
            7'd6: SDA <= 0;
            7'd7: SDA <= 0;
            7'd8: SDA <= 0;
            7'd9: SDA <= 0;
            7'd10: SDA <= 0; // write
            7'd11: begin ACK[15] <= I2C_SDA; master_enable <= 0; end // ack
            // 7'd11: master_enable <= 0;
            7'd12: begin master_enable <= 1; SDA <= 1; end // read temp
            7'd13: SDA <= 1;
            7'd14: SDA <= 1;
            7'd15: SDA <= 1;
            7'd16: SDA <= 0;
            7'd17: SDA <= 0;
            7'd18: SDA <= 1;
            7'd19: SDA <= 1;
            7'd20: begin ACK[14] <= I2C_SDA; master_enable <= 0; end // ack
            // 7'd20: master_enable <= 0;
            7'd21: master_enable <= 1;  // repeated start
            7'd22: begin
                SDA <= 1'b1;
                SCL <= 1'b1;
            end
            7'd23: SDA <= 0;
            7'd24: SCL <= 0;
            7'd25: SDA <= 1; // slave addr
            7'd26: SDA <= 0;
            7'd27: SDA <= 0;
            7'd28: SDA <= 0;
            7'd29: SDA <= 0;
            7'd30: SDA <= 0;
            7'd31: SDA <= 0;
            7'd32: SDA <= 1; // read
            7'd33: begin ACK[13] <= I2C_SDA; master_enable <= 0; end // nack
            7'd34: SDA <= 0;
            // 7'd33: master_enable <= 0; // nack
            // 7'd34: master_enable <= 1; // repeated start
            // 7'd35: begin
            //     SDA <= 1'b1;
            //     SCL <= 1'b1;
            // end
            // 7'd36: SDA <= 0;
            // 7'd37: SCL <= 0;
            // 7'd38: SDA <= 1; // slave addr
            // 7'd39: SDA <= 0;
            // 7'd40: SDA <= 0;
            // 7'd41: SDA <= 0;
            // 7'd42: SDA <= 0;
            // 7'd43: SDA <= 0;
            // 7'd44: SDA <= 0;
            // 7'd45: SDA <= 1; // read
            // // 7'd46: begin ACK[12] <= I2C_SDA; master_enable <= 0; end // ack
            // 7'd46: master_enable <= 0; // ack
            default: ACK[0] <= I2C_SDA; // should eventually turn off
        endcase
    end
end

// always @(negedge TEMP_ACK) begin
//     ACK[0] <= 1'b0;
// end

// assign I2C_SCL = ((SD_COUNTER >= 4) & (SD_COUNTER <= 21)) ? ~COUNT[9] : (SD_COUNTER >= 26) ? ~COUNT[9] : SCL;
assign I2C_SCL = ((SD_COUNTER >= 4) & (SD_COUNTER <= 21)) ? ~COUNT[9] : (SD_COUNTER >= 26) ? ~COUNT[9] : SCL;
assign I2C_SDA = (master_enable == 1) ? SDA : 'bz;

endmodule

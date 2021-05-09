`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2021 04:35:06 AM
// Design Name: 
// Module Name: i2c_firmware
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
module i2c_firmware(
    input CLK100MHZ,
    input btnC,
    input btnR,
    inout I2C_SDA,
    output I2C_SCL,
    output [15:0] LED
    );

wire reset;

reg master_enable;
reg START = 1'bx;
reg SCL, SDA;
reg [6:0] SD_COUNTER;
reg [9:0] COUNT = 10'b0;
reg [7:0] FWREV;

assign reset = btnC;
assign LED[7:0] = FWREV;

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
        master_enable <= 1;
        SCL <= 1;
        SDA <= 1;
        FWREV <= 0;
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
            7'd11: master_enable <= 0; // ack
            7'd12: begin master_enable <= 1; SDA <= 1; end // firmware first byte
            7'd13: SDA <= 0;
            7'd14: SDA <= 0;
            7'd15: SDA <= 0;
            7'd16: SDA <= 0;
            7'd17: SDA <= 1;
            7'd18: SDA <= 0;
            7'd19: SDA <= 0;
            7'd20: master_enable <= 0; // ack
            7'd21: begin master_enable <= 1; SDA <= 1; end // firmware second byte
            7'd22: SDA <= 0;
            7'd23: SDA <= 1;
            7'd24: SDA <= 1;
            7'd25: SDA <= 1;
            7'd26: SDA <= 0;
            7'd27: SDA <= 0;
            7'd28: SDA <= 0;
            7'd29: master_enable <= 0; // ack
            7'd30: master_enable <= 1; // start again
            7'd31: begin
                SDA <= 1;
                SCL <= 1;
            end
            7'd32: SDA <= 0;
            7'd33: SCL <= 0;
            7'd34: SDA <= 1; // save addr
            7'd35: SDA <= 0;
            7'd36: SDA <= 0;
            7'd37: SDA <= 0;
            7'd38: SDA <= 0;
            7'd39: SDA <= 0;
            7'd40: SDA <= 0;
            7'd41: SDA <= 1; // read
            7'd42: master_enable <= 0; // ack
            7'd44: FWREV[7] <= I2C_SDA; // firmware revision byte 
            7'd45: FWREV[6] <= I2C_SDA;
            7'd46: FWREV[5] <= I2C_SDA;
            7'd47: FWREV[4] <= I2C_SDA;
            7'd48: FWREV[3] <= I2C_SDA;
            7'd49: FWREV[2] <= I2C_SDA;
            7'd50: FWREV[1] <= I2C_SDA;
            7'd51: FWREV[0] <= I2C_SDA;
            7'd52: begin master_enable <= 1; SDA <= 1; end // nack
            7'd53: begin // stop condition
                SDA <= 0;
                SCL <= 1;
            end
            7'd54: SDA <= 1;
        endcase
    end
end

assign I2C_SCL = ((SD_COUNTER >= 4) & SD_COUNTER <= 30) ? ~COUNT[9] : ((SD_COUNTER >= 35) & (SD_COUNTER <= 54)) ? ~COUNT[9] : SCL;
assign I2C_SDA = (master_enable == 1) ? SDA : 'bz;

endmodule

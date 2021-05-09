`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2021 01:31:24 AM
// Design Name: 
// Module Name: tb_i2c_firmwaare
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


module tb_i2c_firmware;

wire I2C_SDA, I2C_SCL;
wire [15:0] LED;
reg CLK, BTNC, BTNR;

i2c_firmware UUT (
    .CLK100MHZ(CLK),
    .btnC(BTNC),
    .btnR(BTNR),
    .I2C_SDA(I2C_SDA),
    .I2C_SCL(I2C_SCL),
    .LED(LED)
);

always begin
    #5 CLK = ~CLK;
end

initial begin
    CLK = 0;
    BTNC = 0;

    #10 BTNC = 1;
    #10 BTNC = 0;
    #10 BTNR = 1;
end
        
endmodule

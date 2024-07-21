/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
*/

`default_nettype none

module tt_um_wfang4285 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output reg  [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n    // reset_n - low to reset
);

  // FSM representing security chip based on sensor/ other inputs.
  localparam [1:0]
      OFF = 2'b00,
      ARMED = 2'b01,
      TRIGGERED = 2'b10,
      ALARM_ON = 2'b11;

  reg [1:0] current;
  reg [1:0] next;
  reg alarm; // Alarm output
  
  //Updating next state.
  always @(*) begin
    next = current;
    case(current)
      OFF: if (ui_in[0]) next = ARMED;
           else next = OFF;
      ARMED: if (ui_in[1]) next = TRIGGERED;
             else next = ARMED;
      TRIGGERED: if (ui_in[2]) next = ALARM_ON;
                 else next = TRIGGERED;
      ALARM_ON: next = ALARM_ON;
      default: next = OFF;
    endcase 
  end

  //Alarm updating
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current <= OFF;
      alarm <= 0;
    end else begin
      current <= next;
      if (current == ALARM_ON) begin
        alarm <= 1;
      end else begin
        alarm <= 0;
      end
    end
  end

  //Output pin update.
  always @(*) begin
    uo_out[1:0] = current;
    uo_out[3:2] = next;
    uo_out[4] = alarm;
  end 
  
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:3], ui_out[7:5], uio_in, 1'b0};
  assign uio_oe = 8'b0; 
  assign uio_out = 8'b0; 
endmodule


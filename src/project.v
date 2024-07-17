/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module wfang4285 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n,    // reset_n - low to reset
    input  wire       sensor,   //State representing the sensor
    input  wire       arm,      //State representing armed alarm.
    output reg        alarm,    //Alarm output.
    input  wire       on,       //Alarm on/off
    output reg [1:0]  state,
    output reg [1:0]  next_state
);

  //FSM representing security chip based on "Sensors."
  localparam [1:0]
      off = 2'b00,
      armed = 2'b01,
      triggered = 2'b10,
      alarm_on = 2'b11;

  reg [1:0] current;
  reg [1:0] next;
  wire arm = ui_in[0];
  wire sensor = ui_in[1];
  wire on = ui_in[2];
  
  //Checking state and assigning your next.
  always @(*) begin
    next = current;
    case(current)
      off: if (arm) next = armed;
           else next = off;
      armed: if (sensor) next = triggered;
             else next = armed;
      triggered: if (on) next = alarm_on;
                 else next = triggered;
      alarm_on: next = alarm_on;
      default: next = off;
    endcase 
  end

  //Updates state and status of alarm. 
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current <= off;
      alarm <= 0;
    end else begin
      current <= next;
      if (current == alarm_on) begin
        alarm <= 1;
      end else begin
        alarm <= 0;
      end
    end
  end

  //Updating info
  always @(*) begin
    assign state = current;
    assign next_state = next;
  end 

  wire uo_in[0] = current;
  wire uo_out[1] = next;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, rst_n, 1'b0};
  assign uio_oe = 8'b0; 
  assign uio_out = 8'b0; 
endmodule

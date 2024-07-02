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
    input wire        arm,      //State representing armed alarm.
    output reg        alarm,    //Alarm output.
    input wire        on        //Alarm on/off
);

  //FSM representing security chip based on "Sensors."
  typedef enum reg [1:0] {
      off = 2'b00,
      armed = 2'b01,
      triggered = 2'b10,
      alarm = 2'b11
  } state_t;

  reg [1:0] state;
  reg [1:0] next_state;
  
  //Checking state and assigning your next_state.
  always @(*) begin
    case(state)
      off: if (arm) next_state = armed;
           else next_state = off;
      armed: if (sensor) next_state = triggered;
             else next_state = armed;
      triggered: if (on) next_state = alarm;
             else next_state = triggered;
      alarm: next_state = alarm;
      default: next_state = off;
    endcase 
  end

  //Updates state and status of alarm. 
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= off;
      alarm <= 0;
    end else begin
      state <= next_state;
      if (state == alarm) begin
        alarm <= 1;
      end else begin
        alarm <= 0;
      end
    end
  end

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, rst_n, 1'b0};
  assign uio_oe = 8'b0; 
  assign uio_out = 8'b0; 
endmodule

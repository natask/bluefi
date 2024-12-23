//
// Generated by Bluespec Compiler, version 2024.07 (build b4f31db)
//
// On Tue Nov 12 16:42:34 EST 2024
//
//
// Ports:
// Name                         I/O  size props
// RDY_txStart                    O     1
// RDY_txData                     O     1
// RDY_txEnd                      O     1 const
// out_get                        O    32 reg
// RDY_out_get                    O     1 reg
// CLK                            I     1 clock
// RST_N                          I     1 reset
// txStart_txVec                  I    34
// txData_inData                  I     8
// EN_txStart                     I     1
// EN_txData                      I     1
// EN_txEnd                       I     1
// EN_out_get                     I     1
//
// No combinational paths from inputs to outputs
//
//

// compiler directives used by bsv dont define them
// `define BSV_ASSIGNMENT_DELAY #5
// `define BSV_POSITIVE_RESET 1'b1

module axi_transceiver #
	(
    	// Users to add parameters here

    	// User parameters ends
    	// Do not modify the parameters beyond this line


    	// Parameters of Axi Slave Bus Interface S00_AXIS
    	parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,

    	// Parameters of Axi Slave Bus Interface S01_AXIS
    	parameter integer C_S01_AXIS_TDATA_WIDTH	= 32,

    	// Parameters of Axi Slave Bus Interface S02_AXIS
    	parameter integer C_S02_AXIS_TDATA_WIDTH	= 32,

    	// Parameters of Axi Master Bus Interface M00_AXIS
    	parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
    	parameter integer C_M00_AXIS_START_COUNT	= 32,

    	// Parameters of Axi Master Bus Interface M01_AXIS
    	parameter integer C_M01_AXIS_TDATA_WIDTH	= 32,
    	parameter integer C_M01_AXIS_START_COUNT	= 32,

    	// Parameters of Axi Master Bus Interface M02_AXIS
    	parameter integer C_M02_AXIS_TDATA_WIDTH	= 32,
    	parameter integer C_M02_AXIS_START_COUNT	= 32
	)
	(
    	// Users to add ports here

    	// User ports ends
    	// Do not modify the ports beyond this line


    	// Ports of Axi Slave Bus Interface S00_AXIS (reciever in 32)
    	input wire  s00_axis_aclk,
    	input wire  s00_axis_aresetn,
    	output wire  s00_axis_tready,
    	input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
    	input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
    	input wire  s00_axis_tlast,
    	input wire  s00_axis_tvalid,

    	// Ports of Axi Slave Bus Interface S01_AXIS (transmitter txstart 34)
    	input wire  s01_axis_aclk,
    	input wire  s01_axis_aresetn,
    	output wire  s01_axis_tready,
    	input wire [C_S01_AXIS_TDATA_WIDTH-1 : 0] s01_axis_tdata,
    	input wire [(C_S01_AXIS_TDATA_WIDTH/8)-1 : 0] s01_axis_tstrb,
    	input wire  s01_axis_tlast,
    	input wire  s01_axis_tvalid,

    	// Ports of Axi Slave Bus Interface S02_AXIS (transmitter txdata 8)
    	input wire  s02_axis_aclk,
    	input wire  s02_axis_aresetn,
    	output wire  s02_axis_tready,
    	input wire [C_S02_AXIS_TDATA_WIDTH-1 : 0] s02_axis_tdata,
    	input wire [(C_S02_AXIS_TDATA_WIDTH/8)-1 : 0] s02_axis_tstrb,
    	input wire  s02_axis_tlast,
    	input wire  s02_axis_tvalid,

    	// Ports of Axi Master Bus Interface M00_AXIS (transmitter out 32)
    	input wire  m00_axis_aclk,
    	input wire  m00_axis_aresetn,
    	output wire  m00_axis_tvalid,
    	output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
    	output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
    	output wire  m00_axis_tlast,
    	input wire  m00_axis_tready,

    	// Ports of Axi Master Bus Interface M01_AXIS (reciever outdata 8)
    	input wire  m01_axis_aclk,
    	input wire  m01_axis_aresetn,
    	output wire  m01_axis_tvalid,
    	output wire [C_M01_AXIS_TDATA_WIDTH-1 : 0] m01_axis_tdata,
    	output wire [(C_M01_AXIS_TDATA_WIDTH/8)-1 : 0] m01_axis_tstrb,
    	output wire  m01_axis_tlast,
    	input wire  m01_axis_tready,

    	// Ports of Axi Master Bus Interface M02_AXIS (reciever outlength 12)
    	input wire  m02_axis_aclk,
    	input wire  m02_axis_aresetn,
    	output wire  m02_axis_tvalid,
    	output wire [C_M02_AXIS_TDATA_WIDTH-1 : 0] m02_axis_tdata,
    	output wire [(C_M02_AXIS_TDATA_WIDTH/8)-1 : 0] m02_axis_tstrb,
    	output wire  m02_axis_tlast,
    	input wire  m02_axis_tready
	);

//  // rule RL_putData
//   assign CAN_FIRE_RL_putData = transceiver$RDY_transmitter_txData ;
//   assign WILL_FIRE_RL_putData = transceiver$RDY_transmitter_txData ;

//   // rule RL_putTXStart
//   assign CAN_FIRE_RL_putTXStart = transceiver$RDY_transmitter_txStart ;
//   assign WILL_FIRE_RL_putTXStart = transceiver$RDY_transmitter_txStart ;

//   // rule RL_getOutput
//   assign CAN_FIRE_RL_getOutput =
// 	     transceiver$RDY_transmitter_out_get &&
// 	     transceiver$RDY_receiver_in_put ;
//   assign WILL_FIRE_RL_getOutput = CAN_FIRE_RL_getOutput ;

//   // rule RL_getLength
//   assign CAN_FIRE_RL_getLength = transceiver$RDY_receiver_outLength_get ;
//   assign WILL_FIRE_RL_getLength = transceiver$RDY_receiver_outLength_get ;

//   // rule RL_getData
//   assign CAN_FIRE_RL_getData = transceiver$RDY_receiver_outData_get ;
//   assign WILL_FIRE_RL_getData = transceiver$RDY_receiver_outData_get ;

//   // rule RL_tick
//   assign CAN_FIRE_RL_tick = 1'd1 ;
//   assign WILL_FIRE_RL_tick = 1'd1 ;

//   // register counter
//   assign counter$D_IN = 12'h0 ;
//   assign counter$EN = 1'b0 ;

//   // register cycle
//   assign cycle$D_IN = cycle + 32'd1 ;
//   assign cycle$EN = 1'd1 ;

//   // register data
//   assign data$D_IN = data + 8'd1 ;
//   assign data$EN = transceiver$RDY_transmitter_txData ;

//   // register packetNo
//   assign packetNo$D_IN = packetNo + 32'd1 ;
//   assign packetNo$EN = transceiver$RDY_transmitter_txStart ;

//   // register data
//   reg [7 : 0] data;
//   wire [7 : 0] data$D_IN;
//   wire data$EN;

//   // register packetNo
//   reg [31 : 0] packetNo;
//   wire [31 : 0] packetNo$D_IN;
//   wire packetNo$EN;
//    // register rate
//   reg [2 : 0] rate;
//   wire [2 : 0] rate$D_IN;
//   wire rate$EN;

  // ports of submodule transceiver
  wire [33 : 0] transceiver$transmitter_txStart_txVec;
  wire [31 : 0] transceiver$receiver_in_put, transceiver$transmitter_out_get;
  wire [11 : 0] transceiver$receiver_outLength_get;
  wire [7 : 0] transceiver$receiver_outData_get,
	       transceiver$transmitter_txData_inData;
  wire transceiver$EN_receiver_in_put,
       transceiver$EN_receiver_outData_get,
       transceiver$EN_receiver_outLength_get,
       transceiver$EN_transmitter_out_get,
       transceiver$EN_transmitter_txData,
       transceiver$EN_transmitter_txEnd,
       transceiver$EN_transmitter_txStart,
       transceiver$RDY_receiver_in_put,
       transceiver$RDY_receiver_outData_get,
       transceiver$RDY_receiver_outLength_get,
       transceiver$RDY_transmitter_out_get,
       transceiver$RDY_transmitter_txData,
       transceiver$RDY_transmitter_txStart;

  // rule scheduling signals
  wire CAN_FIRE_RL_getData,
       CAN_FIRE_RL_getLength,
       CAN_FIRE_RL_getOutput,
       CAN_FIRE_RL_putData,
       CAN_FIRE_RL_putTXStart,
       CAN_FIRE_RL_tick,
       WILL_FIRE_RL_getData,
       WILL_FIRE_RL_getLength,
       WILL_FIRE_RL_getOutput,
       WILL_FIRE_RL_putData,
       WILL_FIRE_RL_putTXStart,
       WILL_FIRE_RL_tick;
 
  mkTransceiver transceiver(.CLK(s00_axis_aclk),
			    .RST_N(s00_axis_aresetn),

                   	// Ports of Axi Slave Bus Interface S00_AXIS (reciever in 32)
			    .receiver_in_put(transceiver$receiver_in_put),
                   .EN_receiver_in_put(transceiver$EN_receiver_in_put),
                   .RDY_receiver_in_put(transceiver$RDY_receiver_in_put),

    	               // Ports of Axi Slave Bus Interface S01_AXIS (transmitter txstart 34)
			    .transmitter_txStart_txVec(transceiver$transmitter_txStart_txVec),
                   .EN_transmitter_txStart(transceiver$EN_transmitter_txStart),
                   .RDY_transmitter_txStart(transceiver$RDY_transmitter_txStart),

			     // Ports of Axi Slave Bus Interface S02_AXIS (transmitter txdata 8)
                   .transmitter_txData_inData(transceiver$transmitter_txData_inData),
			    .EN_transmitter_txData(transceiver$EN_transmitter_txData),
                   .RDY_transmitter_txData(transceiver$RDY_transmitter_txData),

    	               // Ports of Axi Master Bus Interface M00_AXIS (transmitter out 32)
                   .transmitter_out_get(transceiver$transmitter_out_get),
                   .EN_transmitter_out_get(transceiver$EN_transmitter_out_get),
			    .RDY_transmitter_out_get(transceiver$RDY_transmitter_out_get),

			    .EN_transmitter_txEnd(transceiver$EN_transmitter_txEnd),
			    .RDY_transmitter_txEnd(),

    	               // Ports of Axi Master Bus Interface M01_AXIS (reciever outdata 8)
                   .receiver_outData_get(transceiver$receiver_outData_get),
			    .EN_receiver_outData_get(transceiver$EN_receiver_outData_get),    
			    .RDY_receiver_outData_get(transceiver$RDY_receiver_outData_get),

    	               // Ports of Axi Master Bus Interface M02_AXIS (reciever outlength 12)			    
			    .receiver_outLength_get(transceiver$receiver_outLength_get),
			    .EN_receiver_outLength_get(transceiver$EN_receiver_outLength_get),
			    .RDY_receiver_outLength_get(transceiver$RDY_receiver_outLength_get)
                   );

 // S00_AXIS (receiver in 32)
 // ignore // input wire [:]  s00_axis_tstrb,
 assign transceiver$receiver_in_put =  s00_axis_tdata;
 assign transceiver$EN_receiver_in_put = s00_axis_tvalid && transceiver$RDY_receiver_in_put;
 assign s00_axis_tready = transceiver$RDY_receiver_in_put;
 // how to use 
    	// input wire      s00_axis_tlast,

 // S01_AXIS (transmitter txstart 34)
 assign transceiver$transmitter_txStart_txVec =  {s01_axis_tdata, 2'b0}; //higher 2 bits zero (power unused).() 12 bit length, 3 bits rate, 16 bit servce, 3 bit power  
 assign transceiver$EN_transmitter_txStart = s01_axis_tvalid && transceiver$RDY_transmitter_txStart;
 assign s01_axis_tready = transceiver$RDY_transmitter_txStart;
 // how to use 
    	// input wire      s01_axis_tlast,

 // S02_AXIS (transmitter txdata 8)
 assign transceiver$transmitter_txData_inData =  s02_axis_tdata; //truncate top 24 bits
 assign transceiver$EN_transmitter_txData = s02_axis_tvalid && transceiver$RDY_transmitter_txData;
 assign s02_axis_tready = transceiver$RDY_transmitter_txData;
 // how to use 
    // input wire      s02_axis_tlast,

 //  M00_AXIS (transmitter out 32)
 assign m00_axis_tdata = transceiver$transmitter_out_get;
 assign transceiver$EN_transmitter_out_get = m00_axis_tready && transceiver$RDY_transmitter_out_get;
 assign m00_axis_tvalid = transceiver$RDY_transmitter_out_get;
 assign m00_axis_tstrb = (1 << (C_M00_AXIS_TDATA_WIDTH/8))-1; //not used (maybe dma cares)

 // how to use 
    	// output wire      m00_axis_tlast,

 //  M01_AXIS (reciever outdata 8)
 assign m01_axis_tdata = {24'b0, transceiver$receiver_outData_get};//truncate top 24 bits
 assign transceiver$EN_receiver_outData_get = m01_axis_tready && transceiver$RDY_receiver_outData_get;
 assign m01_axis_tvalid = transceiver$RDY_receiver_outData_get;
 assign m01_axis_tstrb = (1 << (C_M01_AXIS_TDATA_WIDTH/8))-1; //not used (maybe dma cares)

 // how to use 
    	// output wire      m01_axis_tlast,

 // M02_AXIS (reciever outlength 12)	
 assign m02_axis_tdata = {20'b0, transceiver$receiver_outLength_get} ;//truncate top 32 - 12 = 20 bits
 assign transceiver$EN_receiver_outLength_get = m02_axis_tready && transceiver$RDY_receiver_outLength_get;
 assign m02_axis_tvalid = transceiver$RDY_receiver_outLength_get;
 assign m02_axis_tstrb = (1 << (C_M02_AXIS_TDATA_WIDTH/8))-1; //not used (maybe dma cares)


 // how to use 
   // output wire      m02_axis_tlast,
 assign transceiver$EN_transmitter_txEnd = !s00_axis_aresetn;
endmodule
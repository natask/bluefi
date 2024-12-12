// compiler directives used by bsv dont define them
// `define BSV_ASSIGNMENT_DELAY #5
// `define BSV_POSITIVE_RESET 1'b1

//stripped_down_ output of transmitter is directly fed into the reciever
module rf_feedback_transceiver #
	(
    	// Users to add parameters here

    	// User parameters ends
    	// Do not modify the parameters beyond this line


    	// Parameters of Axi Slave Bus Interface S00_AXIS
    	parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,

    	// Parameters of Axi Slave Bus Interface S01_AXIS
    	parameter integer C_S01_AXIS_TDATA_WIDTH	= 32,

    	// // Parameters of Axi Slave Bus Interface S02_AXIS
    	// parameter integer C_S02_AXIS_TDATA_WIDTH	= 32,

    	// Parameters of Axi Master Bus Interface M00_AXIS
    	parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
    	parameter integer C_M00_AXIS_START_COUNT	= 32,

        parameter [2:0] rate = 1, //0 to 7
        parameter [11:0] length = 1024, //can be variable

    	// Parameters of Axi Master Bus Interface M01_AXIS
    	parameter integer C_M01_AXIS_TDATA_WIDTH	= 32,
    	parameter integer C_M01_AXIS_START_COUNT	= 32

    	// // Parameters of Axi Master Bus Interface M02_AXIS
    	// parameter integer C_M02_AXIS_TDATA_WIDTH	= 32,
    	// parameter integer C_M02_AXIS_START_COUNT	= 32
	)
	(
    	// Users to add ports here

    	// User ports ends
    	// Do not modify the ports beyond this line


    	// Ports of Axi Slave Bus Interface S00_AXIS (reciever in 32)
        // Ports of Axi Slave Bus Interface S01_AXIS (transmitter txstart 34)
        // Ports of Axi Slave Bus Interface S02_AXIS (transmitter txdata 8)


        // Ports of Axi Slave Bus Interface S02_AXIS (transmitter txdata 8)
    	input wire  s00_axis_aclk,
    	input wire  s00_axis_aresetn,
    	output wire  s00_axis_tready,
    	input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
    	input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
    	input wire  s00_axis_tlast,
    	input wire  s00_axis_tvalid,

    	// // Ports of Axi Slave Bus Interface S01_AXIS (transmitter txstart 34)

		// Ports of Axi Slave Bus Interface S00_AXIS (reciever in 32)
    	input wire  s01_axis_aclk,
    	input wire  s01_axis_aresetn,
    	output wire  s01_axis_tready,
    	input wire [C_S01_AXIS_TDATA_WIDTH-1 : 0] s01_axis_tdata,
    	input wire [(C_S01_AXIS_TDATA_WIDTH/8)-1 : 0] s01_axis_tstrb,
    	input wire  s01_axis_tlast,
    	input wire  s01_axis_tvalid,

    	// Ports of Axi Master Bus Interface M00_AXIS (transmitter out 32)
    	// Ports of Axi Master Bus Interface M01_AXIS (reciever outdata 8)
        // Ports of Axi Master Bus Interface M02_AXIS (reciever outlength 12)

        // Ports of Axi Master Bus Interface M01_AXIS (reciever outdata 8)
    	input wire  m00_axis_aclk,
    	input wire  m00_axis_aresetn,
    	output wire  m00_axis_tvalid,
    	output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
    	output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
    	output wire  m00_axis_tlast,
    	input wire  m00_axis_tready,

    	// // Ports of Axi Master Bus Interface M01_AXIS (reciever outdata 8)
		
		// Ports of Axi Master Bus Interface M00_AXIS (transmitter out 32)
    	input wire  m01_axis_aclk,
    	input wire  m01_axis_aresetn,
    	output wire  m01_axis_tvalid,
    	output wire [C_M01_AXIS_TDATA_WIDTH-1 : 0] m01_axis_tdata,
    	output wire [(C_M01_AXIS_TDATA_WIDTH/8)-1 : 0] m01_axis_tstrb,
    	output wire  m01_axis_tlast,
    	input wire  m01_axis_tready
	);

 reg [31:0] counter;

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


 // transmiter txstart
 // ignore // input wire [:]  s00_axis_tstrb,
 assign transceiver$transmitter_txStart_txVec =
	     { length,
	       rate,
	       19'd0 } ;
assign transceiver$EN_transmitter_txStart = transceiver$RDY_transmitter_txStart; //always start transaction when ready
assign transceiver$EN_receiver_outLength_get = transceiver$RDY_receiver_outLength_get;
 // how to use 
    	// input wire      s00_axis_tlast,
always@(posedge s00_axis_aclk) begin
    if (s00_axis_aresetn == 0) counter <= 0;
    else begin 
        if (transceiver$EN_transmitter_txStart)
	$display("Going to send a packet %d at rate:%d, length:%d",
		 counter,
		 rate,
		 length[11:0]);
      if (transceiver$EN_transmitter_txData)
	$display("transmitter input: rate:%d, data:%h", rate, transceiver$transmitter_txData_inData);

    if (transceiver$EN_receiver_outLength_get) $display("Going to receiver a packet of length:%d",transceiver$receiver_outLength_get);
    if (transceiver$EN_receiver_outData_get) $display("receiver output: data:%h",transceiver$receiver_outData_get);
    if (transceiver$EN_receiver_in_put) $display("receiver I/Q: data:%h",transceiver$receiver_in_put);
        if(transceiver$EN_receiver_outData_get) begin
            $display("receiver counter: %h",counter);
            if(counter == length - 1) counter <= 0;
            else counter <= counter + 1;

        end
    end
end

// Ports of Axi Slave Bus Interface S00_AXIS (transmitter txdata 8)
 assign s00_axis_tready = transceiver$RDY_transmitter_txData;
 assign transceiver$transmitter_txData_inData = s00_axis_tdata; // take the low 8 bits
 assign transceiver$EN_transmitter_txData = s00_axis_tvalid && transceiver$RDY_transmitter_txData;
    //input wire  s00_axis_tlast,

 // S01_AXIS (receiver in 32)
 // ignore // input wire [:]  s01_axis_tstrb,
 assign transceiver$receiver_in_put =  s01_axis_tdata;
 assign transceiver$EN_receiver_in_put = s01_axis_tvalid && transceiver$RDY_receiver_in_put;
 assign s01_axis_tready = transceiver$RDY_receiver_in_put;
 //input wire  s01_axis_tlast,

    // Ports of Axi Master Bus Interface M00_AXIS (reciever outdata 8)
 assign m00_axis_tvalid = transceiver$RDY_receiver_outData_get;
 assign m00_axis_tstrb = (1 << (C_M00_AXIS_TDATA_WIDTH/8))-1; //not used (maybe dma cares)
 assign m00_axis_tdata = {24'b0, transceiver$receiver_outData_get};//0 top 24 bits
 assign transceiver$EN_receiver_outData_get = m00_axis_tready && transceiver$RDY_receiver_outData_get;
 assign m00_axis_tlast = counter == length - 1; // create tlast signal on finished transaction, (not sure if necessary, there is a large dma overhead)

  //  M01_AXIS (transmitter out 32)
 assign m01_axis_tdata = transceiver$transmitter_out_get;
 assign transceiver$EN_transmitter_out_get = m01_axis_tready && transceiver$RDY_transmitter_out_get;
 assign m01_axis_tvalid = transceiver$RDY_transmitter_out_get;
 assign m01_axis_tstrb = (1 << (C_M00_AXIS_TDATA_WIDTH/8))-1; //not used (maybe dma cares)
 assign m01_axis_tlast = 0; // always streaming to output (any information from counter to use here)

 //  transmitter end
 assign transceiver$EN_transmitter_txEnd = !s00_axis_aresetn; //resent transmitter when get a tlast (maybe not a good idea) s00_axis_tlast
endmodule
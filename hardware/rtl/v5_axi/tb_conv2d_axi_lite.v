`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
// AXI4-Lite Testbench for CNN Accelerator
//-----------------------------------------------------------------------------
// Purpose: Verify AXI wrapper functions correctly under software control
// Simulates: ARM CPU writing inputs/weights, starting accelerator, reading result
// Expected: Output = 9 (all-ones input × all-ones kernel)
//-----------------------------------------------------------------------------

module tb_conv2d_axi_lite;

    // Clock and reset
    reg clk;
    reg rstn;

    // AXI Write Address Channel
    reg  [6:0]  AWADDR;
    reg         AWVALID;
    wire        AWREADY;

    // AXI Write Data Channel
    reg  [31:0] WDATA;
    reg         WVALID;
    wire        WREADY;

    // AXI Write Response Channel
    wire [1:0]  BRESP;
    wire        BVALID;
    reg         BREADY;

    // AXI Read Address Channel
    reg  [6:0]  ARADDR;
    reg         ARVALID;
    wire        ARREADY;

    // AXI Read Data Channel
    wire [31:0] RDATA;
    wire [1:0]  RRESP;
    wire        RVALID;
    reg         RREADY;

    // Instantiate DUT
    conv2d_axi_lite #(
        .C_S_AXI_DATA_WIDTH(32),
        .C_S_AXI_ADDR_WIDTH(7)
    ) dut (
        .S_AXI_ACLK   (clk),
        .S_AXI_ARESETN(rstn),

        .S_AXI_AWADDR (AWADDR),
        .S_AXI_AWVALID(AWVALID),
        .S_AXI_AWREADY(AWREADY),

        .S_AXI_WDATA  (WDATA),
        .S_AXI_WVALID (WVALID),
        .S_AXI_WREADY (WREADY),

        .S_AXI_BRESP  (BRESP),
        .S_AXI_BVALID (BVALID),
        .S_AXI_BREADY (BREADY),

        .S_AXI_ARADDR (ARADDR),
        .S_AXI_ARVALID(ARVALID),
        .S_AXI_ARREADY(ARREADY),

        .S_AXI_RDATA  (RDATA),
        .S_AXI_RRESP  (RRESP),
        .S_AXI_RVALID (RVALID),
        .S_AXI_RREADY (RREADY)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    // --------------------------------------------------------
    // AXI Write Task (simulates ARM CPU write)
    // --------------------------------------------------------
    task axi_write(input [6:0] addr, input [31:0] data);
    begin
        @(posedge clk);
        AWADDR  <= addr;
        AWVALID <= 1;
        WDATA   <= data;
        WVALID  <= 1;
        BREADY  <= 1;

        wait (AWREADY && WREADY);
        @(posedge clk);

        AWVALID <= 0;
        WVALID  <= 0;

        wait (BVALID);
        @(posedge clk);
        BREADY <= 0;
    end
    endtask

    // --------------------------------------------------------
    // AXI Read Task (simulates ARM CPU read)
    // --------------------------------------------------------
    task axi_read(input [6:0] addr, output [31:0] data);
    begin
        @(posedge clk);
        ARADDR  <= addr;
        ARVALID <= 1;
        RREADY  <= 1;

        wait (ARREADY);
        @(posedge clk);

        ARVALID <= 0;

        wait (RVALID);
        data = RDATA;
        @(posedge clk);
        RREADY <= 0;
    end
    endtask

    // --------------------------------------------------------
    // Test Sequence
    // --------------------------------------------------------
    integer i;
    reg [31:0] read_data;
    reg [31:0] ctrl_status;

    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;

        AWADDR = 0; AWVALID = 0;
        WDATA  = 0; WVALID  = 0;
        BREADY = 0;
        ARADDR = 0; ARVALID = 0;
        RREADY = 0;

        // Reset sequence
        #50 rstn = 1;
        #20;

        $display("================================================");
        $display("AXI4-Lite CNN Accelerator Testbench");
        $display("================================================");

        // Write input pixels (all 1s)
        $display("Writing input pixels...");
        for (i = 0; i < 9; i = i + 1)
            axi_write(7'h04 + i*4, 32'd1);

        // Write kernel weights (all 1s)
        $display("Writing kernel weights...");
        for (i = 0; i < 9; i = i + 1)
            axi_write(7'h28 + i*4, 32'd1);

        // Start accelerator
        $display("Starting accelerator...");
        axi_write(7'h00, 32'd1);

        // Poll for done
        $display("Polling for completion...");
        repeat (10) begin
            axi_read(7'h00, ctrl_status);
            if (ctrl_status[1]) begin
                $display("Accelerator done!");
                disable poll_loop;
            end
            #20;
        end
        poll_loop:;

        // Read result
        axi_read(7'h4C, read_data);

        $display("================================================");
        $display("Result = %0d", $signed(read_data[15:0]));
        $display("Expected = 9");
        $display("STATUS: %s",
            ($signed(read_data[15:0]) == 9) ? "TEST PASSED" : "TEST FAILED");
        $display("================================================");

        #50 $finish;
    end

endmodule

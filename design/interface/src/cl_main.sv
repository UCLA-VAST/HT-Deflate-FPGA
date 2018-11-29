module cl_main
  (
`include "cl_ports.vh" // Fixed port definition

   );

`include "cl_common_defines.vh"      // CL Defines for all examples
`include "cl_id_defines.vh"          // Defines for ID0 and ID1 (PCI ID's)
`include "cl_main_defines.vh"                // CL Defines for cl_main

   logic rst_main_n_sync;


   //--------------------------------------------0
   // Start with Tie-Off of Unused Interfaces
   //---------------------------------------------
   // the developer should use the next set of `include
   // to properly tie-off any unused interface
   // The list is put in the top of the module
   // to avoid cases where developer may forget to
   // remove it from the end of the file

`include "unused_flr_template.inc"
`include "unused_ddr_a_b_d_template.inc"
`include "unused_dma_pcis_template.inc"
`include "unused_cl_sda_template.inc"
`include "unused_sh_bar1_template.inc"
`include "unused_apppf_irq_template.inc"

   // Denoted by Weikang:
   // what's cl_debug_bridge's role
   cl_debug_bridge CL_DEBUG_BRIDGE 
     (
      .clk(clk_main_a0),
      .S_BSCAN_drck(drck),
      .S_BSCAN_shift(shift),
      .S_BSCAN_tdi(tdi),
      .S_BSCAN_update(update),
      .S_BSCAN_sel(sel),
      .S_BSCAN_tdo(tdo),
      .S_BSCAN_tms(tms),
      .S_BSCAN_tck(tck),
      .S_BSCAN_runtest(runtest),
      .S_BSCAN_reset(reset),
      .S_BSCAN_capture(capture),
      .S_BSCAN_bscanid_en(bscanid_en)
      );

   //-------------------------------------------------
   // ID Values (cl_hello_world_defines.vh)
   //-------------------------------------------------
   assign cl_sh_id0[31:0] = `CL_SH_ID0;
   assign cl_sh_id1[31:0] = `CL_SH_ID1;

   //-------------------------------------------------
   // Reset Synchronization
   //-------------------------------------------------
   logic pre_sync_rst_n;

   always_ff @(negedge rst_main_n or posedge clk_main_a0)
     if (!rst_main_n)
       begin
	  pre_sync_rst_n  <= 0;
	  rst_main_n_sync <= 0;
       end
     else
       begin
	  pre_sync_rst_n  <= 1;
	  rst_main_n_sync <= pre_sync_rst_n;
       end

   //-------------------------------------------------
   // PCIe OCL AXI-L (SH to CL) Timing Flops
   //-------------------------------------------------

   // Write address                                                                                                              
   logic        sh_ocl_awvalid_q;
   logic [31:0] sh_ocl_awaddr_q;
   logic        ocl_sh_awready_q;
   
   // Write data                                                                                                                
   logic        sh_ocl_wvalid_q;
   logic [31:0] sh_ocl_wdata_q;
   logic [ 3:0] sh_ocl_wstrb_q;
   logic        ocl_sh_wready_q;
   
   // Write response                                                                                                            
   logic        ocl_sh_bvalid_q;
   logic [ 1:0] ocl_sh_bresp_q;
   logic        sh_ocl_bready_q;
   assign ocl_sh_bresp_q = 0;
   
   // Read address                                                                                                              
   logic        sh_ocl_arvalid_q;
   logic [31:0] sh_ocl_araddr_q;
   logic        ocl_sh_arready_q;
   
   // Read data/response                                                                                                        
   logic        ocl_sh_rvalid_q;
   logic [31:0] ocl_sh_rdata_q;
   logic [ 1:0] ocl_sh_rresp_q;
   logic        sh_ocl_rready_q;

   axi_register_slice_light AXIL_OCL_REG_SLC 
     (
      .aclk          (clk_main_a0),
      .aresetn       (rst_main_n_sync),
      .s_axi_awaddr  (sh_ocl_awaddr),
      .s_axi_awprot  (2'h0),
      .s_axi_awvalid (sh_ocl_awvalid),
      .s_axi_awready (ocl_sh_awready),
      .s_axi_wdata   (sh_ocl_wdata),
      .s_axi_wstrb   (sh_ocl_wstrb),
      .s_axi_wvalid  (sh_ocl_wvalid),
      .s_axi_wready  (ocl_sh_wready),
      .s_axi_bresp   (ocl_sh_bresp),
      .s_axi_bvalid  (ocl_sh_bvalid),
      .s_axi_bready  (sh_ocl_bready),
      .s_axi_araddr  (sh_ocl_araddr),
      .s_axi_arvalid (sh_ocl_arvalid),
      .s_axi_arready (ocl_sh_arready),
      .s_axi_rdata   (ocl_sh_rdata),
      .s_axi_rresp   (ocl_sh_rresp),
      .s_axi_rvalid  (ocl_sh_rvalid),
      .s_axi_rready  (sh_ocl_rready),
      .m_axi_awaddr  (sh_ocl_awaddr_q),
      .m_axi_awprot  (),
      .m_axi_awvalid (sh_ocl_awvalid_q),
      .m_axi_awready (ocl_sh_awready_q),
      .m_axi_wdata   (sh_ocl_wdata_q),
      .m_axi_wstrb   (sh_ocl_wstrb_q),
      .m_axi_wvalid  (sh_ocl_wvalid_q),
      .m_axi_wready  (ocl_sh_wready_q),
      .m_axi_bresp   (ocl_sh_bresp_q),
      .m_axi_bvalid  (ocl_sh_bvalid_q),
      .m_axi_bready  (sh_ocl_bready_q),
      .m_axi_araddr  (sh_ocl_araddr_q),
      .m_axi_arvalid (sh_ocl_arvalid_q),
      .m_axi_arready (ocl_sh_arready_q),
      .m_axi_rdata   (ocl_sh_rdata_q),
      .m_axi_rresp   (ocl_sh_rresp_q),
      .m_axi_rvalid  (ocl_sh_rvalid_q),
      .m_axi_rready  (sh_ocl_rready_q)
      );
   
   assign ocl_sh_rresp_q   = 0;
   
   // Write Response
   always_ff @(posedge clk_main_a0) begin
      if (!rst_main_n_sync) begin
	 ocl_sh_bvalid_q <= 0;
      end
      else begin
	 ocl_sh_bvalid_q <=  ocl_sh_bvalid_q && sh_ocl_bready_q ? 1'b0  :
			     ~ocl_sh_bvalid_q && sh_ocl_wvalid_q && ocl_sh_wready_q ? 1'b1  :
			     ocl_sh_bvalid_q;
      end
   end

   logic [15:0] cl_sh_pcim_awid_q;
   logic [63:0] cl_sh_pcim_awaddr_q;
   logic [7:0] 	cl_sh_pcim_awlen_q;
   logic [2:0] 	cl_sh_pcim_awsize_q;
   logic [18:0] cl_sh_pcim_awuser_q;
   logic        cl_sh_pcim_awvalid_q;
   logic 	sh_cl_pcim_awready_q;
   logic [511:0] cl_sh_pcim_wdata_q;
   logic [63:0]  cl_sh_pcim_wstrb_q;
   logic 	 cl_sh_pcim_wlast_q;
   logic 	 cl_sh_pcim_wvalid_q;
   logic 	 sh_cl_pcim_wready_q;
   logic [15:0]  sh_cl_pcim_bid_q;
   logic [1:0] 	 sh_cl_pcim_bresp_q;
   logic 	 sh_cl_pcim_bvalid_q;
   logic 	 cl_sh_pcim_bready_q;
   logic [15:0]  cl_sh_pcim_arid_q;
   logic [63:0]  cl_sh_pcim_araddr_q;
   logic [7:0] 	 cl_sh_pcim_arlen_q;
   logic [2:0] 	 cl_sh_pcim_arsize_q;
   logic [18:0]  cl_sh_pcim_aruser_q;
   logic 	 cl_sh_pcim_arvalid_q;
   logic 	 sh_cl_pcim_arready_q;
   logic [15:0]  sh_cl_pcim_rid_q;
   logic [511:0] sh_cl_pcim_rdata_q;
   logic [1:0] 	 sh_cl_pcim_rresp_q;
   logic 	 sh_cl_pcim_rlast_q;
   logic 	 sh_cl_pcim_rvalid_q;
   logic 	 cl_sh_pcim_rready_q;
   
   assign cl_sh_pcim_awid_q = 0;
   assign cl_sh_pcim_awsize_q = 3'b110;
   //14:11 are the byte-enable for the first DW (bit value 1 mean byte is enable; i.e. not masked)
   assign cl_sh_pcim_awuser_q[14:11] = 4'b1111;
   //18:15 are the byte-enable for the last DW (bit value 1 mean byte is enable; i.e. not masked)
   assign cl_sh_pcim_awuser_q[18:15] = 4'b1111;
   //10:0 Length in DW of the transaction
   assign cl_sh_pcim_awuser_q[10:0] = (cl_sh_pcim_awlen_q + 1) << 4;

   assign cl_sh_pcim_bready_q = 1;
   // Temporary don't support strb signal
   assign cl_sh_pcim_wstrb_q = 64'hFFFFFFFFFFFFFFFF;
   
   // PCIe Write Registers
   
   // input to interconnect
   logic 	 pcie_write_req_data_V_last_full_n;
   logic 	 pcie_write_req_data_V_data_V_full_n;
   logic 	 pcie_write_req_apply_V_num_full_n;
   logic 	 pcie_write_req_apply_V_addr_full_n;
   
   // output from interconnect
   logic 	 pcie_write_req_data_V_last_din;
   logic 	 pcie_write_req_data_V_last_write;
   logic [511:0] pcie_write_req_data_V_data_V_din;
   logic 	 pcie_write_req_data_V_data_V_write;
   logic [63:0]  pcie_write_req_apply_V_addr_din;
   logic 	 pcie_write_req_apply_V_addr_write;
   logic [7:0] 	 pcie_write_req_apply_V_num_din;
   logic 	 pcie_write_req_apply_V_num_write;

   // glue logic
   assign cl_sh_pcim_awaddr_q = pcie_write_req_apply_V_addr_din;
   assign cl_sh_pcim_awlen_q = pcie_write_req_apply_V_num_din - 1;
   assign cl_sh_pcim_awvalid_q = pcie_write_req_apply_V_addr_write;
   assign pcie_write_req_apply_V_addr_full_n = sh_cl_pcim_awready_q;
   assign pcie_write_req_apply_V_num_full_n = sh_cl_pcim_awready_q;
   
   assign pcie_write_req_data_V_data_V_full_n = sh_cl_pcim_wready_q;
   assign pcie_write_req_data_V_last_full_n = sh_cl_pcim_wready_q;
   assign cl_sh_pcim_wlast_q = pcie_write_req_data_V_last_din;
   assign cl_sh_pcim_wdata_q = pcie_write_req_data_V_data_V_din;
   assign cl_sh_pcim_wvalid_q = pcie_write_req_data_V_data_V_write;

   // PCIe Read Registers

   // input to interconnect
   logic [511:0] pcie_read_resp_V_data_V_dout;
   logic 	 pcie_read_resp_V_data_V_empty_n;
   logic 	 pcie_read_resp_V_last_dout;
   logic 	 pcie_read_resp_V_last_empty_n;
   logic 	 pcie_read_req_V_num_full_n;
   logic 	 pcie_read_req_V_addr_full_n;
   
   // output from interconnect
   logic [7:0] 	 pcie_read_req_V_num_din;
   logic 	 pcie_read_req_V_num_write;
   logic [63:0]  pcie_read_req_V_addr_din;
   logic 	 pcie_read_req_V_addr_write;
   logic 	 pcie_read_resp_V_last_read;
   logic 	 pcie_read_resp_V_data_V_read;

   // glue logic
   assign cl_sh_pcim_arid_q = 0;
   // 10:0 Length in DW of the transaction
   assign cl_sh_pcim_aruser_q[10:0] = (cl_sh_pcim_arlen_q + 1) << 4;
   // 18:11 Must be set to 0xFF; could be ignored in next release
   assign cl_sh_pcim_aruser_q[18:11] = 8'hFF;
   assign cl_sh_pcim_araddr_q = pcie_read_req_V_addr_din;
   assign cl_sh_pcim_arlen_q = pcie_read_req_V_num_din - 1; 
   assign cl_sh_pcim_arsize_q = 3'b110;
   assign cl_sh_pcim_arvalid_q = pcie_read_req_V_addr_write;
   assign cl_sh_pcim_rready_q = pcie_read_resp_V_data_V_read;
   assign pcie_read_req_V_num_full_n = sh_cl_pcim_arready_q;
   assign pcie_read_req_V_addr_full_n = sh_cl_pcim_arready_q;
   assign pcie_read_resp_V_data_V_dout = sh_cl_pcim_rdata_q;
   assign pcie_read_resp_V_last_dout = sh_cl_pcim_rlast_q;
   assign pcie_read_resp_V_data_V_empty_n = sh_cl_pcim_rvalid_q;
   assign pcie_read_resp_V_last_empty_n = sh_cl_pcim_rvalid_q;

   // Peek-Poke Registers  
   
   // input to interconnect
   logic [31:0]  poke_V_data_dout;   
   logic         poke_V_data_empty_n;
   logic [31:0]  poke_V_tag_dout;
   logic 	 poke_V_tag_empty_n;
   logic 	 peek_req_V_empty_n;
   logic [31:0]  peek_req_V_rd_data;
   logic 	 peek_resp_V_full_n;
   
   // output from interconnect
   logic         poke_V_data_read;
   logic 	 poke_V_tag_read;
   logic 	 peek_req_V_rd_en;
   logic [31:0]  peek_resp_V_wr_data;
   logic 	 peek_resp_V_wr_en;

   // Peek-Poke/CL glue logic
   assign poke_V_tag_dout = sh_ocl_awaddr_q;   
   assign poke_V_data_dout = sh_ocl_wdata_q;
   assign ocl_sh_awready_q = poke_V_tag_read;   
   assign ocl_sh_wready_q = poke_V_data_read;
   assign poke_V_tag_empty_n = sh_ocl_awvalid_q;  
   assign poke_V_data_empty_n = sh_ocl_wvalid_q;

   assign peek_req_V_rd_data = sh_ocl_araddr_q;
   assign peek_req_V_empty_n = sh_ocl_arvalid_q;
   assign ocl_sh_arready_q = peek_req_V_rd_en;
   
   assign ocl_sh_rdata_q = peek_resp_V_wr_data;
   assign ocl_sh_rvalid_q = peek_resp_V_wr_en;
   assign peek_resp_V_full_n = sh_ocl_rready_q;
   
   logic 	 interconnects_start;
   
   
   always @ (posedge clk_main_a0) begin
      if (!rst_main_n_sync) begin
	 interconnects_start <= 1'b0;
      end else begin
	 interconnects_start <= 1'b1;
      end
   end
   
   axi_register_slice AXIL_PCIM_REG_SLC
     (
      .aclk(clk_main_a0),
      .aresetn(rst_main_n_sync),
      .s_axi_awid(cl_sh_pcim_awid_q),
      .s_axi_awaddr(cl_sh_pcim_awaddr_q),
      .s_axi_awlen(cl_sh_pcim_awlen_q),
      .s_axi_awsize(cl_sh_pcim_awsize_q),
      .s_axi_awvalid(cl_sh_pcim_awvalid_q),
      .s_axi_awready(sh_cl_pcim_awready_q),
      .s_axi_wdata(cl_sh_pcim_wdata_q),
      .s_axi_wstrb(cl_sh_pcim_wstrb_q),
      .s_axi_wlast(cl_sh_pcim_wlast_q),
      .s_axi_wvalid(cl_sh_pcim_wvalid_q),
      .s_axi_wready(sh_cl_pcim_wready_q),
      .s_axi_bid(sh_cl_pcim_bid_q),
      .s_axi_bresp(sh_cl_pcim_bresp_q),
      .s_axi_bvalid(sh_cl_pcim_bvalid_q),
      .s_axi_bready(cl_sh_pcim_bready_q),
      .s_axi_arid(cl_sh_pcim_arid_q),
      .s_axi_araddr(cl_sh_pcim_araddr_q),
      .s_axi_arlen(cl_sh_pcim_arlen_q),
      .s_axi_arsize(cl_sh_pcim_arsize_q),
      .s_axi_arvalid(cl_sh_pcim_arvalid_q),
      .s_axi_arready(sh_cl_pcim_arready_q),
      .s_axi_rid(sh_cl_pcim_rid_q),
      .s_axi_rdata(sh_cl_pcim_rdata_q),
      .s_axi_rresp(sh_cl_pcim_rresp_q),
      .s_axi_rlast(sh_cl_pcim_rlast_q),
      .s_axi_rvalid(sh_cl_pcim_rvalid_q),
      .s_axi_rready(cl_sh_pcim_rready_q),
      .m_axi_awid(cl_sh_pcim_awid),
      .m_axi_awaddr(cl_sh_pcim_awaddr),
      .m_axi_awlen(cl_sh_pcim_awlen),
      .m_axi_awsize(cl_sh_pcim_awsize),
      .m_axi_awvalid(cl_sh_pcim_awvalid),
      .m_axi_awready(sh_cl_pcim_awready),
      .m_axi_wdata(cl_sh_pcim_wdata),
      .m_axi_wstrb(cl_sh_pcim_wstrb),
      .m_axi_wlast(cl_sh_pcim_wlast),
      .m_axi_wvalid(cl_sh_pcim_wvalid),
      .m_axi_wready(sh_cl_pcim_wready),
      .m_axi_bid(sh_cl_pcim_bid),
      .m_axi_bresp(sh_cl_pcim_bresp),
      .m_axi_bvalid(sh_cl_pcim_bvalid),
      .m_axi_bready(cl_sh_pcim_bready),
      .m_axi_arid(cl_sh_pcim_arid),
      .m_axi_araddr(cl_sh_pcim_araddr),
      .m_axi_arlen(cl_sh_pcim_arlen),
      .m_axi_arsize(cl_sh_pcim_arsize),
      .m_axi_arvalid(cl_sh_pcim_arvalid),
      .m_axi_arready(sh_cl_pcim_arready),
      .m_axi_rid(sh_cl_pcim_rid),
      .m_axi_rdata(sh_cl_pcim_rdata),
      .m_axi_rresp(sh_cl_pcim_rresp),
      .m_axi_rlast(sh_cl_pcim_rlast),
      .m_axi_rvalid(sh_cl_pcim_rvalid),
      .m_axi_rready(cl_sh_pcim_rready)
      );

   //-------------------------------------------------
   // DRAM-C
   //-------------------------------------------------
   
   logic  [7:0]     dramC_read_req_V_num_din;
   logic 	    dramC_read_req_V_num_full_n;
   logic 	    dramC_read_req_V_num_write;
   logic [63:0]     dramC_read_req_V_addr_din;
   logic 	    dramC_read_req_V_addr_full_n;
   logic 	    dramC_read_req_V_addr_write;
   
   logic 	    dramC_read_resp_V_last_dout;
   logic 	    dramC_read_resp_V_last_empty_n;
   logic    	    dramC_read_resp_V_last_read;
   logic [511:0]    dramC_read_resp_V_data_V_dout;
   logic 	    dramC_read_resp_V_data_V_empty_n;
   logic 	    dramC_read_resp_V_data_V_read;
   
   logic 	    dramC_write_req_data_V_last_din;
   logic 	    dramC_write_req_data_V_last_full_n;
   logic 	    dramC_write_req_data_V_last_write;
   logic [511:0]    dramC_write_req_data_V_data_V_din;
   logic 	    dramC_write_req_data_V_data_V_full_n;
   logic 	    dramC_write_req_data_V_data_V_write;
   
   logic [7:0] 	    dramC_write_req_apply_V_num_din;
   logic 	    dramC_write_req_apply_V_num_full_n;
   logic 	    dramC_write_req_apply_V_num_write;
   logic [63:0]     dramC_write_req_apply_V_addr_din;
   logic 	    dramC_write_req_apply_V_addr_full_n;
   logic 	    dramC_write_req_apply_V_addr_write;
   
   // read control channel
   logic [7:0] 	    cl_sh_ddr_arlen_q;
   logic            sh_cl_ddr_arready_q;
   logic            cl_sh_ddr_arvalid_q;
   logic [63:0]     cl_sh_ddr_araddr_q;
   logic [2:0] 	    cl_sh_ddr_arsize_q;
   logic [15:0]     cl_sh_ddr_arid_q;

   logic            cl_sh_ddr_rlast_q;
   logic            sh_cl_ddr_rvalid_q;
   logic            cl_sh_ddr_rready_q;
   logic [511:0]    sh_cl_ddr_rdata_q;
   logic [1:0] 	    sh_cl_ddr_rresp_q;
   logic [15:0]     sh_cl_ddr_rid_q;

   logic [7:0] 	    cl_sh_ddr_awlen_q;
   logic            sh_cl_ddr_awready_q;
   logic [63:0]     cl_sh_ddr_awaddr_q;
   logic            cl_sh_ddr_awvalid_q;
   logic [15:0]     cl_sh_ddr_awid_q; 
   logic [2:0] 	    cl_sh_ddr_awsize_q;

   logic            cl_sh_ddr_wlast_q; 
   logic            sh_cl_ddr_wready_q;
   logic [511:0]    cl_sh_ddr_wdata_q;
   logic            cl_sh_ddr_wvalid_q;
   logic [63:0]     cl_sh_ddr_wstrb_q;
   logic [15:0]     cl_sh_ddr_wid_q;

   logic            cl_sh_ddr_bready_q;
   logic [1:0] 	    sh_cl_ddr_bresp_q;
   logic [15:0]     sh_cl_ddr_bid_q;
   logic            sh_cl_ddr_bvalid_q;

   logic            sh_cl_ddr_is_ready_q;

   // glue logic
   
   // read control channel
   assign cl_sh_ddr_arlen_q = dramC_read_req_V_num_din - 1;
   assign dramC_read_req_V_num_full_n = sh_cl_ddr_arready_q;
   assign cl_sh_ddr_arvalid_q = dramC_read_req_V_addr_write;
   assign cl_sh_ddr_araddr_q = dramC_read_req_V_addr_din;
   assign dramC_read_req_V_addr_full_n = sh_cl_ddr_arready_q;
   assign cl_sh_ddr_arsize_q = 3'b110;
   assign cl_sh_ddr_arid_q = 0;

   //read data channel
   assign dramC_read_resp_V_last_dout = cl_sh_ddr_rlast_q;
   assign dramC_read_resp_V_last_empty_n = sh_cl_ddr_rvalid_q; 
   assign cl_sh_ddr_rready_q = dramC_read_resp_V_data_V_read;
   assign dramC_read_resp_V_data_V_dout = sh_cl_ddr_rdata_q;
   assign dramC_read_resp_V_data_V_empty_n = sh_cl_ddr_rvalid_q;

   // write control channel
   assign cl_sh_ddr_awlen_q = dramC_write_req_apply_V_num_din - 1;
   assign dramC_write_req_apply_V_num_full_n = sh_cl_ddr_awready_q;
   assign cl_sh_ddr_awaddr_q = dramC_write_req_apply_V_addr_din;
   assign dramC_write_req_apply_V_addr_full_n = sh_cl_ddr_awready_q;
   assign cl_sh_ddr_awvalid_q = dramC_write_req_apply_V_addr_write;
   assign cl_sh_ddr_awid_q = 0;
   assign cl_sh_ddr_awsize_q = 3'b110;
   
   // write data channel  
   assign cl_sh_ddr_wlast_q = dramC_write_req_data_V_last_din;
   assign dramC_write_req_data_V_last_full_n = sh_cl_ddr_wready_q;
   assign cl_sh_ddr_wdata_q = dramC_write_req_data_V_data_V_din;
   assign dramC_write_req_data_V_data_V_full_n = sh_cl_ddr_wready_q;
   assign cl_sh_ddr_wvalid_q = dramC_write_req_data_V_data_V_write;
   assign cl_sh_ddr_wstrb_q = 64'hFFFF_FFFF_FFFF_FFFF;
   assign cl_sh_ddr_wid_q = 0;
   
   // write feedback
   assign cl_sh_ddr_bready_q = 1'b1;
   
   always @(posedge clk_main_a0) begin
      sh_cl_ddr_is_ready_q <= sh_cl_ddr_is_ready;
   end

   axi_register_slice AXI_DDR_REG_SLC
     (
      .aclk(clk_main_a0),
      .aresetn(rst_main_n_sync),
      .s_axi_awid(cl_sh_ddr_awid_q),
      .s_axi_awaddr(cl_sh_ddr_awaddr_q),
      .s_axi_awlen(cl_sh_ddr_awlen_q),
      .s_axi_awsize(cl_sh_ddr_awsize_q),
      .s_axi_awvalid(cl_sh_ddr_awvalid_q),
      .s_axi_awready(sh_cl_ddr_awready_q),
      .s_axi_wdata(cl_sh_ddr_wdata_q),
      .s_axi_wstrb(cl_sh_ddr_wstrb_q),
      .s_axi_wlast(cl_sh_ddr_wlast_q),
      .s_axi_wvalid(cl_sh_ddr_wvalid_q),
      .s_axi_wready(sh_cl_ddr_wready_q),
      .s_axi_bid(sh_cl_ddr_bid_q), 
      .s_axi_bresp(sh_cl_ddr_bresp_q),
      .s_axi_bvalid(sh_cl_ddr_bvalid_q),
      .s_axi_bready(cl_sh_ddr_bready_q),
      .s_axi_arid(cl_sh_ddr_arid_q),
      .s_axi_araddr(cl_sh_ddr_araddr_q),
      .s_axi_arlen(cl_sh_ddr_arlen_q),
      .s_axi_arsize(cl_sh_ddr_arsize_q),
      .s_axi_arvalid(cl_sh_ddr_arvalid_q),
      .s_axi_arready(sh_cl_ddr_arready_q),
      .s_axi_rid(sh_cl_ddr_rid_q),
      .s_axi_rdata(sh_cl_ddr_rdata_q),
      .s_axi_rresp(sh_cl_ddr_rresp_q),
      .s_axi_rlast(sh_cl_ddr_rlast_q),
      .s_axi_rvalid(sh_cl_ddr_rvalid_q),
      .s_axi_rready(cl_sh_ddr_rready_q),
      .m_axi_awid(cl_sh_ddr_awid),
      .m_axi_awaddr(cl_sh_ddr_awaddr),
      .m_axi_awlen(cl_sh_ddr_awlen),
      .m_axi_awsize(cl_sh_ddr_awsize),
      .m_axi_awvalid(cl_sh_ddr_awvalid),
      .m_axi_awready(sh_cl_ddr_awready),
      .m_axi_wdata(cl_sh_ddr_wdata),
      .m_axi_wstrb(cl_sh_ddr_wstrb),
      .m_axi_wlast(cl_sh_ddr_wlast),
      .m_axi_wvalid(cl_sh_ddr_wvalid),
      .m_axi_wready(sh_cl_ddr_wready),
      .m_axi_bid(sh_cl_ddr_bid),
      .m_axi_bresp(sh_cl_ddr_bresp),
      .m_axi_bvalid(sh_cl_ddr_bvalid),
      .m_axi_bready(cl_sh_ddr_bready),
      .m_axi_arid(cl_sh_ddr_arid),
      .m_axi_araddr(cl_sh_ddr_araddr),
      .m_axi_arlen(cl_sh_ddr_arlen),
      .m_axi_arsize(cl_sh_ddr_arsize),
      .m_axi_arvalid(cl_sh_ddr_arvalid),
      .m_axi_arready(sh_cl_ddr_arready),
      .m_axi_rid(sh_cl_ddr_rid),
      .m_axi_rdata(sh_cl_ddr_rdata),
      .m_axi_rresp(sh_cl_ddr_rresp),
      .m_axi_rlast(sh_cl_ddr_rlast),
      .m_axi_rvalid(sh_cl_ddr_rvalid),
      .m_axi_rready(cl_sh_ddr_rready)
      );

   // Vivado HLS Top Module
   interconnects interconnects_inst 
     (
      .ap_clk(clk_main_a0),
      .ap_rst(!rst_main_n_sync),
      .ap_start(interconnects_start),
      .ap_done(),
      .ap_ready(),
      .ap_idle(),
      .peek_req_V_dout(peek_req_V_rd_data),
      .peek_req_V_empty_n(peek_req_V_empty_n),
      .peek_req_V_read(peek_req_V_rd_en),
      .peek_resp_V_din(peek_resp_V_wr_data),
      .peek_resp_V_full_n(peek_resp_V_full_n),
      .peek_resp_V_write(peek_resp_V_wr_en),
      .pcie_read_req_V_num_din(pcie_read_req_V_num_din),
      .pcie_read_req_V_num_full_n(pcie_read_req_V_num_full_n),
      .pcie_read_req_V_num_write(pcie_read_req_V_num_write),
      .pcie_read_req_V_addr_din(pcie_read_req_V_addr_din),
      .pcie_read_req_V_addr_full_n(pcie_read_req_V_addr_full_n),
      .pcie_read_req_V_addr_write(pcie_read_req_V_addr_write),
      .pcie_read_resp_V_last_dout(pcie_read_resp_V_last_dout),
      .pcie_read_resp_V_last_empty_n(pcie_read_resp_V_last_empty_n),ap_start
      .pcie_read_resp_V_last_read(pcie_read_resp_V_last_read),
      .pcie_read_resp_V_data_V_dout(pcie_read_resp_V_data_V_dout),
      .pcie_read_resp_V_data_V_empty_n(pcie_read_resp_V_data_V_empty_n),
      .pcie_read_resp_V_data_V_read(pcie_read_resp_V_data_V_read),
      .pcie_write_req_data_V_last_din(pcie_write_req_data_V_last_din),
      .pcie_write_req_data_V_last_full_n(pcie_write_req_data_V_last_full_n),
      .pcie_write_req_data_V_last_write(pcie_write_req_data_V_last_write),
      .pcie_write_req_data_V_data_V_din(pcie_write_req_data_V_data_V_din),
      .pcie_write_req_data_V_data_V_full_n(pcie_write_req_data_V_data_V_full_n),
      .pcie_write_req_data_V_data_V_write(pcie_write_req_data_V_data_V_write),
      .pcie_write_req_apply_V_num_din(pcie_write_req_apply_V_num_din),
      .pcie_write_req_apply_V_num_full_n(pcie_write_req_apply_V_num_full_n),
      .pcie_write_req_apply_V_num_write(pcie_write_req_apply_V_num_write),
      .pcie_write_req_apply_V_addr_din(pcie_write_req_apply_V_addr_din),
      .pcie_write_req_apply_V_addr_full_n(pcie_write_req_apply_V_addr_full_n),
      .pcie_write_req_apply_V_addr_write(pcie_write_req_apply_V_addr_write),      
      .poke_V_tag_dout(poke_V_tag_dout),
      .poke_V_tag_empty_n(poke_V_tag_empty_n),
      .poke_V_tag_read(poke_V_tag_read),
      .poke_V_data_dout(poke_V_data_dout),
      .poke_V_data_empty_n(poke_V_data_empty_n),
      .poke_V_data_read(poke_V_data_read),
      .dramC_read_req_V_num_din(dramC_read_req_V_num_din),
      .dramC_read_req_V_num_full_n(dramC_read_req_V_num_full_n),
      .dramC_read_req_V_num_write(dramC_read_req_V_num_write),
      .dramC_read_req_V_addr_din(dramC_read_req_V_addr_din),
      .dramC_read_req_V_addr_full_n(dramC_read_req_V_addr_full_n),
      .dramC_read_req_V_addr_write(dramC_read_req_V_addr_write),
      .dramC_read_resp_V_last_dout(dramC_read_resp_V_last_dout),
      .dramC_read_resp_V_last_empty_n(dramC_read_resp_V_last_empty_n),
      .dramC_read_resp_V_last_read(dramC_read_resp_V_last_read),
      .dramC_read_resp_V_data_V_dout(dramC_read_resp_V_data_V_dout),
      .dramC_read_resp_V_data_V_empty_n(dramC_read_resp_V_data_V_empty_n),
      .dramC_read_resp_V_data_V_read(dramC_read_resp_V_data_V_read),
      .dramC_write_req_data_V_last_din(dramC_write_req_data_V_last_din),
      .dramC_write_req_data_V_last_full_n(dramC_write_req_data_V_last_full_n),
      .dramC_write_req_data_V_last_write(dramC_write_req_data_V_last_write),
      .dramC_write_req_data_V_data_V_din(dramC_write_req_data_V_data_V_din),
      .dramC_write_req_data_V_data_V_full_n(dramC_write_req_data_V_data_V_full_n),
      .dramC_write_req_data_V_data_V_write(dramC_write_req_data_V_data_V_write),
      .dramC_write_req_apply_V_num_din(dramC_write_req_apply_V_num_din),
      .dramC_write_req_apply_V_num_full_n(dramC_write_req_apply_V_num_full_n),
      .dramC_write_req_apply_V_num_write(dramC_write_req_apply_V_num_write),
      .dramC_write_req_apply_V_addr_din(dramC_write_req_apply_V_addr_din),
      .dramC_write_req_apply_V_addr_full_n(dramC_write_req_apply_V_addr_full_n),
      .dramC_write_req_apply_V_addr_write(dramC_write_req_apply_V_addr_write)
      );
   
endmodule

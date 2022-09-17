module culsans_tb ();

    // Clock & reset generation

    logic clk;
    logic rst;

    localparam CLK_PERIOD = 10ns;

   initial begin
        clk = 1'b0;
        rst = 1'b1;

        repeat(8)
            #(CLK_PERIOD/2) clk = ~clk;

        rst = 1'b1;

        forever begin
            #(CLK_PERIOD/2) clk = ~clk;
        end
    end

    logic rtc;

    localparam int unsigned RTC_CLOCK_PERIOD = 30.517us;

    initial begin
        forever begin
            rtc = 1'b0;
            forever begin
                #(RTC_CLOCK_PERIOD/2) rtc = ~rtc;
            end
        end
    end

    // Detect the end of the simulation

    logic [31:0] exit_val;

    initial begin
        forever begin

            wait (exit_val[0]);

            if ((exit_val >> 1)) begin
                $error("*** FAILED *** (tohost = %0d)", (exit_val >> 1));
            end else begin
                $info("*** SUCCESS *** (tohost = %0d)", (exit_val >> 1));
            end

            $finish();
        end
    end

    // Memory initialisation

    initial begin
        integer file;
        integer error;
        string  mem_init_file = "main.hex";

        @(negedge rst);
        #1

        file = $fopen(mem_init_file, "r");
        $ferror(file, error);
        $fclose(file);
        if (error == 0) begin
           $readmemh(mem_init_file, i_culsans.i_sram.gen_cut[0].gen_mem.i_tc_sram_wrapper.i_tc_sram.sram);
        end


    end

    // DUT

    ariane_ccu_multicore_top #(
        .InclSimDTM (1'b0),
        .NUM_WORDS  (2**10), // 1Kwords
        .BootAddress (ariane_soc::DRAMBase)
    ) i_culsans (
        .clk_i (clk),
        .rtc_i (rtc),
        .rst_ni(~rst),
        .exit_o (exit_val)
    );
    


    // ...

endmodule
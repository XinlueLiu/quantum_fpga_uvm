// driver
class tb_quantum_gates_driver extends uvm_driver #(tb_quantum_gates_item); //#(REQ,RSP). If same, just put one
    `uvm_component_utils(tb_quantum_gates_driver)

    virtual quantum_gate_if q_vif;
    
    function new(string name = "tb_quantum_gates_driver", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        $display("DRV: build_phase");
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        tb_quantum_gates_item q_obj;
        // driver sequencer handshake
        // allow driver to get a series of transaction objects from sequencer
        // it we need response from driver to sequence with a different resposne type, we can use get(REQ) put(RSP) duo
        $display("=======UVM DRIVER RUN_PHASE WAITING TO FINISH RESET=========="); 
        @(posedge q_vif.rst_n)
        repeat(5) @(q_vif.driver_cb);
        $display("=======UVM DRIVER RUN_PHASE AFTER RESET AND 5 CLOCKS=========="); 
        forever begin
            `uvm_info(get_type_name(), $sformatf("Waiting data from sequencer"), UVM_NONE)
            seq_item_port.get_next_item(q_obj);
            `uvm_info(get_type_name(), $sformatf("DRV got next item"), UVM_NONE)
            drive_item(q_obj);
            `uvm_info(get_type_name(), $sformatf("DRV finished driving item"), UVM_NONE)
            seq_item_port.item_done();
            `uvm_info(get_type_name(), $sformatf("DRV item done"), UVM_NONE)
        end
    endtask : run_phase

    virtual task drive_item(tb_quantum_gates_item q_obj);
        @(q_vif.driver_cb);
        q_vif.driver_cb.load_en <= q_obj.load_en;
        q_vif.driver_cb.gate_evolve <= q_obj.gate_evolve;
        q_vif.driver_cb.gate_select <= q_obj.gate_select;
        q_vif.driver_cb.alpha_real <= q_obj.alpha_real;
        q_vif.driver_cb.alpha_imag <= q_obj.alpha_imag;
        q_vif.driver_cb.beta_real <= q_obj.beta_real;
        q_vif.driver_cb.beta_imag <= q_obj.beta_imag;
        @(q_vif.driver_cb);
        q_vif.driver_cb.load_en <= 0;
        q_vif.driver_cb.gate_evolve <= 0;
        // do begin
        //     @(q_vif.driver_cb);
        //     $display("DRV: t=%0t rst_n=%0b gate_done=%0b gate_evolve=%0b load_en=%0d",                                            
        //    $time, q_vif.rst_n, q_vif.driver_cb.gate_done, q_vif.gate_evolve, q_obj.load_en);
        // end
        // while ((!q_vif.driver_cb.gate_done) && (!q_obj.load_en));
    endtask : drive_item
endclass : tb_quantum_gates_driver
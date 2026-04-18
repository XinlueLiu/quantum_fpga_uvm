// sequence
class tb_quantum_gates_seq extends uvm_sequence;
    `uvm_object_utils(tb_quantum_gates_seq)

    tb_quantum_gates_item q_item;

    function new(string name = "tb_quantum_gates_seq");
        super.new(name);
    endfunction 

    virtual task body();
        $display("=======UVM SEQUENCE BODY ENTRY==========");
        q_item = tb_quantum_gates_item::type_id::create("q_item");
        // first clock cycle, load the signal
        $display("=======UVM SEQUENCE BODY START ITEM 0==========");
        start_item(q_item);
        q_item.load_en = 1;
        // qubit is at initial state of 1, which is alpha|0> + beta|1>
        q_item.alpha_real = 0;
        q_item.alpha_imag = 0;
        q_item.beta_real = 1;
        q_item.beta_imag = 0;
        $display("=======UVM SEQUENCE BODY FINISH ITEM 0==========");
        finish_item(q_item);
        // second clock cycle, perform gate_select for calculation. and gate evolve=1 for saving to register(gate operation finishes in zero time)
        $display("=======UVM SEQUENCE BODY START ITEM 1==========");
        start_item(q_item);
        q_item.load_en = 0;
        q_item.gate_evolve = 1;
        q_item.gate_select = 0;
        $display("=======UVM SEQUENCE BODY FINISH ITEM 1==========");
        finish_item(q_item);
        $display("=======UVM SEQUENCE FINISHED==========");
        // third clock cycle, the register is updated, and now we can observe the output signals out_*. but how do we let predictor and scoreboard know this is what we are comparing?
        // do we need to send anything here?
        // simple sequence
    endtask : body
endclass : tb_quantum_gates_seq
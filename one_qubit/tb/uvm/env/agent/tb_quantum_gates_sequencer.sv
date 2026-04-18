// sequencer
class tb_quantum_gates_sequencer extends uvm_sequencer #(tb_quantum_gates_item);
    `uvm_component_utils(tb_quantum_gates_sequencer)
    
    function new(string name = "tb_quantum_gates_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    /*
    - Single agent with empty sequencer → you need neither, start_item/finish_item just work
    - Single agent with custom sequencer fields → p_sequencer is convenient but you could also manual $cast on m_sequencer
    - Virtual sequencer coordinating multiple agents → p_sequencer is practically essential, because that's how the       
    virtual sequence reaches the sub-sequencer handles to route traffic 
    */

endclass : tb_quantum_gates_sequencer
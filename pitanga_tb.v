`timescale 1ns/1ns

module timer_tb;
    logic clk, stc, inc, run, sw, blk;
    logic [6:0] seg0;
    logic [6:0] seg1; 
    logic [6:0] seg2; 
    logic [6:0] seg3;
    logic [9:0] led;

    always begin
        #2 // inverte o clock a cada 2ns
        clk = ~clk;
    end

    initial begin
        $monitor($time, "stc=%b, inc=%b, run=%b, sw=%b", stc, inc, run, sw);
        $dumpfile("timer_tb.vcd");
        $dumpvars(0, timer);

        clk = 0; // no tempo t=0
        
        // AJUSTE DE SEGUNDOS
        #10 stc = 1; stc = ~stc; // seta ajuste de segundos em t=10
        
        #10 for (integer i = 0; i < 30; i = i + 1) begin
            inc = 1; inc = ~inc; // incrementa segundos a cada 1ns 30 vezes
        end
        
        // AJUSTE DE MINUTOS
        #20 stc = 1; stc = ~stc; // seta ajuste de minutos
        
        #10 for (integer i = 0; i < 10; i = i + 1) begin
            inc = 1; inc = ~inc; // incrementa minutos a cada 1ns 10 vezes
        end
        
        // TESTE DE CONDIÇÕES DE ATIVAÇÃO
        #20 run = 1; // tenta ativar o timer sem condições necessárias
        run = ~run;
        
        // TESTE DE DECREMENTAÇÃO
        #10 sw = 1; // ativa chave de decrementação
        #10 inc = 1; inc = ~inc; // decrementa unidade selecionada em 1 (selecionado: minutos)
        sw = ~sw; // desativa chave de decrementação
        
        // AJUSTE DE HORAS
        #20 stc = 1; stc = ~stc; // seta ajuste de horas
        #10 inc = 1; inc = ~inc; // ajusta horas para 1;
        
        // INICIAÇÃO DO TIMER
        #20 run = 1;
        #10 run = ~run; // teste de pause
        #10 run = 1;

        // FINALIZAÇÃO DA SIMULAÇÃO
        #100 $finish;
    end
endmodule

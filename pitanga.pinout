module counter(clk, stc, inc, run, sw, blk, seg0, seg1, seg2, seg3, led);
    input clk; // relógio do sistema (clock)
    input stc; // troca de unidade horário, se pausado (b0)
    input inc; //  ajusta a unidade, se pausado (b1)
    input run; // pausa/despausa (b3)
    input sw; // mudar operação de ajuste (sw0)
    output reg blk; // saída de relógio (blink)
 
    // Saídas para displays de 7 segmentos/leds
    output [6:0] seg0;   
    output [6:0] seg1;
    output [6:0] seg2;
    output [6:0] seg3;
    output [9:0] led;

    reg [5:0] cnt_hour; // 6 bits para representar [0,64]
    reg [5:0] cnt_min; // 6 bits para representar [0,64]   
    reg [5:0] cnt_sec; // 6 bits para representar [0,64]

    localparam STATE_IDLE = 2'b00;
    localparam STATE_PAUSE = 2'b01;
    localparam STATE_RUNNING = 2'b10;
    localparam STATE_FINISHED = 2'b11;

    reg [1:0] state = STATE_IDLE; // controle de estados da aplicação
 
    localparam SELECTED_NONE = 2'b00;
    localparam SELECTED_SEC = 2'b01;
    localparam SELECTED_MIN = 2'b10;
    localparam SELECTED_HOUR = 2'b11;

    reg [1:0] current = SELECTED_NONE; // controle de unidade selecionada

    localparam FALSE = 1'b0;
    localparam TRUE = 1'b1;

    // piscadinhas
    reg blink_sec;
    reg blink_min;
    reg blink_hour;

    // Bloco de controle
    always@(posedge clk) begin
        blink_sec <= FALSE;
        blink_min <= FALSE;
        blink_hour <= FALSE;

        case (state)
            STATE_IDLE: begin// estado inicial
                cnt_hour <= 5'b00001;
                cnt_min <= 6'b000000;
                cnt_sec <= 6'b000000;
                current <= SELECTED_SEC; // estado de ajuste
                state <= STATE_PAUSE; // seta estado pausado para ajustes
            end
            STATE_PAUSE: begin // estado de ajustes
                blk <= 1'b1;
                if (stc) begin // troca de unidades
                    current <= current + 1;
                    // faz piscar a unidade escolhida
                    case (current)
                        SELECTED_SEC: blink_sec <= TRUE;
                        SELECTED_MIN: blink_min <= TRUE;
                        SELECTED_HOUR: blink_hour <= TRUE;
                    endcase
                end else if (inc) begin // incremento
                    case (current)
                        SELECTED_SEC: begin
                            if (!sw)
                                cnt_sec <= cnt_sec + 1;
                            else 
                                cnt_sec <= cnt_sec - 1;
                        end
                        SELECTED_MIN: begin
                            if (!sw)
                                cnt_min <= cnt_min + 1;
                            else 
                                cnt_min <= cnt_min - 1;
                        end
                        SELECTED_HOUR: begin
                            if (!sw)
                                cnt_hour <= cnt_hour + 1;
                            else
                                cnt_hour <= cnt_hour - 1;
                        end
                    endcase
                end else if (current == SELECTED_NONE && run) // avanço de estado
                        if (((cnt_hour || cnt_min) || cnt_sec)) // acontece somente se existirem valores setados
                            state <= STATE_RUNNING;
                // garante que os valores não ultrapassem seu intervalo
                if (cnt_hour > 23)
                    cnt_hour <= 0;
                else if (cnt_min > 59)
                    cnt_min <= 0;
                else if (cnt_sec > 59)
                    cnt_sec <= 0;
            end
            STATE_RUNNING: begin // cronômetro rodando
                blk <= ~clk;

                if (run) state <= STATE_PAUSE;

                if ((!cnt_sec && !cnt_min) && !cnt_hour) // fim de execução
                    state <= STATE_FINISHED;
                else if ((!cnt_sec && !cnt_min) && cnt_hour) begin
                    // decrementação das horas
                    cnt_hour <= cnt_hour - 1;
                    cnt_min <= 59;
                    cnt_sec <= 59;
                end else if ((!cnt_sec && cnt_min)) begin
                    // decrementação dos minutos
                    cnt_min <= cnt_min - 1;
                    cnt_sec <= 59;
                end else if (cnt_sec) begin
                    // decrementação dos segundos
                    cnt_sec <= cnt_sec - 1;
                end
            end
            STATE_FINISHED: begin // fim da contagem
                blk <= 1'b0;
                // piscadinha total
                blink_sec <= TRUE;
                blink_min <= TRUE;
                blink_hour <= TRUE;
            end
        endcase
    end

    // exibição dos leds (segundos)
    lights_on sec(
        .count(cnt_sec),
        .leds_on(led),
        .blink(blink_sec)
    );
    // exibição no display (minutos)
    display_hhmm min(
        .count(cnt_min),
        .display_d(seg1),
        .display_u(seg0),
        .blink(blink_min)
    );
    // exibição no display (horas)
    display_hhmm hour(
        .count(cnt_hour),
        .display_d(seg3),
        .display_u(seg2),
        .blink(blink_hour)
    );
endmodule:counter

module display_hhmm(count, display_d, display_u, blink);
    input [5:0] count;
    output [6:0] display_d;
    output [6:0] display_u;
    input blink;

    reg [3:0] dezenas;
    reg [3:0] unidades;

    // contador separado em dezenas e unidades
    always @(*) begin
        dezenas = (blink) ? (4'b1010) : count / 10;
        unidades = (blink) ? (4'b1010) : count % 10;
    end

    // exibições nos displays
    display dp7_dezenas(
        .nibble(dezenas),
        .display7seg(display_d)
    );

    display dp7_unidades(
        .nibble(unidades),
        .display7seg(display_u)
    );
endmodule:display_hhmm

module lights_on(count, leds_on, blink);
    input [5:0] count;
    output reg [9:0] leds_on;
    input blink;
    
    reg [3:0] unidades;
    reg [3:0] dezenas;

    // contador separado em dezenas e unidades
    always @(*) begin
        dezenas = (blink) ? 
            ((!count) ? 4'b1111 : 4'b0000) : count / 10;
        unidades = (blink) ? 
            ((!count) ? 4'b1111 : 4'b0000) : count % 10;
    end

    always@(*) begin
        //if (dezenas == 3'b001) // contador em 10
          //  leds_on = 10'b1111111111; // indica todas as luzes acesas
        if (!unidades && !dezenas) // zero
            leds_on = 10'b0000000000;
        else // contador é um numero quebrado
            leds_on = (1 << unidades) - 1;
    end
endmodule:lights_on

module display(nibble, display7seg);
    input [3:0]	nibble;
    output reg [6:0] display7seg;

    always@(*) begin
        case (nibble)
            4'b0000: display7seg = 7'b1111110;
            4'b0001: display7seg = 7'b0110000;
            4'b0010: display7seg = 7'b1101101;
            4'b0011: display7seg = 7'b1111001;
            4'b0100: display7seg = 7'b0110011;
            4'b0101: display7seg = 7'b1011011;
            4'b0110: display7seg = 7'b1011111;
            4'b0111: display7seg = 7'b1110000;
            4'b1000: display7seg = 7'b1111111;
            4'b1001: display7seg = 7'b1111011;
            4'b1010: display7seg = 7'b0000000; // blink-code
            default: display7seg = 7'b0000000;
        endcase
    end
endmodule:display

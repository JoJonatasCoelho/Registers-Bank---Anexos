module reg8b(
    input logic clk, rst, wr_en, wr_global,
    input logic[7:0] din,
    output reg [7:0] dout
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            dout <= 8'b0; // Resetar o registro quando rst está ativo
        else if (wr_global && wr_en)
            dout <= din;
    end
endmodule

module decoder(
    input [2:0] enderecoReg,
    output [7:0] interruptores
);
    assign interruptores = 1 << enderecoReg;
endmodule

module BancoDeReg(
    input reset, clk, wr_en,
    input [2:0] add_rd0, add_rd1, add_wr, // Corrigido para 3 bits para endereçar 8 registradores
    input [7:0] wr_data,
    output reg [7:0] rd0, rd1
);

    wire [7:0] interruptores;
    reg [7:0] register [7:0]; // Declarar os registradores como reg [7:0]

    decoder seleciona(.enderecoReg(add_wr), .interruptores(interruptores)); // Correção da conexão
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin: gen_regs
            reg8b register_inst(
                .rst(reset),
                .din(wr_data),
                .wr_en(interruptores[i]),
                .wr_global(wr_en),
                .clk(clk),
                .dout(register[i])
            );
        end
    endgenerate

    always_ff @(posedge clk) begin
        rd0 <= register[add_rd0];
        rd1 <= register[add_rd1];
    end
endmodule
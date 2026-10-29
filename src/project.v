module tt_um_project (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    reg [31:0] a_reg;
    reg [31:0] b_reg;
    reg [6:0]  opcode_reg;
    wire [31:0] alu_result;

    // Kendi yazdığın 32-bit ALU'yu buraya bağlıyoruz:
    alu u_alu (
        .a(a_reg),
        .b(b_reg),
        .opcode(opcode_reg),
        .r(alu_result)
    );

    // 8-bitlik pinleri kullanarak 32-bit verileri bayt bayt içeri yükleme mantığı:
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg      <= 32'b0;
            b_reg      <= 32'b0;
            opcode_reg <= 7'b0;
        end else if (ena) begin
            case (uio_in[3:0])
                4'h0: a_reg[7:0]   <= ui_in;
                4'h1: a_reg[15:8]  <= ui_in;
                4'h2: a_reg[23:16] <= ui_in;
                4'h3: a_reg[31:24] <= ui_in;
                4'h4: b_reg[7:0]   <= ui_in;
                4'h5: b_reg[15:8]  <= ui_in;
                4'h6: b_reg[23:16] <= ui_in;
                4'h7: b_reg[31:24] <= ui_in;
                4'h8: opcode_reg   <= ui_in[6:0];
                default: ;
            endcase
        end
    end

    // ALU sonucunun (32-bit) hangi baytının dışarı (uo_out) aktarılacağını seçme:
    wire [7:0] result_byte;
    assign result_byte = (uio_in[5:4] == 2'b00) ? alu_result[7:0]   :
                         (uio_in[5:4] == 2'b01) ? alu_result[15:8]  :
                         (uio_in[5:4] == 2'b10) ? alu_result[23:16] : alu_result[31:24];

    // Çıkış atamaları
    assign uo_out  = result_byte;
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule

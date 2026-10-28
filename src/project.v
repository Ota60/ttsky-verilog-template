module tt_um_my_project (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // Kendi sayacını çağırıyoruz ve çıkışını uo_out[3:0]'a bağlıyoruz:
    my_counter u_counter (
        .clk(clk),
        .rst_n(rst_n),
        .counter_out(uo_out[3:0]) // Sayıcının 4 biti doğrudan çıkış pinlerine gider
    );

    // Diğer kullanılmayan çıkışları sıfırlayalım (güvenlik için):
    assign uo_out[7:4] = 4'b0000;
    assign uio_out     = 8'b00000000;
    assign uio_oe      = 8'b00000000;

endmodule

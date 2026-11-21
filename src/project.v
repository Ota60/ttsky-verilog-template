`default_nettype none

module tt_um_project (
    input  wire [7:0] ui_in,    // Sabit girişler: [4] SCLK, [5] CS# (Veri hatlarını artık uio üzerinden alacağız)
    output wire [7:0] uo_out,   // Çıkışlar (LED'ler vb.)
    inout  wire [7:0] uio,      // Çift yönlü pinler: [3:0] QSPI IO[3:0]
    input  wire       ena,      // Tasarım aktif sinyali
    input  wire       clk,      // Ana sistem saati
    input  wire       rst_n     // Aktif-düşük reset
);

    // QSPI kontrol sinyalleri ui_in üzerinden geliyor
    wire       qspi_sclk = ui_in[4];
    wire       qspi_cs_n = ui_in[5];

    // Çift yönlü QSPI veri hatları için sinyaller
    wire [3:0] qspi_io_in;   // Çipten içeri giren veri
    reg  [3:0] qspi_io_out;  // Çipten dışarı çıkan veri (Okuma modunda)
    reg        qspi_oe;      // Yön sinyali: 1 = Çıkış (Master'a veri yolluyoruz), 0 = Giriş (Veri alıyoruz)

    // Tiny Tapeout uio pinlerini inout olarak bağlıyoruz
    // uio_oe 1 olduğunda qspi_io_out dışarı veri basar, 0 olduğunda dışarıyı dinleriz.
    assign uio[0] = qspi_oe ? qspi_io_out[0] : 1'bz;
    assign uio[1] = qspi_oe ? qspi_io_out[1] : 1'bz;
    assign uio[2] = qspi_oe ? qspi_io_out[2] : 1'bz;
    assign uio[3] = qspi_oe ? qspi_io_out[3] : 1'bz;
    
    // Kullanılmayan diğer uio pinlerini boşa çıkartalım
    assign uio[7:4] = 4'bzzzz;

    // İçeri giren verileri okumak için hatları bağlıyoruz
    assign qspi_io_in = uio[3:0];

    // İç değişkenler ve yazmaçlar
    reg [31:0] reg_a;
    reg [31:0] reg_b;
    reg [7:0]  reg_opcode;

    // QSPI İletişim ve Veri Alma Mantığı
    always @(posedge qspi_sclk or negedge rst_n) begin
        if (!rst_n) begin
            reg_a       <= 32'b0;
            reg_b       <= 32'b0;
            reg_opcode  <= 8'b0;
            qspi_oe     <= 1'b0; // Başlangıçta dinleme (giriş) modundayız
            qspi_io_out <= 4'b0;
        end else if (!qspi_cs_n) begin
            // Çip seçili iken (CS aktif)
            // Şimdilik yönü giriş (0) tutup verileri içeri alıyoruz
            qspi_oe     <= 1'b0; 
            reg_a       <= {reg_a[27:0], qspi_io_in};
        end
    end

    // ALU Modülümüzü Çağıralım
    wire [31:0] alu_result;
    
    systemickernel_i_alu alu_inst (
        .a(reg_a),
        .b(reg_b),
        .opcode(reg_opcode),
        .r(alu_result)
    );

    // Sonucu dışarıdaki LED'lere verelim
    assign uo_out = alu_result[7:0];

    // Kullanılmayan sinyal uyarısını önleyelim
    wire _unused = &{ena, ui_in[7:6], 1'b0};

endmodule

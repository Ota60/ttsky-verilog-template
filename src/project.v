`default_nettype none

module tt_um_project (
    input  wire [7:0] ui_in,    // Sabit girişler: [4] SCLK, [5] CS#
    output wire [7:0] uo_out,   // Çıkışlar (LED'ler vb.)
    input  wire [7:0] uio_in,   // Çift yönlü pinlerin GİRİŞ hattı
    output wire [7:0] uio_out,  // Çift yönlü pinlerin ÇIKIŞ hattı
    output wire [7:0] uio_oe,   // Çift yönlü pinlerin YÖN kontrolü (1=Çıkış, 0=Giriş)
    input  wire       ena,      // Tasarım aktif sinyali
    input  wire       clk,      // Ana sistem saati
    input  wire       rst_n     // Aktif-düşük reset
);

    // QSPI kontrol sinyalleri ui_in üzerinden geliyor
    wire       qspi_sclk = ui_in[4];
    wire       qspi_cs_n = ui_in[5];

    // Çift yönlü QSPI veri hatları için iç sinyaller
    wire [3:0] qspi_io_in;   
    reg  [3:0] qspi_io_out;  
    reg        qspi_oe;      

    // Tiny Tapeout portlarına bağlantılar
    assign qspi_io_in   = uio_in[3:0]; // Dışarıdan gelen veriyi okuyoruz
    
    // QSPI çıkışlarını ve yönünü Tiny Tapeout pinlerine bağlıyoruz
    assign uio_out[3:0] = qspi_io_out;
    assign uio_oe[3:0]  = {4{qspi_oe}}; // qspi_oe 1 ise çıkış, 0 ise giriş
    
    // Kullanılmayan diğer uio pinlerini pasif yapalım
    assign uio_out[7:4] = 4'b0;
    assign uio_oe[7:4]  = 4'b0;

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
    wire _unused = &{ena, ui_in[7:6], uio_in[7:4], 1'b0};

endmodule

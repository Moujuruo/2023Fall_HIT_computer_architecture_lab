module cache (
    input            clk             ,  // clock, 100MHz
    input            rst             ,  // active low

    //  Sram-Like�ӿ��źţ�����CPU����Cache
    input         cpu_req      ,    //��CPU������Cache
    input  [31:0] cpu_addr     ,    //��CPU������Cache
    output [31:0] cache_rdata  ,    //��Cache���ظ�CPU
    output        cache_addr_ok,    //��Cache���ظ�CPU
    output        cache_data_ok,    //��Cache���ظ�CPU

    //  AXI�ӿ��źţ�����Cache��������
    output [3 :0] arid   ,              //Cache�����淢�������ʱʹ�õ�AXI�ŵ���id��
    output [31:0] araddr ,              //Cache�����淢�������ʱ��ʹ�õĵ�ַ
    output        arvalid,              //Cache�����淢�������������ź�
    input         arready,              //�������ܷ񱻽��յ������ź�

    input  [3 :0] rid    ,              //������Cache��������ʱʹ�õ�AXI�ŵ���id��
    input  [31:0] rdata  ,              //������Cache���ص�����
    input         rlast  ,              //�Ƿ���������Cache���ص����һ������
    input         rvalid ,              //������Cache��������ʱ��������Ч�ź�
    output        rready                //��ʶ��ǰ��Cache�Ѿ�׼���ÿ��Խ������淵�ص�����
);

    wire [6:0] index = cpu_addr[11:5];  //CPU��ַ��index����Ϊ����ַ����һ����ˮ��
    wire [19:0] cpu_tag = cpu_addr[31:12];  //CPU��ַ��tag������ѡ·���ڶ�����ˮ��
    wire [4:0] offset = cpu_addr[4:0];  //CPU��ַ��offset

    wire hit0, hit1;
    wire rden0, rden1;
    wire wen0, wen1;

    reg hit0_reg, hit1_reg;
    reg [31:0] cpu_addr_reg;
    wire [6:0] index_reg = cpu_addr_reg[11:5];  //CPU��ַ��index����Ϊ����ַ����һ����ˮ��
    wire [19:0] cpu_tag_reg = cpu_addr_reg[31:12];  //CPU��ַ��tag������ѡ·���ڶ�����ˮ��
    wire [4:0] offset_reg = cpu_addr_reg[4:0];  //CPU��ַ��offset

    // always @(posedge clk) begin
    //     if (!rst) cpu_addr_reg <= 0;
    //     if (!cache_addr_ok) cpu_addr_reg <= cpu_addr_reg;
    //     else cpu_addr_reg <= cpu_addr;
    // end

    assign rden0 = (cpu_req && cache_addr_ok) ? 1 : 0;
    assign rden1 = (cpu_req && cache_addr_ok) ? 1 : 0;

    // ʵ��������tag�ȽϺ���Чλ����ģ��
    icache_tagv_table tagv0(
        .clk(clk),
        .resetn(rst),
        .wen(wen0),
        .valid_wdata(1),
        .tag_wdata(cpu_tag_reg),
        .windex(index_reg),
        .rden(rden0),
        .cpu_addr(cpu_addr),
        .hit(hit0)
    );

    icache_tagv_table tagv1(
        .clk(clk),
        .resetn(rst),
        .wen(wen1),
        .valid_wdata(1),
        .tag_wdata(cpu_tag_reg),
        .windex(index_reg),
        .rden(rden1),
        .cpu_addr(cpu_addr),
        .hit(hit1)
    );

    // ���� Cache �ӿ��ź� 
    wire [31:0] bram_data0, bram_data1; // Cache 
    wire [31:0] bram_in0, bram_in1; // ��������
    wire [31:0] bram_addr0, bram_addr1; // ��ַ����
    wire wea_0, wea_1; 
    wire enb_0, enb_1;

    assign enb_0 = rden0;
    assign enb_1 = rden1;

    // ʵ�������� Cache
    Bram BRAM0(
        .addra(bram_addr0),
        .clka(clk),
        .dina(bram_in0),
        .wea(wea_0),
        .clkb(clk),
        .enb(enb_0),
        .addrb(cpu_addr[11:2]),
        .doutb(bram_data0)
    );

    Bram BRAM1(
        .addra(bram_addr1),
        .clka(clk),
        .dina(bram_in1),
        .wea(wea_1),
        .clkb(clk),
        .enb(enb_1),
        .addrb(cpu_addr[11:2]),
        .doutb(bram_data1)
    );


    reg lru_bit [0:127];
    integer i;

    // �ڷ���Cacheʱ����LRUλ
    always @(posedge clk) begin
        if (!rst) begin
            // ��ʼ��LRUλ
            for (i = 0; i < 128; i=i+1) begin
                lru_bit[i] <= 0;
            end
        end else if (cpu_req && cache_addr_ok) begin
            // ������Cacheʱ������LRUλ
            lru_bit[index] <= ~lru_bit[index];
        end
    end

    // ѡ���滻��·
    wire replace_way0 = ~lru_bit[index_reg];
    wire replace_way1 = lru_bit[index_reg];

    localparam IDLE = 0, WAITING = 1, RECEIVING = 2, LAST = 3, INIT = 4; // ���״̬
    reg [2:0] axi_state = INIT;
    reg ar_valid, r_ready;
    reg [31:0] ar_addr;

    assign araddr = ar_addr;
    assign rready = r_ready;
    assign arvalid = ar_valid;
    assign arid = 0;

    assign cache_miss = (axi_state == INIT) ? 0 : ~(hit0 || hit1); // �����Ƿ������ж��Ƿ���cache miss

    always @(posedge clk) begin
        if (!rst) begin
            axi_state <= INIT; // INIT ��ʼ����ˮ��
            ar_addr <= 0;
            ar_valid <= 0;
            r_ready <= 0;
        end else begin
            case(axi_state) // ״̬��ת��
                INIT:begin
                    axi_state <= IDLE;
                end
                IDLE:begin
                    if (cache_miss) begin
                        axi_state <= WAITING; 
                        ar_addr <= {cpu_addr_reg[31:5], 5'b00000};  // ����Cache�����׵�ַ
                        ar_valid <= 1; // ���Ͷ�����
                    end
                end
                WAITING:begin
                    if (arready) begin // �ӵ������󱻽��յ������ź�
                        axi_state <= RECEIVING;
                        r_ready <= 1; // ���ͽ������ݵ������ź�
                        ar_valid <= 0;
                    end
                end
                RECEIVING:begin
                    if (rready && rlast) begin // ���յ����һ������
                        axi_state <= LAST;
                        r_ready <= 0;
                    end
                end
                LAST:begin
                    axi_state <= IDLE; // ר��Ϊ�ͳ�����cache miss ���������ָ���������Ƶ�״̬
                end
            endcase
            if (rden0 || rden1) 
                cpu_addr_reg <= cpu_addr;
        end
    end

    assign cache_addr_ok = (!rst || axi_state == INIT) ? 1 : 
    (axi_state == RECEIVING) ? 0
     : (hit0 || hit1 || axi_state == LAST) ? 1 : 0;

    // �� cache_data_ok �� cache_addr_ok ��һ������
    // reg cache_addr_ok_reg;
    // always @(posedge clk) begin
    //     if (!rst) cache_addr_ok_reg <= 0;
    //     else cache_addr_ok_reg <= cache_addr_ok;
    // end

    // assign cache_data_ok = (!rst || axi_state == INIT) ? 1 :
    // (cache_rdata == 0) ? 0 : cache_addr_ok_reg;
    assign cache_data_ok = (hit0 || hit1 || axi_state == LAST) ? 1 : 0;

    reg [31:0] bramin0, bramin1;
    reg [31:0] bramaddr0, bramaddr1;
    reg [31:0] first_miss_data;
    reg wea0, wea1;

    assign cache_rdata = (hit0) ? bram_data0 : (hit1) ? bram_data1 : (axi_state == LAST) ? first_miss_data : 
    0;

    assign bram_in0 = bramin0;
    assign bram_in1 = bramin1;
    assign wea_0 = wea0;
    assign wea_1 = wea1;
    assign bram_addr0 = bramaddr0;
    assign bram_addr1 = bramaddr1;
    reg [2:0] counter = 3'b000;

    always @(posedge clk) begin
        if (rvalid) begin
            if (replace_way0) begin
               bramin0 <= rdata; 
               wea0 <= 1;
               bramaddr0 = {index_reg, counter}; // counter��0����7������ѡȡCache���е�һ��λ��
               if (bramaddr0 == cpu_addr_reg[11:2]) // ע��Ҫ������ֵһ�£���Ȼ��ը��
                    first_miss_data <= rdata;
               counter <= counter + 1;
            end
            else if (replace_way1) begin
               bramin1 <= rdata; 
               wea1 <= 1;
               bramaddr1 = {index_reg, counter};
               if (bramaddr1 == cpu_addr_reg[11:2])
                    first_miss_data <= rdata;
               counter <= counter + 1;
            end
        end
        else begin
            wea0 <= 0;
            wea1 <= 0;
            counter <= 3'b000;
        end
    end

    // assign wen0 = (rvalid && replace_way0) ? 1 : 0;
    // assign wen1 = (rvalid && replace_way1) ? 1 : 0;
    assign wen0 = wea0;
    assign wen1 = wea1;

endmodule
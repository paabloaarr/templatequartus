`timescale 1ns/1ps

module top_tb;
    logic a;
    logic b;
    logic y;

    top dut (
        .a(a),
        .b(b),
        .y(y)
    );

    // Prueba las cuatro combinaciones de entrada de la puerta AND.
    // Adapta los estímulos y el resultado esperado al cambiar el diseño.
    initial begin
        for (int i = 0; i < 4; i++) begin
            {a, b} = i[1:0];
            #10;
            if (y !== (a & b))
                $fatal(1, "Error: a=%b b=%b y=%b, esperado=%b", a, b, y, a & b);
        end

        $display("PASS: todas las combinaciones son correctas.");
        $finish;
    end
endmodule

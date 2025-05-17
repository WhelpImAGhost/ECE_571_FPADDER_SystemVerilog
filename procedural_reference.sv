module FPAdder (fpbus bus);

shortreal fA, fB, fX;


always_comb 
begin
	fA = $bitstoshortreal(bus.A);
	fB = $bitstoshortreal(bus.B);
	fX = fA + fB;
	bus.Result = $shortrealtobits(fX);

end
endmodule

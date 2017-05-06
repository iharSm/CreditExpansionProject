bl = BlackLitterman
returns1 = bl.simulate();

returns_m = bl.simulate_markovitz();

plot(bl.dates(41:end), cumprod(1+returns_m),bl.dates(41:end), cumprod(1+returns1))
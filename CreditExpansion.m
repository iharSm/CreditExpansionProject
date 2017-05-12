all_countries = {'Australia' 'Austria' 'Belgium' 'Canada' 'Denmark' 'France' 'Germany' 'Ireland' 'Italy' 'Japan' 'Korea' 'Netherlands' 'Norway' 'Singapore' 'Spain' 'Sweden' 'Switzerland' 'UK' 'US'};
bank_countries = {'Australia' 'Belgium' 'Canada' 'Denmark' 'France' 'Germany' 'Ireland' 'Italy' 'Japan' 'Netherlands' 'Norway' 'Spain' 'Sweden' 'Switzerland' 'UK' 'US'};
i = 13;
ret = [];



bl = BlackLitterman('data/predictions/bank_return_1y.xlsx', bank_countries,'data/historical data/unhedged_histdata.xlsx', 'bank returns', 4);
ret = [ret;bl.run('1 year prediction. Unhedged bank returns', i)];
i=i+1;

bl = BlackLitterman('data/predictions/bank_return_2y.xlsx',bank_countries, 'data/historical data/unhedged_histdata.xlsx', 'bank returns', 8);
ret = [ret;bl.run('2 year prediction. Unhedged bank returns', i)];
i=i+1;

bl = BlackLitterman('data/predictions/bank_return_3y.xlsx', bank_countries, 'data/historical data/unhedged_histdata.xlsx', 'bank returns', 12);
ret = [ret;bl.run('3 year prediction. Unhedged bank returns',i)];
i=i+1;

bl = BlackLitterman('data/predictions/non_financial_return_1y.xlsx',all_countries, 'data/historical data/unhedged_histdata.xlsx', 'total returns', 4);
ret = [ret;bl.run('1 year prediction. Unhedged total returns',i)];
i=i+1;

bl = BlackLitterman('data/predictions/non_financial_return_2y.xlsx',all_countries, 'data/historical data/unhedged_histdata.xlsx', 'total returns', 8);
ret = [ret;bl.run('2 year prediction. Unhedged total returns',i)];
i=i+1;

bl = BlackLitterman('data/predictions/non_financial_return_3y.xlsx',all_countries, 'data/historical data/unhedged_histdata.xlsx', 'total returns', 12);
ret = [ret;bl.run('3 year prediction. Unhedged total returns',i)];
i=i+1;

bl = BlackLitterman('data/predictions/bank_return_1y.xlsx',bank_countries, 'data/historical data/hedged_histdata.xlsx', 'bank returns', 4);
ret = [ret;bl.run('1 year prediction. Hedged bank returns',i)];
i=i+1;

bl = BlackLitterman('data/predictions/bank_return_2y.xlsx',bank_countries, 'data/historical data/hedged_histdata.xlsx', 'bank returns', 8);
ret = [ret;bl.run('2 year prediction. Hedged bank returns',i)];
i=i+1;

bl = BlackLitterman('data/predictions/bank_return_3y.xlsx',bank_countries, 'data/historical data/hedged_histdata.xlsx', 'bank returns', 12);
ret = [ret;bl.run('3 year prediction. Hedged bank returns',i)];
i=i+1;

bl = BlackLitterman('data/predictions/non_financial_return_1y.xlsx',all_countries, 'data/historical data/hedged_histdata.xlsx', 'total returns', 4);
ret = [ret;bl.run('1 year prediction. Hedged total returns',i)];
i=i+1;

bl = BlackLitterman('data/predictions/non_financial_return_2y.xlsx',all_countries, 'data/historical data/hedged_histdata.xlsx', 'total returns', 8);
ret = [ret;bl.run('2 year prediction. Hedged total returns',i)];
i=i+1;

bl = BlackLitterman('data/predictions/non_financial_return_3y.xlsx',all_countries, 'data/historical data/hedged_histdata.xlsx', 'total returns', 12);
ret = [ret;bl.run('3 year prediction. Hedged total returns',i)];
i=i+1;
xlswrite('returns.xlsx',ret);
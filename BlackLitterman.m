classdef BlackLitterman
    
    properties
        predictions_file;
        historical_returns_file;
        mu_credit_exp;
        historical_returns;
        dates;
        risk_free_rate;
        number_of_obs;
        portfolio_size;
    end
    
    methods
        function obj = BlackLitterman(predictions_file, countries, historical_returns_file, historical_returns_sheet, frequency)
            obj.predictions_file = predictions_file;
            obj.historical_returns_file = historical_returns_file;
            
            obj.dates = sort([datetime([1920:2012]', 1, 1);
                datetime([1920:2012]', 4, 1);
                datetime([1920:2012]', 7, 1);
                datetime([1920:2012]', 10, 1)]);
            
            tr = timerange('01/01/1976','10/01/2012');
            
            obj.mu_credit_exp = readtable(obj.predictions_file,'Sheet','mean');
            obj.mu_credit_exp.Var1 = [];
            obj.mu_credit_exp = table2timetable(obj.mu_credit_exp,'RowTimes',obj.dates);
            obj.mu_credit_exp = obj.mu_credit_exp(:,countries);
            
            obj.mu_credit_exp = obj.mu_credit_exp(tr,:);
            func = @(x)(1+x).^(1/frequency)-1;
            temp = obj.mu_credit_exp.Properties.VariableNames;
            obj.mu_credit_exp = varfun(func,obj.mu_credit_exp(2:end,:));
            obj.mu_credit_exp.Properties.VariableNames = temp;
            
            [obj.number_of_obs, obj.portfolio_size] = size(obj.mu_credit_exp);
            
            obj.historical_returns = readtable(historical_returns_file, 'Sheet', historical_returns_sheet);
            obj.historical_returns.Var1 = [];
            obj.historical_returns = table2timetable(obj.historical_returns,'RowTimes',obj.dates);
            obj.historical_returns = obj.historical_returns(tr, countries);
            
            obj.risk_free_rate = readtable('data/historical data/RiskFree.xlsx');
            obj.risk_free_rate = table2timetable(obj.risk_free_rate,'RowTimes',obj.dates);
            obj.risk_free_rate.Date = []
            
            obj.dates = sort([datetime([1976:2012]', 1, 1);
                datetime([1976:2012]', 4, 1);
                datetime([1976:2012]', 7, 1);
                datetime([1976:2012]', 10, 1)]);
            
            obj.mu_credit_exp = fillmissing(obj.mu_credit_exp, 'nearest');
            obj.historical_returns = fillmissing(obj.historical_returns, 'nearest');
            
            
            
            
        end
        
        %follows example on the page 5 of The Black - Litterman Approach by
        %Attilio Meucci
        function [P, v]  = portfolioViews(obj,date)
            P = eye(obj.portfolio_size);
            v = table2array(obj.mu_credit_exp(date,1:end))';
        end
        
        function [mu, sigma] = portfolioMuCov(obj, date)
            tr = timerange(obj.dates(1),date);
            
            mu = mean(table2array(obj.historical_returns(tr,1:end)))';
            sigma = cov(table2array(obj.historical_returns(tr,1:end)));
        end
        
        % all equations are from Meucci
        function [mu_bl, sigma_bl] = blackLittermanModel(obj, P,v, mu,sigma)
            [m,n] = size(P);
            w = ones(n,1)/(n+1);
            tau = 1/m;
            pi = 2.4*sigma*w;
            
            %c=1 - no uncertaity in the views
            Omega = P*sigma*P';
            
            %eq 20
            mu_bl = pi + tau*sigma*P'*inv(tau*P*sigma*P' + Omega)*(v-P*pi);
            
            %eq21
            sigma_bl = (1+tau)*sigma - tau^2 * sigma * P'*inv(tau*P*sigma*P' + Omega)*P*sigma;
            
        end
        
        function weights = markowitz (obj, mu0, mu, V, benchmark_risk, Sample_Returns)
            U = chol(V);
            S_R = table2array(Sample_Returns);
            
            [T,n] = size(S_R);
            
            cvx_begin quiet
            
            variables x0 x(n)
            maximize(x0*mu0 + mu'*x)
            
            subject to
            norm(U*x) <= benchmark_risk;
            sum(x) + x0== 1
            x0>=0
            abs(x - 0.2)<=0.2;
            cvx_end
            weights = [x0; x];
            
        end
        
        function port_returns = simulate(obj)
            port_returns = [];
            w= [];
            old_date = obj.dates(40);
            for date = obj.dates(41:end)'
                mu0 = (1+obj.risk_free_rate{old_date, 'US'})^(0.25) - 1;
                mu0_future = (1+obj.risk_free_rate{date, 'US'})^(0.25) - 1;
                e = ones(obj.portfolio_size,1);	

                [P, v ] = obj.portfolioViews(old_date);
                [mu, sigma] = obj.portfolioMuCov(old_date);
                benchmark_risk = sqrt(e'*sigma*e)/(obj.portfolio_size);
                [mu_bl, sigma_bl] = obj.blackLittermanModel(P,v, mu,sigma);
                weights = obj.markowitz (mu0, mu_bl, sigma_bl, benchmark_risk, obj.historical_returns(timerange(obj.dates(1),old_date),:));
                port_returns = [port_returns;mu0_future*weights(1)+obj.historical_returns{date,:}*weights(2:end)];
                w = [w;weights'];
                old_date = date;
            end
            xlswrite('weights_bl.xlsx',w);
        end
        
        function port_returns = simulate_markowitz (obj)
            port_returns = [];
            w= [];
            old_date = obj.dates(40);
            for date = obj.dates(41:end)'
                mu0 = (1+obj.risk_free_rate{old_date, 'US'})^(0.25) - 1;
                mu0_future = (1+obj.risk_free_rate{date, 'US'})^(0.25) - 1;
                e = ones(obj.portfolio_size,1);	
                [P, v ] = obj.portfolioViews(old_date);
                [mu, sigma] = obj.portfolioMuCov(old_date);
                benchmark_risk = sqrt(e'*sigma*e)/(obj.portfolio_size);
                weights = obj.markowitz (mu0, mu, sigma,benchmark_risk, obj.historical_returns(timerange(obj.dates(1),old_date),:));
                port_returns = [port_returns;mu0_future*weights(1)+obj.historical_returns{date,:}*weights(2:end)];
                old_date = date;
                w = [w;weights'];
            end
            xlswrite('weights.xlsx',w);
        end
        
        function w = run(obj, ttl, fig_ind)
            returns_bl = obj.simulate();
            returns_m = obj.simulate_markowitz();

            portf_bl = cumprod(1+returns_bl);
            portf = cumprod(1+returns_m);

            figure
                plot(obj.dates(42:end), portf,obj.dates(42:end), portf_bl)

                title(ttl)
                legend('Markowitz', 'Black-Litterman', 'Location', 'NorthWest'); 
                savefig(strcat('plots/fig',int2str(fig_ind), '.fig'));
                
            w = [ttl, portf_bl(end), portf(end)];
        end
    end
end


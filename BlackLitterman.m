classdef BlackLitterman
    %BlackLitterman Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fileName = 'data/bank_equity_returns_3y.xlsx';
        mu_credit_exp;
        historical_returns;
        dates
    end
    
    methods
        function obj = BlackLitterman()
            obj.dates = sort([datetime([1920:2013]', 1, 1);
                datetime([1920:2013]', 4, 1);
                datetime([1920:2013]', 7, 1);
                datetime([1920:2012]', 10, 1)]);
            [m,n] = size(obj.dates);
            tr = timerange('01/01/1974','04/01/2013');
            
            obj.mu_credit_exp = readtable(obj.fileName,'Sheet','mean');
            
            obj.mu_credit_exp.Var1 = [];
            obj.mu_credit_exp = table2timetable(obj.mu_credit_exp,'RowTimes',obj.dates);
            
            obj.mu_credit_exp = obj.mu_credit_exp(tr,:);
            
            
            obj.historical_returns = readtable('data/histdata.xlsx', 'Sheet','equity_tot_excess_return');
            obj.historical_returns.Var1 = [];
            obj.historical_returns = table2timetable(obj.historical_returns,'RowTimes',obj.dates);
            obj.historical_returns = obj.historical_returns(tr,:);
            
            obj.dates = sort([datetime([1974:2013]', 1, 1);
                datetime([1974:2012]', 4, 1);
                datetime([1974:2012]', 7, 1);
                datetime([1974:2012]', 10, 1)]);
            
            
            obj.mu_credit_exp = fillmissing(obj.mu_credit_exp, 'nearest');
            obj.historical_returns = fillmissing(obj.historical_returns, 'nearest');
        
        end
        
        function [P, v]  = portfolioViews(obj,date)
            P = eye(20);
            v = table2array(obj.mu_credit_exp(date,1:end))';
        end
        
        function [mu, sigma] = portfolioMuCov(obj, date)
            tr = timerange(obj.dates(1),date);
            
            mu = mean(table2array(obj.historical_returns(tr,1:end)))';
            sigma = cov(table2array(obj.historical_returns(tr,1:end)));
        end
        
        function [mu_bl, sigma_bl] = blackLittermanModel(obj, P,v, mu,sigma)
            [m,n] = size(P);
            w = ones(n,1)/n;
            tau = 1/m;
            pi = 2.4*sigma*w;
            
            %c=1 - no uncertaity in the views
            Omega = P*sigma*P';

            mu_bl = pi + tau*sigma*P'*inv(tau*P*sigma*P' + Omega)*(v-P*pi);
            sigma_bl = (1+tau)*sigma - tau^2 * sigma * P'*inv(tau*P*sigma*P' + Omega)*P*sigma;
            
        end
        
        function weights = markovitz(obj, mu, V)
                   
            n = length(mu);
            e = ones(n,1);
            U = chol(V);
            
            sigma = 0.2;
            
            cvx_begin quiet
            
            variables x(n)
            
            maximize(mu'*x);
            
            subject to
                norm(U*x) <= sigma;
                sum(x) == 1;
                abs(x)<=0.5;
            cvx_end
            
            weights = [x]
        end
        
        function port_returns = simulate(obj)
            port_returns = [];
            old_date = obj.dates(40);
            for date = obj.dates(41:end)'
                [P, v ] = obj.portfolioViews(old_date);
                [mu, sigma] = obj.portfolioMuCov(old_date);
                [mu_bl, sigma_bl] = obj.blackLittermanModel(P,v, mu,sigma);
                weights = obj.markovitz(mu_bl, sigma_bl);
                port_returns = [port_returns;table2array(obj.historical_returns(date,:))*weights]
                old_date = date;
            end

        end
        
        function port_returns = simulate_markovitz(obj)
            port_returns = [];
            old_date = obj.dates(40);
            for date = obj.dates(41:end)'
                [mu, sigma] = obj.portfolioMuCov(old_date);
                weights = obj.markovitz(mu, sigma);
                port_returns = [port_returns;table2array(obj.historical_returns(date,:))*weights]
                old_date = date;
            end
        end
    end
end


classdef BlackLitterman
    %BlackLitterman Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fileName = 'data/bank_equity_returns_3y.xlsx';
        mu_credit_exp;
        historical_returns;
        %sigma
    end
    
    methods
        function obj = BlackLitterman()
            obj.mu_credit_exp = readtable(obj.fileName,'Sheet','mean', 'ReadRowNames',true);
            %obj.sigma = xlsread(fileName, 'sd');
        end
        
        function view = portfolioViews(obj,date)
            P = eye(20);
            v = obj.mu_credit_exp(date,2:end);
            view = [P, table2array(v)'];
        end
        
        function muCov = portfolioMuCov(obj, date)
            obj.historical_returns = readtable('data/histdata.xlsx', 'Sheet','equity_tot_excess_return', 'ReadRowNames',true);
            
            mu = mean(obj.historical_returns(1:date,2:end));
            sigma = cov(obj.historical_returns(1:date,2:end));
            
            muCov=[mu,sigma];
        end
        
        function [mu_bl, sigma_bl] = blackLittermanModel(obj, view, mu,sigma)
            [m,n] = size(view);
            w = ones(n,1)/n;
            tau = 1/m;
            pi = 2.4*sigma*w;
            
            %c=1 - no uncertaity in the views
            Omega = P*sigma*P';
            v =1;
            mu_bl = pi + tau*sigma*P'*inv(tau*P*sigma*P' + Omega)*(v-P*pi);
            
            sigma_bl = (1+tau)*sigma - tau^2 * sigma * P'*inv(tau*P*sigma*P' + Omega)*P*sigma;
            
        end
        
        function weights = markovitz(obj, mu, V)
            n = length(mu);
            e = ones(n,1);
            U = chol(V);
            
            cvx_begin quiet
            
            variables x0 x(n) y(n)
            
            maximize(x0*mu0 + mu'*x);
            
            subject to
            norm(U*x) <= sigma;
            x0+sum(x) + total_trans_cost == 1;
            x == xx +y;
            x0>=0;
            abs(x - 0.1)<=0.05;
            cvx_end
            
            weights = [x0, x']
        end
        
        function port_returns = simulate(obj)
            port_returns = [];
            for i = 1980:2012
                for j = 1:4
                    date = strcat(int2str(i),'_',int2str(j));
                    view = obj.portfolioViews(date);
                    muCov = obj.portfolioMuCov(date);
                    mu_bl, sigma_bl = obj.blackLittermanModel(view, muCov(1),muCov(2));
                    weights = markovitz(mu_bl, sigma_bl);
                    port_returns = [port_returns,weights']
                end
            end
        end
    end
end


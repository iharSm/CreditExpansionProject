classdef BlackLitterman
    %BlackLitterman Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        
    end
    
    methods
        function view = portfolioViews()
            
        
        end
        
        function sigma = portfolioCovariance()
        end
        
        function mu_bl, sigma_bl = BlackLittermanModel(view, sigma)
            tau = 1;
            pi = 1;
            Omega = ;
            v =;
            mu_bl = pi + tau*sigma*P'*inv(tau*P*sigma*P' + Omega)*(v-P*pi);
            
            sigma_bl = (1+tau)*sigma - tau^2 * sigma * P'*inv(tau*P*sigma*P' + Omega)*P*sigma);
            
        end
        
        function weights = Markovitz(mu, V)
            n = length(mu);
            e = ones(n,1);
            U = chol(V);

            cvx_begin quiet
    
            variables x0 x(n) y(n) total_trans_cost
              
            maximize(x0*mu0 + mu'*x);
        
            subject to
                  norm(U*x) <= sigma;
                  x0+sum(x) + total_trans_cost == 1;
                  x == xx +y;
                  trans_cost*sum(abs(y)) <= total_trans_cost;
                  x0>=0;
                  abs(x - 0.1)<=0.05;
            cvx_end
        
        end
    end
    
end


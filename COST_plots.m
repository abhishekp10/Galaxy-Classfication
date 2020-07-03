%Plot cost function, train error and test error to check for convergence

f2 = figure;
    subplot(3,1,1)
    plot(1:length(Cost_op),Cost_op); 
            title('cost fct o/p (training)',...
                'FontName','LucidaSans', 'FontWeight','bold');
            xlabel('gradient steps');
            axis tight; axis 'auto y'; 
            hold on; box on;
            hold off;
            
    subplot(3,1,2)
    plot(1:length(TRN_err),TRN_err); 
            title('Train error plot',...
                'FontName','LucidaSans', 'FontWeight','bold');
            xlabel('gradient steps');
            axis tight; axis 'auto y'; 
            hold on; box on;
            hold off;
            
            
    subplot(3,1,3)
    plot(1:length(TST_err),TST_err); 
            title('Test error plot',...
                'FontName','LucidaSans', 'FontWeight','bold');
            xlabel('gradient steps');
            axis tight; axis 'auto y'; 
            hold on; box on;
            hold off;
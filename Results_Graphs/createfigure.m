function createfigure(ymatrix1)
%CREATEFIGURE(YMATRIX1)
%  YMATRIX1:  bar matrix data

%  Auto-generated by MATLAB on 19-Aug-2015 10:10:06

% Create figure
figure1 = figure('Color',[1 1 1]);

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'all');

% Create multiple lines using matrix input to bar
bar1 = bar(ymatrix1,'BarWidth',1,'Parent',axes1);
set(bar1(1),'FaceColor',[0 1 0],'DisplayName','visits');
set(bar1(2),'FaceColor',[0 0 1],'DisplayName','reads');
set(bar1(3),'FaceColor',[1 0 0],'DisplayName','clicks');

% Create title
title('Descending relevance ranking','FontSize',20);

% Create legend
legend1 = legend(axes1,'show');
set(legend1,'EdgeColor',[1 1 1],'YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.390242710666526 0.631986715244146 0.105410465993534 0.2394643888568],...
    'FontSize',16);

% extract_plot_from_panel: script to extract plot from a panelled 
% figure (eg acceptfigure)
hf = gcf;
ax = findobj(hf.Children,'Type','axes');
hfig = figure('Name','Clusters','Tag','PlotFig');
copyobj(ax,hfig);

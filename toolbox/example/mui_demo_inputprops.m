function [inp,run] = mui_demo_inputprops()
    %sample input properties to run diffusion2Dmodel
    % input data 
    inp.Xint = 20;
    inp.Yint = 30;    
    inp.Xlength = 100;
    inp.Ylength = 150;
    inp.DiffCoeff = 0.5;
    inp.uPeak = 0.8;
    inp.PkSize = 0.2;
    % boundary conditions
    inp.uEast = 0;
    inp.uWest = 0;
    inp.uSouth = 0;
    inp.uNorth = 0;
    % run data
    run.is3D = false;
    run.TimeStep = 0.5;
    run.NumStep = 100;
    run.NumScheme = 1;
    run.BCoption = 1;
end

    
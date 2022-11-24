classdef RCWA_TZH < handle
    properties(SetAccess=protected)
        ShowProcess             % show the process of the simulation
        BlurCoef = 0          % blur device to accelerate the caculation
        ShrinkCoef = 0         % blur and shrink device to accelerate the caculation
        dispersion = 1          % define dispersion
        RecordField = 0         % reconstructe field inside device 
        RecordDifOrder = 0      % record diffrection order for every wavelength
        referur                 % permeability and permittivity in reflection region
        trnerur                 % permeability and permittivity in transmission region
        R
        T
        Ref_order               % reflection in each order
        Trn_order               % transmission in each order
        source                  % source of the simulation
        device                  % device of the simulation
    end
    
    properties 
        field                   % field of the simualtion
        isbuildLayer=0            % is the layer and material should be build? 
        
    end
    
    properties (Constant,Hidden)
        % Define the units
        micrometers = 1;
        nanometers  = 1 / 1000;
        centimeter = 10000;
        meter = 1000000;
        radians     = 1;
        degrees = pi/180;
        sur_nor = [0; 0; -1];                     % define surface normal
    end
    
    methods

        function ObjRCWA_TZH = RCWA_TZH(referur,trnerur,ShowProcess)
            % Purpose: Define object RCWA_TZH
            % Input: the number of spatial harmonics along x and y (HAS TO BE ODD NUM)
            ObjRCWA_TZH.referur = referur;
            ObjRCWA_TZH.trnerur = trnerur;
            ObjRCWA_TZH.ShowProcess = ShowProcess;
        end
        
        function ObjRCWA_TZH = UseBlurEffect(ObjRCWA_TZH,BlurCoef)
            % Purpose: open the blur effect to accelerate caculation
            % Input: blur coefficient--How many times the device will be shrinked
            if numel(BlurCoef) == 1
                ObjRCWA_TZH.BlurCoef = BlurCoef;
            else
                error('BlurCoef should be a single number')
            end
        end
        
        function ObjRCWA_TZH = UseShrinkEffect(ObjRCWA_TZH,ShrinkCoef)
            % Purpose: open the blur effect to accelerate caculation
            % Input: blur coefficient--How many times the device will be shrinked
            if numel(ShrinkCoef) == 1
                ObjRCWA_TZH.ShrinkCoef = ShrinkCoef;
            else
                error('ShrinkCoef should be a single number')
            end            
            
        end
        
        function ObjRCWA_TZH = Dispersion(ObjRCWA_TZH,dispersion)
            % Purpose: define the dispersion of materials
            ObjRCWA_TZH.dispersion = dispersion;
        end
            
        
        function ObjRCWA_TZH = ConstructField(ObjRCWA_TZH)
            % Purpose: start record field inside device
            ObjRCWA_TZH.RecordField = 1;
%             % initialize field object
%             ObjRCWA_TZH.field = 
        end
        
        function ObjRCWA_TZH = RecordDiffOrder(ObjRCWA_TZH)
           % Purpose: record diffrection order
           ObjRCWA_TZH.RecordDifOrder = 1;
        end
        
        function RCWA_Run(ObjRCWA_TZH,source,device,field)
            if ObjRCWA_TZH.ShowProcess == 1
                h = waitbar(0,'1','Name','RCWA_TZH Caculating...',...
                    'CreateCancelBtn',...
                    'setappdata(gcbf,''canceling'',1)');
                setappdata(h,'canceling',0)
            end
            
            ObjRCWA_TZH.source = source;
            ObjRCWA_TZH.device = device;
            if  ObjRCWA_TZH.dispersion == 0             % deal with dispersion of the mateiral
                if ObjRCWA_TZH.isbuildLayer==1
                BuildLayer(ObjRCWA_TZH.device);
                BuildPattern(ObjRCWA_TZH.device);
                end
                if ObjRCWA_TZH.BlurCoef ~= 0         %open the blur effect
                    BlurDevice(ObjRCWA_TZH.device,ObjRCWA_TZH.BlurCoef)
                end
                if ObjRCWA_TZH.ShrinkCoef ~= 0       %open the shrink effect
                    ShrinkDevice(ObjRCWA_TZH.device,ObjRCWA_TZH.ShrinkCoef)
                end
                ConvDevice(ObjRCWA_TZH.device);
            end
            if ObjRCWA_TZH.RecordField == 1             % initialize Filed object to be prepared to record field
                LayerNum = sum(ObjRCWA_TZH.device.ilayer);
                ObjRCWA_TZH.field = field;
                ObjRCWA_TZH.field.W_V = cell(1,LayerNum);
                ObjRCWA_TZH.field.LAM = cell(1,LayerNum);
            end
            
            if ObjRCWA_TZH.RecordDifOrder == 1             % initialize matrix to record diffrection for each order
%                 x_k = size(device.PQR);
                Ref_order_ = zeros(device.PQR(1),device.PQR(2),source.snum);            % record refection in each order
                Trn_order_ = Ref_order_;            % record transmission in each order
            end
%             if ObjRCWA_TZH.RecordField == 1             % initialize Filed object to be prepared to record field
%                 LayerNum = sum(ObjRCWA_TZH.device.ilayer);
%                 ObjRCWA_TZH.field = Field;
%                 for wavenum = 1: NLAM
%                     ObjRCWA_TZH.field(wavenum).wavenumber = wavenum;
%                     ObjRCWA_TZH.field(wavenum).W_V = cell(1,LayerNum);
%                     ObjRCWA_TZH.field(wavenum).LAM = cell(1,LayerNum);
%                 end
%             end
            NLAM = source.snum;                  %determine how many simulations
            for nlam = 1 : NLAM
                if ObjRCWA_TZH.dispersion == 1
                    if ObjRCWA_TZH.isbuildLayer==1
                    BuildLayer(ObjRCWA_TZH.device,nlam);
                    BuildPattern(ObjRCWA_TZH.device,nlam);
                    end
                    if ObjRCWA_TZH.BlurCoef ~= 0         %open the blur effect
                        BlurDevice(ObjRCWA_TZH.device,ObjRCWA_TZH.BlurCoef)
                    end
                    if ObjRCWA_TZH.ShrinkCoef ~= 0       %open the shrink effect
                        ShrinkDevice(ObjRCWA_TZH.device,ObjRCWA_TZH.ShrinkCoef)
                    end
                    ConvDevice(ObjRCWA_TZH.device);
                end
                % Make patterns in the layer input:[center],radius,[in which ilayer],[er, ur]
                [Ref,Trn] = RCWAer(ObjRCWA_TZH,source,ObjRCWA_TZH.device,nlam);
                if ObjRCWA_TZH.RecordDifOrder == 1
                    Ref_order_(:,:,nlam) = reshape(Ref,device.PQR);            % record refection in each order
                    Trn_order_(:,:,nlam) = reshape(Trn,device.PQR);            % record transmission in each order
                end
                Ref = sum(Ref(:));
                Trn = sum(Trn(:));
                ObjRCWA_TZH.R(nlam) = 100*Ref;
                ObjRCWA_TZH.T(nlam) = 100*Trn;
                % caculate field in device 
                if ObjRCWA_TZH.RecordField == 1
                    if ObjRCWA_TZH.field.CoordXYZ ~= 0
                        ObjRCWA_TZH.field.CaculatePointField
                    elseif ObjRCWA_TZH.field.LayerZ ~= 0
                        ObjRCWA_TZH.field.CaculateLayerField
                    elseif sum(ObjRCWA_TZH.field.GridZ) ~= 0
                        ObjRCWA_TZH.field.CaculateGridField;
                    end
                end
                if ObjRCWA_TZH.ShowProcess == 1
                    waitbar(nlam/NLAM,h,'I am working, please don''t disturb me ...');
                    if getappdata(h,'canceling')
                        delete(h)
                        break
                    end
                end
            end
            if ObjRCWA_TZH.RecordDifOrder == 1 
                ObjRCWA_TZH.Ref_order = Ref_order_;
                ObjRCWA_TZH.Trn_order = Trn_order_;
                clear Ref_order_ Trn_order_
            end
            if  ObjRCWA_TZH.ShowProcess == 1
                delete(h)
            end
            
        end
        
        
        function PlotRT(ObjRCWA_TZH)
            % Create figure
            figure1 = figure('Name','Reflection and Transmission','NumberTitle','off');
            
            % Create axes
            axes1 = axes('Parent',figure1,'FontWeight','demi','FontSize',14);
            box(axes1,'on');
            hold(axes1,'all');
            
            plot(ObjRCWA_TZH.source.wavelength/ObjRCWA_TZH.nanometers,ObjRCWA_TZH.R,'-r','LineWidth',2); hold on;
            plot(ObjRCWA_TZH.source.wavelength/ObjRCWA_TZH.nanometers,ObjRCWA_TZH.T,'-b','LineWidth',2);
            plot(ObjRCWA_TZH.source.wavelength/ObjRCWA_TZH.nanometers,100-(ObjRCWA_TZH.R+ObjRCWA_TZH.T),'-k','LineWidth',2); hold off;
            legend('Reflectance', 'Transmittance', 'Conservation')
            axis([min(ObjRCWA_TZH.source.wavelength)/ObjRCWA_TZH.nanometers max(ObjRCWA_TZH.source.wavelength)/ObjRCWA_TZH.nanometers 0 105]);
            xlabel('Wavelength (nm)','FontWeight','demi','FontSize',12);
            ylabel('%   ','Rotation',0,'FontWeight','demi','FontSize',12);
            title('SPECTRAL RESPONSE','FontWeight','bold','FontSize',14);
        end
        
        function PlotR(ObjRCWA_TZH)
            figure1 = figure('Name','Reflection','NumberTitle','off');
            % Create axes
            axes1 = axes('Parent',figure1,'FontWeight','demi','FontSize',14);
            box(axes1,'on');
            hold(axes1,'all');
            
            plot(ObjRCWA_TZH.source.wavelength/ObjRCWA_TZH.nanometers,ObjRCWA_TZH.R,'-r','LineWidth',2);
            legend('Reflectance')
            axis([min(ObjRCWA_TZH.source.wavelength)/ObjRCWA_TZH.nanometers max(ObjRCWA_TZH.source.wavelength)/ObjRCWA_TZH.nanometers 0 105]);
            xlabel('Wavelength (nm)','FontWeight','demi','FontSize',12);
            ylabel('%   ','Rotation',0,'FontWeight','demi','FontSize',12);
            title('Reflection','FontWeight','bold','FontSize',14);
        end
           
        function PlotT(ObjRCWA_TZH)
            figure1 = figure('Name','Transmission','NumberTitle','off');
            % Create axes
            axes1 = axes('Parent',figure1,'FontWeight','demi','FontSize',14);
            box(axes1,'on');
            hold(axes1,'all');
            
            plot(ObjRCWA_TZH.source.wavelength/ObjRCWA_TZH.nanometers,ObjRCWA_TZH.T,'-b','LineWidth',2);
            legend('Transmittance')
            axis([min(ObjRCWA_TZH.source.wavelength)/ObjRCWA_TZH.nanometers max(ObjRCWA_TZH.source.wavelength)/ObjRCWA_TZH.nanometers 0 105]);
            xlabel('Wavelength (nm)','FontWeight','demi','FontSize',12);
            ylabel('%   ','Rotation',0,'FontWeight','demi','FontSize',12);
            title('Transmission','FontWeight','bold','FontSize',14);
        end
        
        function PlotA(ObjRCWA_TZH)
            figure1 = figure('Name','Absorption','NumberTitle','off');
            % Create axes
            axes1 = axes('Parent',figure1,'FontWeight','demi','FontSize',14);
            box(axes1,'on');
            hold(axes1,'all');
            plot(ObjRCWA_TZH.source.wavelength/ObjRCWA_TZH.nanometers,100-(ObjRCWA_TZH.R+ObjRCWA_TZH.T),'-k','LineWidth',2);
            legend('Absorption')
            axis([min(ObjRCWA_TZH.source.wavelength)/ObjRCWA_TZH.nanometers max(ObjRCWA_TZH.source.wavelength)/ObjRCWA_TZH.nanometers 0 105]);
            xlabel('Wavelength (nm)','FontWeight','demi','FontSize',12);
            ylabel('%   ','Rotation',0,'FontWeight','demi','FontSize',12);
            title('Absorption','FontWeight','bold','FontSize',14);
        end
        
        function SaveData(ObjRCWA_TZH,name)
            filename = strcat(name,'.mat');
            save(filename);
        end
                       
    end
            
end
    
        
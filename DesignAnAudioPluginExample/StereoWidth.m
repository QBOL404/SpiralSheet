classdef StereoWidth < audioPlugin                            % <== (1) Inherit from audioPlugin.
    properties
        Width = 1;                                            % <== (2) Define tunable property.
    end
    properties (Constant)
        PluginInterface = audioPluginInterface( ...           % <== (3) Map tunable property to plugin parameter.
            audioPluginParameter('Width', ...
                'Mapping',{'pow',2,0,4}));
    end
    methods
        function out = process(plugin,in)                     %< == (4) Define processing method.

            x = [in(:,1) + in(:,2), in(:,1) - in(:,2)];             %  (a) Mid-side encoding.
            y = [x(:,1), x(:,2)*plugin.Width];                      %  (b) Adjust stereo width.
            out = [(y(:,1) + y(:,2))/2, (y(:,1) - y(:,2))/2];       %  (c) Mid-side decoding.

        end
    end
end
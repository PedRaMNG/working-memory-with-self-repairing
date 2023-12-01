function [video] = make_video (Ca, V_line, Iapp, t_record_met)
params = model_parameters();
V = reshape(V_line, params.mneuro, params.nneuro, []);
% Iapp = Iapp ./ 10;
% V = V ./ 100;
Ca_v = Ca(:,:,t_record_met > -1);
Ca1 = min(Ca_v,[],'all');
Ca_v = (Ca_v - Ca1);
Ca1 = max(Ca_v,[],'all');
Ca_v = Ca_v ./ Ca1 .* 255;
Ca_v = uint8(Ca_v);

V_v = V(:,:,t_record_met > -1);
V_v1 = min(V_v,[],'all');
V_v = (V_v - V_v1);
V_v1 = max(V_v,[],'all');
V_v = V_v ./ V_v1 .* 255;
V_v = uint8(V_v);

Iapp_v = Iapp(:,:,t_record_met > -1);
Iapp_v = single(Iapp_v);
Iapp_v1 = min(Iapp_v,[],'all');
Iapp_v = (Iapp_v - Iapp_v1);
Iapp_v1 = max(Iapp_v,[],'all');
Iapp_v = Iapp_v ./ Iapp_v1 .* 255;
Iapp_v = uint8(Iapp_v);

video = horzcat(Iapp_v, V_v, Ca_v);
end
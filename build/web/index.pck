GDPC                                                                                <   res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex 1      �      &�y���ڞu;>��.p   res://default_env.tres  p      �       um�`�N��<*ỳ�8    res://fullscreen_shader.gd.remap�<      ,       ��M� Ha�����*0   res://fullscreen_shader.gdc        �      ��G�uP,��n�!�G�{   res://fullscreen_shader.tres�      �      �:�
Ͻ�7|F� ��(   res://fullscreen_shader_material.tres   �      �      S�s
�D5��W�̗F~   res://hotel_corridor.tres   @      �      �w���D�#ˈ7��{    res://hotel_corridor_shader.tres�      )      �sX��aO����q�   res://icon.png  =      �      G1?��z�c��vN��   res://icon.png.import    7      �      ��fe��6�B��^ U�   res://main.tscn �9      '      �m�;h���Ȯ���,�?   res://project.binary J      5      ��+	���Jj=C-            [gd_resource type="Environment" load_steps=2 format=2]

[sub_resource type="ProceduralSky" id=1]

[resource]
background_mode = 2
background_sky = SubResource( 1 )
             GDSC            0      ����������¶   �������Ŷ���   �����׶�   ��Ŷ   ����������������¶��   ���Ӷ���   ������������ض��   �������ض���   ��������Ӷ��   �������ڶ���   ���������������۶���   ζ��   ϶��      width_by_height                    
                        .      3YY0�  P�  QV�  ;�  �  PQT�  �  �  �  PQT�  �  �  �  �  �	  T�
  PR�  T�  �  T�  QY`[gd_resource type="Shader" format=2]

[resource]
code = "shader_type canvas_item;

uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform float width_by_height = 1.0;

mat2 rot(float t)
{
 	return mat2(vec2(cos(t), sin(t)), vec2(-sin(t), cos(t)));   
}

/* thanks to iq */
float udRoundBox( vec3 p, vec3 b, float r )
{
  return length(max(abs(p)-b,0.0))-r;
}

vec3 times()
{
    float gt = fract(TIME * 0.5) * 3.0;
    float a = clamp(gt - 0.0, 0.0, 1.0);
    float b = clamp(gt - 1.0, 0.0, 1.0);
    float c = clamp(gt - 2.0, 0.0, 1.0);
    return vec3(a, b, c);
}

float map(vec3 p)
{
    float height = 1.0;
    float ground = p.y + height;
    
    vec3 pt = times();
    float pound = 1.0 - pow(1.0-pt.y, 2.0) - pow(pt.z, 32.0);
    pound *= 2.0;
    
	float srot = smoothstep(0.0, 1.0, (pt.y+pt.z)*0.5);
    mat2 mrot = rot(-0.3 + srot * 3.14);
    
    vec3 boxoff = vec3(0.0, pound, 0.0);
    p.xz *= mrot;
    float box = udRoundBox(p - boxoff, vec3(height)*0.5, height*0.25);
 	return min(ground, box);
}

float trace(vec3 o, vec3 r)
{
 	float t = 0.0;
    for (int i = 0; i < 32; ++i) {
        vec3 p = o + r * t;
        float d = map(p);
        t += d * 0.5;
    }
    return t;
}

float rayplane(vec3 o, vec3 r, vec3 p, vec3 n)
{
	return dot(p - o, n) / dot(r, n);
}

vec3 _texture(vec3 p)
{
	vec3 ta = texture(iChannel2, p.xz).xyz;
    vec3 tb = texture(iChannel2, p.yz).xyz;
    vec3 tc = texture(iChannel2, p.xy).xyz;
    return (ta*ta + tb*tb + tc*tc) / 3.0;
}

vec3 normal(vec3 p)
{
	vec3 o = vec3(0.01, 0.0, 0.0);
    return normalize(vec3(map(p+o.xyy) - map(p-o.xyy),
                          map(p+o.yxy) - map(p-o.yxy),
                          map(p+o.yyx) - map(p-o.yyx)));
}

vec3 smoke(vec3 o, vec3 r, vec3 f, float t)
{
    vec3 tms = times();
    vec3 sm = vec3(0.0);
    const int c = 32;
    float fc = float(c);
    for (int i = 0; i < c; ++i)
    {
        float j = float(i) / fc;
        float bout = 1.0 + tms.x;
        vec3 p = vec3(cos(j*6.28), 0.0, sin(j*6.28)) * bout;
        p.y = -1.0;
        float pt = rayplane(o, r, p, f);
        if (pt < 0.0) continue;
        if (pt > t)  continue;
        vec3 pp = o + r * pt;
        float cd = length(pp - p);
        vec2 uv = (pp - p).xy * 0.1 + vec2(j,j) * 2.0;
        vec3 tex = texture(iChannel1, uv).xyz;
        tex *= tex;
        tex = vec3(tex.x + tex.y + tex.z) / 3.0;
        vec3 part = tex;
        part /= 1.0 + cd * cd * 10.0 * tms.x;
        part *= clamp(abs(t - pt), 0.0, 1.0);
        part /= 1.0 + pt * pt;
        part *= clamp(pt, 0.0, 1.0);
        sm += part;
    }
    sm *= 1.0 - smoothstep(0.0, 1.0, tms.x);
    return sm;
}

vec3 shade(vec3 o, vec3 r, vec3 f, vec3 w, float t)
{
    vec3 tuv = w;
    if (tuv.y > -0.85)
    {
        vec3 pt = times();
		float srot = smoothstep(0.0, 1.0, (pt.y+pt.z)*0.5);
    	mat2 mrot = rot(-0.3 + srot * 3.14);
        tuv.xz *= mrot;
        float pound = 1.0 - pow(1.0-pt.y, 2.0) - pow(pt.z, 32.0);
        pound *= 2.0;
        tuv.y -= pound;
    }
    vec3 tex = _texture(tuv * 0.5);
    vec3 sn = normal(w);
	vec3 ground = vec3(1.0, 1.0, 1.0);
    vec3 sky = vec3(1.0, 0.9, 0.9);
    vec3 slight = mix(ground, sky, 0.5+0.5*sn.y);
    float aoc = 0.0;
    const int aocs = 8;
    for (int i = 0; i < aocs; ++i) {
        vec3 p = w - r * float(i) * 0.2;
        float d = map(p);
        aoc += d * 0.5;
    }
    aoc /= float(aocs);
    aoc = 1.0 - 1.0 / (1.0 + aoc);
    float fog = 1.0 / (1.0 + t * t * 0.01);
    vec3 smk = smoke(o, r, f, t);
    float fakeocc = 0.5 + 0.5 * pow(1.0 - times().y, 4.0);
    vec3 fc = slight * tex * aoc + smk * sky;
    fc = mix(fc * fakeocc, sky, 1.0-fog);
    return fc;
}

void mainImage( out vec4 fragColor, in vec2 uv)
{
    uv = uv * 2.0 - 1.0;
    uv.x *= width_by_height;
    
    vec3 r = normalize(vec3(uv, 0.8 - dot(uv, uv) * 0.2));
    vec3 o = vec3(0.0, 0.125, -1.5);
    vec3 f = vec3(0.0, 0.0, 1.0);
    
    vec3 pt = times();
    
    float shake = pow(1.0 - pt.x, 4.0);
    vec3 smack = texture(iChannel0, vec2(pt.x, 0.5)).xyz * 2.0 - 1.0;
    smack *= shake;
    
    o.x += smack.x * shake * 0.25;
    o.z += smack.y * shake * 0.1;
    
    mat2 smackrot = rot(0.3 + smack.z * shake * 0.1);
    r.xy *= smackrot;
    f.xy *= smackrot;
    
    float t = trace(o, r);
    vec3 w = o + r * t;
    //float fd = map(w);
    
    vec3 fc = shade(o, r, f, w, t);
    
	fragColor = vec4(sqrt(fc), 1.0);
}

void fragment()
{
	vec2 flipped_uvs = vec2(UV.x, 1.0 - UV.y);
	mainImage(COLOR, flipped_uvs);
}"
  [gd_resource type="ShaderMaterial" load_steps=4 format=2]

[ext_resource path="res://icon.png" type="Texture" id=1]
[ext_resource path="res://fullscreen_shader.tres" type="Shader" id=2]

[sub_resource type="NoiseTexture" id=3]

[resource]
shader = ExtResource( 2 )
shader_param/width_by_height = 1.667
shader_param/iChannel0 = SubResource( 3 )
shader_param/iChannel1 = ExtResource( 1 )
shader_param/iChannel2 = ExtResource( 1 )
    [gd_resource type="ShaderMaterial" load_steps=4 format=2]

[ext_resource path="res://hotel_corridor_shader.tres" type="Shader" id=1]
[ext_resource path="res://icon.png" type="Texture" id=2]

[sub_resource type="NoiseTexture" id=3]

[resource]
shader = ExtResource( 1 )
shader_param/width_by_height = 1.66
shader_param/iChannel0 = SubResource( 3 )
shader_param/iChannel1 = ExtResource( 2 )
shader_param/iChannel2 = ExtResource( 2 )
 [gd_resource type="Shader" format=2]

[resource]
code = "shader_type canvas_item;

uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform float width_by_height = 1.0;
const float pi = 3.141592654;
const float fovAngle = pi / 4.;


const vec3 color_wood   = vec3(137., 74.,  47. ) / 255.;
const vec3 color_carpet = vec3(202., 63.,  63. ) / 255.;
const vec3 color_wall   = vec3(143., 176., 130.) / 255.;
const vec3 color_trim   = vec3(245., 189., 163.) / 255.;

const float room_z_ext = 1.25;


mat4 rotMat(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(vec4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0),
                vec4(oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0),
                vec4(oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0),
                vec4(0.0,                                0.0,                                0.0,                                1.0));
}

vec3 rotate(vec3 p, vec3 axis, float angle)
{
    return (rotMat(axis, angle) * vec4(p, 0)).xyz;
}

float sdf_sphere(vec3 p, vec3 c, float r)
{
    return length(c - p) - r;
}

float sdf_plane(vec3 p, vec3 n, float h)
{
    return dot(p, n) - h;
}

float sdf_box(vec3 p, vec3 c, vec3 e)
{
    vec3 q = abs(p - c) - e;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float scene_window(float d, vec3 p)
{
    vec3 p_window = vec3(p.x, mod(p.y, 16.), p.z);
    d = max(d, -sdf_box(p_window, vec3(-1.7, 8., 1.5 - room_z_ext), vec3(0.3, 2.5, .75)));
    d = min(d, sdf_box(p_window, vec3(-1.4, 8., 0.7 - room_z_ext), vec3(0.1, 2.5, 0.05)));
    d = min(d, sdf_box(p_window, vec3(-1.8, 8., 1.9 - room_z_ext), vec3(0.05, 2.5, 0.05)));
    d = min(d, sdf_box(p_window, vec3(-1.8, 8., 1.1 - room_z_ext), vec3(0.05, 2.5, 0.05)));
    vec3 p_window_vspoke = vec3(p_window.x, 8. + mod(p_window.y, 1.), p_window.z);
    d = min(d, sdf_box(p_window_vspoke, vec3(-1.8, 8., 1.5 - room_z_ext), vec3(0.05, 0.05, 0.75)));
    
    return d;
}

float scene(vec3 p)
{
    float d = 1e12;
    
    // Twisting corridor
    //float twist = 32. - p.y / 32.;
    //p.x = p.x * cos(twist) - p.z * sin(twist);
    //p.z = p.z * cos(twist) + p.x * sin(twist);

    d = min(d, -sdf_box(p, vec3(0,0,0), vec3(1.5, 128., room_z_ext)));
    
    // Pillars & beams
    vec3 p_supports = vec3(abs(p.x), mod(p.y, 8.), p.z);
    d = min(d, sdf_box(p_supports, vec3(1.5, 4., 0), vec3(0.3, 0.3, room_z_ext)));
    d = min(d, sdf_box(p_supports, vec3(0, 4., room_z_ext), vec3(1.5, 0.3, 0.3)));
    
    // Door
    vec3 p_door = vec3(p.x, mod(p.y, 16.), p.z);
    d = max(d, -sdf_box(p_door, vec3(2., 0.66, 1.1 - room_z_ext), vec3(0.75, 0.66, 1.1)));

    d = scene_window(d, p);
    
    
    return d;
}

vec3 calcNormal(in vec3 p)
{
    const float eps = 0.001;
    const vec2 h = vec2(eps,0);
    return normalize(
        vec3(
            scene(p+h.xyy) - scene(p-h.xyy),
            scene(p+h.yxy) - scene(p-h.yxy),
            scene(p+h.yyx) - scene(p-h.yyx)
        )
    );
}

bool march(in vec3 rayOrig, in vec3 rayDir, in int stepsMax, in float stepLengthMax, out float dist)
{
    for (int i = 0; i < stepsMax; ++i)
    {
        vec3 p = vec3(rayOrig + rayDir * dist);
        float d = scene(p);

        if (d < 0.002)
            return true;

        dist += min(stepLengthMax, d);
    }
    
    return false;
}

vec3 color(in vec3 p, in float depth)
{
    vec3 cout = vec3(1, 0, 1);
    
    if (p.z < -room_z_ext + 0.01) { // Floor
        if (abs(p.x) < 0.75) {
            cout = color_carpet + texture(iChannel0, p.xy * vec2(1, 1.)).x;
            //cout *= mod(floor(abs(sin(p.y) * tan(p.x * 1.9 - 1.5)) * 4.), 4.) / 4.;
            cout += mod(floor(sin(p.x * 4.) * cos(p.y * 2.) * 5.), 5.) / 16.;
        } else {
            vec2 plank_p = vec2(floor(p.x * 4.), floor((p.y + mod(floor(p.x * 4.), 2.)) / 3.));
            vec2 sample_p = plank_p / 128.;
            cout = color_wood + texture(iChannel0, sample_p).x * 0.25;
        }
    } else if (p.x < -1.9) {
        cout = vec3(0);
    //} else if (sdf_box(p, vec3(p.x, mod(p.y, 4.) - 8., p.z), vec3(2., 2., 2.)) < 0.) {
    //    cout = vec3(1.);
    } else { // Walls & ceiling
        cout = color_wall;
    }
    
    return cout;
}

void mainImage( out vec4 fragColor, in vec2 uv )
{
	uv.x = uv.x * width_by_height - (width_by_height - 1.0) * 0.5;
    float walk_dist = mod(-TIME * 8., 128.);
    vec3 rayOrig = vec3(sin(walk_dist) * 0.05, walk_dist, 1.6 + abs(sin(walk_dist)) * 0.1 - room_z_ext);
    
    vec3 rayDir = rotate(
        rotate(
            vec3(0,0,1),
            vec3(0,1,0),
            -(uv.x - .5) * fovAngle
        ),
        vec3(1,0,0),
        (uv.y - .5) * fovAngle - pi/1.8
    );
    
    float hitDist = 0.01;
    bool hit = march(rayOrig, rayDir, 256, .5, hitDist);
    vec3 hitPos = rayOrig + rayDir * hitDist;
    vec3 normal = calcNormal(hitPos);
    
    vec3 color = color(hitPos, hitDist);
    vec3 lit = color * (
        // Flashlight
        (dot(rayDir, normalize(vec3(sin(TIME * 12.) * 0.05, -1, -0.24 - cos(TIME * 16.) * 0.05))) - 0.66) * 24. / (hitDist)
    );
    
    lit *= vec3(-dot(normal, rayDir));
   
    // Output to screen
    //fragColor = vec4(rayDir, 1);
    //fragColor = vec4(normal, 1.);
    fragColor = vec4(lit, 1.);
}

void fragment()
{
	vec2 flipped_uvs = vec2(UV.x, 1.0 - UV.y);
	mainImage(COLOR, flipped_uvs);
}"
       GDST@   @            �  WEBPRIFF�  WEBPVP8L�  /?����m��������_"�0@��^�"�v��s�}� �W��<f��Yn#I������wO���M`ҋ���N��m:�
��{-�4b7DԧQ��A �B�P��*B��v��
Q�-����^R�D���!(����T�B�*�*���%E["��M�\͆B�@�U$R�l)���{�B���@%P����g*Ųs�TP��a��dD
�6�9�UR�s����1ʲ�X�!�Ha�ߛ�$��N����i�a΁}c Rm��1��Q�c���fdB�5������J˚>>���s1��}����>����Y��?�TEDױ���s���\�T���4D����]ׯ�(aD��Ѓ!�a'\�G(��$+c$�|'�>����/B��c�v��_oH���9(l�fH������8��vV�m�^�|�m۶m�����q���k2�='���:_>��������á����-wӷU�x�˹�fa���������ӭ�M���SƷ7������|��v��v���m�d���ŝ,��L��Y��ݛ�X�\֣� ���{�#3���
�6������t`�
��t�4O��ǎ%����u[B�����O̲H��o߾��$���f���� �H��\��� �kߡ}�~$�f���N\�[�=�'��Nr:a���si����(9Lΰ���=����q-��W��LL%ɩ	��V����R)�=jM����d`�ԙHT�c���'ʦI��DD�R��C׶�&����|t Sw�|WV&�^��bt5WW,v�Ş�qf���+���Jf�t�s�-BG�t�"&�Ɗ����׵�Ջ�KL�2)gD� ���� NEƋ�R;k?.{L�$�y���{'��`��ٟ��i��{z�5��i������c���Z^�
h�+U�mC��b��J��uE�c�����h��}{�����i�'�9r�����ߨ򅿿��hR�Mt�Rb���C�DI��iZ�6i"�DN�3���J�zڷ#oL����Q �W��D@!'��;�� D*�K�J�%"�0�����pZԉO�A��b%�l�#��$A�W�A�*^i�$�%a��rvU5A�ɺ�'a<��&�DQ��r6ƈZC_B)�N�N(�����(z��y�&H�ض^��1Z4*,RQjԫ׶c����yq��4���?�R�����0�6f2Il9j��ZK�4���է�0؍è�ӈ�Uq�3�=[vQ�d$���±eϘA�����R�^��=%:�G�v��)�ǖ/��RcO���z .�ߺ��S&Q����o,X�`�����|��s�<3Z��lns'���vw���Y��>V����G�nuk:��5�U.�v��|����W���Z���4�@U3U�������|�r�?;�
         [remap]

importer="texture"
type="StreamTexture"
path="res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://icon.png"
dest_files=[ "res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=true
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
process/normal_map_invert_y=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
              [gd_scene load_steps=5 format=2]

[ext_resource path="res://fullscreen_shader.gd" type="Script" id=1]
[ext_resource path="res://fullscreen_shader_material.tres" type="Material" id=2]
[ext_resource path="res://hotel_corridor.tres" type="Material" id=3]

[sub_resource type="GradientTexture" id=1]

[node name="Node2D" type="Node2D"]

[node name="stomp" type="TextureRect" parent="."]
material = ExtResource( 2 )
margin_right = 1025.0
margin_bottom = 600.0
texture = SubResource( 1 )
expand = true
stretch_mode = 1
script = ExtResource( 1 )

[node name="hotel_corridor" type="TextureRect" parent="."]
visible = false
material = ExtResource( 3 )
margin_right = 1025.0
margin_bottom = 600.0
texture = SubResource( 1 )
expand = true
stretch_mode = 1
script = ExtResource( 1 )
__meta__ = {
"_edit_group_": true
}
         [remap]

path="res://fullscreen_shader.gdc"
    �PNG

   IHDR   @   @   �iq�   sRGB ���  �IDATx��ytTU��?�ի%���@ȞY1JZ �iA�i�[P��e��c;�.`Ow+4�>�(}z�EF�Dm�:�h��IHHB�BR!{%�Zߛ?��	U�T�
���:��]~�������-�	Ì�{q*�h$e-
�)��'�d�b(��.�B�6��J�ĩ=;���Cv�j��E~Z��+��CQ�AA�����;�.�	�^P	���ARkUjQ�b�,#;�8�6��P~,� �0�h%*QzE� �"��T��
�=1p:lX�Pd�Y���(:g����kZx ��A���띊3G�Di� !�6����A҆ @�$JkD�$��/�nYE��< Q���<]V�5O!���>2<��f��8�I��8��f:a�|+�/�l9�DEp�-�t]9)C�o��M~�k��tw�r������w��|r�Ξ�	�S�)^� ��c�eg$�vE17ϟ�(�|���Ѧ*����
����^���uD�̴D����h�����R��O�bv�Y����j^�SN֝
������PP���������Y>����&�P��.3+�$��ݷ�����{n����_5c�99�fbסF&�k�mv���bN�T���F���A�9�
(.�'*"��[��c�{ԛmNު8���3�~V� az
�沵�f�sD��&+[���ke3o>r��������T�]����* ���f�~nX�Ȉ���w+�G���F�,U�� D�Դ0赍�!�B�q�c�(
ܱ��f�yT�:��1�� +����C|��-�T��D�M��\|�K�j��<yJ, ����n��1.FZ�d$I0݀8]��Jn_� ���j~����ցV���������1@M�)`F�BM����^x�>
����`��I�˿��wΛ	����W[�����v��E�����u��~��{R�(����3���������y����C��!��nHe�T�Z�����K�P`ǁF´�nH啝���=>id,�>�GW-糓F������m<P8�{o[D����w�Q��=N}�!+�����-�<{[���������w�u�L�����4�����Uc�s��F�륟��c�g�u�s��N��lu���}ן($D��ת8m�Q�V	l�;��(��ڌ���k�
s\��JDIͦOzp��مh����T���IDI���W�Iǧ�X���g��O��a�\:���>����g���%|����i)	�v��]u.�^�:Gk��i)	>��T@k{'	=�������@a�$zZ�;}�󩀒��T�6�Xq&1aWO�,&L�cřT�4P���g[�
p�2��~;� ��Ҭ�29�xri� ��?��)��_��@s[��^�ܴhnɝ4&'
��NanZ4��^Js[ǘ��2���x?Oܷ�$��3�$r����Q��1@�����~��Y�Qܑ�Hjl(}�v�4vSr�iT�1���f������(���A�ᥕ�$� X,�3'�0s����×ƺk~2~'�[�ё�&F�8{2O�y�n�-`^/FPB�?.�N�AO]]�� �n]β[�SR�kN%;>�k��5������]8������=p����Ցh������`}�
�J�8-��ʺ����� �fl˫[8�?E9q�2&������p��<�r�8x� [^݂��2�X��z�V+7N����V@j�A����hl��/+/'5�3�?;9
�(�Ef'Gyҍ���̣�h4RSS� ����������j�Z��jI��x��dE-y�a�X�/�����:��� +k�� �"˖/���+`��],[��UVV4u��P �˻�AA`��)*ZB\\��9lܸ�]{N��礑]6�Hnnqqq-a��Qxy�7�`=8A�Sm&�Q�����u�0hsPz����yJt�[�>�/ޫ�il�����.��ǳ���9��
_
��<s���wT�S������;F����-{k�����T�Z^���z�!t�۰؝^�^*���؝c
���;��7]h^
��PA��+@��gA*+�K��ˌ�)S�1��(Ե��ǯ�h����õ�M�`��p�cC�T")�z�j�w��V��@��D��N�^M\����m�zY��C�Ҙ�I����N�Ϭ��{�9�)����o���C���h�����ʆ.��׏(�ҫ���@�Tf%yZt���wg�4s�]f�q뗣�ǆi�l�⵲3t��I���O��v;Z�g��l��l��kAJѩU^wj�(��������{���)�9�T���KrE�V!�D���aw���x[�I��tZ�0Y �%E�͹���n�G�P�"5FӨ��M�K�!>R���$�.x����h=gϝ�K&@-F��=}�=�����5���s �CFwa���8��u?_����D#���x:R!5&��_�]���*�O��;�)Ȉ�@�g�����ou�Q�v���J�G�6�P�������7��-���	պ^#�C�S��[]3��1���IY��.Ȉ!6\K�:��?9�Ev��S]�l;��?/� ��5�p�X��f�1�;5�S�ye��Ƅ���,Da�>�� O.�AJL(���pL�C5ij޿hBƾ���ڎ�)s��9$D�p���I��e�,ə�+;?�t��v�p�-��&����	V���x���yuo-G&8->�xt�t������Rv��Y�4ZnT�4P]�HA�4�a�T�ǅ1`u\�,���hZ����S������o翿���{�릨ZRq��Y��fat�[����[z9��4�U�V��Anb$Kg������]������8�M0(WeU�H�\n_��¹�C�F�F�}����8d�N��.��]���u�,%Z�F-���E�'����q�L�\������=H�W'�L{�BP0Z���Y�̞���DE��I�N7���c��S���7�Xm�/`�	�+`����X_��KI��^��F\�aD�����~�+M����ㅤ��	SY��/�.�`���:�9Q�c �38K�j�0Y�D�8����W;ܲ�pTt��6P,� Nǵ��Æ�:(���&�N�/ X��i%�?�_P	�n�F�.^�G�E���鬫>?���"@v�2���A~�aԹ_[P, n��N������_rƢ��    IEND�B`�       ECFG
      application/config/name         Shader Test    application/run/main_scene         res://main.tscn    application/config/icon         res://icon.png     global/shader          +   gui/common/drop_mouse_on_gui_input_disabled         )   physics/common/enable_pause_aware_picking         $   rendering/quality/driver/driver_name         GLES2   %   rendering/vram_compression/import_etc         &   rendering/vram_compression/import_etc2          )   rendering/environment/default_environment          res://default_env.tres             
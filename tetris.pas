program Tetris;
(*******************************************
* Por Víctor Barbero - Diciembre de 2.001  *
* vbarbero@movistar.com o @telefonica.net *
*                                          *
* Última modificación := 19-09-2003;       *
*******************************************) {v1.0c}
uses crt, graph;
const
DLY = 1;
{Constante para las llamadas a Delay(). Cuanto mayor es este valor, m s
lento va el juego. Modificar según velocidad del procesador.}

type
PO = record X,Y : shortint; end;
PU = record Nivel : shortint; Points : integer; Nombre : string[12]; end;

var
Pos : array[1..4] of PO;
Posicion : array[1..308] of boolean;
LinH : array[1..4] of shortint;
FichUs : array[1..7] of shortint;
Datos : array[1..7] of PU;
StRot, MaxRot, NextFich : shortint;
Ficha, Nivel, NivelInic : shortint;
CdmX, CdmY : shortint;
LineasH, Puntos, Rtraso : integer;
sonido, primejec, nuevapartida, nuevaficha, datosenmem : boolean;

procedure IniciaVideo;
var
Driver, Modo : integer;
begin
Driver := VGAHi; Modo := VGA;
initgraph(Modo, Driver,'.BGI');
end;

procedure PintaCuadro(X,Y,col : shortint);
begin
if ((X > 12) or (X < 1)) then exit;
setcolor(col);
rectangle(93+(15*X),83+(15*Y), 106+(15*X),96+(15*Y));
putpixel(96+(15*X),86+(15*Y), col+8);
putpixel(103+(15*X),86+(15*Y), col+8);
putpixel(96+(15*X),93+(15*Y), col+8);
putpixel(103+(15*X),93+(15*Y), col+8);
putpixel(98+(15*X),88+(15*Y), col+8);
putpixel(101+(15*X),88+(15*Y), col+8);
putpixel(98+(15*X),91+(15*Y), col+8);
putpixel(101+(15*X),91+(15*Y), col+8);
putpixel(95+(15*X),89+(15*Y), col);
putpixel(104+(15*X),90+(15*Y), col);
putpixel(99+(15*X),86+(15*Y), col);
putpixel(100+(15*X),93+(15*Y), col);
end;

procedure BorraCuadro(X,Y : shortint);
begin
setfillstyle(1,0); setcolor(0);
bar(93+(15*X),83+(15*Y), 106+(15*X),96+(Y*15));
end;

procedure PintaFicha(PosX, PosY, Fich : shortint);
begin
PintaCuadro(Pos[1].X+PosX, Pos[1].Y+PosY, Fich);
PintaCuadro(Pos[2].X+PosX, Pos[2].Y+PosY, Fich);
PintaCuadro(Pos[3].X+PosX, Pos[3].Y+PosY, Fich);
PintaCuadro(Pos[4].X+PosX, Pos[4].Y+PosY, Fich);
end;

procedure BorraFicha(PosX, PosY : shortint);
begin
BorraCuadro(Pos[1].X+PosX, Pos[1].Y+PosY);
BorraCuadro(Pos[2].X+PosX, Pos[2].Y+PosY);
BorraCuadro(Pos[3].X+PosX, Pos[3].Y+PosY);
BorraCuadro(Pos[4].X+PosX, Pos[4].Y+PosY);
end;

function EscogeFicha(Apu : shortint) : shortint;
begin
case Apu of
1 : begin Pos[1].X := 0; Pos[1].Y := 0; 
Pos[2].X := 0; Pos[2].Y := -1;
Pos[3].X := 0; Pos[3].Y := 1; EscogeFicha := 4;
Pos[4].X := 1 ; Pos[4].Y := 1; end;
2 : begin Pos[1].X := 0; Pos[1].Y := 0; 
Pos[2].X := -1; Pos[2].Y := 0;
Pos[3].X := 1; Pos[3].Y := 0; EscogeFicha := 4;
Pos[4].X := 0; Pos[4].Y := -1; end;
3 : begin Pos[1].X := 0; Pos[1].Y := 0; 
Pos[2].X := 0; Pos[2].Y := -1;
Pos[3].X := 1; Pos[3].Y := 0; EscogeFicha := 2;
Pos[4].X := 1; Pos[4].Y := 1; end;
4 : begin Pos[1].X := 0; Pos[1].Y := 0; 
Pos[2].X := -1; Pos[2].Y := 0;
Pos[3].X := 1; Pos[3].Y := 0; EscogeFicha := 2;
Pos[4].X := 2; Pos[4].Y := 0; end;
5 : begin Pos[1].X := 0; Pos[1].Y := 0; 
Pos[2].X := 1; Pos[2].Y := 0;
Pos[3].X := 0; Pos[3].Y := -1; EscogeFicha := 1;
Pos[4].X := 1; Pos[4].Y := -1; end;
6 : begin Pos[1].X := 0; Pos[1].Y := 0; 
Pos[2].X := 0; Pos[2].Y := -1;
Pos[3].X := 0; Pos[3].Y := 1; EscogeFicha := 4;
Pos[4].X := -1; Pos[4].Y := 1; end;
else begin Pos[1].X := 0; Pos[1].Y := 0; 
Pos[2].X := -1; Pos[2].Y := 0;
Pos[3].X := 0; Pos[3].Y := -1; EscogeFicha := 2;
Pos[4].X := -1; Pos[4].Y := 1; end;
end;
end;

procedure PasaPersiana;
var v : integer;
begin
setcolor(12); setfillstyle(9,4);
for v := 0 to 12 do begin
rectangle(366,176+(19*v), 513,194+(19*v));
circle(386,186+(19*v),4); circle(493,186+(19*v),4);
floodfill(436,186+(19*v),12);
Delay(30*DLY);
end;
setcolor(0); setfillstyle(1,0); Delay(30*DLY);
for v := 12 downto 0 do begin
bar(366,176+(19*v), 513,194+(19*v));
Delay(30*DLY);
end;
end;

procedure VaciaBuffer; ASSEMBLER;
ASM
@@inicio:
mov ah,01
int $16
JZ @@fin
mov ah,00
int $16
JMP @@inicio
@@fin:
END;

procedure RotaFicha(var CmX, CmY  : shortint; Fich : shortint);
var
AuX, AuY, c, l : shortint;
hecho, nocambio, choque : boolean; Paos : array[1..4] of PO;
begin
hecho := false; nocambio := false; choque := false;
if (StRot < MaxRot) then begin
for c := 1 to 4 do begin
AuX := Pos[c].X; AuY := Pos[c].Y;
Paos[c].X := -AuY; Paos[c].Y := AuX;
end;
end;
if (StRot = MaxRot) then hecho := true;

for c := 1 to 4 do if Posicion[((Paos[c].Y+CmY)*14)+((Paos[c].X+CmX))] = true then nocambio := true;

if ((nocambio = false) and (hecho = false)) then begin
{No hay choque y no reset ficha}
for c := 1 to 4 do begin
Pos[c].X := Paos[c].X; Pos[c].Y := Paos[c].Y;
end;
StRot := StRot + 1;
end;
if ((nocambio = true) and (hecho = false)) then begin
{Hay choque y no reset ficha}
if CmX > 11 then begin {Pared derecha}
for c := 1 to 4 do if Posicion[((Paos[c].Y+CmY)*14)+((Paos[c].X+(CmX-1)))] = true then choque := true;
if (choque = false) then begin
for c := 1 to 4 do begin
Pos[c].X := Paos[c].X; Pos[c].Y := Paos[c].Y;
end;
CmX := CmX - 1; StRot := StRot + 1;
end;
end;
if CmX < 2 then begin {Pared izquierda}
for c := 1 to 4 do if Posicion[((Paos[c].Y+CmY)*14)+((Paos[c].X+(CmX+1)))] = true then choque := true;
if (choque = false) then begin
for c := 1 to 4 do begin
Pos[c].X := Paos[c].X; Pos[c].Y := Paos[c].Y;
end;
CmX := CmX + 1; StRot := StRot + 1;
end;
end;
end;
if (hecho = true) then begin
{Hay reset ficha}
nocambio := false;
if ((Fich = 2) and (CmX = 12)) then begin
if (Posicion[(CmY*14)+10] = false) then begin
CmX := CmX - 1; MaxRot := EscogeFicha(Fich); StRot := 1;
end;
nocambio := true;
end;
if ((Fich = 4) and (CmX = 1)) then begin
if ((Posicion[(CmY*14)+2] = false) and (Posicion[(CmY*14)+3] = false)
and (Posicion[(CmY*14)+4] = false)) then begin
CmX := CmX + 1; MaxRot := EscogeFicha(Fich); StRot := 1;
end;
nocambio := true;
end;
if ((Fich = 4) and (CmX = 12)) then begin
if ((Posicion[(CmY*14)+11] = false) and (Posicion[(CmY*14)+10] = false)
and (Posicion[(CmY*14)+9] = false)) then begin
CmX := CmX - 2; MaxRot := EscogeFicha(Fich); StRot := 1;
end;
nocambio := true;
end;
if (nocambio = false) then begin
MaxRot := EscogeFicha(Fich); choque := false;
for c := 1 to 4 do if Posicion[((Pos[c].Y+CmY)*14)+((Pos[c].X+CmX))] = true then choque := true;
if (choque = true) then begin
for c := 1 to (MaxRot-1) do begin
for l := 1 to 4 do begin
AuX := Pos[l].X; AuY := Pos[l].Y;
Pos[l].X := -AuY; Pos[l].Y := AuX;
end;
end;
end else StRot := 1;
end;
end;
end;

procedure SubFichUs(fcha,cantidad : shortint);
begin
setcolor(14);
if fcha = 0 then fcha := 7;
line(375+(15*fcha),400-cantidad,380+(15*fcha),400-cantidad);
end;

procedure IniciaCampo;
var c,v,t,i : integer;
begin
setcolor(4); c := 30; {--->Ladrillitos<----}
while c < 461 do begin             {Linea horizontal}
line(40,c, 600,c); c := c + 10; end; v := 20; t := 0;
while v < 451 do begin {Lineas verticales}
c := 40; if odd(t) = false then i := 20;
while c < (601-i) do begin
line(c+i,v, c+i,v+10); c := c + 40; end;
v := v + 10; t := t + 1; i := 0; end;
line(60,20, 580,20);
setcolor(0); line(220,70,260 ,70); {Lineas quitaladrillos}
line(340,20,380,20); line(480,460,520,460);
line(440,430,480,430); line(60,411,60,431);
setfillstyle(6,4); floodfill(1,1,4); {Fondos}
setcolor(12); setfillstyle(1,0); {Lineas exteriores del tablero}
bar(101,71, 299,398); bar(361,171, 519,429);
setfillstyle(6,4); floodfill(150,300,4);
floodfill(420,350,4);
end;

procedure ReiniciaCampo;
var c,l : integer;
begin
setcolor(12);
setfillstyle(1,0); bar(105,80, 288,398); {Tapa fondos}
bar(365,175, 514,424); line(365,175, 365,424);
line(365,424, 514,424); line(514,424, 514,175);
line(105,80, 105,398); line(105,398, 288,398); line(288,398, 288,80);
end;

function EligeHandicap : shortint;
procedure Selec(nl,co : shortint);
begin
setcolor(co);
rectangle(420,222+(nl*20), 424,226+(nl*20));
rectangle(416,222+(nl*20), 420,226+(nl*20));
rectangle(412,218+(nl*20), 416,222+(nl*20));
rectangle(412,222+(nl*20), 416,226+(nl*20));
rectangle(454,222+(nl*20), 458,226+(nl*20));
rectangle(458,222+(nl*20), 462,226+(nl*20));
rectangle(462,222+(nl*20), 466,226+(nl*20));
rectangle(462,226+(nl*20), 466,230+(nl*20));
end;
var nl,hp : shortint; trt : string[1]; tl : char; ca : integer;
begin
setcolor(7);
for nl := 0 to 9 do begin
str(nl,trt);
outtextxy(436,221+(nl*20),trt);
end;
setcolor(11); outtextxy(385,190,'ELIJA HANDICAP');
setcolor(8); line(385,210, 495,210);
nl := 0; Selec(0,6);
repeat
tl := readkey;
case tl of
#80 : if ((nl+1)<10) then begin Selec(nl,0);
nl := nl + 1; Selec(nl,6); end;
#72 : if ((nl-1)>-1) then begin Selec(nl,0);
nl := nl - 1; Selec(nl,6); end;
end;
until tl = #13;
EligeHandicap := nl; PasaPersiana;
end;

function EscAlFich(var Nxt : shortint) : shortint;
var f,l : shortint;
begin
EscAlFich := Nxt;
f := random(7)+1;
Nxt := f;
setcolor(0); setfillstyle(1,0);
bar(467,264, 491,281); {Borrado ficha anterior}
setcolor(f);
case f of
1 : begin rectangle(480,270, 485,275);
rectangle(480,275, 485,280);
rectangle(480,265, 485,270);
rectangle(475,275, 480,280); end;
2 : begin rectangle(480,270, 485,275);
rectangle(480,275, 485,280);
rectangle(485,275, 490,280);
rectangle(475,275, 480,280); end;
3 : begin rectangle(480,265, 485,270);
rectangle(480,270, 485,275);
rectangle(485,270, 490,275);
rectangle(485,275, 490,280); end;
4 : begin rectangle(468,270, 473,275);
rectangle(473,270, 478,275);
rectangle(483,270, 488,275);
rectangle(478,270, 483,275); end;
5 : begin rectangle(480,270, 485,275);
rectangle(480,275, 485,280);
rectangle(485,270, 490,275);
rectangle(485,275, 490,280); end;
6 : begin rectangle(480,270, 485,275);
rectangle(480,275, 485,280);
rectangle(480,265, 485,270);
rectangle(485,275, 490,280); end
else begin rectangle(485,265, 490,270);
rectangle(480,270, 485,275);
rectangle(485,270, 490,275);
rectangle(480,275, 485,280); end;
end;
end;

procedure CreaFichero;
var
PUF : file of PU; s : shortint; DatAux : array[1..7] of PU;
begin
assign(PUF,'Tetris.fpt');
{$I-} rewrite(PUF); {$I+}
if IOResult <> 0 then begin closegraph;
writeln('­ERROR!, No se pudo crear el fichero de datos.'); halt; end;
for s := 1 to 7 do begin
DatAux[s].Nombre := '- - -'; DatAux[s].Points := 0;
DatAux[s].Nivel := 0; seek(PUF,s);
write(PUF,DatAux[s]);
end;
end;

procedure ManejaDatos(op : boolean); {True para cargar}
var
PUF : file of PU; t : shortint;
begin
assign(PUF,'Tetris.fpt');
{$I-} reset(PUF); {$I+}
if IOResult <> 0 then begin CreaFichero; reset(PUF); end;
for t := 1 to 7 do begin
seek(PUF,t);
if op then begin read(PUF,Datos[t]); datosenmem := true; end
else write(PUF,Datos[t]); end;
close(PUF);
end;

procedure VerPuntuaci;
var
s : pointer; l : string[12];
m : word; j : shortint;
begin
PasaPersiana;
setcolor(11); outtextxy(392,190,'HALL OF FAME');
setcolor(8); line(385,210, 495,210);
setcolor(7); setfillstyle(9,8);
bar(375,249, 500,264);
setfillstyle(1,0); setcolor(0);
sector(375,256,0,360,7,5);
sector(500,264,90,180,120,9);
setcolor(8); line(448,264,448,256);
line(401,264,401,259);
m := imagesize(374,248,501,265); getmem(s,m);
getimage(374,248,501,265,s^); putimage(374,277,s^,0);
putimage(374,219,s^,0); putimage(374,306,s^,0);
putimage(374,335,s^,0); putimage(374,364,s^,0);
putimage(374,393,s^,0); freemem(s,m);
if (datosenmem = false) then ManejaDatos(true);
for j := 1 to 7 do begin
str(j,l); setcolor(9); outtextxy(373,191+(29*j),l);
setcolor(15); outtextxy(390,188+(29*j),Datos[j].Nombre);
str(Datos[j].Nivel,l); setcolor(7); outtextxy(405,199+(29*j),l);
str(Datos[j].Points,l); outtextxy(453,199+(29*j),l);
end; setcolor(8); outtextxy(405,413,'Nivel'); outtextxy(453,413,'Puntos');
line(401,410,401,421); line(448,410,448,421);
readkey;
end;

procedure NuevoRecord(Pountos, Nhivel : integer);
var juli : string[12];
t : char; p,s : shortint;
aux : integer;
begin
PasaPersiana;
setcolor(11); outtextxy(392,190,'NUEVO RECORD');
setcolor(8); line(385,210, 495,210);
setcolor(7); outtextxy(388,230,'­Enhorabuena!');
outtextxy(381,253,'Has establecido');
outtextxy(381,263,'un nuevo record');
line(381,298, 500,298);
line(381,370, 500,370);
line(381,299, 381,369);
line(500,299, 500,369); p := 1;
if sonido then begin
Sound(293); Delay(193*DLY); NoSound; Delay(27*DLY);
Sound(293); Delay(110*DLY); NoSound; Sound(293); Delay(110*DLY);
Sound(440); Delay(330*DLY); Sound(293); Delay(110*DLY);
Sound(440); Delay(440*DLY); NoSound; end;
setfillstyle(7,8); floodfill(455,335,7);
setfillstyle(1,0); bar(389,349,491,359);
setcolor(15); outtextxy(404,310,'Introduce');
outtextxy(404,330,'tu nombre');
repeat
t := readkey;
if ((t<>#13) and (t<>#8) and (p<13)) then begin juli[p] := t;
setcolor(9);
outtextxy(385+(8*p),351,juli[p]); end;
if ((t = #8) and (p>1)) then begin p := p - 1;
setfillstyle(1,0);
juli[p] := ' ';
bar(385+(8*p),349,392+(8*p),357); end
else if p <13 then p := p + 1;
until t = #13;
for s := (p-1) to 12 do juli[s] := ' ';
Datos[7].Nivel := Nhivel;
Datos[7].Points := Pountos;
Datos[7].Nombre := juli;
for p := 1 to 7 do
for s := p+1 to 7 do
if ((Datos[p].Points < Datos[s].Points) or
((Datos[p].Points = Datos[s].Points)
and (Datos[p].Nivel < Datos[s].Nivel))) then begin
aux := Datos[p].Points;
Datos[p].Points := Datos[s].Points;
Datos[s].Points := aux;
aux := Datos[p].Nivel;
Datos[p].Nivel := Datos[s].Nivel;
Datos[s].Nivel := aux;
juli := Datos[p].Nombre;
Datos[p].Nombre := Datos[s].Nombre;
Datos[s].Nombre := juli;
end;
ManejaDatos(false);
end;

procedure CompruebaMejora(Ptos,Nvel : integer);
var c : shortint;
begin
if (datosenmem = false) then ManejaDatos(true);
for c := 1 to 7 do if Ptos > Datos[c].Points then
begin NuevoRecord(Ptos,Nvel);
datosenmem := true;
break; end;
VerPuntuaci;
end;

function EligeNivel : shortint;
procedure Selec(nl,co : shortint);
begin
setcolor(co);
rectangle(420,222+(nl*20), 424,226+(nl*20));
rectangle(416,222+(nl*20), 420,226+(nl*20));
rectangle(416,218+(nl*20), 420,222+(nl*20));
rectangle(416,226+(nl*20), 420,230+(nl*20));
rectangle(454,222+(nl*20), 458,226+(nl*20));
rectangle(458,222+(nl*20), 462,226+(nl*20));
rectangle(458,218+(nl*20), 462,222+(nl*20));
rectangle(458,226+(nl*20), 462,230+(nl*20));
end;
var nl : shortint; trt : string[1]; tl : char;
begin
setcolor(7);
for nl := 0 to 9 do begin
str(nl,trt); outtextxy(436,221+(nl*20),trt);
end;
setcolor(11); outtextxy(398,190,'ELIJA NIVEL');
setcolor(8); line(385,210, 495,210);
nl := 0; Selec(0,6);
repeat
tl := readkey;
case tl of
#80 : if ((nl+1)<10) then begin Selec(nl,0);
nl := nl + 1; Selec(nl,6); end;
#72 : if ((nl-1)>-1) then begin Selec(nl,0);
nl := nl - 1; Selec(nl,6); end;
end;
until tl = #13;
EligeNivel := nl + 1;
PasaPersiana;
end;

procedure PoneMarcador(lih,niv : shortint; pos : integer);
var numli : string[5]; l, t : shortint;
begin
setcolor(8);
line(372,204, 490,204); line(372,183, 511,183);
line(372,225, 469,225); rectangle(489,213,502,226);
line(448,246, 511,183); line(460,243, 450,253); {diagonales}
line(372,246, 448,246); line(372,183, 372,246);
line(505,243, 505,290); line(505,243, 460,243);
line(450,253, 450,290); line(450,290, 505,290);
setcolor(7);
outtextxy(376,211,'Lineas: ');
outtextxy(384,232,'Nivel: ');
outtextxy(376,190,'Puntos: ');
outtextxy(465,248,'Prox.');
outtextxy(395,273,'v1.0');
if sonido then begin setcolor(10); outtextxy(492,216,#14); end;
setcolor(9); {Mostrar resultados conseguidos}
str(lih,numli); outtextxy(436,211,numli);
str(niv-1,numli); outtextxy(436,232,numli);
str(pos,numli); outtextxy(436,190,numli);
setcolor(11);
outtextxy(385,260,'Tetris');
setcolor(1); setfillstyle(1,1);{Pintado de fichas 3x3}
bar(391,407, 394,416); bar(388,413, 391,416);
setcolor(2); setfillstyle(1,2);
bar(403,411, 412,414); bar(406,408, 409,411);
setcolor(3); setfillstyle(1,3);
bar(419,407, 422,413); bar(422,410, 425,416);
setcolor(4); setfillstyle(1,4); bar(436,405, 440,417);
setcolor(5); setfillstyle(1,5); bar(450,407, 456,413);
setcolor(6); setfillstyle(1,6);
bar(466,407, 469,416); bar(469,413, 472,416);
setcolor(7); setfillstyle(1,7);
bar(479,410, 482,416); bar(482,407, 485,413);
{Repintado de las fichas usadas}
for l := 1 to 7 do for t := 1 to FichUs[l] do SubFichUs(l,t);
end;

procedure FinJuego;
var
xel : integer;
begin
PasaPersiana; setcolor(0);
for xel := 1 to 330 do begin
rectangle(320-xel,240-xel, 320+xel,240+xel);
Delay(5*DLY); end;
closegraph; writeln('TETRIS - V¡ctor Barbero - Dic. 2.001'); halt;
end;

procedure Presentacion;
procedure PintCuad(X,Y : integer);
begin
rectangle(X-2,Y-2, X+2,Y+2);
end;
procedure SeleccUno(A : boolean);
var c : integer;
begin
c := 384; setcolor(6);
repeat PintCuad(c,333); PintCuad(c,354); c := c + 4; until c > 498;
if (A = true) then begin {Borrado del Dos}
c := 372; setcolor(0);
repeat PintCuad(c,363); PintCuad(c,384);
c := c + 4; until c > 504;
end;
end;
procedure SeleccDos(A : boolean);
var c : integer;
begin
if (A = true) then begin {Borrado del Uno}
c := 384; setcolor(0);
repeat PintCuad(c,333); PintCuad(c,354);
c := c + 4; until c > 498;
end else begin {Borrado del Tres}
c := 416; setcolor(0);
repeat PintCuad(c,384); PintCuad(c,404);
c := c + 4; until c > 464;
end;
c := 372; setcolor(6);
repeat PintCuad(c,363); PintCuad(c,384); c := c + 4; until c > 504;
end;
procedure SeleccTres(A : boolean);
var c : integer;
begin
if (A = true) then begin {Borrado del Dos}
c := 372; setcolor(0);
repeat PintCuad(c,363); PintCuad(c,384);
c := c + 4; until c > 504;
end;
c := 416; setcolor(6);
repeat PintCuad(c,384); PintCuad(c,404); c := c + 4; until c > 464;
end;
var
c : integer; x : shortint; tec : char;
selecc : shortint;
s,t : word; borrado : boolean;
p,l : pointer;
begin
setcolor(8); outtextxy(385,180,'V¡ctor Barbero');
outtextxy(393,358,'Dic. - 2.001');
s := imagesize(382,177, 497,188); getmem(p,s);
t := imagesize(391,355, 488,365); getmem(l,t);
getimage(382,177,497,188,p^); getimage(391,355,488,365,l^);
for c := 177 to 260 do begin putimage(382,c,p^,0); Delay(15*DLY);
putimage(391,(260-c)+272,l^,0); end;
freemem(p,s); freemem(l,t);
borrado := false; setcolor(7); x := 23;
repeat
PintCuad(387,209-x); PintCuad(391,209+x); PintCuad(395,209+x);
PintCuad(403,233-x); PintCuad(403,229+x); PintCuad(403,225-x);
PintCuad(415,217-x); PintCuad(415,233+x); PintCuad(407,225+x);
PintCuad(471,229-x); PintCuad(468,233+x); PintCuad(464,233-x);
PintCuad(395,217-x); PintCuad(395,221+x); PintCuad(395,225+x);
PintCuad(464,217-x); PintCuad(468,217+x); PintCuad(395,229-x);
PintCuad(395,233+x); PintCuad(451,221-x); PintCuad(451,217+x);
PintCuad(460,233-x); PintCuad(468,225+x); PintCuad(458,221+x);
PintCuad(464,225-x); PintCuad(460,225+x); PintCuad(460,217-x);
PintCuad(435,217-x); PintCuad(439,225+x); PintCuad(435,225+x);
PintCuad(431,219-x); PintCuad(431,223+x); PintCuad(433,229-x);
PintCuad(451,233-x); PintCuad(451,229+x); PintCuad(451,225+x);
PintCuad(415,209-x); PintCuad(419,209+x); PintCuad(423,209-x);
PintCuad(403,221-x); PintCuad(403,217+x); PintCuad(407,233+x);
PintCuad(411,233-x); PintCuad(407,217+x); PintCuad(411,217-x);
PintCuad(423,229-x); PintCuad(423,233+x); PintCuad(432,233-x);
PintCuad(427,209-x); PintCuad(431,209+x); PintCuad(423,213+x);
PintCuad(423,217-x); PintCuad(423,221+x); PintCuad(423,225-x);
PintCuad(443,233-x); PintCuad(443,229+x); PintCuad(443,225+x);
PintCuad(443,221-x); PintCuad(443,217+x); PintCuad(439,217-x);
PintCuad(399,209-x); PintCuad(403,209+x); PintCuad(395,213-x);
if (borrado = false) then begin setcolor(0); borrado := true; end else
begin setcolor(7); x := x - 1; if x = 0 then borrado := true
else borrado := false; end;
Delay(20*DLY);
until x < 0;
setcolor(11); outtextxy(471,204,'v1.0');
setcolor(7); outtextxy(389,340,'Nueva partida');
outtextxy(376,370,'Ver puntuaciones');
outtextxy(421,390,'Salir');
selecc := 1; SeleccUno(false);
repeat
tec := readkey;
if (tec = #80) then begin
case selecc of
1 : begin SeleccDos(true); selecc := 2; end;
2 : begin SeleccTres(true); selecc := 3; end;
end;
end;
if (tec = #72) then begin
case selecc of
3 : begin SeleccDos(false); selecc := 2; end;
2 : begin SeleccUno(true); selecc := 1; end;
end;
end;
until tec = #13;
case selecc of
2 : VerPuntuaci;
3 : FinJuego;
end;
end;

procedure CambioNivel(var nvl : shortint; var Ptos : integer);
var t : integer; s : string[4]; l : shortint;
begin
PasaPersiana; nvl := nvl + 1;
setcolor(11); outtextxy(380,190,'CAMBIO DE NIVEL');

setcolor(8); line(385,210, 495,210);
line(372,312, 507,312); line(372,399, 507,399);
outtextxy(425,328,'x500'); outtextxy(425,348,'x350');
outtextxy(425,368,'x225'); outtextxy(425,388,'x100');

setcolor(7); outtextxy(387,220,'­Enhorabuena!');
outtextxy(412,235,'pasa al'); outtextxy(418,403,'TOTAL');
outtextxy(409,258,'Nivel');
outtextxy(375,300,'Lineas'); outtextxy(457,300,'Puntos');
outtextxy(397,320,'Tetris'); outtextxy(397,340,'Triple');
outtextxy(397,360,'Double'); outtextxy(397,380,'Single');

setcolor(4); line(400,253, 474,253); line(400,270, 474,270);
line(398,251, 476,251); line(398,272, 476,272);

setcolor(9); str(nvl-1,s); outtextxy(459,258,s);
str(LinH[4],s); outtextxy(378,320,s); {Lineas hechas}
t := -5; repeat t := t + 5; str(t,s);
setcolor(9); outtextxy(470,323,s);
Delay(1*DLY); setcolor(0); outtextxy(470,323,s);
until t = LinH[4]*500;
setcolor(9); outtextxy(470,323,s); Delay(100*DLY);
str(LinH[3],s); outtextxy(378,340,s); {Lineas hechas}
if sonido then begin Sound(880); Delay(8*DLY); NoSound; end;
t := -5; repeat t := t + 5; str(t,s);
setcolor(9); outtextxy(470,343,s);
Delay(1*DLY); setcolor(0); outtextxy(470,343,s);
until t = LinH[3]*350;
setcolor(9); outtextxy(470,343,s); Delay(100*DLY);
str(LinH[2],s); outtextxy(378,360,s); {Lineas hechas}
if sonido then begin Sound(880); Delay(8*DLY); NoSound; end;
t := -5; repeat t := t + 5; str(t,s);
setcolor(9); outtextxy(470,363,s);
Delay(1*DLY); setcolor(0); outtextxy(470,363,s);
until t = LinH[2]*225;
setcolor(9); outtextxy(470,363,s); Delay(100*DLY);
str(LinH[1],s); outtextxy(378,380,s); {Lineas hechas}
if sonido then begin Sound(880); Delay(8*DLY); NoSound; end;
t := -5; repeat t := t + 5; str(t,s);
setcolor(9); outtextxy(470,383,s);
Delay(1*DLY); setcolor(0); outtextxy(470,383,s);
until t = LinH[1]*100;
setcolor(9); outtextxy(470,383,s); Delay(100*DLY);
t := (LinH[4]*500)+(LinH[3]*350)+(LinH[2]*225)+(LinH[1]*100);
Ptos := Ptos + t;
LinH[1] := 0; LinH[2] := 0; LinH[3] := 0; LinH[4] := 0;
str(t,s); outtextxy(470,403,s);
if sonido then begin Sound(880); Delay(10*DLY); NoSound; end;
VaciaBuffer; {Int_10h, eres ganador!!} readkey; PasaPersiana;
PoneMarcador(LineasH,nvl,Ptos); setfillstyle(1,0);
setcolor(0); {ReSet del Campo} bar(106,80, 287,397);
for t := 1 to 293 do if Posicion[t] = true then PintaCuadro(t mod 14, t div 14,nvl);
end;

procedure Menu;
var t : char; op : shortint;
procedure Selecta(opt,col : shortint);
begin
setcolor(col); rectangle(379,237+(opt*23),382,240+(opt*23));
rectangle(379,240+(opt*23),382,243+(opt*23));
rectangle(379,243+(opt*23),382,246+(opt*23));
rectangle(379,246+(opt*23),382,249+(opt*23));
rectangle(382,246+(opt*23),385,249+(opt*23));
rectangle(385,246+(opt*23),388,249+(opt*23));
rectangle(388,246+(opt*23),391,249+(opt*23));
end;
begin
PasaPersiana;
setcolor(11); outtextxy(426,190,'MENU');
setcolor(8); line(385,210, 495,210);
setcolor(7); if not sonido then outtextxy(385,260,'Activar sonido.')
else outtextxy(385,260,'Quitar sonido.');
outtextxy(385,283,'Hall of Fame.');
outtextxy(385,306,'Volver al juego.');
outtextxy(385,329,'Salir.');
setfillstyle(7,8); bar(370,250, 377,354);
op := 1; Selecta(1,10);
repeat
t := readkey;
if ((t = #80) and (op<4)) then begin Selecta(op,0); op := op + 1; Selecta(op,10); end;
if ((t = #72) and (op>1)) then begin Selecta(op,0); op := op - 1; Selecta(op,10); end;
until t = #13;
case op of
1 : sonido := not sonido;
2 : VerPuntuaci;
4 : begin setcolor(7);
outtextxy(385,390,'¿Seguro [S/N]?'); repeat t := readkey;
t := upcase(t); until t in ['S','N'];
if t = 'S' then begin CompruebaMejora(Puntos,Nivel);
FinJuego; end; end;
end;
PasaPersiana; PoneMarcador(LineasH,Nivel,Puntos);
end;

procedure CompruebaLineas(var cols : shortint; var putos : integer);
var v, e : shortint; l : integer;
LGanadoras : array[1..4] of shortint;
ya : boolean;
numli : string[3];
procedure BajaLineas(BLinea : shortint);
var p : integer;
begin
for p := (BLinea*14)+14 downto 15 do begin {CAMBIO DE POSICIONES}
if p > (BLinea*14) then begin {Pintado de la linea a bajar}
if Posicion[p-14] = true then begin
PintaCuadro(p mod 14, p div 14,cols);
Posicion[p] := true;
end else Posicion[p] := false;
end;
if p < (BLinea*14) then begin {Pintado de las lineas anteriores}
if (((Posicion[p-14] = true) and (Posicion[p] = false)) and
((p mod 14 <> 0) or (p mod 14 <> 13))) then
begin PintaCuadro(p mod 14, p div 14,cols);
Posicion[p] := true;
end;
if (((Posicion[p-14] = false) and (Posicion[p] = true)) and
((p mod 14 <> 0) or (p mod 14 <> 13))) then
begin BorraCuadro(p mod 14, p div 14);
Posicion[p] := false;
end;
end;
end;
end;
procedure LineaTetris;
var p : integer;
begin
for p := 108 to 357 do begin {Linea TETRIS}
if p < 287 then begin setcolor(4);
line(p,83+(15*LGanadoras[1]), p,96+(LGanadoras[4]*15)); end;
if p = 174 then begin setcolor(15);
outtextxy(159,(87+15*LGanadoras[4]),'T');
outtextxy(159,(87+15*LGanadoras[3]),'T');
outtextxy(159,(87+15*LGanadoras[1]),'T');
outtextxy(159,(87+15*LGanadoras[2]),'T'); end;
if p = 189 then begin setcolor(15);
outtextxy(174,(87+15*LGanadoras[4]),'E');
outtextxy(174,(87+15*LGanadoras[3]),'E');
outtextxy(174,(87+15*LGanadoras[1]),'E');
outtextxy(174,(87+15*LGanadoras[2]),'E'); end;
if p = 204 then begin setcolor(15);
outtextxy(189,(87+15*LGanadoras[4]),'T');
outtextxy(189,(87+15*LGanadoras[3]),'T');
outtextxy(189,(87+15*LGanadoras[1]),'T');
outtextxy(189,(87+15*LGanadoras[2]),'T'); end;
if p = 219 then begin setcolor(15);
outtextxy(204,(87+15*LGanadoras[4]),'R');
outtextxy(204,(87+15*LGanadoras[3]),'R');
outtextxy(204,(87+15*LGanadoras[1]),'R');
outtextxy(204,(87+15*LGanadoras[2]),'R'); end;
if p = 234 then begin setcolor(15);
outtextxy(219,(87+15*LGanadoras[4]),'I');
outtextxy(219,(87+15*LGanadoras[3]),'I');
outtextxy(219,(87+15*LGanadoras[1]),'I');
outtextxy(219,(87+15*LGanadoras[2]),'I'); end;
if p = 249 then begin setcolor(15);
outtextxy(234,(87+15*LGanadoras[4]),'S');
outtextxy(234,(87+15*LGanadoras[3]),'S');
outtextxy(234,(87+15*LGanadoras[2]),'S');
outtextxy(234,(87+15*LGanadoras[1]),'S'); end;
if p > 178 then begin setcolor(0);
line(p-71,83+(15*LGanadoras[1]), p-71,96+(LGanadoras[4]*15));
end;
Delay(8*DLY); if sonido then Sound(p*4);
end; ya := false; LineasH := LineasH + 4; LinH[4] := LinH[4] + 1;
BajaLineas(LGanadoras[1]); BajaLineas(LGanadoras[2]);
BajaLineas(LGanadoras[3]); BajaLineas(LGanadoras[4]); NoSound;
end;
procedure LineaTriple;
var p : integer;
begin
for p := 108 to 357 do begin {Linea TRIPLE}
if p < 287 then begin setcolor(4);
line(p,83+(15*LGanadoras[1]), p,97+(LGanadoras[1]*15));
line(p,83+(15*LGanadoras[2]), p,97+(LGanadoras[2]*15));
line(p,83+(15*LGanadoras[3]), p,97+(LGanadoras[3]*15)); end;
if p = 174 then begin setcolor(15);
outtextxy(159,(87+15*LGanadoras[3]),'T');
outtextxy(159,(87+15*LGanadoras[1]),'T');
outtextxy(159,(87+15*LGanadoras[2]),'T'); end;
if p = 189 then begin setcolor(15);
outtextxy(174,(87+15*LGanadoras[3]),'R');
outtextxy(174,(87+15*LGanadoras[1]),'R');
outtextxy(174,(87+15*LGanadoras[2]),'R'); end;
if p = 204 then begin setcolor(15);
outtextxy(189,(87+15*LGanadoras[3]),'I');
outtextxy(189,(87+15*LGanadoras[1]),'I');
outtextxy(189,(87+15*LGanadoras[2]),'I'); end;
if p = 219 then begin setcolor(15);
outtextxy(204,(87+15*LGanadoras[3]),'P');
outtextxy(204,(87+15*LGanadoras[1]),'P');
outtextxy(204,(87+15*LGanadoras[2]),'P'); end;
if p = 234 then begin setcolor(15);
outtextxy(219,(87+15*LGanadoras[3]),'L');
outtextxy(219,(87+15*LGanadoras[1]),'L');
outtextxy(219,(87+15*LGanadoras[2]),'L'); end;
if p = 249 then begin setcolor(15);
outtextxy(234,(87+15*LGanadoras[3]),'E');
outtextxy(234,(87+15*LGanadoras[2]),'E');
outtextxy(234,(87+15*LGanadoras[1]),'E'); end;
if p > 178 then begin setcolor(0);
line(p-71,83+(15*LGanadoras[1]), p-71,97+(LGanadoras[1]*15));
line(p-71,83+(15*LGanadoras[2]), p-71,97+(LGanadoras[2]*15));
line(p-71,83+(15*LGanadoras[3]), p-71,97+(LGanadoras[3]*15)); end;
Delay(6*DLY); if sonido then Sound(p*3);
end; ya := false; LineasH := LineasH + 3; LinH[3] := LinH[3] + 1;
BajaLineas(LGanadoras[1]); BajaLineas(LGanadoras[2]);
BajaLineas(LGanadoras[3]); NoSound;
end;
procedure LineaDoble;
var p : integer;
begin
for p := 108 to 357 do begin {Linea DOUBLE}
if p < 287 then begin setcolor(4);
line(p,83+(15*LGanadoras[1]), p,97+(LGanadoras[1]*15));
line(p,83+(15*LGanadoras[2]), p,97+(LGanadoras[2]*15)); end;
if p = 174 then begin setcolor(15);
outtextxy(159,(87+15*LGanadoras[1]),'D');
outtextxy(159,(87+15*LGanadoras[2]),'D'); end;
if p = 189 then begin setcolor(15);
outtextxy(174,(87+15*LGanadoras[1]),'O');
outtextxy(174,(87+15*LGanadoras[2]),'O'); end;
if p = 204 then begin setcolor(15);
outtextxy(189,(87+15*LGanadoras[1]),'U');
outtextxy(189,(87+15*LGanadoras[2]),'U'); end;
if p = 219 then begin setcolor(15);
outtextxy(204,(87+15*LGanadoras[1]),'B');
outtextxy(204,(87+15*LGanadoras[2]),'B'); end;
if p = 234 then begin setcolor(15);
outtextxy(219,(87+15*LGanadoras[1]),'L');
outtextxy(219,(87+15*LGanadoras[2]),'L'); end;
if p = 249 then begin setcolor(15);
outtextxy(234,(87+15*LGanadoras[2]),'E');
outtextxy(234,(87+15*LGanadoras[1]),'E'); end;
if p > 178 then begin setcolor(0);
line(p-71,83+(15*LGanadoras[1]), p-71,97+(LGanadoras[1]*15));
line(p-71,83+(15*LGanadoras[2]), p-71,97+(LGanadoras[2]*15)); end;
Delay(5*DLY); if sonido then Sound(p*2);
end; ya := false; LineasH := LineasH + 2; LinH[2] := LinH[2] + 1;
BajaLineas(LGanadoras[1]); BajaLineas(LGanadoras[2]); NoSound;
end;
procedure LineaSimple;
var p : integer;
begin
for p := 108 to 377 do begin {Linea SINGLE}
if p < 287 then begin setcolor(4);
line(p,83+(15*LGanadoras[1]), p,96+(LGanadoras[1]*15)); end;
if p = 174 then begin setcolor(15);
outtextxy(159,(87+15*LGanadoras[1]),'S'); end;
if p = 189 then begin setcolor(15);
outtextxy(174,(87+15*LGanadoras[1]),'I'); end;
if p = 204 then begin setcolor(15);
outtextxy(189,(87+15*LGanadoras[1]),'N'); end;
if p = 219 then begin setcolor(15);
outtextxy(204,(87+15*LGanadoras[1]),'G'); end;
if p = 234 then begin setcolor(15);
outtextxy(219,(87+15*LGanadoras[1]),'L'); end;
if p = 249 then begin setcolor(15);
outtextxy(234,(87+15*LGanadoras[1]),'E'); end;
if p > 198 then begin setcolor(0);
line(p-91,83+(15*LGanadoras[1]), p-91,96+(LGanadoras[1]*15)); end;
Delay(4*DLY); if sonido then Sound(p);
end; NoSound;
ya := false; LineasH := LineasH + 1; LinH[1] := LinH[1] + 1;
BajaLineas(LGanadoras[1]);
end;
begin
e := 1; v := 1; LGanadoras[1] := 0; LGanadoras[2] := 0;
LGanadoras[3] := 0; LGanadoras[4] := 0; ya := true;
l := 15;
repeat
if ((Posicion[l]) and (Posicion[l+1]) and
(Posicion[l+2]) and (Posicion[l+3]) and (Posicion[l+4]) and
(Posicion[l+5]) and (Posicion[l+6]) and (Posicion[l+7]) and
(Posicion[l+8]) and (Posicion[l+9]) and (Posicion[l+10]) and
(Posicion[l+11])) then begin LGanadoras[v] := l div 14;
v := v + 1; end;
l := l + 14;
until l > 285;
setcolor(15);
if ((LGanadoras[4] <> 0) and (ya = true)) then LineaTetris;
if ((LGanadoras[3] <> 0) and (ya = true)) then LineaTriple;
if ((LGanadoras[2] <> 0) and (ya = true)) then LineaDoble;
if ((LGanadoras[1] <> 0) and (ya = true)) then LineaSimple;
if ya = false then begin
setcolor(0); setfillstyle(1,0); {Borrar lineas anteriores}
bar(434,210, 460,220);
setcolor(9); {Mostrar lineas hechas}
str(LineasH,numli); outtextxy(436,211,numli);
if ((LineasH mod 20 < 4) and (LineasH div 20 = (cols-NivelInic+1)))
then CambioNivel(cols,putos);
end;
end;

procedure AvanzaFicha(Vx,spsr : shortint; var CmmX,CmmY : shortint);
var CdX, CdY : shortint; avnzY, Rotacion, nocambio : boolean;
begin {1 -> CdmX++; -1 -> CdmX--; 2 ->RotaFicha; 3 ->CdmY++;}
CdX := CmmX; CdY := CmmY;
avnzY := false; nocambio := false; Rotacion := false;
case Vx of
1 : CdX := CdX+1;
-1 : CdX := CdX-1;
2 : begin BorraFicha(CmmX,CmmY); RotaFicha(CmmX,CmmY,spsr);
Rotacion := true; end;
3 : begin CdY := CdY+1; avnzY := true; end;
end;
if Posicion[((Pos[1].Y+CdY)*14)+((Pos[1].X+CdX))] = true then nocambio := true;
if Posicion[((Pos[2].Y+CdY)*14)+((Pos[2].X+CdX))] = true then nocambio := true;
if Posicion[((Pos[3].Y+CdY)*14)+((Pos[3].X+CdX))] = true then nocambio := true;
if Posicion[((Pos[4].Y+CdY)*14)+((Pos[4].X+CdX))] = true then nocambio := true;
if ((nocambio = false) and (Rotacion = false)) then begin
BorraFicha(CmmX, CmmY);
case Vx of
1 : CmmX := CmmX+1;
-1 : CmmX := CmmX-1;
3 : CmmY := CmmY+1;
end;
end;
if ((nocambio) and (avnzY)) then nuevaficha := true;
PintaFicha(CmmX,CmmY,spsr);
end;

procedure TanMatao(Putos : integer; Lin : shortint);
var T : char; cadn : string[6];
begin
PasaPersiana;
setcolor(4); line(402,210, 476,210);
line(402,210, 402,255); line(403,255, 475,255);
line(476,211, 476,255); line(396,204, 482,204);
line(396,205, 396,261); line(397,261, 482,261);
line(482,260, 482,205); setfillstyle(6,4);
floodfill(440,207,4);
setcolor(11); outtextxy(412,220,'G A M E'); Delay(300*DLY);
outtextxy(412,240,'O V E R'); Delay(300*DLY);
setcolor(7);
outtextxy(390,290,'Puntos: ');
outtextxy(390,310,'Lineas: ');
setcolor(9); str(Putos,cadn); outtextxy(465,290,cadn);
str(Lin,cadn); outtextxy(465,310,cadn);
setcolor(7);
outtextxy(392,345,'šDesea jugar'); outtextxy(379,363,'otra vez? [S/N]');
repeat
T := readkey; T := upcase(T);
until T in ['S','N'];
CompruebaMejora(Putos,Nivel);
if T = 'S' then begin nuevapartida := true; PasaPersiana end
else FinJuego;
end;

procedure LeeTecla(afiu : shortint; var CX, CY : shortint; var Rts : integer);
var PosP : char;
begin
if Keypressed then PosP := readkey;
case PosP of
#77 : AvanzaFicha(1,afiu,CX,CY);
#75 : AvanzaFicha(-1,afiu,CX,CY);
#32 : AvanzaFicha(2,afiu,CX,CY);
#80 : Rts := 0;
#27 : Menu;
end;
end;

procedure UnaNuevaFicha(var Nvl : shortint; var Pts : integer; CdX, CdY : shortint);
var nml : string[6];
begin
PintaFicha(CdX,CdY,Nvl); {Pinta anterior de muertos}
Posicion[((Pos[1].Y+CdY)*14)+((Pos[1].X+CdX))] := true; {Declaración}
Posicion[((Pos[2].Y+CdY)*14)+((Pos[2].X+CdX))] := true; {de muertos}
Posicion[((Pos[3].Y+CdY)*14)+((Pos[3].X+CdX))] := true; {de la}
Posicion[((Pos[4].Y+CdY)*14)+((Pos[4].X+CdX))] := true; {anterior}
setfillstyle(1,0); bar(434,189,485,197); {Borrar los puntos anteriores}
setcolor(9); str(Pts,nml); outtextxy(436,190,nml);
CompruebaLineas(Nvl,Pts);
if sonido then begin Sound(69); Delay(6*DLY); NoSound; end;
Pts := Pts + ((CdY+(Nvl*2)) div 2);
end;

begin
primejec := true; randomize;
NextFich := random(7)+1;
sonido := true;
IniciaVideo; IniciaCampo; {Pintado del tablero}
repeat
ReiniciaCampo;
if (primejec = true) then begin Presentacion;
primejec := false; PasaPersiana; end;
Nivel := EligeNivel; {Selección de Dificultad}
CdmY := EligeHandicap; NivelInic := Nivel;
for Puntos := 1 to 308 do Posicion[Puntos] := false; {Borrado de arrays}
for CdmX := 0 to CdmY do begin {Activación de las casillas de Handicap}
for Ficha := 0 to 12 do begin
if ((random(10) > 3)) then Posicion[((21-CdmX)*14)+Ficha] := true;
end;
end;
for LineasH := 1 to 294 do if Posicion[LineasH] then PintaCuadro(LineasH mod 14, LineasH div 14,Nivel);
Puntos := 0; while Puntos < 293 do begin {Declaración de bordes en Posicion}
Posicion[Puntos] := true; Posicion[Puntos+13] := true;
Puntos := Puntos + 14; end;
for Puntos := 294 to 308 do Posicion[Puntos] := true;
nuevapartida := false; {ReSet de valores}
Rtraso := (600-(33*Nivel)) div 2;
LinH[1] := 0; LinH[2] := 0; LinH[3] := 0; LinH[4] := 0;
FichUs[1] := 0; FichUs[2] := 0; FichUs[3] := 0;
FichUs[4] := 0; FichUs[5] := 0; FichUs[6] := 0; FichUs[7] := 0;
nuevaficha := false;
LineasH := 0; Puntos := 0;
PoneMarcador(0,Nivel,0);
FichUs[NextFich] := FichUs[NextFich] + 1;
SubFichUs(NextFich,FichUs[NextFich]);
Ficha := EscAlFich(NextFich); StRot := 1;
MaxRot := EscogeFicha(Ficha); {Preparación de fichas}
CdmX := 7; CdmY := 1; PintaFicha(CdmX,CdmY,Ficha);
repeat
LeeTecla(Ficha,CdmX,CdmY,Rtraso);
LeeTecla(Ficha,CdmX,CdmY,Rtraso);
LeeTecla(Ficha,CdmX,CdmY,Rtraso);
Delay(Rtraso*DLY);
LeeTecla(Ficha,CdmX,CdmY,Rtraso);
LeeTecla(Ficha,CdmX,CdmY,Rtraso);
LeeTecla(Ficha,CdmX,CdmY,Rtraso);
Delay(Rtraso*DLY);
AvanzaFicha(3,Ficha,CdmX,CdmY);
if nuevaficha then begin
UnaNuevaFicha(Nivel,Puntos,CdmX,CdmY);
if CdmY < 2 then TanMatao(Puntos,LineasH) else begin
FichUs[NextFich] := FichUs[NextFich] + 1;
SubFichUs(NextFich,FichUs[NextFich]);
Ficha := EscAlFich(NextFich); MaxRot := EscogeFicha(Ficha);
CdmX := random(5)+3; StRot := 1; CdmY := 1;
PintaFicha(CdmX,CdmY,Ficha); nuevaficha := false; end;
Rtraso := (600-(33*Nivel)) div 2; VaciaBuffer; end;
until nuevapartida;
until 3=2;
end.

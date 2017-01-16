unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ComCtrls, StdCtrls, Buttons, ExtCtrls, Math, Menus, ShellAPI;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    StringGrid1: TStringGrid;
    ButtonStart: TButton;
    GroupBox2: TGroupBox;
    StringGrid3: TStringGrid;
    Label1: TLabel;
    StringGrid2: TStringGrid;
    Label2: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure mmExitClick(Sender: TObject);
    procedure mCalcClick(Sender: TObject);
    procedure mmGetHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  R: array [1..10, 1..10] of real; // ������� ������� (��� ����������)
  R_first: array [1..10, 1..10] of real = // �������� �������������� �������
  ((  1.00, -0.46,  0.15,  0.31, -0.19,  0.28,  0.13,  0.37,  0.19,  0.82 ),
   ( -0.46,  1.00, -0.16, -0.20, -0.47, -0.34, -0.15, -0.28, -0.21, -0.36 ),
   (  0.15, -0.16,  1.00,  0.01, -0.23,  0.22,  0.28,  0.27,  0.19,  0.18 ),
   (  0.31, -0.20,  0.01,  1.00, -0.30,  0.12,  0.02, -0.01,  0.12,  0.32 ),
   ( -0.19, -0.47, -0.23, -0.30,  1.00, -0.19, -0.26, -0.32, -0.04, -0.23 ),
   (  0.28, -0.34,  0.22,  0.12, -0.19,  1.00,  0.34,  0.52,  0.08,  0.10 ),
   (  0.13, -0.15,  0.28,  0.02, -0.26,  0.34,  1.00,  0.21,  0.06,  0.00 ),
   (  0.37, -0.28,  0.27, -0.01, -0.32,  0.52,  0.21,  1.00,  0.01,  0.23 ),
   (  0.19, -0.21,  0.19,  0.12, -0.04,  0.08,  0.06,  0.01,  1.00,  0.33 ),
   (  0.82, -0.36,  0.18,  0.32, -0.23,  0.10,  0.00,  0.23,  0.33,  1.00 )
  );

  //�������� ������
 { R_first: array [1..4, 1..4] of real =
  ((1,    0.42, 0.54, 0.66),
   (0.42, 1,    0.32, 0.44),
   (0.54, 0.32, 1,    0.22),
   (0.66, 0.44, 0.22, 1   ));  }

  n: integer;
implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  i, j: integer;
begin
  n := 10; // ������� �����������
  StringGrid1.ColCount := n + 1;
  StringGrid1.RowCount := n + 1;
  for i := 1 to n do // ��������� ������� �� �������� � �������
  begin
    StringGrid1.Cells[0, i] := IntToStr(i);
    StringGrid1.Cells[i, 0] := IntToStr(i);
  end;

  for i := 1 to n do // ���������� �������
    for j := 1 to n do
      StringGrid1.Cells[j, i] := FloatToStr(R_first[i, j]);
end;

function sign(y: real): integer;
begin
  if (y > 0)
    then sign := 1
    else sign := -1;
end;


procedure TForm1.ButtonStartClick(Sender: TObject);
label m1, m2;
var
  E: array[1..10, 1..10] of real; // ��������� �������
  lamda: array [1..10] of real;
  i, j, ind, w: integer;
  int1, rho, ab: real;
  norm1: real; // ��������� �����
  norm2: real; // �������� �����
  thr: real; // �����
  v1, v2, v3, mu, omega, sint, cost: real;
  tmp1, tmp2: real;
  iq, ip, k: integer;
  summ, sm, pi: real;
  p, pdel,summ1: real;
begin
  rho := 0.95; //�������� �����������

  for i := 1 to n do
    for j := 1 to n do
      R[i, j] := R_first[i, j];

  //--��������� ��������� ������� E---
  for i := 1 to n do
    for j := 1 to n do
      if i = j then
        E[i, j] := 1
        else E[i, j] := 0;

  //---���������� ��������� ����� norm1, �������� ����� norm2 � ������ thr----
  int1 := 0;
  for i := 2 to n do
    for j := 1 to i-1 do
      int1 := int1 + 2 * R[i, j] * R[i, j];

  if int1 <> 0 then
  begin
    thr := sqrt(int1);
    norm1 := sqrt(int1);
    norm2 := (rho / n) * norm1;
  end else exit;

  ind := 0;
  m1:
  thr := thr / n;

  //---��������� �������������� ���������---
  m2:
  for iq := 2 to n do
  begin
    for ip := 1 to iq - 1 do
    begin
      ab := abs(R[ip, iq]);
      if not (ab < thr) then
      begin
        ind := 1;
        v1 := R[ip, ip];
        v2 := R[ip, iq];
        v3 := R[iq, iq];
        mu := 0.5 * (v1 - v3);
        omega := -sign(mu) * v2 / sqrt(v2 * v2 + mu * mu);
        if mu = 0 then
          omega := -1;
        sint := omega / sqrt(2 * (1 + sqrt(1 - omega * omega)));
        cost := sqrt(1 - sint * sint);
        for i := 1 to n do
        begin
          if i <> ip then
            if i <> iq then
            begin
              int1 := R[i, ip];
              mu := R[i, iq];
              R[iq, i] := int1 * sint + mu * cost;
              R[i, iq] := R[iq, i];
              R[i, ip] := int1 * cost - mu * sint;
              R[ip,i] := R[i, ip];
            end;
          int1 := E[i, ip];
          mu := E[i, iq];
          E[i, iq] := int1 * sint + mu * cost;
          E[i, ip] := int1 * cost - mu * sint;
        end;

        mu := sint * sint;
        omega := cost * cost;
        int1 := sint * cost;
        R[ip, ip]:= v1 * omega + v3 * mu - 2 * v2 * int1;
        R[iq, iq]:= v1 * mu + v3 * omega + 2 * v2 * int1;
        R[ip, iq]:= (v1 - v3) * int1 + v2 * (omega - mu);
        R[iq, ip]:= R[ip, iq];
      end;
    end;
  end;

  //---�������� ���������� �������� ��������---
  if ind = 1 then
    begin
    ind := 0;
    goto m2;
    end else if thr > norm2 then
               goto m1;

  //---������� ������������ ��-�� ������� R (����������� �����) � ������ lambda---
  for i := 1 to n do
    for j := 1 to n do
      if i = j then
        lamda[i] := R[i, j];

    for i := 1 to n do
           summ1:= summ1+lamda[i];
           Label4.Caption := '�����= ' + FloatToStr(summ1);

  //---������������� ����������� ����� (� �����-�� �� ����������� �-��) � ������� ��������---
  for i := 1 to n - 1 do
  begin
    for j := i + 1 to n do
      if lamda[i] < lamda[j] then
      begin
        tmp1 := lamda[i];
        lamda[i] := lamda[j];
        lamda[j] := tmp1;
        for w := 1 to n do
        begin
          tmp2 := E[w, i];
          E[w, i] := E[w, j];
          E[w, j] := tmp2;
        end;
      end;
  end;

  StringGrid2.ColCount := n;
  for i := 1 to n do
    StringGrid2.Cells[i - 1, 0] := FloatToStr(RoundTo(lamda[i], -4));

  StringGrid3.RowCount := n;
  StringGrid3.ColCount := n;
  for i := 1 to n do
    for j := 1 to n do
      StringGrid3.Cells[i - 1, j - 1] := FloatToStr(RoundTo(E[j, i], -4));

  pdel := 0;
  p := 0;
  for i := 1 to n do
    pdel := pdel + lamda[i];

  for i := 1 to n do
  begin
    p := p + lamda[i];
    if p / pdel > rho then
      break;
  end;

  Label1.Caption := '����� ' + IntToStr(i) + ' �������� ��� ����������� ' + FloatToStr(rho);
end;

procedure TForm1.mmExitClick(Sender: TObject);
begin
 Close;
end;

procedure TForm1.mCalcClick(Sender: TObject);
begin
  if ButtonStart.Enabled then
    ButtonStartClick(Sender);
end;

procedure TForm1.mmGetHelpClick(Sender: TObject);
var
  s: AnsiString;
begin
  if (not DirectoryExists(GetCurrentDir + '\Help')) then //�������� ������������� ����� � ������
  begin
    ShowMessage('������. �� ������� ����� �����:' + #13 + GetCurrentDir + '\Help' + #13 + #13 + '������� �� ����� ���� �������.');
    exit;
  end;

  if (not FileExists(GetCurrentDir + '\Help\Index.html')) then //�������� ������������� ����� �����
  begin
    ShowMessage('������. �� ������� ����� ����:' + #13 + GetCurrentDir + '\Help\index.html' + #13 + #13 + '������� �� ����� ���� �������.');
    exit;
  end;

  s := GetCurrentDir + '\Help\Index.html';
  try
    ShellExecute(0, 'open', PChar(s), nil, nil, SW_RESTORE);
    except begin
      ShowMessage('�������! �� �������� ������� �������.');
    end;
  end;
end;

end.

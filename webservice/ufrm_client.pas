unit ufrm_client;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON.Writers,
  System.JSON.Types,
  System.JSON,

  FireDAC.Comp.Client,

  Data.DB,
  Data.DBXPlatform,

  u_ds_classhelper,

  ufrm_srvmethod, FireDAC.Stan.Option;

type
{$METHODINFO ON}
  Tfrm_client = class(TDataModule)
  private

  public
    //FUNCTION GET
    function Clients(const AToken: string): TJSONArray;
    //FUNCTION PUT
    function AcceptClients: string;
    //FUNCTION POST
    function UpdateClients: string;
    //FUNCTION DELETE
    function CancelClients(const AToken, ACod: string): string;

  end;

  Client = class(Tfrm_client)

  end;
{$METHODINFO OFF}

var
  frm_client: Tfrm_client;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}
{ Tfrm_client }

function Tfrm_client.AcceptClients: string;
begin
  Result := 'PUT';
end;

function Tfrm_client.CancelClients(const AToken, ACod: string): string;
begin
  Result := 'DELETE';
end;

function Tfrm_client.Clients(const AToken: string): TJSONArray;
var
  SQL     : string;
  qry     : TFDQuery;
  method  : Tfrm_srvmethod;
begin
  SQL     := 'call proc_client_read('+ QuotedStr(AToken) +');';

  method  := Tfrm_srvmethod.Create(Self);
  qry     := TFDQuery.Create(Self);

  qry.Connection := method.conn_db;
  qry.FetchOptions.Mode := TFDFetchMode.fmAll;
  qry.Open(SQL);

  if not (qry.IsEmpty) then begin
    Result := qry.DataSetToJSON;
  end else begin
    Result := qry.DataSetToJSON;
  end;

  GetInvocationMetadata().ResponseCode    := 200;
  GetInvocationMetadata().ResponseContent := Result.ToString;
end;

function Tfrm_client.UpdateClients: string;
begin
  Result := 'POST';
end;

end.

unit ufrm_srvmethod;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Json,
  System.JSON.Writers,
  System.JSON.Types,

  DataSnap.DSProviderDataModuleAdapter,
  Datasnap.DSServer,
  Datasnap.DSAuth,

  Data.DB,
  Data.DBXPlatform,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Phys.MySQLDef,
  FireDAC.Phys.MySQL,
  FireDAC.Comp.UI,
  FireDAC.Comp.Client,
  FireDAC.Stan.StorageBin,
  FireDAC.Stan.StorageJSON,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt;

type
  Tfrm_srvmethod = class(TDSServerModule)
    conn_db         : TFDConnection;
    wait_cursor     : TFDGUIxWaitCursor;
    driver_link     : TFDPhysMySQLDriverLink;
    man_db          : TFDManager;
    json_link       : TFDStanStorageJSONLink;
    bin_link        : TFDStanStorageBinLink;
    schema_adapter  : TFDSchemaAdapter;
  private
    { Private declarations }
  public
    { Public declarations }
    function echostring(Value: string): string;
    function reversestring(Value: string): string;

    function user_signin(usr_username, usr_password: string): string;
    function contract_user_signin(ctr_id: Int64; ctr_usr_username, ctr_usr_password: string) : string;

    function get_contract(ctr_token: string): string;
    function get_product(ctr_token: string): string;
    function get_client(ctr_token: string): string;
    function get_enterprise(ctr_token: string): string;
    function get_insurance(ctr_token: string): string;
    function get_phonebook(ctr_token: string):string;
  end;

  methods = class(Tfrm_srvmethod)

  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

uses System.StrUtils;

function Tfrm_srvmethod.user_signin(usr_username, usr_password: string): string;
var
  SQL           : string;
  qry           : TFDQuery;
  lResultado    : TJSONObject;
  lStringWriter : TStringWriter;
  lJSonWriter   : TJSonTextWriter;
begin
  SQL := 'set @po_valid_user = 0;' +
         'set @po_usr_cod    = 0;' +
         'call proc_user_signin('+ QuotedStr(usr_username) +', '+ QuotedStr(usr_password) +', @po_valid_user, @po_usr_cod);' +
         'select @po_valid_user as valid_user, @po_usr_cod as usr_cod;';

  qry := TFDQuery.Create(Self);

  qry.Close;
  qry.Connection := conn_db;
  qry.SQL.Add(SQL);
  qry.Prepare;
  qry.Open;

  if qry.FieldByName('valid_user').AsInteger = 1 then begin
    try
      try
        lStringWriter := TStringWriter.Create;
        lJSonWriter   := TJsonTextWriter.Create(lStringWriter);

        lJSonWriter.Formatting := TJsonFormatting.Indented;
        lJSonWriter.WriteStartObject;

        lJSonWriter.WritePropertyName('result');
        lJSonWriter.WriteValue('success');
        lJSonWriter.WritePropertyName('user_signin');
        lJSonWriter.WriteStartArray;

        while not (qry.Eof) do begin
          lJSonWriter.WriteStartObject;

          lJSonWriter.WritePropertyName('valid_user');
          lJSonWriter.WriteValue(qry.FieldByName('valid_user').AsString);
          lJSonWriter.WritePropertyName('usr_cod');
          lJSonWriter.WriteValue(qry.FieldByName('usr_cod').AsString);

          qry.Next;
          lJSonWriter.WriteEndObject;
        end;

        lJSonWriter.WriteEndArray;
        lJSonWriter.WriteEndObject;

        result := lStringWriter.ToString;

        GetInvocationMetadata().ResponseCode    := 200;
        GetInvocationMetadata().ResponseContent := Result;
      except on E: Exception do
      end;
    finally
    end;
  end else begin
    try
      try
        lResultado := TJSONObject.Create;

        lResultado.AddPair('result', 'error');

        result := lResultado.ToString;

        GetInvocationMetadata().ResponseCode    := 200;
        GetInvocationMetadata().ResponseContent := Result;
      except on E: Exception do
      end;
    finally
    end;
  end;
end;

function Tfrm_srvmethod.contract_user_signin(ctr_id: Int64; ctr_usr_username, ctr_usr_password: string): string;
var
  SQL           : string;
  qry           : TFDQuery;
  lResultado    : TJSONObject;
  lStringWriter : TStringWriter;
  lJSonWriter   : TJSonTextWriter;
begin
  SQL := 'set @po_valid_user  = 0;'       +
         'set @po_ctr_usr_cod = 0;'       +
         'set @po_ctr_token   = 0;'       +
         'call proc_contract_user_signin('+ IntToStr(ctr_id) +', '+ QuotedStr(ctr_usr_username) +', '+ QuotedStr(ctr_usr_password) +', @po_valid_user, @po_ctr_usr_cod, @po_ctr_token);' +
         'select @po_valid_user as valid_user, @po_ctr_usr_cod as ctr_usr_cod, @po_ctr_token as ctr_token;';

  qry := TFDQuery.Create(Self);

  qry.Close;
  qry.Connection := conn_db;
  qry.SQL.Add(SQL);
  qry.Prepare;
  qry.Open;

  if not (qry.IsEmpty) then begin
    try
      try
        lStringWriter := TStringWriter.Create;
        lJSonWriter   := TJsonTextWriter.Create(lStringWriter);

        lJSonWriter.Formatting := TJsonFormatting.Indented;
        lJSonWriter.WriteStartObject;

        lJSonWriter.WritePropertyName('result');
        lJSonWriter.WriteValue('success');
        lJSonWriter.WritePropertyName('contract_user_signin');
        lJSonWriter.WriteStartArray;

        while not (qry.Eof) do begin
          lJSonWriter.WriteStartObject;

          lJSonWriter.WritePropertyName('valid_user');
          lJSonWriter.WriteValue(qry.FieldByName('valid_user').AsLargeInt);
          lJSonWriter.WritePropertyName('ctr_usr_cod');
          lJSonWriter.WriteValue(qry.FieldByName('ctr_usr_cod').AsString);
          lJSonWriter.WritePropertyName('ctr_token');
          lJSonWriter.WriteValue(qry.FieldByName('ctr_token').AsString);

          qry.Next;
          lJSonWriter.WriteEndObject;
        end;

        lJSonWriter.WriteEndArray;
        lJSonWriter.WriteEndObject;

        Result := lStringWriter.ToString;

        GetInvocationMetadata().ResponseCode    := 200;
        GetInvocationMetadata().ResponseContent := Result;
      except on E: Exception do
      end;
    finally
    end;
  end;
end;

function Tfrm_srvmethod.echostring(Value: string): string;
begin
  Result := Value;
end;

function Tfrm_srvmethod.get_client(ctr_token: string): string;
var
  SQL           : string;
  qry           : TFDQuery;
  lResultado    : TJSONObject;
  lStringWriter : TStringWriter;
  lJSonWriter   : TJSonTextWriter;
begin
  SQL := 'call proc_client_read('+ QuotedStr(ctr_token) +');';

  qry := TFDQuery.Create(Self);

  qry.Close;
  qry.Connection := conn_db;
  qry.SQL.Add(SQL);
  qry.Prepare;
  qry.Open;

  if not (qry.IsEmpty) then begin
    try
      try
        lStringWriter := TStringWriter.Create;
        lJSonWriter   := TJsonTextWriter.Create(lStringWriter);

        lJSonWriter.Formatting := TJsonFormatting.Indented;
        lJSonWriter.WriteStartObject;

        lJSonWriter.WritePropertyName('result');
        lJSonWriter.WriteValue('success');
        lJSonWriter.WritePropertyName('client');
        lJSonWriter.WriteStartArray;

        while not (qry.Eof) do begin
          lJSonWriter.WriteStartObject;

          lJSonWriter.WritePropertyName('cli_cod');
          lJSonWriter.WriteValue(qry.FieldByName('cli_cod').AsString);
          lJSonWriter.WritePropertyName('table_price_tbp_cod');
          lJSonWriter.WriteValue(qry.FieldByName('table_price_tbp_cod').AsString);
          lJSonWriter.WritePropertyName('cli_type');
          lJSonWriter.WriteValue(qry.FieldByName('cli_type').AsString);
          lJSonWriter.WritePropertyName('cli_id');
          lJSonWriter.WriteValue(qry.FieldByName('cli_id').AsInteger);
          lJSonWriter.WritePropertyName('cli_first_name');
          lJSonWriter.WriteValue(qry.FieldByName('cli_first_name').AsString);
          lJSonWriter.WritePropertyName('cli_last_name');
          lJSonWriter.WriteValue(qry.FieldByName('cli_last_name').AsString);
          lJSonWriter.WritePropertyName('cli_email');
          lJSonWriter.WriteValue(qry.FieldByName('cli_email').AsString);
          lJSonWriter.WritePropertyName('cli_cpfcnpj');
          lJSonWriter.WriteValue(qry.FieldByName('cli_cpfcnpj').AsString);
          lJSonWriter.WritePropertyName('cli_rgie');
          lJSonWriter.WriteValue(qry.FieldByName('cli_rgie').AsString);
          lJSonWriter.WritePropertyName('cli_im');
          lJSonWriter.WriteValue(qry.FieldByName('cli_im').AsString);
          lJSonWriter.WritePropertyName('cli_suframa');
          lJSonWriter.WriteValue(qry.FieldByName('cli_suframa').AsString);
          lJSonWriter.WritePropertyName('cli_add_bus_zipcode');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bus_zipcode').AsString);
          lJSonWriter.WritePropertyName('cli_add_bus_address');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bus_address').AsString);
          lJSonWriter.WritePropertyName('cli_add_bus_number');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bus_number').AsString);
          lJSonWriter.WritePropertyName('cli_add_bus_street');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bus_street').AsString);
          lJSonWriter.WritePropertyName('cli_add_bus_complement');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bus_complement').AsString);
          lJSonWriter.WritePropertyName('cli_add_bus_city');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bus_city').AsString);
          lJSonWriter.WritePropertyName('cli_add_bus_state');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bus_state').AsString);
          lJSonWriter.WritePropertyName('cli_add_bus_country');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bus_country').AsString);
          lJSonWriter.WritePropertyName('cli_add_bil_zipcode');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bil_zipcode').AsString);
          lJSonWriter.WritePropertyName('cli_add_bil_address');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bil_address').AsString);
          lJSonWriter.WritePropertyName('cli_add_bil_number');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bil_number').AsString);
          lJSonWriter.WritePropertyName('cli_add_bil_street');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bil_street').AsString);
          lJSonWriter.WritePropertyName('cli_add_bil_complement');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bil_complement').AsString);
          lJSonWriter.WritePropertyName('cli_add_bil_city');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bil_city').AsString);
          lJSonWriter.WritePropertyName('cli_add_bil_state');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bil_state').AsString);
          lJSonWriter.WritePropertyName('cli_add_bil_country');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_bil_country').AsString);
          lJSonWriter.WritePropertyName('cli_add_bus_zipcode');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_del_zipcode').AsString);
          lJSonWriter.WritePropertyName('cli_add_del_address');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_del_address').AsString);
          lJSonWriter.WritePropertyName('cli_add_del_number');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_del_number').AsString);
          lJSonWriter.WritePropertyName('cli_add_del_street');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_del_street').AsString);
          lJSonWriter.WritePropertyName('cli_add_del_complement');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_del_complement').AsString);
          lJSonWriter.WritePropertyName('cli_add_del_city');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_del_city').AsString);
          lJSonWriter.WritePropertyName('cli_add_del_state');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_del_state').AsString);
          lJSonWriter.WritePropertyName('cli_add_del_country');
          lJSonWriter.WriteValue(qry.FieldByName('cli_add_del_country').AsString);
          lJSonWriter.WritePropertyName('cli_phone1');
          lJSonWriter.WriteValue(qry.FieldByName('cli_phone1').AsString);
          lJSonWriter.WritePropertyName('cli_phone2');
          lJSonWriter.WriteValue(qry.FieldByName('cli_phone2').AsString);
          lJSonWriter.WritePropertyName('cli_phone3');
          lJSonWriter.WriteValue(qry.FieldByName('cli_phone3').AsString);
          lJSonWriter.WritePropertyName('cli_phone4');
          lJSonWriter.WriteValue(qry.FieldByName('cli_phone4').AsString);
          lJSonWriter.WritePropertyName('cli_contact');
          lJSonWriter.WriteValue(qry.FieldByName('cli_contact').AsString);
          lJSonWriter.WritePropertyName('cli_day_maturity');
          lJSonWriter.WriteValue(qry.FieldByName('cli_day_maturity').AsString);
          lJSonWriter.WritePropertyName('cli_dt_birthopen');
          lJSonWriter.WriteValue(qry.FieldByName('cli_dt_birthopen').AsString);
          lJSonWriter.WritePropertyName('cli_weight');
          lJSonWriter.WriteValue(qry.FieldByName('cli_weight').AsString);
          lJSonWriter.WritePropertyName('cli_height');
          lJSonWriter.WriteValue(qry.FieldByName('cli_height').AsString);
          lJSonWriter.WritePropertyName('cli_blood_type');
          lJSonWriter.WriteValue(qry.FieldByName('cli_blood_type').AsString);
          lJSonWriter.WritePropertyName('cli_rh_factor');
          lJSonWriter.WriteValue(qry.FieldByName('cli_rh_factor').AsString);
          lJSonWriter.WritePropertyName('cli_du_factor');
          lJSonWriter.WriteValue(qry.FieldByName('cli_du_factor').AsString);
          lJSonWriter.WritePropertyName('cli_cns');
          lJSonWriter.WriteValue(qry.FieldByName('cli_cns').AsString);
          lJSonWriter.WritePropertyName('cli_gender');
          lJSonWriter.WriteValue(qry.FieldByName('cli_gender').AsString);
          lJSonWriter.WritePropertyName('cli_skin_color');
          lJSonWriter.WriteValue(qry.FieldByName('cli_skin_color').AsString);
          lJSonWriter.WritePropertyName('cli_status');
          lJSonWriter.WriteValue(qry.FieldByName('cli_status').AsBoolean);
          lJSonWriter.WritePropertyName('cli_image1');
          lJSonWriter.WriteValue(qry.FieldByName('cli_image1').AsString);
          lJSonWriter.WritePropertyName('cli_deleted_at');
          lJSonWriter.WriteValue(qry.FieldByName('cli_deleted_at').AsString);
          lJSonWriter.WritePropertyName('cli_dt_registration');
          lJSonWriter.WriteValue(qry.FieldByName('cli_dt_registration').AsString);

          qry.Next;
          lJSonWriter.WriteEndObject;
        end;

        lJSonWriter.WriteEndArray;
        lJSonWriter.WriteEndObject;

        Result := lStringWriter.ToString;

        GetInvocationMetadata().ResponseCode    := 200;
        GetInvocationMetadata().ResponseContent := Result;
      except on E: Exception do
      end;
    finally
    end;
  end;
end;

function Tfrm_srvmethod.get_contract(ctr_token: string): string;
var
  SQL           : string;
  qry           : TFDQuery;
  lResultado    : TJSONObject;
  lStringWriter : TStringWriter;
  lJSonWriter   : TJSonTextWriter;
begin
  SQL := 'call proc_contract_read('+ QuotedStr(ctr_token) +');';

  qry := TFDQuery.Create(Self);

  qry.Close;
  qry.Connection := conn_db;
  qry.SQL.Add(SQL);
  qry.Prepare;
  qry.Open;

  if not (qry.IsEmpty) then begin
    try
      try
        lStringWriter := TStringWriter.Create;
        lJSonWriter   := TJsonTextWriter.Create(lStringWriter);

        lJSonWriter.Formatting := TJsonFormatting.Indented;
        lJSonWriter.WriteStartObject;

        lJSonWriter.WritePropertyName('result');
        lJSonWriter.WriteValue('success');
        lJSonWriter.WritePropertyName('contract');
        lJSonWriter.WriteStartArray;

        while not (qry.Eof) do begin
          lJSonWriter.WriteStartObject;

          lJSonWriter.WritePropertyName('ctr_id');
          lJSonWriter.WriteValue(qry.FieldByName('ctr_id').AsLargeInt);
          lJSonWriter.WritePropertyName('ctr_first_name');
          lJSonWriter.WriteValue(qry.FieldByName('ctr_first_name').AsString);
          lJSonWriter.WritePropertyName('ctr_last_name');
          lJSonWriter.WriteValue(qry.FieldByName('ctr_last_name').AsString);
          lJSonWriter.WritePropertyName('ctr_email');
          lJSonWriter.WriteValue(qry.FieldByName('ctr_email').AsString);
          lJSonWriter.WritePropertyName('ctr_phone1');
          lJSonWriter.WriteValue(qry.FieldByName('ctr_phone1').AsString);
          lJSonWriter.WritePropertyName('ctr_dt_birth');
          lJSonWriter.WriteValue(qry.FieldByName('ctr_dt_birth').AsString);
          lJSonWriter.WritePropertyName('ctr_user_license');
          lJSonWriter.WriteValue(qry.FieldByName('ctr_user_license').AsString);
          lJSonWriter.WritePropertyName('ctr_status');
          lJSonWriter.WriteValue(qry.FieldByName('ctr_status').AsBoolean);
          lJSonWriter.WritePropertyName('ctr_deleted_at');
          lJSonWriter.WriteValue(qry.FieldByName('ctr_deleted_at').AsString);
          lJSonWriter.WritePropertyName('ctr_dt_registration');
          lJSonWriter.WriteValue(qry.FieldByName('ctr_dt_registration').AsString);

          qry.Next;
          lJSonWriter.WriteEndObject;
        end;

        lJSonWriter.WriteEndArray;
        lJSonWriter.WriteEndObject;

        Result := lStringWriter.ToString;

        GetInvocationMetadata().ResponseCode    := 200;
        GetInvocationMetadata().ResponseContent := Result;
      except on E: Exception do
      end;
    finally
    end;
  end;
end;

function Tfrm_srvmethod.get_enterprise(ctr_token: string): string;
var
  SQL           : string;
  qry           : TFDQuery;
  lResultado    : TJSONObject;
  lStringWriter : TStringWriter;
  lJSonWriter   : TJSonTextWriter;
begin
  SQL := 'call proc_enterprise_read('+ QuotedStr(ctr_token) +');';

  qry := TFDQuery.Create(Self);

  qry.Close;
  qry.Connection := conn_db;
  qry.SQL.Add(SQL);
  qry.Prepare;
  qry.Open;

  if not (qry.IsEmpty) then begin
    try
      try
        lStringWriter := TStringWriter.Create;
        lJSonWriter   := TJsonTextWriter.Create(lStringWriter);

        lJSonWriter.Formatting := TJsonFormatting.Indented;
        lJSonWriter.WriteStartObject;

        lJSonWriter.WritePropertyName('result');
        lJSonWriter.WriteValue('success');
        lJSonWriter.WritePropertyName('enterprise');
        lJSonWriter.WriteStartArray;

        while not (qry.Eof) do begin
          lJSonWriter.WriteStartObject;

          lJSonWriter.WritePropertyName('ent_cod');
          lJSonWriter.WriteValue(qry.FieldByName('ent_cod').AsString);
          lJSonWriter.WritePropertyName('ent_id');
          lJSonWriter.WriteValue(qry.FieldByName('ent_id').AsInteger);
          lJSonWriter.WritePropertyName('ent_type');
          lJSonWriter.WriteValue(qry.FieldByName('ent_type').AsString);
          lJSonWriter.WritePropertyName('ent_first_name');
          lJSonWriter.WriteValue(qry.FieldByName('ent_first_name').AsString);
          lJSonWriter.WritePropertyName('ent_last_name');
          lJSonWriter.WriteValue(qry.FieldByName('ent_last_name').AsString);
          lJSonWriter.WritePropertyName('ent_nickname');
          lJSonWriter.WriteValue(qry.FieldByName('ent_nickname').AsString);
          lJSonWriter.WritePropertyName('ent_email');
          lJSonWriter.WriteValue(qry.FieldByName('ent_email').AsString);
          lJSonWriter.WritePropertyName('ent_cnpj');
          lJSonWriter.WriteValue(qry.FieldByName('ent_cnpj').AsString);
          lJSonWriter.WritePropertyName('ent_ie');
          lJSonWriter.WriteValue(qry.FieldByName('ent_ie').AsString);
          lJSonWriter.WritePropertyName('ent_im');
          lJSonWriter.WriteValue(qry.FieldByName('ent_im').AsString);
          lJSonWriter.WritePropertyName('ent_suframa');
          lJSonWriter.WriteValue(qry.FieldByName('ent_suframa').AsString);
          lJSonWriter.WritePropertyName('ent_add_bus_zipcode');
          lJSonWriter.WriteValue(qry.FieldByName('ent_add_bus_zipcode').AsString);
          lJSonWriter.WritePropertyName('ent_add_bus_address');
          lJSonWriter.WriteValue(qry.FieldByName('ent_add_bus_address').AsString);
          lJSonWriter.WritePropertyName('ent_add_bus_number');
          lJSonWriter.WriteValue(qry.FieldByName('ent_add_bus_number').AsString);
          lJSonWriter.WritePropertyName('ent_add_bus_street');
          lJSonWriter.WriteValue(qry.FieldByName('ent_add_bus_street').AsString);
          lJSonWriter.WritePropertyName('ent_add_bus_complement');
          lJSonWriter.WriteValue(qry.FieldByName('ent_add_bus_complement').AsString);
          lJSonWriter.WritePropertyName('ent_add_bus_city');
          lJSonWriter.WriteValue(qry.FieldByName('ent_add_bus_city').AsString);
          lJSonWriter.WritePropertyName('ent_add_bus_state');
          lJSonWriter.WriteValue(qry.FieldByName('ent_add_bus_state').AsString);
          lJSonWriter.WritePropertyName('ent_add_bus_country');
          lJSonWriter.WriteValue(qry.FieldByName('ent_add_bus_country').AsString);
          lJSonWriter.WritePropertyName('ent_phone1');
          lJSonWriter.WriteValue(qry.FieldByName('ent_phone1').AsString);
          lJSonWriter.WritePropertyName('ent_phone2');
          lJSonWriter.WriteValue(qry.FieldByName('ent_phone2').AsString);
          lJSonWriter.WritePropertyName('ent_phone3');
          lJSonWriter.WriteValue(qry.FieldByName('ent_phone3').AsString);
          lJSonWriter.WritePropertyName('ent_phone4');
          lJSonWriter.WriteValue(qry.FieldByName('ent_phone4').AsString);
          lJSonWriter.WritePropertyName('ent_contact');
          lJSonWriter.WriteValue(qry.FieldByName('ent_contact').AsString);
          lJSonWriter.WritePropertyName('ent_dt_open');
          lJSonWriter.WriteValue(qry.FieldByName('ent_dt_open').AsString);
          lJSonWriter.WritePropertyName('ent_status');
          lJSonWriter.WriteValue(qry.FieldByName('ent_status').AsBoolean);
          lJSonWriter.WritePropertyName('ent_deleted_at');
          lJSonWriter.WriteValue(qry.FieldByName('ent_deleted_at').AsString);
          lJSonWriter.WritePropertyName('ent_dt_registration');
          lJSonWriter.WriteValue(qry.FieldByName('ent_dt_registration').AsString);

          qry.Next;
          lJSonWriter.WriteEndObject;
        end;

        lJSonWriter.WriteEndArray;
        lJSonWriter.WriteEndObject;

        Result := lStringWriter.ToString;

        GetInvocationMetadata().ResponseCode    := 200;
        GetInvocationMetadata().ResponseContent := Result;
      except on E: Exception do
      end;
    finally
    end;
  end;
end;

function Tfrm_srvmethod.get_insurance(ctr_token: string): string;
var
  SQL           : string;
  qry           : TFDQuery;
  lResultado    : TJSONObject;
  lStringWriter : TStringWriter;
  lJSonWriter   : TJSonTextWriter;
begin
  SQL := 'call proc_insurance_read('+ QuotedStr(ctr_token) +');';

  qry := TFDQuery.Create(Self);

  qry.Close;
  qry.Connection := conn_db;
  qry.SQL.Add(SQL);
  qry.Prepare;
  qry.Open;

  if not (qry.IsEmpty) then begin
    try
      try
        lStringWriter := TStringWriter.Create;
        lJSonWriter   := TJsonTextWriter.Create(lStringWriter);

        lJSonWriter.Formatting := TJsonFormatting.Indented;
        lJSonWriter.WriteStartObject;

        lJSonWriter.WritePropertyName('result');
        lJSonWriter.WriteValue('success');
        lJSonWriter.WritePropertyName('insurance');
        lJSonWriter.WriteStartArray;

        while not (qry.Eof) do begin
          lJSonWriter.WriteStartObject;

          lJSonWriter.WritePropertyName('ins_cod');
          lJSonWriter.WriteValue(qry.FieldByName('ins_cod').AsString);
          lJSonWriter.WritePropertyName('contract_ctr_cod');
          lJSonWriter.WriteValue(qry.FieldByName('contract_ctr_cod').AsString);
          lJSonWriter.WritePropertyName('table_price_tbp_cod');
          lJSonWriter.WriteValue(qry.FieldByName('table_price_tbp_cod').AsString);
          lJSonWriter.WritePropertyName('ins_id');
          lJSonWriter.WriteValue(qry.FieldByName('ins_id').AsInteger);
          lJSonWriter.WritePropertyName('ins_first_name');
          lJSonWriter.WriteValue(qry.FieldByName('ins_first_name').AsString);
          lJSonWriter.WritePropertyName('ins_last_name');
          lJSonWriter.WriteValue(qry.FieldByName('ins_last_name').AsString);
          lJSonWriter.WritePropertyName('ins_nickname');
          lJSonWriter.WriteValue(qry.FieldByName('ins_nickname').AsString);
          lJSonWriter.WritePropertyName('ins_email');
          lJSonWriter.WriteValue(qry.FieldByName('ins_email').AsString);
          lJSonWriter.WritePropertyName('ins_cnpj');
          lJSonWriter.WriteValue(qry.FieldByName('ins_cnpj').AsString);
          lJSonWriter.WritePropertyName('ins_im');
          lJSonWriter.WriteValue(qry.FieldByName('ins_im').AsString);
          lJSonWriter.WritePropertyName('ins_add_bus_zipcode');
          lJSonWriter.WriteValue(qry.FieldByName('ins_add_bus_zipcode').AsString);
          lJSonWriter.WritePropertyName('ins_add_bus_address');
          lJSonWriter.WriteValue(qry.FieldByName('ins_add_bus_address').AsString);
          lJSonWriter.WritePropertyName('ins_add_bus_number');
          lJSonWriter.WriteValue(qry.FieldByName('ins_add_bus_number').AsString);
          lJSonWriter.WritePropertyName('ins_add_bus_street');
          lJSonWriter.WriteValue(qry.FieldByName('ins_add_bus_street').AsString);
          lJSonWriter.WritePropertyName('ins_add_bus_complement');
          lJSonWriter.WriteValue(qry.FieldByName('ins_add_bus_complement').AsString);
          lJSonWriter.WritePropertyName('ins_add_bus_city');
          lJSonWriter.WriteValue(qry.FieldByName('ins_add_bus_city').AsString);
          lJSonWriter.WritePropertyName('ins_add_bus_state');
          lJSonWriter.WriteValue(qry.FieldByName('ins_add_bus_state').AsString);
          lJSonWriter.WritePropertyName('ins_add_bus_country');
          lJSonWriter.WriteValue(qry.FieldByName('ins_add_bus_country').AsString);
          lJSonWriter.WritePropertyName('ins_phone1');
          lJSonWriter.WriteValue(qry.FieldByName('ins_phone1').AsString);
          lJSonWriter.WritePropertyName('ins_phone2');
          lJSonWriter.WriteValue(qry.FieldByName('ins_phone2').AsString);
          lJSonWriter.WritePropertyName('ins_phone3');
          lJSonWriter.WriteValue(qry.FieldByName('ins_phone3').AsString);
          lJSonWriter.WritePropertyName('ins_phone4');
          lJSonWriter.WriteValue(qry.FieldByName('ins_phone4').AsString);
          lJSonWriter.WritePropertyName('ins_contact');
          lJSonWriter.WriteValue(qry.FieldByName('ins_contact').AsString);
          lJSonWriter.WritePropertyName('ins_day_maturity');
          lJSonWriter.WriteValue(qry.FieldByName('ins_day_maturity').AsString);
          lJSonWriter.WritePropertyName('ins_dt_open');
          lJSonWriter.WriteValue(qry.FieldByName('ins_dt_open').AsString);
          lJSonWriter.WritePropertyName('ins_status');
          lJSonWriter.WriteValue(qry.FieldByName('ins_status').AsInteger);
          lJSonWriter.WritePropertyName('ins_deleted_at');
          lJSonWriter.WriteValue(qry.FieldByName('ins_deleted_at').AsString);
          lJSonWriter.WritePropertyName('ins_dt_registration');
          lJSonWriter.WriteValue(qry.FieldByName('ins_dt_registration').AsString);

          qry.Next;
          lJSonWriter.WriteEndObject;
        end;

        lJSonWriter.WriteEndArray;
        lJSonWriter.WriteEndObject;

        Result := lStringWriter.ToString;

        GetInvocationMetadata().ResponseCode    := 200;
        GetInvocationMetadata().ResponseContent := Result;
      except on E: Exception do
      end;
    finally
    end;
  end;
end;

function Tfrm_srvmethod.get_phonebook(ctr_token: string): string;
var
  SQL           : string;
  qry           : TFDQuery;
  lResultado    : TJSONObject;
  lStringWriter : TStringWriter;
  lJSonWriter   : TJSonTextWriter;
begin
  SQL := 'call proc_phonebook_read('+ QuotedStr(ctr_token) +');';

  qry := TFDQuery.Create(Self);

  qry.Close;
  qry.Connection := conn_db;
  qry.SQL.Add(SQL);
  qry.Prepare;
  qry.Open;

  if not (qry.IsEmpty) then begin
    try
      try
        lStringWriter := TStringWriter.Create;
        lJSonWriter   := TJsonTextWriter.Create(lStringWriter);

        lJSonWriter.Formatting := TJsonFormatting.Indented;
        lJSonWriter.WriteStartObject;

        lJSonWriter.WritePropertyName('result');
        lJSonWriter.WriteValue('success');
        lJSonWriter.WritePropertyName('phonebook');
        lJSonWriter.WriteStartArray;

        while not (qry.Eof) do begin
          lJSonWriter.WriteStartObject;

          lJSonWriter.WritePropertyName('pho_cod');
          lJSonWriter.WriteValue(qry.FieldByName('pho_cod').AsString);
          lJSonWriter.WritePropertyName('pho_id');
          lJSonWriter.WriteValue(qry.FieldByName('pho_id').AsInteger);
          lJSonWriter.WritePropertyName('pho_name');
          lJSonWriter.WriteValue(qry.FieldByName('pho_name').AsString);
          lJSonWriter.WritePropertyName('pho_phone1');
          lJSonWriter.WriteValue(qry.FieldByName('pho_phone1').AsString);
          lJSonWriter.WritePropertyName('pho_phone2');
          lJSonWriter.WriteValue(qry.FieldByName('pho_phone2').AsString);
          lJSonWriter.WritePropertyName('pho_phone3');
          lJSonWriter.WriteValue(qry.FieldByName('pho_phone3').AsString);
          lJSonWriter.WritePropertyName('pho_phone4');
          lJSonWriter.WriteValue(qry.FieldByName('pho_phone4').AsString);
          lJSonWriter.WritePropertyName('pho_contact');
          lJSonWriter.WriteValue(qry.FieldByName('pho_contact').AsString);
          lJSonWriter.WritePropertyName('pho_deleted_at');
          lJSonWriter.WriteValue(qry.FieldByName('pho_deleted_at').AsString);
          lJSonWriter.WritePropertyName('pho_dt_registration');
          lJSonWriter.WriteValue(qry.FieldByName('pho_dt_registration').AsString);

          qry.Next;
          lJSonWriter.WriteEndObject;
        end;

        lJSonWriter.WriteEndArray;
        lJSonWriter.WriteEndObject;

        Result := lStringWriter.ToString;

        GetInvocationMetadata().ResponseCode    := 200;
        GetInvocationMetadata().ResponseContent := Result;
      except on E: Exception do
      end;
    finally
    end;
  end;
end;

function Tfrm_srvmethod.get_product(ctr_token: string): string;
var
  SQL           : string;
  qry           : TFDQuery;
  lResultado    : TJSONObject;
  lStringWriter : TStringWriter;
  lJSonWriter   : TJSonTextWriter;
begin
  SQL := 'call proc_product_read('+ QuotedStr(ctr_token) +');';

  qry := TFDQuery.Create(Self);

  qry.Close;
  qry.Connection := conn_db;
  qry.SQL.Add(SQL);
  qry.Prepare;
  qry.Open;

  if not (qry.IsEmpty) then begin
    try
      try
        lStringWriter := TStringWriter.Create;
        lJSonWriter   := TJsonTextWriter.Create(lStringWriter);

        lJSonWriter.Formatting := TJsonFormatting.Indented;
        lJSonWriter.WriteStartObject;

        lJSonWriter.WritePropertyName('result');
        lJSonWriter.WriteValue('success');
        lJSonWriter.WritePropertyName('product');
        lJSonWriter.WriteStartArray;

        while not (qry.Eof) do begin
          lJSonWriter.WriteStartObject;

          lJSonWriter.WritePropertyName('pro_cod');
          lJSonWriter.WriteValue(qry.FieldByName('pro_cod').AsString);
          lJSonWriter.WritePropertyName('contract_ctr_cod');
          lJSonWriter.WriteValue(qry.FieldByName('contract_ctr_cod').AsString);
          lJSonWriter.WritePropertyName('material_mat_cod');
          lJSonWriter.WriteValue(qry.FieldByName('material_mat_cod').AsString);
          lJSonWriter.WritePropertyName('supplier_sup_cod');
          lJSonWriter.WriteValue(qry.FieldByName('supplier_sup_cod').AsString);
          lJSonWriter.WritePropertyName('product_class_prc_cod');
          lJSonWriter.WriteValue(qry.FieldByName('product_class_prc_cod').AsString);
          lJSonWriter.WritePropertyName('product_class_sub_prs_cod');
          lJSonWriter.WriteValue(qry.FieldByName('product_class_sub_prs_cod').AsString);
          lJSonWriter.WritePropertyName('manufacturer_man_cod');
          lJSonWriter.WriteValue(qry.FieldByName('manufacturer_man_cod').AsString);
          lJSonWriter.WritePropertyName('brand_bra_cod');
          lJSonWriter.WriteValue(qry.FieldByName('brand_bra_cod').AsString);
          lJSonWriter.WritePropertyName('ncm_ncm_cod');
          lJSonWriter.WriteValue(qry.FieldByName('ncm_ncm_cod').AsString);
          lJSonWriter.WritePropertyName('product_unit_pru_cod');
          lJSonWriter.WriteValue(qry.FieldByName('product_unit_pru_cod').AsString);
          lJSonWriter.WritePropertyName('pro_id');
          lJSonWriter.WriteValue(qry.FieldByName('pro_id').AsInteger);
          lJSonWriter.WritePropertyName('pro_type');
          lJSonWriter.WriteValue(qry.FieldByName('pro_type').AsString);
          lJSonWriter.WritePropertyName('pro_name');
          lJSonWriter.WriteValue(qry.FieldByName('pro_name').AsString);
          lJSonWriter.WritePropertyName('pro_initials');
          lJSonWriter.WriteValue(qry.FieldByName('pro_initials').AsString);
          lJSonWriter.WritePropertyName('pro_tag');
          lJSonWriter.WriteValue(qry.FieldByName('pro_tag').AsString);
          lJSonWriter.WritePropertyName('pro_description');
          lJSonWriter.WriteValue(qry.FieldByName('pro_description').AsString);
          lJSonWriter.WritePropertyName('pro_gender');
          lJSonWriter.WriteValue(qry.FieldByName('pro_gender').AsString);
          lJSonWriter.WritePropertyName('pro_annotation');
          lJSonWriter.WriteValue(qry.FieldByName('pro_annotation').AsString);
          lJSonWriter.WritePropertyName('pro_barcod');
          lJSonWriter.WriteValue(qry.FieldByName('pro_barcod').AsString);
          lJSonWriter.WritePropertyName('pro_barcod_manufacturer');
          lJSonWriter.WriteValue(qry.FieldByName('pro_barcod_manufacturer').AsString);
          lJSonWriter.WritePropertyName('pro_height');
          lJSonWriter.WriteValue(qry.FieldByName('pro_height').AsFloat);
          lJSonWriter.WritePropertyName('pro_width');
          lJSonWriter.WriteValue(qry.FieldByName('pro_width').AsFloat);
          lJSonWriter.WritePropertyName('pro_length');
          lJSonWriter.WriteValue(qry.FieldByName('pro_length').AsFloat);
          lJSonWriter.WritePropertyName('pro_weight');
          lJSonWriter.WriteValue(qry.FieldByName('pro_weight').AsFloat);
          lJSonWriter.WritePropertyName('pro_liter');
          lJSonWriter.WriteValue(qry.FieldByName('pro_liter').AsFloat);
          lJSonWriter.WritePropertyName('pro_delivery_term');
          lJSonWriter.WriteValue(qry.FieldByName('pro_delivery_term').AsInteger);
          lJSonWriter.WritePropertyName('pro_status');
          lJSonWriter.WriteValue(qry.FieldByName('pro_status').AsString);
          lJSonWriter.WritePropertyName('pro_deleted_at');
          lJSonWriter.WriteValue(qry.FieldByName('pro_deleted_at').AsString);
          lJSonWriter.WritePropertyName('pro_dt_registration');
          lJSonWriter.WriteValue(qry.FieldByName('pro_dt_registration').AsString);

          qry.Next;
          lJSonWriter.WriteEndObject;
        end;

        lJSonWriter.WriteEndArray;
        lJSonWriter.WriteEndObject;

        Result := lStringWriter.ToString;

        GetInvocationMetadata().ResponseCode    := 200;
        GetInvocationMetadata().ResponseContent := Result;
      except on E: Exception do
      end;
    finally
    end;
  end;
end;

function Tfrm_srvmethod.reversestring(Value: string): string;
begin
  Result := System.StrUtils.ReverseString(Value);
end;

end.


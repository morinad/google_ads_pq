section GoogleAdsBL;

client_id = "13860562608-rolk2hhj4tecggm0k1odjrfo5m905hce.apps.googleusercontent.com";
client_secret = "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";

developerToken = Text.FromBinary(Binary.FromText("OGlDdWlMR0Z3eUNDNzV1MElxSjM="));
redirect_uri = "https://preview.powerbi.com/views/oauthredirect.html";
windowWidth = 1200;
windowHeight = 1000;


[DataSource.Kind="GoogleAdsBL", Publish="GoogleAdsBL.UI"]

shared GoogleAdsBL.Data = Value.ReplaceType(GoogleAdsBL.Stat, FuncType);

FuncType = type function (
      login  as (type text meta [
        Documentation.FieldCaption = "Account ID:",
        Documentation.FieldDescription = "Enter your Google.Ads login ID.",
        Documentation.SampleValues = {"123-456-7890"}
    ]),
     
      token  as (type text meta [
        Documentation.FieldCaption = "Your refresh token:",
        Documentation.FieldDescription = "Enter your Google Ads refresh Token",
        Documentation.SampleValues = {"1//gfgFG33qJfk23mbh1fghKMnqhh3p"}
    ]),

     preset  as (type text meta [
        Documentation.FieldCaption = "Report preset:",
        Documentation.FieldDescription = "Do not choose columns and report type, only preset.",
        Documentation.AllowedValues = {"no preset", "account" , "campaigns" , "keywords" , "adgroups" , "ads" , "location" , "age" , "gender" , "search_term"}
    ]),

    reporttype  as (type nullable text meta [
        Documentation.FieldCaption = "Report type:",
        Documentation.FieldDescription = "Choose your report type.",
         Documentation.SampleValues = {"campaign"}
    ]),

   fields  as (type nullable text meta [
        Documentation.FieldCaption = "Columns (separated by commas):",
        Documentation.FieldDescription = "Enter your table columns you want to get in the report (separated by commas). Enter space to use columns by default.",
        Documentation.SampleValues = {"segments.date,campaign.name,metrics.cost_micros"}
    ]),
    
    start as (type nullable text meta [
        Documentation.FieldCaption = "Start date:",
        Documentation.FieldDescription = "Enter the first date of your statistics. You can specify date in YYYY-MM-DD format or use dynamic formats: today, yesterday, 69daysAgo.",
        Documentation.SampleValues = {"2022-02-28"}
    ]),
     end as (type nullable text meta [
        Documentation.FieldCaption = "End date:",
        Documentation.FieldDescription = "Enter the last date of your statistics. You can specify date in YYYY-MM-DD format or use dynamic formats: today, yesterday, 69daysAgo.",
        Documentation.SampleValues = {"yesterday"}
    ]),

    client  as (type nullable  text meta [
        Documentation.FieldCaption = "Customer ID:",
        Documentation.FieldDescription = "Enter your Google.Ads customer ID.",
        Documentation.SampleValues = {"123-456-7890"}
    ]),

    language  as (type text meta [
        Documentation.FieldCaption = "Choose language:",
        Documentation.FieldDescription = "English or Russian.",
        Documentation.AllowedValues = {"EN", "RU"}
    ])

    )
    as table meta [
        Documentation.Name = "Google.Ads Function",
        Documentation.LongDescription = 
        "Created to get data from Google.Ads. Use all dimensions and metrics according to chosen report type.",
        Documentation.Examples = {
        [
            Description = "Without date:",
            Code = "GoogleAdsBL.Data(""123-456-7890"",""1//gfgFG33qJfk23mbh1fghKMnqhh3p"", ""no preset"", ""ad_group"", ""ad_group.name,metrics.clicks"", null, null, null,  ""EN"")",
            Result = "Google Ads stat table"
        ],
        [
            Description = "With date:",
            Code = "GoogleAdsBL.Data(""123-456-7890"",""1//gfgFG33qJfk23mbh1fghKMnqhh3p"", ""no preset"", ""campaign"", ""campaign.name,metrics.impressions"", ""2022-01-01"", ""2022-12-31"", null, ""RU"")",
            Result ="Table with 3 chosen columns"
        ],
        [
            Description = "Choose report type (on the left menu) and then choose your dimensions and metrics:",
            Code = "https://developers.google.com/google-ads/api/fields/v15/overview",
            Result = "The best report!"
        ]
        }
    ];


GoogleAdsBL.Stat = 
(login as text, 
token as text,
preset as  text,  
reporttype as nullable text, 
fields as nullable text, 
start as nullable text, 
end as nullable text, 
client as  nullable text,   
language as text) =>

let

accessToken = getToken(token), 
pagesize = "10000",
realapiversion =  "v15", 
realclient = if client=null then Text.Replace(login,"-","") else Text.Replace(client,"-","") ,

report = 
if preset = "account" then "customer" else
if preset = "campaigns" then "campaign" else
if preset = "keywords" then "keyword_view" else
if preset = "adgroups" then "ad_group"  else
if preset = "ads" then "ad_group_ad" else
if preset = "location" then "location_view" else
if preset = "age" then "age_range_view" else
if preset = "gender" then "gender_view" else
if preset = "search_term" then "search_term_view" else
reporttype ,

fieldlist = 
if preset = "account" then "segments.date,customer.descriptive_name,customer.id,metrics.impressions,metrics.clicks,metrics.cost_micros,metrics.all_conversions" else
if preset = "campaigns" then "segments.date,campaign.name,campaign.id,campaign.status,metrics.impressions,metrics.clicks,metrics.cost_micros,metrics.all_conversions" else
if preset = "keywords" then "segments.date,metrics.impressions,metrics.clicks,metrics.cost_micros,metrics.all_conversions" else
if preset = "adgroups" then "segments.date,ad_group.campaign,ad_group.name,ad_group.id,ad_group.status,metrics.impressions,metrics.clicks,metrics.cost_micros,metrics.all_conversions" else
if preset = "ads" then "segments.date,ad_group_ad.ad_group,ad_group_ad.ad.name,ad_group_ad.ad.id,ad_group_ad.status,ad_group_ad.ad.type,metrics.impressions,metrics.clicks,metrics.cost_micros,metrics.all_conversions" else
if preset = "location" then "segments.date,metrics.impressions,metrics.clicks,metrics.cost_micros,metrics.all_conversions" else
if preset = "age" then "segments.date,metrics.impressions,metrics.clicks,metrics.cost_micros,metrics.all_conversions" else
if preset = "gender" then "segments.date,metrics.impressions,metrics.clicks,metrics.cost_micros,metrics.all_conversions" else
if preset = "search_term" then "segments.date,search_term_view.search_term,search_term_view.ad_group,segments.keyword.info.text,segments.keyword.info.match_type,search_term_view.status,segments.keyword.ad_group_criterion,metrics.impressions,metrics.clicks,metrics.cost_micros,metrics.all_conversions" else
fields ,

geterror = getpage(login, accessToken, report, fieldlist, start, end, realclient , "" , pagesize , realapiversion , false),
tokenlist  = List.FirstN(List.Generate(()=> "", each _ <> null, each getpage(login, accessToken, report, fieldlist, start, end, realclient ,  _ , pagesize , realapiversion , false)),100),
totable = Table.FromList(tokenlist , Splitter.SplitByNothing(), null, null, ExtraValues.Error),
addcolumn = Table.AddColumn(totable , "data", each getpage(login, accessToken, report, fieldlist, start, end, realclient ,  [Column1] , pagesize , realapiversion , true)),
deletecolumn1 = Table.RemoveColumns(addcolumn ,{"Column1"}),
expdata = expand(Table.ExpandListColumn(deletecolumn1 , "data"),"data"),
columns = Table.ColumnNames(expdata),
expall =  List.Accumulate(columns, expdata, (state, current) => expand(state , current) ),

cost =try Table.TransformColumns(Table.TransformColumnTypes(expall ,{{"costMicros", type number}}), {{"costMicros", each _ / 1000000, type number}}) otherwise expall ,
    

type1 =try  Table.TransformColumnTypes(cost , {{"allConversions", type number}}, "en-AU") otherwise cost ,
type2 =try  Table.TransformColumnTypes(type1 ,{{"day", type date}}) otherwise type1 ,
type3 =try Table.TransformColumnTypes(type2 ,{ {"clicks", Int64.Type}}) otherwise type2 ,
type4 =try Table.TransformColumnTypes(type3 ,{ {"impressions", Int64.Type}}) otherwise type3 ,
type5 =try Table.TransformColumnTypes(type4 ,{ {"date", Date.Type}}) otherwise type4 ,
type6 =try Table.TransformColumnTypes(type5 ,{ {"status", type text}}) otherwise type5,
type7 =try Table.TransformColumnTypes(type6 ,{ {"id", type text}}) otherwise type6,
type8 =try Table.TransformColumnTypes(type7 ,{ {"name", type text}}) otherwise type7,
type9 =try Table.TransformColumnTypes(type8 ,{ {"campaign", type text}}) otherwise type8,
type10 =try Table.TransformColumnTypes(type9 ,{ {"resourceName", type text}}) otherwise type9,
type11 =try Table.TransformColumnTypes(type10 ,{ {"adGroup", type text}}) otherwise type10,
type12 =try Table.TransformColumnTypes(type11 ,{ {"searchTerm", type text}}) otherwise type11,

final = if language = "RU" then
let
ren1 = try Table.RenameColumns(type12 ,{{"date", "Дата"}}) otherwise type4,
ren2 = try Table.RenameColumns(ren1 ,{{"costMicros", "Расход"}}) otherwise ren1 ,
ren3 = try Table.RenameColumns(ren2 ,{{"clicks", "Клики"}}) otherwise ren2 ,
ren4 = try Table.RenameColumns(ren3 ,{{"impressions", "Показы"}}) otherwise ren3 ,
ren5 = try Table.RenameColumns(ren4 ,{{"allConversions", "Конверсии"}}) otherwise ren4 ,
ren6 = try Table.RenameColumns(ren5 ,{{"campaign", "Кампания"}}) otherwise ren5, 
ren7 = try Table.RenameColumns(ren6 ,{{"campaign_id", "ID кампании"}}) otherwise ren6 ,
ren8 = try Table.RenameColumns(ren7 ,{{"campaign_state", "Статус кампании"}}) otherwise ren7 ,
ren9 = try Table.RenameColumns(ren8 ,{{"ad_group", "Группа"}}) otherwise ren8 ,
ren10 = try Table.RenameColumns(ren9 ,{{"ad_group_id", "ID группы"}}) otherwise ren9 ,
ren11 = try Table.RenameColumns(ren10 ,{{"ad_group_state", "Статус группы"}}) otherwise ren10 ,
ren12 = try Table.RenameColumns(ren11 ,{{"ad_state", "Статус объявления"}}) otherwise ren11 ,
ren13 = try Table.RenameColumns(ren12 ,{{"ad_id", "ID объявления"}}) otherwise ren12 ,
ren14 = try Table.RenameColumns(ren13 ,{{"ad", "Объявление"}}) otherwise ren13 ,
ren15 = try Table.RenameColumns(ren14 ,{{"description", "Описание"}}) otherwise ren14 ,
ren16 = try Table.RenameColumns(ren15 ,{{"destination_url", "Целевой URL"}}) otherwise ren15, 
ren17 = try Table.RenameColumns(ren16 ,{{"display_url", "Отображаемый URL"}}) otherwise ren16 ,
ren18 = try Table.RenameColumns(ren17 ,{{"ad_type", "Тип объявления"}}) otherwise ren17 ,
ren19 = try Table.RenameColumns(ren18 ,{{"avg_position", "Средняя позиция"}}) otherwise ren18,
ren20 = try Table.RenameColumns(ren19 ,{{"client_name", "Клиент"}}) otherwise ren19 ,
ren21 = try Table.RenameColumns(ren20 ,{{"customer_id", "ID клиента"}}) otherwise ren20 ,
ren22 = try Table.RenameColumns(ren21 ,{{"account", "Аккаунт"}}) otherwise ren21 ,
ren23 = try Table.RenameColumns(ren22 ,{{"keyword_id", "ID условия показа"}}) otherwise ren22 ,
ren24 = try Table.RenameColumns(ren23 ,{{"criteria_type", "Тип условия показа"}}) otherwise ren23 ,
ren25 = try Table.RenameColumns(ren24 ,{{"search_term", "Поисковый запрос"}}) otherwise ren24 ,
ren26 = try Table.RenameColumns(ren25 ,{{"keyword", "Ключевая фраза"}}) otherwise ren25 ,
ren27 = try Table.RenameColumns(ren26 ,{{"match_type", "Тип соответствия"}}) otherwise ren26 ,
ren28 = try Table.RenameColumns(ren27 ,{{"city", "Город"}}) otherwise ren27 ,
ren29 = try Table.RenameColumns(ren28 ,{{"region", "Регион"}}) otherwise ren28 ,
ren30 = try Table.RenameColumns(ren29 ,{{"age_range", "Возраст"}}) otherwise ren29 ,
ren31 = try Table.RenameColumns(ren30 ,{{"gender", "Пол"}}) otherwise ren30 ,
ren32 = try Table.RenameColumns(ren31 ,{{"device", "Устройства"}}) otherwise ren31 ,
ren33 = try Table.RenameColumns(ren32 ,{{"month", "Месяц"}}) otherwise ren32 ,
ren34 = try Table.RenameColumns(ren33 ,{{"status", "Статус"}}) otherwise ren33,
ren35 = try Table.RenameColumns(ren34 ,{{"id", "ID"}}) otherwise ren34, 
ren36 = try Table.RenameColumns(ren35 ,{{"name", "Название"}}) otherwise ren35, 
ren37 = try Table.RenameColumns(ren36 ,{{"resourceName", "Сегмент"}}) otherwise ren36,
ren38 = try Table.RenameColumns(ren37 ,{{"adGroup", "Группа"}}) otherwise ren37,
ren39 = try Table.RenameColumns(ren38 ,{{"searchTerm", "Поисковый запрос"}}) otherwise ren38 
in ren39 else type12

in try final otherwise geterror;


getpage = (login as text, token as text, report as text, fieldlist as text, start as nullable text, end as nullable text, client as  nullable text,  pagetoken as nullable text, pagesize as text, apivers as text, getdata as logical  ) =>
let
pagetok = if pagetoken =null then "" else pagetoken, 
sizepage = pagesize,
datewhere = try " WHERE segments.date BETWEEN '" &  dateFunc(start) & "' AND '" &  dateFunc(end) & "'" otherwise " ",
nodatewhere = " ",
where = if (start = "" and end = "") or (start = null and end = null) then nodatewhere else datewhere ,
headers= [ #"Content-Type" = "application/json", #"developer-token" = "8iCuiLGFwyCC75u0IqJ3rw", #"login-customer-id" = Text.Replace(login,"-",""), #"Authorization" = "Bearer "& token ],
body = "{""pageSize"":" & sizepage & ", ""pageToken"":""" & pagetok & """, ""query"": ""SELECT " & fieldlist & " FROM " & report & where & """}",
jsondata = Json.FromValue( Json.Document(Text.ToBinary(body))),
realclient = if client=null then Text.Replace(login,"-","") else Text.Replace(client,"-","") ,
web = Web.Contents("https://googleads.googleapis.com/", [RelativePath = apivers & "/customers/" & realclient & "/googleAds:search", Headers = headers, ManualStatusHandling = {404, 400}, Content = jsondata]),
result = Json.Document(web),
final = try result [error]  otherwise if getdata = true then result[results] else try result[nextPageToken] otherwise null
in final;


dateFunc= (dat)=> 
if dat = "yesterday" then Date.ToText(Date.AddDays(Date.From(DateTime.LocalNow()) , -1),"yyyy-MM-dd") else 
if dat = "today" then Date.ToText(Date.From(DateTime.LocalNow()),"yyyy-MM-dd") else 
if dat = null then null else
if (try Number.From(Text.BeforeDelimiter(dat,"daysAgo")) otherwise 0) >0 then 
Date.ToText(Date.AddDays(Date.From(DateTime.LocalNow()),-1*Number.From(Text.BeforeDelimiter(dat,"daysAgo"))),"yyyy-MM-dd") else dat;


expand = (tbl, clmn)=>
let
columns = Record.FieldNames(Record.Field(tbl{0},clmn)),
data = Table.ExpandRecordColumn(tbl, clmn, columns, columns)
in data;


getToken= (tkn as text)=>
let
tok=Text.Replace(tkn,"\",""),
app_credentials ="client_id="&client_id&"&client_secret="&client_secret,
url = app_credentials & "&refresh_token=" & tok & "&grant_type=refresh_token",
GetJson = Web.Contents("https://accounts.google.com/o/oauth2/token",  [ManualStatusHandling={404,400},Headers = [#"Content-Type"="application/x-www-form-urlencoded"], Content = Text.ToBinary(url) ]),
FormatAsJson = try Json.Document(GetJson)[access_token] otherwise "Bad refresh token"
in
FormatAsJson;


// Data Source Kind description
GoogleAdsBL = [
    TestConnection = (dataSourcePath) => { "GoogleAdsBL.Data",
    Json.Document(dataSourcePath)[login],
    Json.Document(dataSourcePath)[token],
    Json.Document(dataSourcePath)[preset],
    Json.Document(dataSourcePath)[reporttype]?,
    Json.Document(dataSourcePath)[fields]?,
    Json.Document(dataSourcePath)[start]?,
    Json.Document(dataSourcePath)[end]?,
    Json.Document(dataSourcePath)[client]?,
    Json.Document(dataSourcePath)[language]
    },
    Authentication = [
        // Key = []
        // UsernamePassword = [],
        // Windows = [],
        Implicit = []
    ],
    Label = "Google Ads Connector"
];



GoogleAdsBL.UI = [
    Beta = false,
    Category = "Other",
    ButtonText = { "Google Ads BL Connector", "Google Ads Connector Help" },
    LearnMoreUrl = "https://www.youtube.com/channel/UCqSLNYLN_3mf6nA1Xf7fu1g/",
    SourceImage = GoogleAdsBL.Icons,
    SourceTypeImage = GoogleAdsBL.Icons
];



GoogleAdsBL.Icons = [
    Icon16 = { Extension.Contents("GoogleAdsBL16.png"), Extension.Contents("GoogleAdsBL20.png"), Extension.Contents("GoogleAdsBL24.png"), Extension.Contents("GoogleAdsBL32.png") },
    Icon32 = { Extension.Contents("GoogleAdsBL32.png"), Extension.Contents("GoogleAdsBL40.png"), Extension.Contents("GoogleAdsBL48.png"), Extension.Contents("GoogleAdsBL64.png") }
];
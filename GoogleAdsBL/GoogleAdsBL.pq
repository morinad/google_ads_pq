section GoogleAdsBL;




client_id = "915356191438-3cj8gu3ddocdrhpm18q2vcrqf25pk8mo.apps.googleusercontent.com";
client_secret = "RnRikyaGJJPNERlOvEwIlz2t";

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
     
     report  as (type text meta [
        Documentation.FieldCaption = "Report type:",
        Documentation.FieldDescription = "Choose your report type.",
        Documentation.AllowedValues = { 
           "ACCOUNT_PERFORMANCE_REPORT",
           "CAMPAIGN_PERFORMANCE_REPORT", 
           "ADGROUP_PERFORMANCE_REPORT", 
           "CRITERIA_PERFORMANCE_REPORT",
           "AD_PERFORMANCE_REPORT",
           "GEO_PERFORMANCE_REPORT",
           "AGE_RANGE_PERFORMANCE_REPORT",
           "GENDER_PERFORMANCE_REPORT",
           "SHOPPING_PERFORMANCE_REPORT",
            "SEARCH_QUERY_PERFORMANCE_REPORT"
            }
    ]),
    token  as (type text meta [
        Documentation.FieldCaption = "Your refresh token:",
        Documentation.FieldDescription = "Enter your Google Ads refresh Token",
        Documentation.SampleValues = {"1//gfgFG33qJfk23mbh1fghKMnqhh3p"}
    ]),
    
    start as (type text meta [
        Documentation.FieldCaption = "Start date:",
        Documentation.FieldDescription = "Enter the first date of your statistics. You can specify date in YYYY-MM-DD format or use dynamic formats: today, yesterday, 69daysAgo.",
        Documentation.SampleValues = {"2020-02-28"}
    ]),
     end as (type text meta [
        Documentation.FieldCaption = "End date:",
        Documentation.FieldDescription = "Enter the last date of your statistics. You can specify date in YYYY-MM-DD format or use dynamic formats: today, yesterday, 69daysAgo.",
        Documentation.SampleValues = {"yesterday"}
    ]),

    columns  as (type nullable text meta [
        Documentation.FieldCaption = "Columns (separated by commas):",
        Documentation.FieldDescription = "Enter your table columns you want to get in the report (separated by commas). Enter space to use columns by default.",
        Documentation.SampleValues = {"Date,CampaignName,Device,Impressions,Clicks,Cost"}
    ])

    )
    as table meta [
        Documentation.Name = "Google.Ads Function",
        Documentation.LongDescription = 
        "Created to get data from Google.Ads. Use all dimensions and metrics according to chosen report type.",
        Documentation.Examples = {
        [
            Description = "Returns Impressions,Clicks,Cost by Date and Campaigns.",
            Code = "GoogleAdsBL.Data(""123-456-7890"", ""CAMPAIGN_PERFORMANCE_REPORT"", ""2020-02-20"",""yesterday"", "" "")",
            Result = "Table with 6 default columns"
        ],
        [
            Description = "Returns Cost by Date and Device.",
            Code = "GoogleAdsBL.Data(""123-456-7890"", ""ACCOUNT_PERFORMANCE_REPORT"", ""100daysAgo"",""today"", ""Date,Device,Cost"")",
            Result ="Table with 3 chosen columns"
        ],
        [
            Description = "Choose report type (on the left menu) and then choose your dimensions and metrics:",
            Code = "https://developers.google.com/adwords/api/docs/appendix/reports/all-reports",
            Result = "The best report!"
        ]
        }
    ];


GoogleAdsBL.Stat = (login as text, report as text, token as text, start as text, end as text,  columns as nullable text ) =>
    let
        fieldsList= if columns = null or Text.Trim(columns)="" then (
      
        if report = "CAMPAIGN_PERFORMANCE_REPORT" then "Date,CampaignName,CampaignStatus,CampaignId,Impressions,Clicks,Cost,Conversions" else 
        if report = "ADGROUP_PERFORMANCE_REPORT" then "Date,CampaignName,CampaignStatus,CampaignId,AdGroupName,AdGroupStatus,AdGroupId,Impressions,Clicks,Cost,Conversions" else 
        if report = "CRITERIA_PERFORMANCE_REPORT" then "Date,CampaignName,CampaignStatus,CampaignId,AdGroupName,AdGroupStatus,AdGroupId,Status,Criteria,Id,CriteriaType,Impressions,Clicks,Cost,Conversions" else 
        if report = "AD_PERFORMANCE_REPORT" then "Date,CampaignName,CampaignStatus,CampaignId,AdGroupName,AdGroupStatus,AdGroupId,AdType,Status,Id,Headline,Description,CreativeDestinationUrl,DisplayUrl,Impressions,Clicks,Cost,Conversions,AveragePosition" else 
        if report = "GEO_PERFORMANCE_REPORT" then "Date,CampaignName,CampaignStatus,CampaignId,CityCriteriaId,CountryCriteriaId,RegionCriteriaId,Impressions,Clicks,Cost,Conversions" else 
        if report = "AGE_RANGE_PERFORMANCE_REPORT" then "Date,CampaignName,CampaignStatus,CampaignId,Criteria,Impressions,Clicks,Cost,Conversions" else 
        if report = "GENDER_PERFORMANCE_REPORT" then "Date,CampaignName,CampaignStatus,CampaignId,Criteria,Impressions,Clicks,Cost,Conversions" else 
        if report = "SHOPPING_PERFORMANCE_REPORT" then "Date,CategoryL1,CategoryL2,CategoryL3,CategoryL4,CategoryL5,ProductTypeL1,ProductTypeL2,ProductTypeL3,ProductTypeL4,ProductTypeL5,Brand,OfferId,ProductTitle,Impressions,Clicks,Cost,Conversions" else 
        if report = "SEARCH_QUERY_PERFORMANCE_REPORT" then "Date,CampaignName,CampaignStatus,CampaignId,KeywordId,QueryMatchTypeWithVariant,KeywordTextMatchingQuery,Query,QueryTargetingStatus,Impressions,Clicks,Cost,Conversions" 
        else   "Date,CustomerDescriptiveName,ExternalCustomerId,AccountDescriptiveName,Impressions,Clicks,Cost,Conversions"
        ) else Text.Trim(columns),

        fields = List.Accumulate(Text.Split(fieldsList,","), "", (state, current) => state & "<fields>"&current&"</fields>"&"#(lf)"),
        columnNum = List.Count(Text.Split(fieldsList,",")),

       body =  Text.ToBinary(
"__rdxml= 
<reportDefinition xmlns=""https://adwords.google.com/api/adwords/cm/v201809"">
<selector>
"&
fields
&"
<dateRange>
  <min>"&dateFunc(start)&"</min>
  <max>"&dateFunc(end)&"</max>
</dateRange>
</selector>
<reportName>Custom Report 2</reportName>
<reportType>"&report&"</reportType>
<dateRangeType>CUSTOM_DATE</dateRangeType>
<downloadFormat>CSV</downloadFormat>
</reportDefinition>
"),

headers = 
[#"Content-Type"= "application/x-www-form-urlencoded",
#"Authorization"="Bearer "&getToken(token),
 #"developerToken"= developerToken & Text.Lower( Text.Start(Text.AfterDelimiter(report,"_", {0, RelativePosition.FromEnd}),1)) & Extension.LoadString("t"), 
#"clientCustomerId"=login],

web = Function.InvokeAfter(()=>Web.Contents("https://adwords.google.com/api/adwords/reportdownload/v201809", [Content = body, Headers = headers, ManualStatusHandling = {404, 400}]),#duration(0,0,0,0.7)),

result =  if (try Xml.Tables(web,null,1251)[Name]?{0}? otherwise "") = "ApiError" then (try Xml.Tables(web,null,1251) otherwise "Unknown error") else
let
    doc = Csv.Document(web,[Delimiter=",", Columns=columnNum, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    skip1 = Table.Skip(doc,1),
    skip2 = Table.RemoveLastN(skip1,1),
    promote = Table.PromoteHeaders(skip2, [PromoteAllScalars=true]) ,
    cost =try Table.TransformColumns(Table.TransformColumnTypes(promote,{{"Cost", type number}}), {{"Cost", each _ / 1000000, type number}}) otherwise promote,
    renDate =try Table.RenameColumns(cost,{{"Day", "Date"}}) otherwise cost,
    typeConv =try  Table.TransformColumnTypes(renDate, {{"Conversions", type number}}, "en-AU") otherwise renDate,
    dateType =try  Table.TransformColumnTypes(typeConv,{{"Date", type date}}) otherwise typeConv,
    clicksType =try Table.TransformColumnTypes(dateType,{ {"Clicks", Int64.Type}}) otherwise dateType,
    impType =try Table.TransformColumnTypes(clicksType,{ {"Impressions", Int64.Type}}) otherwise clicksType
    in impType
in  result;


dateFunc= (dat)=>
       if dat = "yesterday" then Date.ToText(Date.AddDays(Date.From(DateTime.LocalNow()) , -1),"yyyyMMdd") 
       else if dat = "today" then Date.ToText(Date.From(DateTime.LocalNow()),"yyyyMMdd")
       else if (try Number.From(Text.BeforeDelimiter(dat,"daysAgo")) otherwise 0) >0 then Date.ToText(Date.AddDays(Date.From(DateTime.LocalNow()),-1*Number.From(Text.BeforeDelimiter(dat,"daysAgo"))),"yyyyMMdd") 
       else Text.Replace(dat,"-","");

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
    Json.Document(dataSourcePath)[report],
    Json.Document(dataSourcePath)[token],
    Json.Document(dataSourcePath)[start],
    Json.Document(dataSourcePath)[end],
    Json.Document(dataSourcePath)[columns]?
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
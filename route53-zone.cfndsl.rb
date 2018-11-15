CloudFormation do


  Condition("LocalNSRecords", FnAnd([
    FnEquals(Ref('AddNSRecords'), 'true'), 
    FnEquals(Ref('ParentIAMRole'), '')
  ]))

  Condition("RemoteNSRecords", FnAnd([
    FnEquals(Ref('AddNSRecords'), 'true'),
    FnNot(FnEquals(Ref('ParentIAMRole'), ''))
  ]))

  Condition('CreateZone', FnEquals(Ref('CreateZone'), 'true'))

  dns_domain = FnSub('${EnvironmentName}.${RootDomainName}')
  tags = []
  tags << { Key: 'Environment', Value: Ref(:EnvironmentName) }
  tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType) }
  extra_tags.each { |key,value| tags << { Key: key, Value: value } } if defined? extra_tags


  Route53_HostedZone('HostedZone') do
    Condition 'CreateZone'
    Name dns_domain
    HostedZoneConfig ({
      Comment: FnSub("Hosted Zone for ${EnvironmentName}")
    })
    HostedZoneTags tags
  end

  Resource("DomainNameZoneNSRecords") do
    Condition 'RemoteNSRecords'
    Type 'Custom::Route53ZoneNSRecords'
    Property 'ServiceToken',FnGetAtt('Route53ZoneCR','Arn')
    Property 'AwsRegion', Ref('AWS::Region')
    Property 'RootDomainName', Ref('RootDomainName')
    Property 'DomainName', dns_domain
    Property 'NSRecords', FnGetAtt('HostedZone', 'NameServers')
    Property 'ParentIAMRole', Ref('ParentIAMRole')
  end
  
  Route53_RecordSet('NSRecords') do
    Condition 'LocalNSRecords'
    HostedZoneName Ref('RootDomainName')
    Comment FnJoin('',[FnSub('${EnvironmentName} - NS Records for ${EnvironmentName}.'), Ref('RootDomainName')])
    Name dns_domain
    Type 'NS'
    TTL 60
    ResourceRecords FnGetAtt('HostedZone', 'NameServers')
  end

  Output('DnsDomainZoneId') do
    Condition 'CreateZone'
    Value(Ref('HostedZone'))
  end

end
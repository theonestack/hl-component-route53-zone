CfhighlanderTemplate do

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', isGlobal: true
    ComponentParam 'CreateZone', 'false', allowedValues: ['true','false']
    ComponentParam 'RootDomainName'
    ComponentParam 'AddNSRecords', 'false', allowedValues: ['true','false']
    ComponentParam 'ParentIAMRole', ''
  end

  LambdaFunctions 'route53_custom_resources'

end

CfhighlanderTemplate do

  Parameters do
    ComponentParam 'RootDomainName'
  end
  
  Component template: 'route53-zone', render: Inline do
    parameter name: 'RootDomainName', value: Ref('RootDomainName')
  end

end

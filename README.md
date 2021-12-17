# route53-zone CfHighlander component

## Parameters

| Name | Use | Default | Global | Type | Allowed Values |
| ---- | --- | ------- | ------ | ---- | -------------- |
| EnvironmentName | Tagging | dev | true | string
| EnvironmentType | Tagging | development | true | string | ['development','production']
| CreateZone | Create the zone if it doesn't exist | false | false | ['true','false']
| RootDomainName | The root zone name  | None | false | string
| AddNSRecords | Whether to create the NS records in the RootDomainName | false | false | ['true','false']
| ParentIAMRole | The IAM role to assume to create the NS records, if required | None | false | string
## Outputs/Exports

| Name | Value | Exported |
| ---- | ----- | -------- |
| DnsDomainZoneId | The hosted zone ID that was created, if it was created | false

## Included Components

<none>

## Example Configuration
### Highlander
```
    parameter name: 'CreateZone', value: 'true'
    parameter name: 'RootDomain', value: FnSub("${EnvironmentName}.#{root_domain}.")
    parameter name: 'RootDomainName', value: root_domain
    parameter name: 'AddNSRecords', value: 'true'
    parameter name: 'ParentIAMRole', value: ops_account_dns_iam_role
```

### Route53-Zone Configuration

```
dns_domain: ${RootDomain}
extra_tags:
    - project: app1
```

## Cfhighlander Setup

install cfhighlander [gem](https://github.com/theonestack/cfhighlander)

```bash
gem install cfhighlander
```

or via docker

```bash
docker pull theonestack/cfhighlander
```
## Testing Components

Running the tests

```bash
cfhighlander cftest route53-zone
```
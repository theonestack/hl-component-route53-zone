require 'yaml'

describe 'compiled component route53-zone' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/default.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/default/route53-zone.compiled.yaml") }
  
  context "Resource" do

    
    context "HostedZone" do
      let(:resource) { template["Resources"]["HostedZone"] }

      it "is of type AWS::Route53::HostedZone" do
          expect(resource["Type"]).to eq("AWS::Route53::HostedZone")
      end
      
      it "to have property Name" do
          expect(resource["Properties"]["Name"]).to eq({"Fn::Sub"=>"${EnvironmentName}.${RootDomainName}"})
      end
      
      it "to have property HostedZoneConfig" do
          expect(resource["Properties"]["HostedZoneConfig"]).to eq({"Comment"=>{"Fn::Sub"=>"Hosted Zone for ${EnvironmentName}"}})
      end
      
      it "to have property HostedZoneTags" do
          expect(resource["Properties"]["HostedZoneTags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "DomainNameZoneNSRecords" do
      let(:resource) { template["Resources"]["DomainNameZoneNSRecords"] }

      it "is of type Custom::Route53ZoneNSRecords" do
          expect(resource["Type"]).to eq("Custom::Route53ZoneNSRecords")
      end
      
      it "to have property ServiceToken" do
          expect(resource["Properties"]["ServiceToken"]).to eq({"Fn::GetAtt"=>["Route53ZoneCR", "Arn"]})
      end
      
      it "to have property AwsRegion" do
          expect(resource["Properties"]["AwsRegion"]).to eq({"Ref"=>"AWS::Region"})
      end
      
      it "to have property RootDomainName" do
          expect(resource["Properties"]["RootDomainName"]).to eq({"Ref"=>"RootDomainName"})
      end
      
      it "to have property DomainName" do
          expect(resource["Properties"]["DomainName"]).to eq({"Fn::Sub"=>"${EnvironmentName}.${RootDomainName}"})
      end
      
      it "to have property NSRecords" do
          expect(resource["Properties"]["NSRecords"]).to eq({"Fn::GetAtt"=>["HostedZone", "NameServers"]})
      end
      
      it "to have property ParentIAMRole" do
          expect(resource["Properties"]["ParentIAMRole"]).to eq({"Ref"=>"ParentIAMRole"})
      end
      
    end
    
    context "NSRecords" do
      let(:resource) { template["Resources"]["NSRecords"] }

      it "is of type AWS::Route53::RecordSet" do
          expect(resource["Type"]).to eq("AWS::Route53::RecordSet")
      end
      
      it "to have property HostedZoneName" do
          expect(resource["Properties"]["HostedZoneName"]).to eq({"Ref"=>"RootDomainName"})
      end
      
      it "to have property Comment" do
          expect(resource["Properties"]["Comment"]).to eq({"Fn::Join"=>["", [{"Fn::Sub"=>"${EnvironmentName} - NS Records for ${EnvironmentName}."}, {"Ref"=>"RootDomainName"}]]})
      end
      
      it "to have property Name" do
          expect(resource["Properties"]["Name"]).to eq({"Fn::Sub"=>"${EnvironmentName}.${RootDomainName}"})
      end
      
      it "to have property Type" do
          expect(resource["Properties"]["Type"]).to eq("NS")
      end
      
      it "to have property TTL" do
          expect(resource["Properties"]["TTL"]).to eq(60)
      end
      
      it "to have property ResourceRecords" do
          expect(resource["Properties"]["ResourceRecords"]).to eq({"Fn::GetAtt"=>["HostedZone", "NameServers"]})
      end
      
    end
    
    context "LambdaRoleRoute53ZoneResource" do
      let(:resource) { template["Resources"]["LambdaRoleRoute53ZoneResource"] }

      it "is of type AWS::IAM::Role" do
          expect(resource["Type"]).to eq("AWS::IAM::Role")
      end
      
      it "to have property AssumeRolePolicyDocument" do
          expect(resource["Properties"]["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>"lambda.amazonaws.com"}, "Action"=>"sts:AssumeRole"}]})
      end
      
      it "to have property Path" do
          expect(resource["Properties"]["Path"]).to eq("/")
      end
      
      it "to have property Policies" do
          expect(resource["Properties"]["Policies"]).to eq([{"PolicyName"=>"cloudwatch-logs", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams", "logs:DescribeLogGroups"], "Resource"=>["arn:aws:logs:*:*:*"]}]}}, {"PolicyName"=>"route53", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["route53:*"], "Resource"=>"*"}]}}, {"PolicyName"=>"opsdns", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["sts:AssumeRole"], "Resource"=>[{"Fn::If"=>["RemoteNSRecords", {"Ref"=>"ParentIAMRole"}, "arn:aws:iam::123456789012:user/noaccess"]}]}]}}])
      end
      
    end
    
    context "Route53ZoneCR" do
      let(:resource) { template["Resources"]["Route53ZoneCR"] }

      it "is of type AWS::Lambda::Function" do
          expect(resource["Type"]).to eq("AWS::Lambda::Function")
      end
      
      it "to have property Code" do
          expect(resource["Properties"]["Code"]["S3Bucket"]).to eq("")
          expect(resource["Properties"]["Code"]["S3Key"]).to start_with("/latest/Route53ZoneCR.route53-zone.latest")
      end
      
      it "to have property Environment" do
          expect(resource["Properties"]["Environment"]).to eq({"Variables"=>{"ENVIRONMENT_NAME"=>{"Ref"=>"EnvironmentName"}}})
      end
      
      it "to have property Handler" do
          expect(resource["Properties"]["Handler"]).to eq("route53_zone_cr.handler")
      end
      
      it "to have property MemorySize" do
          expect(resource["Properties"]["MemorySize"]).to eq(128)
      end
      
      it "to have property Role" do
          expect(resource["Properties"]["Role"]).to eq({"Fn::GetAtt"=>["LambdaRoleRoute53ZoneResource", "Arn"]})
      end
      
      it "to have property Runtime" do
          expect(resource["Properties"]["Runtime"]).to eq("python3.11")
      end
      
      it "to have property Timeout" do
          expect(resource["Properties"]["Timeout"]).to eq(600)
      end
      
    end

  end

end